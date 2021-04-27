%{
    #include<stdio.h>
    #include<string.h>
    #include "prog.tab.h"
    #define MAX 24
    int yylex(void);
    int yyerror(char*);
    int success = 1;
    int count_of_if = 0;
    int count = 0, count1 = 0;
    static int regNumb = 1;

    int lookup(char* id);
    void add_symb_tab(char name[], char type[]);
    char* getType(char* id);
    void updateTypeOfExp(char* type);
    int compareExp(char* leftExp, char* rightExp);
    void write_init_lines();
    void write_closing_lines();
    void allocaInst(char* dtype);
    void storeInst(char* dtype, char* src, char* dest, int isConst);
    void addInst(char* dtype, char* term1, char* term2, int is1const, int is2const);
    void multInst(char* dtype, char* term1, char* term2, int is1const, int is2const);
    void loadInst(char* dtype, char* irname);
    char* calExpDtype(char* dtype1, char* dtype2);
    void addIrForId(char* name);
    int getIrep(char* id);

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
    };
    struct lexIr ir[MAX];

    char* lhsOfExp = "";
    char* instType = "";
    char* dtype = "";

    FILE* fp;
%}


%union{
    char*  str;
    int    ival;
    double dval;

    struct expStruct
    {
        char*  expVal;
        char*  expType;
        int    irName; 
    }eval;

    struct constStruct{
        char* val;
        char* dtype;
    }constval;
};

%token SEMICOLON COMMA ASSIGN IF ELSE ELSE_IF AND OR NOT EQ GE LE LT GT NE WHILE RETURN ADD SUB MULTIPLY DIVIDE INCLUDE PRINT ID LIBRARY INT FLOAT STRING_CONST STRING CHAR DOUBLE CHAR_CONSTANT INTEGER_CONSTANT FLOAT_CONSTANT BEG END
%type <str> LIBRARY INT FLOAT STRING_CONST STRING CHAR DOUBLE CHAR_CONSTANT INTEGER_CONSTANT FLOAT_CONSTANT BEG END
%type <eval> EXP TERM FACTOR ID
%type <constval> const
%start prog

%%
prog : importLib    {
                        write_init_lines(); 
                    }   funcDef;

importLib : lib 
            |;

lib : '#' INCLUDE LT LIBRARY GT importLib   {
                                                printf("%s : library\n", $4);
                                            };

funcDef :   func funcDef 
            |   {
                    write_closing_lines();
                };

func    :   type ID  {
                        printf("%s : Function_id\n", $2.expVal); 
                        add_symb_tab($2.expVal, dtype); 
                        $2.expType = dtype;
                        dtype = "";
                    } '(' argList ')' funcBlock ;

funcBlock : BEG decList stmtList returnStmt END 
            | SEMICOLON;

returnStmt :    RETURN  {
                            printf("Return statement\n");
                        } EXP   {
                                    lhsOfExp = "";
                                    dtype = ""; 
                                } SEMICOLON 
                |; 

argList :   argList COMMA arg 
            | arg 
            |;

arg :   type ID         {
                            printf("%s : Argument_id\n", $2.expVal); 
                            add_symb_tab($2.expVal, dtype);
                            $2.expType = dtype; 

                            $2.irName = regNumb;
                            addIrForId($2.expVal);
                            allocaInst(dtype);

                            dtype = "";
                        }
        |   type ID     {
                            add_symb_tab($2.expVal, dtype); 
                            $2.expType = dtype; 

                            $2.irName = regNumb;
                            addIrForId($2.expVal);
                            allocaInst(dtype);
                        } ASSIGN const  {
                                            printf("%s : Argument_id\n", $2.expVal); 

                                            char strNum[5];
                                            sprintf(strNum, "%d", $2.irName);

                                            storeInst(dtype, $5.val, strNum, 1);
                                            dtype = "";
                                        };

decList :   decl decList 
            | decl 
            |;

decl : type varList SEMICOLON   { 
                                    dtype = "";
                                };

varList :   ID 
            {
                $1.irName = regNumb;
                addIrForId($1.expVal);
                allocaInst(dtype);
            }COMMA varList  {
                                printf("%s : Varlist_id \n", $1.expVal); 
                                add_symb_tab($1.expVal, dtype);
                            } 
            |   ID              
                {
                    printf("%s : Varlist_id \n", $1.expVal); 
                    add_symb_tab($1.expVal, dtype);

                    $1.irName = regNumb;
                    addIrForId($1.expVal);
                    allocaInst(dtype);
                };

type :  INT         {
                        printf("%s : data_type \n", $1); 
                        dtype = "int";
                    } 
        | FLOAT     {
                        printf("%s : data_type \n", $1);
                        dtype = "float";
                    } 
        | STRING    {
                        printf("%s : data_type \n", $1); 
                        dtype = "string";
                    } 
        | CHAR      {
                        printf("%s : data_type \n", $1); 
                        dtype = "char";
                    } 
        | DOUBLE    {
                        printf("%s : data_type \n", $1); 
                        dtype = "double";
                    };

const   : INTEGER_CONSTANT      {
                                    printf("%s : Integer constant\n", $1);

                                    $$.dtype = "int";
                                    $$.val = $1;
                                }    
        | FLOAT_CONSTANT        {
                                    printf("%s : Float constant\n", $1);

                                    $$.dtype = "float";
                                    $$.val = $1;
                                } 
        | '"' STRING_CONST '"'  {
                                    printf("%s : String constant\n", $2); 

                                    $$.dtype = "string";
                                } 
        | CHAR_CONSTANT         {
                                    printf("%s : Char constant\n", $1); 

                                    $$.dtype = "char";
                                };

stmtList :  stmt stmtList 
            | stmt 
            |;

stmt :  assignStmt  ;

assignStmt :    ID  { 
                        if(lookup($1.expVal) == 0){ 
                            printf("Error: %s not declared\n", $1.expVal);
                            lhsOfExp = "invalid";
                        } 
                        else{
                            lhsOfExp = getType($1.expVal);
                        }
                    }   ASSIGN EXP SEMICOLON   {
                                                    if(strcmp($4.expType, "invalid") != 0 && strcmp(lhsOfExp, "invalid") != 0){
                                                        if(strcmp($4.expType, lhsOfExp) != 0){ 
                                                            printf("Warning: %s is assigned to %s value\n",$4.expType, lhsOfExp);
                                                        }
                                                        else{
                                                            char temp[50];
                                                            sprintf(temp, "%d", $4.irName);

                                                            int irep = getIrep($1.expVal);
                                                            char dest[50];
                                                            sprintf(dest, "%d", irep);

                                                            char* src = (strcmp( $4.expVal, "") == 0) ? temp :  $4.expVal;
                                                            int isConst = (strcmp( $4.expVal, "") == 0) ? 0 : 1;
                                                            storeInst(lhsOfExp, src, dest, isConst);
                                                        }
                                                    } 
                                                    printf("%s : Assignment_id \n", $1.expVal); 
                                                    lhsOfExp = "";
                                                };

EXP :   TERM ADD EXP    {
                            
                            char* temp = calExpDtype($1.expType, $3.expType);
                            $$.expType = temp;

                            char sirname1[50], sirname3[50];
                            sprintf(sirname1, "%d", $1.irName);
                            sprintf(sirname3, "%d", $3.irName);
                            
                            if(strcmp(temp, "invalid") != 0){
                                $$.irName = regNumb;
                                char* op1 = (strcmp($1.expVal, "") == 0) ? sirname1 : $1.expVal;
                                char* op2 = (strcmp($3.expVal, "") == 0) ? sirname3 : $3.expVal;

                                int isop1const = (strcmp($1.expVal, "") == 0) ? 0 : 1;
                                int isop2const = (strcmp($3.expVal, "") == 0) ? 0 : 1;

                                addInst($$.expType, op1, op2, isop1const, isop2const);
                            }
                        }
        | TERM SUB EXP  {

                        }
        | TERM          {
                            $$.expType = $1.expType;
                            $$.irName = $1.irName;
                            $$.expVal = $1.expVal;
                        };

TERM :  FACTOR MULTIPLY TERM    {
                                    char* temp = calExpDtype($1.expType, $3.expType);
                                    $$.expType = temp;

                                    char sirname1[50], sirname3[50];
                                    sprintf(sirname1, "%d", $1.irName);
                                    sprintf(sirname3, "%d", $3.irName);

                                    if(strcmp(temp, "invalid") != 0){
                                        $$.irName = regNumb;
                                        char* op1 = (strcmp($1.expVal, "") == 0) ? sirname1 : $1.expVal;
                                        char* op2 = (strcmp($3.expVal, "") == 0) ? sirname3 : $3.expVal;

                                        int isop1const = (strcmp($1.expVal, "") == 0) ? 0 : 1;
                                        int isop2const = (strcmp($3.expVal, "") == 0) ? 0 : 1;

                                        multInst($$.expType, op1, op2, isop1const, isop2const);
                                    }
                                }
        | FACTOR DIVIDE TERM    {
                                    
                                }   
        | FACTOR                {
                                    $$.expType = $1.expType;
                                    $$.irName = $1.irName;
                                    $$.expVal = $1.expVal;
                                };

FACTOR : ID     {
                    printf("%s : Expression_id \n", $1.expVal);
                     
                    if(lookup($1.expVal) == 0){
                        printf("Error: %s not declared\n", $1.expVal);
                        $$.expType = "invalid";
                    } 
                    else{
                        char* temp = getType($1.expVal);

                        $$.expType = temp;
                        $$.expVal = "";
                        $$.irName = regNumb;

                        int irep = getIrep($1.expVal);
                        char sirname1[50];
                        sprintf(sirname1, "%d", irep);

                        loadInst(temp, sirname1);
                    }
                } 
        | const {
                        $$.expType = $1.dtype;
                        $$.expVal = $1.val;
                };
%%


void add_symb_tab(char* name, char* dtype){

    for(int i = 0; i < count; i++){
        if(strcmp(symb_tab[i].lexeme, name) == 0){
            return;
        }
    }

    strcpy(symb_tab[count].lexeme, name);
    strcpy(symb_tab[count].type, dtype);
    count += 1;
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

int lookup(char* id){

    for(int i = 0; i < count; i++){
        if(strcmp(symb_tab[i].lexeme, id) == 0){
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

void write_init_lines()
{
    
    fp = fopen("prog.ll", "w");
    fputs("; ModuleID = 'prog.c'\n", fp);
    fputs("source_filename = \"prog.c\"\n", fp);
    fputs("target datalayout = \"e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128\"\n", fp);
    fputs("target triple = \"x86_64-pc-linux-gnu\"\n\n", fp);
    fputs("; Function Attrs: noinline nounwind optnone uwtable\n", fp);
    fputs("define dso_local i32 @main() #0 {\n", fp);
    fclose(fp);
}

void write_closing_lines()
{

    fp = fopen("prog.ll", "a");
    fputs("\tret i32 0\n}\n\n", fp);
    fputs("attributes #0 = { noinline nounwind optnone uwtable \"correctly-rounded-divide-sqrt-fp-math\"=\"false\" \"disable-tail-calls\"=\"false\" \"frame-pointer\"=\"all\" \"less-precise-fpmad\"=\"false\" \"min-legal-vector-width\"=\"0\" \"no-infs-fp-math\"=\"false\" \"no-jump-tables\"=\"false\" \"no-nans-fp-math\"=\"false\" \"no-signed-zeros-fp-math\"=\"false\" \"no-trapping-math\"=\"false\" \"stack-protector-buffer-size\"=\"8\" \"target-cpu\"=\"x86-64\" \"target-features\"=\"+cx8,+fxsr,+mmx,+sse,+sse2,+x87\" \"unsafe-fp-math\"=\"false\" \"use-soft-float\"=\"false\" }\n\n", fp);
    fputs("!llvm.module.flags = !{!0}\n", fp);
    fputs("!llvm.ident = !{!1}\n\n", fp);
    fputs("!0 = !{i32 1, !\"wchar_size\", i32 4}\n", fp);
    fputs("!1 = !{!\"clang version 10.0.0-4ubuntu1 \"}\n", fp);
    fclose(fp);

}

char* calExpDtype(char* dtype1, char* dtype2){

    if(strcmp(dtype1, dtype2) != 0){
        return "float";
    }
    else{
        return dtype1;
    }
}

void allocaInst(char* dtype){

    if(strcmp(dtype, "int") == 0){
        instType = "i32";
    }
    else if(strcmp(dtype, "float") == 0){
        instType = "float";
    }

    char strNum[5];
    sprintf(strNum, "%d", regNumb);

    fp = fopen("prog.ll", "a");
    fputs("\t%", fp);
    fputs(strNum, fp);
    fputs(" = alloca ", fp);
    fputs(instType, fp);
    fputs(", align 4\n", fp);
    fclose(fp);

    regNumb += 1;
}

void storeInst(char* dtype, char* src, char* dest, int isConst){

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
    

    fp = fopen("prog.ll", "a");
    fputs("\tstore ", fp);
    fputs(instType, fp);
    fputs(" ", fp);
    if(isConst == 0)
        fputs("%", fp);
    fputs(src, fp);
    fputs(", ", fp);
    fputs(instType, fp);
    fputs("* ", fp);
    fputs("%", fp);
    fputs(dest, fp);
    fputs(", align 4\n", fp);

    fclose(fp);

    // regNumb += 1;

}

void loadInst(char* dtype, char* irname){

    if(strcmp(dtype, "int") == 0){
        instType = "i32";
    }
    else if(strcmp(dtype, "float") == 0){
        instType = "float";
    }

    char strNum[5];
    sprintf(strNum, "%d", regNumb);

    fp = fopen("prog.ll", "a");
    fputs("\t%", fp);
    fputs(strNum, fp);
    fputs(" = load ", fp);
    fputs(instType, fp);
    fputs(", ", fp);
    fputs(instType, fp);
    fputs("* %", fp);
    fputs(irname, fp);
    fputs(", align 4\n", fp);

    fclose(fp);

    regNumb += 1;


}

void addInst(char* dtype, char* term1, char* term2, int is1const, int is2const){

    // printf("nareshhhhhhhhh\n");

    if(strcmp(dtype, "int") == 0){
        instType = "i32";
    }
    else if(strcmp(dtype, "float") == 0){
        instType = "float";
    }

    char strNum[5];
    sprintf(strNum, "%d", regNumb);

    fp = fopen("prog.ll", "a");
    fputs("\t%", fp);
    fputs(strNum, fp);
    if(strcmp(dtype, "int") == 0)
        fputs(" = add nsw ", fp);
    else
        fputs(" = fadd ", fp);
    fputs(instType, fp);
    if(strcmp(dtype, "int") == 0){
        if(is1const == 0){
            fputs(" %", fp);
            fputs(term1, fp);
            fputs(", ", fp);
        }
        else{
            fputs(" ", fp);
            fputs(term1, fp);
            fputs(", ", fp);
        }

        if(is2const == 0){
            fputs("%", fp);
            fputs(term2, fp);
            fputs("\n", fp);
        }
        else{
            fputs(" ", fp);
            fputs(term2, fp);
            fputs("\n", fp);
        }
    }
    else{
        if(is1const == 0){
            fputs(" %", fp);
            fputs(term1, fp);
            fputs(", ", fp);
        }
        else{
            fputs(" ", fp);
            strcat(term1, ".000000e+00");
            fputs(term1, fp);
            fputs(", ", fp);
        }

        if(is2const == 0){
            fputs("%", fp);
            fputs(term2, fp);
            fputs("\n", fp);
        }
        else{
            strcat(term2, ".000000e+00");
            fputs(term2, fp);
            fputs("\n", fp);
        }
    }

    fclose(fp);

    regNumb += 1;
}

void multInst(char* dtype, char* term1, char* term2, int is1const, int is2const){

    if(strcmp(dtype, "int") == 0){
        instType = "i32";
    }
    else if(strcmp(dtype, "float") == 0){
        instType = "float";
    }

    char strNum[5];
    sprintf(strNum, "%d", regNumb);

    fp = fopen("prog.ll", "a");
    fputs("\t%", fp);
    fputs(strNum, fp);
    if(strcmp(dtype, "int") == 0)
        fputs(" = mul nsw ", fp);
    else
        fputs(" = fmul ", fp);
    fputs(instType, fp);
    if(strcmp(dtype, "int") == 0){
        if(is1const == 0){
            fputs(" %", fp);
            fputs(term1, fp);
            fputs(", ", fp);
        }
        else{
            fputs(" ", fp);
            fputs(term1, fp);
            fputs(", ", fp);
        }

        if(is2const == 0){
            fputs("%", fp);
            fputs(term2, fp);
            fputs("\n", fp);
        }
        else{
            fputs(term2, fp);
            fputs("\n", fp);
        }
    }
    else{
        if(is1const == 0){
            fputs(" %", fp);
            fputs(term1, fp);
            fputs(", ", fp);
        }
        else{
            fputs(" ", fp);
            strcat(term1, ".000000e+00");
            fputs(term1, fp);
            fputs(", ", fp);
        }

        if(is2const == 0){
            fputs("%", fp);
            fputs(term2, fp);
            fputs("\n", fp);
        }
        else{
            strcat(term2, ".000000e+00");
            fputs(term2, fp);
            fputs("\n", fp);
        }
    }

    fclose(fp);

    regNumb += 1;
}


int main(int argc, char **argv){
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

