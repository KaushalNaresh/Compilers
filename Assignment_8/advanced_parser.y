%{
#include "advanced_parser.tab.h"
#include<stdio.h>
#include<string.h>
#define MAX 1000
int  yylex(void);
int  yyerror(char* s);

void write_init_lines();
void write_closing_lines();
void write_to_file();
void addToSymTab(char *cur_type, char *s);
int  symTabLookUp(char* s);
int  addConditionalExp(int expVal1, char *expType1, int irName1, int expVal2, char *expType2, int irName2, char op);
void backpatch(int list[], int count, int label);
char* getType(char* id);
void addIrForId(char* name);
int getIrep(char* name);
void allocaInst(char* dtype);
void loadInst(char* dtype, char* irname);
void storeInst(char* dtype, char* src, char* dest, int isConst);
void multInst(char* dtype, char* term1, char* term2, int is1const, int is2const);
void addInst(char* dtype, char* term1, char* term2, int is1const, int is2const);
char* calExpDtype(char* dtype1, char* dtype2);
void mergelist(int* c, int* a, int* b, int count1, int count2);
int idxWhereToInsertLabel(char* a);

char* file_buffer[MAX]; 
int lineNumb = 0, nextLabel;
int success = 1, symbTabEntryCount;
int count = 0, count1 = 0;
static int noIrCode = 0;
char* curType;
static int regNumb = 1;

FILE* fp;

struct map
{
    char lexeme[50];
    char type[50];
};
struct map symb_tab[MAX];

struct lexIr
{
    char lexeme[50];
    int irName;
}ir[MAX];

extern char *yytext;
#define YYDEBUG_LEXER_TEXT yytext
%}

%union{
    int    ival;
    float  fval;
    char*  sval;
    
    struct expStruct
    {
        int expVal;
        char*  expType;
        int    irName; 
        struct bList
        {
            int ele[10];
            int count;
        } trueList, falseList;
    }eval;
    
    struct statementStruct
    {
        struct slist
        {
            int ele[10];
            int count;
        } nextList;

    }stmtVal;
};

%token COMMA SEMICOLON RELOP LOGOP OR AND NOT IF WHILE EQ 
%token <sval> ID INT FLOAT
%type  <eval> EXP TERM FACTOR relExp logExp
%type  <stmtVal> stmt assignStmt ifStmt stmtList 
%type  <ival> M
%token <ival> INT_CONST 
%token <fval> FLOAT_CONST
%start prog
%%

prog : { 
            
            symbTabEntryCount = 0; 
            write_init_lines(); 
       } 
       funcDef 
       { 
            if(noIrCode == 0){
                write_closing_lines(); 
            }
            write_to_file();
       };

funcDef :   TYPE_CONST ID{
                printf("%s : Function_id\n", $2); 
                addToSymTab(curType, $2);
                curType = "";
            } '(' argList ')' '{' declList stmtList '}'

argList : arg COMMA argList | arg | ; 

arg	: TYPE_CONST ID {
                        printf("%s : Argument_id\n", $2); 
                        addToSymTab($2, curType);

                        addIrForId($2);
                        allocaInst(curType);
                        curType = "";
                    } 

declList :  decl declList | decl;

decl : TYPE_CONST varList {curType = "";} SEMICOLON

TYPE_CONST : INT 
	        {
                curType = "int"; 
                printf("int : data_type \n");
            };
	        | FLOAT 
            { 
               curType = "float"; 
               printf("float : data_type \n");
            }

varList : ID 
	    { 
            addToSymTab(curType, $1);
            addIrForId($1); 
            allocaInst(curType); 
            printf("%s : Varlist_id \n", $1);   
        }
        COMMA varList
	    |   ID 
        { 
            addToSymTab(curType, $1); 
            addIrForId($1); 
            allocaInst(curType);
            printf("%s : Varlist_id \n", $1);
        }

stmtList :  stmtList M stmt
            {
                    backpatch($1.nextList.ele, $1.nextList.count, $2);
                    /* Save the ele and count fields of $3 to $1 */
                    $$.nextList = $3.nextList;
            }|stmt

stmt :   assignStmt {}
        | ifStmt M { 
            $$ = $1;
            file_buffer[lineNumb] = (char*)malloc(MAX);
            sprintf(file_buffer[lineNumb], "\t%d:\n", regNumb);
            backpatch($1.nextList.ele, $1.nextList.count, $2);

            regNumb += 1;
            lineNumb += 1;
        };

assignStmt : ID '=' EXP SEMICOLON 
	        {    
                char subbuff1[5], subbuff2[5];
                memcpy(subbuff1, getType($1), 3);
                memcpy(subbuff2, $3.expType, 3);
                subbuff1[3] = '\0';
                subbuff2[3] = '\0';

                if(symTabLookUp($1) == 0){ 
                    printf("Error: %s not declared\n", $1);
                    noIrCode = 1;
                } 
                else if(strcmp($3.expType, "invalid") != 0 && noIrCode == 0){

                    char* temp = getType($1);
                    int expIr, isConst, idIr;

                    if(strcmp(subbuff1, subbuff2) != 0){
                        printf("Warning : %s is assigned to %s\n", $3.expType, getType($1));
                    }

                    if((strcmp($3.expType, "int_const") != 0) && (strcmp($3.expType, "float_const") != 0)){
                        
                        expIr = $3.irName;
                        isConst = 0;
                    }
                    else{
                        expIr = $3.expVal;
                        isConst = 1;
                    }

                    char strIr[50];
                    sprintf(strIr, "%d", expIr);

                    idIr = getIrep($1);
                    char strIdIr[50];
                    sprintf(strIdIr, "%d", idIr);

                    storeInst(temp, strIr, strIdIr, isConst);
                      
                }
            }

EXP : TERM '+' EXP 
    { 

        char subbuff1[5], subbuff2[5];
        memcpy(subbuff1, $1.expType, 3);
        memcpy(subbuff2, $3.expType, 3);
        subbuff1[3] = '\0';
        subbuff2[3] = '\0';

        /* Determine the type */
        char* temp = calExpDtype($1.expType, $3.expType);
        $$.expType = temp;

        /* If the type determined is is invalid then set noIrCode flag to 1 */
        if(strcmp(temp, "invalid") == 0){
            noIrCode = 1;
        }

        $$.irName = regNumb;
            
        /* Write the mul instruction */
        if(noIrCode == 0){
            int term1, term2, is1Const, is2Const;

            if(strcmp(subbuff1, subbuff2) != 0){
                printf("Warning : %s and %s are added\n", $1.expType, $3.expType);
            }

            // Checking if TERM or Factor is constant or Identifier
            term1 = (strcmp($1.expType, "int_const") != 0 && strcmp($1.expType, "float_const") != 0)? $1.irName : $1.expVal;
            term2 = (strcmp($3.expType, "int_const") != 0 && strcmp($3.expType, "float_const") != 0)? $3.irName : $3.expVal;

            is1Const = (strcmp($1.expType, "int_const") == 0 || strcmp($1.expType, "float_const") == 0)? 1 : 0;
            is2Const = (strcmp($3.expType, "int_const") == 0 || strcmp($3.expType, "float_const") == 0)? 1 : 0; 

            char sirname1[50], sirname3[50];
            sprintf(sirname1, "%d", term1);
            sprintf(sirname3, "%d", term2);

            addInst(temp, sirname1, sirname3, is1Const, is2Const);
        }
    }
    | TERM 
    { 
        $$.expType = $1.expType; 
        $$.expVal = $1.expVal;
        $$.irName = $1.irName;
    }

TERM : FACTOR '*' TERM 
    { 

        char subbuff1[5], subbuff2[5];
        memcpy(subbuff1, $1.expType, 3);
        memcpy(subbuff2, $3.expType, 3);
        subbuff1[3] = '\0';
        subbuff2[3] = '\0';


        /* Determine the type */
        char* temp = calExpDtype($1.expType, $3.expType);
        $$.expType = temp;

        /* If the type determined is invalid then set noIrCode flag to 1 */
        if(strcmp(temp, "invalid") == 0){
            noIrCode = 1;
        }

        $$.irName = regNumb;

        if(noIrCode == 0){

            int term1, term2, is1Const, is2Const;

            if(strcmp(subbuff1, subbuff2) != 0){
                printf("Warning : %s and %s are multiplied\n", $1.expType, $3.expType);
            }

            // Checking if TERM or Factor is constant or Identifier
            term1 = (strcmp($1.expType, "int_const") != 0 && strcmp($1.expType, "float_const") != 0)? $1.irName : $1.expVal;
            term2 = (strcmp($3.expType, "int_const") != 0 && strcmp($3.expType, "float_const") != 0)? $3.irName : $3.expVal;

            is1Const = (strcmp($1.expType, "int_const") == 0 || strcmp($1.expType, "float_const") == 0)? 1 : 0;
            is2Const = (strcmp($3.expType, "int_const") == 0 || strcmp($3.expType, "float_const") == 0)? 1 : 0; 

            char sirname1[50], sirname3[50];
            sprintf(sirname1, "%d", term1);
            sprintf(sirname3, "%d", term2);

            /* Write the mul instruction */
            multInst(temp, sirname1, sirname3, is1Const, is2Const);
        }
    }
    | FACTOR 
    { 
        $$.expType = $1.expType;
        $$.expVal = $1.expVal;
        $$.irName = $1.irName;
    }

FACTOR : ID 
        { 
            if(symTabLookUp($1) == 1){
                $$.expType = getType($1); 

                int temp = getIrep($1);
                $$.irName = regNumb;

                if(noIrCode == 0) {
                    char sirname1[50];
                    sprintf(sirname1, "%d", temp);
                    loadInst($$.expType, sirname1);
                }
            }
            else{
                printf("Error: %s not declared\n", $1);
                $$.expType = "invalid";
                noIrCode = 1;
            }
           
        } 
        |    INT_CONST 
        {
            $$.expType = "int_const"; 
            $$.expVal = $1; 
        }
        | FLOAT_CONST 
        { 
            $$.expType = "float_const"; 
            $$.expVal = $1; 
        }

ifStmt :    IF'('logExp')' M {

                file_buffer[lineNumb] = (char*)malloc(MAX);
                sprintf(file_buffer[lineNumb], "\t%d:\n", regNumb);
                regNumb += 1;
                lineNumb += 1;

            } '{'stmtList {
                
                        file_buffer[lineNumb] = (char*)malloc(MAX);
                        sprintf(file_buffer[lineNumb], "\tbr label %%%d\n\n", regNumb);
                        lineNumb += 1;

            } '}' 
            {
                backpatch($3.trueList.ele, $3.trueList.count, $5);
                // $$.nextList.count = $3.falseList.count + $7.nextList.count;
                // /* Save logExp.falseList and $7.nextList to $$.nextList*/
                mergelist($$.nextList.ele, $3.falseList.ele, $8.nextList.ele, $3.falseList.count, $8.nextList.count);
                $$.nextList.count = $3.falseList.count + $8.nextList.count;

            }

logExp :    relExp { 
                       $$.expType = $1.expType;
                       $$.trueList = $1.trueList;
                       $$.falseList = $1.falseList;
                    };

relExp :    EXP '>' EXP 
            {
                
                int lNumb = addConditionalExp($1.expVal, $1.expType, $1.irName, 
                                              $3.expVal, $3.expType, $3.irName, '>');
                
                $$.trueList.ele[$$.trueList.count] = lNumb;
                $$.falseList.ele[$$.falseList.count] = lNumb;

                $$.trueList.count += 1;
                $$.falseList.count += 1;

                $$.expType = "bool"; 
                
            }; 

M : { $$ = regNumb; };
%%

void write_init_lines()
{

    file_buffer[lineNumb] = (char*)malloc(MAX);
    sprintf(file_buffer[lineNumb], "; ModuleID = 'prog.c'\n source_filename = \"prog.c\"\n target datalayout = \"e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128\"\n target triple = \"x86_64-pc-linux-gnu\"\n\n; Function Attrs: noinline nounwind optnone uwtable\n define dso_local i32 @main() #0 {\n");

    lineNumb += 1;
}

void write_closing_lines()
{
    /* Write the closing lines in the file_buffer */ 
    /* Write the file_buffer to the file */ 

    file_buffer[lineNumb] = (char*)malloc(MAX);
    sprintf(file_buffer[lineNumb], "\tret i32 0\n}\n\n attributes #0 = { noinline nounwind optnone uwtable \"correctly-rounded-divide-sqrt-fp-math\"=\"false\" \"disable-tail-calls\"=\"false\" \"frame-pointer\"=\"all\" \"less-precise-fpmad\"=\"false\" \"min-legal-vector-width\"=\"0\" \"no-infs-fp-math\"=\"false\" \"no-jump-tables\"=\"false\" \"no-nans-fp-math\"=\"false\" \"no-signed-zeros-fp-math\"=\"false\" \"no-trapping-math\"=\"false\" \"stack-protector-buffer-size\"=\"8\" \"target-cpu\"=\"x86-64\" \"target-features\"=\"+cx8,+fxsr,+mmx,+sse,+sse2,+x87\" \"unsafe-fp-math\"=\"false\" \"use-soft-float\"=\"false\" }\n\n !llvm.module.flags = !{!0}\n !llvm.ident = !{!1}\n\n !0 = !{i32 1, !\"wchar_size\", i32 4}\n !1 = !{!\"clang version 10.0.0-4ubuntu1 \"}\n");

    lineNumb += 1;

}

void write_to_file(){

    fp = fopen("prog.ll", "w");
    for(int i = 0; i < lineNumb; i++){
        fputs(file_buffer[i], fp);
    }
    fclose(fp);
    
}

void addToSymTab(char *cur_type, char *s)
{
    for(int i = 0; i < count; i++){
        if(strcmp(symb_tab[i].lexeme, s) == 0){
            return;
        }
    }

    strcpy(symb_tab[count].lexeme, s);
    strcpy(symb_tab[count].type, cur_type);
    count += 1;
}

int symTabLookUp(char *s)
{
    for(int i = 0; i < count; i++){
        if(strcmp(symb_tab[i].lexeme, s) == 0){
            return 1;
        }
    }

    return 0;
}

char* getType(char* id){

    for(int i = 0; i < count; i++){
        if(strcmp(symb_tab[i].lexeme, id) == 0){
            return symb_tab[i].type;
        }
    }
}

char* calExpDtype(char* dtype1, char* dtype2){

    if(strcmp(dtype2, "invalid") == 0 || strcmp(dtype1, "invalid") == 0){
        return "invalid";
    }
    else if((strcmp(dtype1, "int") == 0 || strcmp(dtype1, "int_const") == 0) && 
            (strcmp(dtype2, "int") == 0 || strcmp(dtype2, "int_const") == 0)){
        return "int";
    }
    else{
        return "float";
    }
}

void addIrForId(char* name){

    for(int i = 0; i < count1; i++){
        if(strcmp(ir[i].lexeme, name) == 0){
            return;
        }
    }

    strcpy(ir[count1].lexeme, name);
    ir[count1].irName = regNumb;
    count1 += 1;

}

int getIrep(char* name){

    for(int i = 0; i < count1; i++){
        if(strcmp(ir[i].lexeme, name) == 0){
            return ir[i].irName;
        }
    }

    return -1;
}

int addConditionalExp(int expVal1, char *expType1, int irName1, int expVal2, char *expType2, int irName2, char op)
{
    if(op == '>')
    {
        if((strcmp(expType1, "int") == 0) && (strcmp(expType2, "int") == 0))
        {
            /* Write icmp and br i1 statements to the file buffer */

            file_buffer[lineNumb] = (char*)malloc(MAX);
            sprintf(file_buffer[lineNumb], "\t%%%d = icmp sgt i32 %%%d, %%%d\n", regNumb, irName1, irName2);
            lineNumb += 1;
            file_buffer[lineNumb] = (char*)malloc(MAX);
            sprintf(file_buffer[lineNumb], "\tbr i1 %%%d, label %%%c, label %%%c\n\n",regNumb, '[', '[');
            lineNumb += 1;
        }
        else if((!strcmp(expType1, "float")) && (!strcmp(expType2, "float")))
        {
            /* Write fcmp and br i1 statements to the file buffer */

            file_buffer[lineNumb] = (char*)malloc(MAX);
            sprintf(file_buffer[lineNumb], "\t%%%d = fcmp ogt i32 %%%d, %%%d\n", regNumb, irName1, irName2);
            lineNumb += 1;
            file_buffer[lineNumb] = (char*)malloc(MAX);
            sprintf(file_buffer[lineNumb], "\tbr i1 %%%d, label %%%c, label %%%c\n\n",regNumb, '[', '[');
            lineNumb += 1;
        }
        else if(strcmp(expType1, "float_const") == 0 || strcmp(expType1, "int_const") == 0)
        {
            file_buffer[lineNumb] = (char*)malloc(MAX);
            sprintf(file_buffer[lineNumb], "\t%%%d = icmp ogt i32 %d, %%%d\n", regNumb, expVal1, irName2);
            lineNumb += 1;
            file_buffer[lineNumb] = (char*)malloc(MAX);
            sprintf(file_buffer[lineNumb], "\tbr i1 %%%d, label %%%c, label %%%c\n\n",regNumb, '[', '[');
            lineNumb += 1;
        }
        else if(strcmp(expType2, "float_const") == 0 || strcmp(expType2, "int_const") == 0)
        {
            file_buffer[lineNumb] = (char*)malloc(MAX);
            sprintf(file_buffer[lineNumb], "\t%%%d = icmp ogt i32 %%%d, %d\n", regNumb, irName1, expVal2);
            lineNumb += 1;
            file_buffer[lineNumb] = (char*)malloc(MAX);
            sprintf(file_buffer[lineNumb], "\tbr i1 %%%d, label %%%c, label %%%c\n\n",regNumb, '[', '[');
            lineNumb += 1;
        }   
    }
    else
    {
        /* ignore */
    }

    regNumb += 1;

    return lineNumb - 1;
}

void allocaInst(char* dtype){

    char* instType;

    if(strcmp(dtype, "int") == 0){
        instType = "i32";
    }
    else if(strcmp(dtype, "float") == 0){
        instType = "float";
    }

    char strNum[5];
    sprintf(strNum, "%d", regNumb);

    file_buffer[lineNumb] = (char*)malloc(MAX);
    sprintf(file_buffer[lineNumb], "\t%%%s = alloca %s, align 4\n", strNum, instType);
    lineNumb += 1;

    regNumb += 1;
}

void loadInst(char* dtype, char* irname){

    char* instType;

    if(strcmp(dtype, "int") == 0){
        instType = "i32";
    }
    else if(strcmp(dtype, "float") == 0){
        instType = "float";
    }

    char strNum[5];
    sprintf(strNum, "%d", regNumb);

    file_buffer[lineNumb] = (char*)malloc(MAX);
    sprintf(file_buffer[lineNumb], "\t%%%s = load %s, %s* %%%s, align 4\n", strNum, instType, instType, irname);
    lineNumb += 1;

    regNumb += 1;
}

void storeInst(char* dtype, char* src, char* dest, int isConst){

    char* instType;

    if(strcmp(dtype, "int") == 0){
        instType = "i32";
    }
    else if(strcmp(dtype, "float") == 0){
        instType = "float";
    }

    if(strcmp(dtype, "float") == 0 && isConst == 1){
        strcat(src, ".000000e+00");
    }

    char strNum[5];
    sprintf(strNum, "%d", regNumb);

    char* temp = isConst == 0? "%": "";


    file_buffer[lineNumb] = (char*)malloc(MAX);
    sprintf(file_buffer[lineNumb], "\tstore %s %s%s, %s* %%%s, align 4\n", instType, temp, src, instType, dest);
    lineNumb += 1;
}

void multInst(char* dtype, char* term1, char* term2, int is1const, int is2const){

    char* instType, *temp, *temp1, *temp2;

    if(strcmp(dtype, "int") == 0){
        instType = "i32";
        temp = "mul nsw";
        temp1 = is1const == 0? "%" : "";
        temp2 = is2const == 0? "%" : "";
    }
    else if(strcmp(dtype, "float") == 0){
        instType = "float";
        temp = "fmul";
        temp1 = is1const == 0? "%" : "";
        term1 = is1const == 1? strcat(term1, ".000000e+00") : term1;
        temp2 = is2const == 0? "%" : "";
        term2 = is2const == 1? strcat(term2, ".000000e+00") : term2;
    }

    char strNum[5];
    sprintf(strNum, "%d", regNumb);


    file_buffer[lineNumb] = (char*)malloc(MAX);
    sprintf(file_buffer[lineNumb], "\t%%%s = %s %s %s%s, %s%s \n", strNum, temp, instType, temp1, term1, temp2, term2);
    lineNumb += 1;

    regNumb += 1;
}

void addInst(char* dtype, char* term1, char* term2, int is1const, int is2const){

    char* instType, *temp, *temp1, *temp2;
    
    if(strcmp(dtype, "int") == 0){
        instType = "i32";
        temp = "add nsw";
        temp1 = is1const == 0? "%" : "";
        temp2 = is2const == 0? "%" : "";
    }
    else if(strcmp(dtype, "float") == 0){
        instType = "float";
        temp = "fadd";
        temp1 = is1const == 0? "%" : "";
        term1 = is1const == 1? strcat(term1, ".000000e+00") : term1;
        temp2 = is2const == 0? "%" : "";
        term2 = is2const == 1? strcat(term2, ".000000e+00") : term2;
    }

    char strNum[5];
    sprintf(strNum, "%d", regNumb);


    file_buffer[lineNumb] = (char*)malloc(MAX);
    sprintf(file_buffer[lineNumb], "\t%%%s = %s %s %s%s, %s%s\n", strNum, temp, instType, temp1, term1, temp2, term2);
    lineNumb += 1;

    regNumb += 1;
}

int idxWhereToInsertLabel(char* a){

    int length = strlen(a);

    for(int i = 0; i < length; i++){
        if(a[i] == '[')
            return i;
    }

    return -1;
}

void backpatch(int list[], int count, int label)
{

    for(int i = 0; i < count; i++){  // iterating over lines where label needs to be inserted

        int ptr = 0, s, o, t = 0;
        char x;
        char c[MAX];  // temporary string to store initial string
        char* a = file_buffer[list[i]];

        // printf("initial %s\n", a); 
        
        int r = strlen(a);  // length of initial string

        char b[50];
        sprintf(b, "%d", label);
        int n = strlen(b);  // length of the string to be added

        // Copying the initial string into another array
        while(ptr < r)
        {
            c[ptr]=a[ptr];
            ptr++;
        }	
        s = n+r; // new length of string

        int p = idxWhereToInsertLabel(a);
        if(p < 0)
            return;

        o = p+n; // idx at where string to be added ends

        // Adding the sub-string
        for(int j=p; j<r; j++)
        {
            x = c[j];
            if(t<n)
            {
                a[j] = b[t];
                t=t+1;
            }
            if(j!=p){
                a[o]=x;
                o=o+1;
            }
        }

        file_buffer[list[i]] = a;
        // printf("final %s\n", a); 
    }
    
}

void mergelist(int* c, int* a, int* b, int count1, int count2){

    for(int i = 0; i < count1; i++){
        c[i] = a[i];
    }
    for(int i = 0; i < count2; i++){
        c[i] = b[i];
    }
}


int main(int argc, char **argv)
{
    yydebug = 0;    // If set to 1 then extra output is not suppressed and you will see working of parser
    yyparse();
    if(success){
    	printf("Parsing Successful\n");
        printf("\nEntries in symbol table :\n");
        for(int i = 0; i < count; i++){
            printf("%s %s\n", symb_tab[i].lexeme, symb_tab[i].type);
        }
    }
    return 0;
}

int yyerror(char *s){
    fprintf(stderr, "%s\n", s);
    success = 0;
    return 0;
}
