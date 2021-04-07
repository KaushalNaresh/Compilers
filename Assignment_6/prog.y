%{
    #include<stdio.h>
    #include<string.h>
    #define MAX 24
    int yylex(void);
    int yyerror(char*);
    int success = 1;
    int count_of_if = 0;
    int count = 0;

    int lookup(char* id);
    void add_symb_tab(char name[], char type[]);
    char* getType(char* id);
    void updateTypeOfExp(char* type);
    int compareExp(char* leftExp, char* rightExp);

    struct map
    {
        char lexeme[50];
        char type[50];
    };
    struct map symb_tab[MAX];

    char dtype[20] = "";
    char prevType[20] = "";
    char consType[20] = "";
    char* lhsOfExp = "";
    char* rhsOfExp = "";
    char* leftExp = "";
    char* rightExp = "";
%}


%union{
    char* str;
}

%token SEMICOLON COMMA ASSIGN IF ELSE ELSE_IF AND OR NOT EQ GE LE LT GT NE WHILE RETURN ADD SUB MULTIPLY DIVIDE INCLUDE PRINT
%token <str> LIBRARY ID INTEGER_CONSTANT FLOAT_CONSTANT INT FLOAT STRING_CONST STRING CHAR DOUBLE CHAR_CONSTANT

%%
prog : importLib funcDef;
importLib : lib | ;
lib : '#' INCLUDE LT LIBRARY GT importLib {printf("%s : library\n", $4);};
funcDef : func funcDef | ;
func : type ID {printf("%s : Function_id\n", $2); add_symb_tab($2, dtype); strcpy(dtype, "");} '(' argList ')' funcBlock ;
funcBlock : '{' decList stmtList returnStmt '}' | SEMICOLON;
returnStmt : RETURN {printf("Return statement\n");} EXP {lhsOfExp = ""; rhsOfExp = ""; strcpy(prevType, ""); strcpy(dtype, ""); strcpy(consType, "");} SEMICOLON |; 
argList : argList COMMA arg | arg |;
arg : type ID  {printf("%s : Argument_id\n", $2); add_symb_tab($2, dtype); strcpy(dtype, "");} | type ID {add_symb_tab($2, dtype); strcpy(dtype, "");} ASSIGN const {printf("%s : Argument_id\n", $2); strcpy(consType, "");};
decList : decl decList | decl |;
decl : type varList SEMICOLON {strcpy(dtype, "");};
varList : ID COMMA varList {printf("%s : Varlist_id \n", $1); add_symb_tab($1, dtype);} |ID {printf("%s : Varlist_id \n", $1); add_symb_tab($1, dtype);} | ID ASSIGN const {strcpy(consType, ""); add_symb_tab($1, dtype);} COMMA varList {printf("%s : Varlist_id \n", $1);} | ID ASSIGN const {printf("%s : Varlist_id \n", $1); add_symb_tab($1, dtype); strcpy(consType, "");};
type : INT {printf("%s : data_type \n", $1); strcpy(dtype,"int");} | FLOAT {printf("%s : data_type \n", $1); strcpy(dtype,"float");} | STRING {printf("%s : data_type \n", $1); strcpy(dtype,"string");} | CHAR {printf("%s : data_type \n", $1); strcpy(dtype,"char");} | DOUBLE {printf("%s : data_type \n", $1); strcpy(dtype,"double");};
const : INTEGER_CONSTANT {printf("%s : Integer constant\n", $1); strcpy(consType,"int");} | FLOAT_CONSTANT {printf("%s : Float constant\n", $1); strcpy(consType,"float");} | '"' STRING_CONST '"'  {printf("%s : String constant\n", $2); strcpy(consType, "string");} | CHAR_CONSTANT {printf("%s : Char constant\n", $1); strcpy(consType,"char");};
stmtList : stmt stmtList | stmt |;
stmt : assignStmt  | ifStmt | whileStmt | printStmt | funcCallStmt;
funcCallStmt : function SEMICOLON;
printStmt : PRINT '(' const COMMA printVarList ')' SEMICOLON {printf("Print statement \n");};
printVarList : ID {if(lookup($1) == 0){ printf("Error: %s not declared\n", $1);}} COMMA printVarList | ID {if(lookup($1) == 0){ printf("Error: %s not declared\n", $1);}};
assignStmt : ID {int res = lookup($1); if(res == 0){ printf("Error: %s not declared\n", $1);} else{lhsOfExp = getType($1);}} ASSIGN EXP SEMICOLON {if(strcmp(rhsOfExp, "invalid") != 0){if(strcmp(lhsOfExp, rhsOfExp) != 0){ printf("Warning: %s is assigned to %s value\n",rhsOfExp, lhsOfExp);}} printf("%s : Assignment_id \n", $1); lhsOfExp = ""; rhsOfExp = ""; strcpy(prevType, ""); strcpy(dtype, ""); strcpy(consType, "");};
EXP : TERM ADD EXP | TERM SUB EXP | TERM;
TERM : FACTOR MULTIPLY TERM | FACTOR DIVIDE TERM | FACTOR;
FACTOR : ID {printf("%s : Expression_id \n", $1); int res = lookup($1); if(res == 0){ printf("Error: %s not declared\n", $1); rhsOfExp = "invalid";} else{char* temp = getType($1); updateTypeOfExp(temp);}} | const {updateTypeOfExp(consType);} | function;
function : ID {printf("Function call statement\n"); if(lookup($1) == 0){ printf("Error: %s function not declared\n", $1); rhsOfExp = "invalid";} else{printf("%s function called\n", $1); char* temp = getType($1); updateTypeOfExp(temp);}} '(' callList ')';
callList : ID {if(lookup($1) == 0){ printf("Error: %s not declared\n", $1);} else{ printf("%s : callList_id \n", $1);}} COMMA callList | ID {if(lookup($1) == 0){ printf("Error: %s not declared\n", $1);} else{ printf("%s : callList_id \n", $1);}} | const {strcpy(consType, "");};
ifStmt : IF {printf("%d If Statement \n", count_of_if); count_of_if += 1; } '(' bExp ')' block if_or_else_or_elsif;
if_or_else_or_elsif : ifStmt | ELSE_IF {printf("else if Statement \n");} '(' bExp ')' block if_or_else_or_elsif | ELSE {printf("else Statement for %d if \n", count_of_if-1); count_of_if -= 1;} block |;
bExp : EXP {leftExp = rhsOfExp; lhsOfExp = ""; rhsOfExp = ""; strcpy(prevType, ""); strcpy(dtype, ""); strcpy(consType, "");} relop EXP {rightExp = rhsOfExp; lhsOfExp = ""; rhsOfExp = ""; strcpy(prevType, ""); strcpy(dtype, ""); strcpy(consType, ""); if(strcmp(leftExp, "invalid") == 0){printf("Error: Invalid left Expression\n");} else if(strcmp(rightExp, "invalid") == 0){printf("Error: Invalid right Expression\n");} else if(strcmp(leftExp, rightExp) != 0){if(compareExp(leftExp, rightExp) == 0){printf("Error: Invalid operands to relational operator\n");}} lhsOfExp = ""; rhsOfExp = ""; strcpy(prevType, ""); strcpy(dtype, ""); strcpy(consType, ""); leftExp = ""; rightExp = "";} | NOT {printf("Not Expression \n");} '(' bExp ')' | bExp AND {printf("And Expression \n");} bExp | bExp OR {printf("Or Expression \n");} bExp;
relop : LT | GT | EQ | NE | LE | GE; 
whileStmt : WHILE {printf("While Statement \n");} '(' bExp ')' block;
block : '{' decList stmtList '}' | decl | stmt | SEMICOLON;
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

int compareExp(char* leftExp, char* rightExp){

    if((strcmp(leftExp,"int") == 0 && strcmp(rightExp, "int") == 0 )|| (strcmp(leftExp, "int") == 0 && strcmp(rightExp, "double") == 0) ||
       (strcmp(leftExp, "double") == 0 && strcmp(rightExp, "int") == 0) || (strcmp(leftExp, "double") == 0 && strcmp(rightExp, "double") == 0) ||
       (strcmp(leftExp, "int") == 0 && strcmp(rightExp, "float") == 0) || (strcmp(leftExp, "float") == 0 && strcmp(rightExp, "int") == 0) ||
       (strcmp(leftExp, "float") == 0 && strcmp(rightExp, "float") == 0) || (strcmp(leftExp, "double") == 0 && strcmp(rightExp, "float") == 0) ||
       (strcmp(leftExp, "float") == 0 && strcmp(rightExp, "double") == 0) || (strcmp(leftExp, "char") == 0 && strcmp(rightExp, "char") == 0) ||
       (strcmp(leftExp, "string") == 0 && strcmp(rightExp, "string") == 0) || (strcmp(leftExp, "int") == 0 && strcmp(rightExp, "char") == 0) ||
       (strcmp(leftExp, "char") == 0 && strcmp(rightExp, "int") == 0)){
           return 1;
       }

    else{
        return 0;
    }
}

void updateTypeOfExp(char* type){

    if(strcmp(rhsOfExp, "invalid") == 0)
        return;

    if(strcmp(prevType, "char") == 0){
        if(strcmp(type, "int") == 0 || strcmp(type, "float") == 0 || strcmp(type, "double") == 0 || strcmp(type, "string") == 0){
            printf("Error: Wrong operands to binary %s and %s\n", prevType, type);
            rhsOfExp = "invalid";
        }

        else{
            rhsOfExp = "char";
            strcpy(prevType, "char");
        }
    }

    else if(strcmp(prevType, "string") == 0){
        if(strcmp(type, "int") == 0 || strcmp(type, "float") == 0 || strcmp(type, "double") == 0 || strcmp(type, "char") == 0){
            printf("Error: Wrong operands to binary %s and %s\n", prevType, type);
            rhsOfExp = "invalid";
        }

        else{
            rhsOfExp = "string";
            strcpy(prevType, "string");
        }
    }

    else if(strcmp(prevType, "int") == 0){
        if(strcmp(type, "string") == 0 || strcmp(type, "char") == 0){
            printf("Error: Wrong operands to binary %s and %s\n", prevType, type);
            rhsOfExp = "invalid";
        }

        else if(strcmp(type, "float") == 0 || strcmp(type, "double") == 0){
            rhsOfExp = type;
            strcpy(prevType, type);
        }
        else{
            rhsOfExp = "int";
            strcpy(prevType, "int");
        }
    }

    else if(strcmp(prevType, "float") == 0){
        if(strcmp(type, "string") == 0 || strcmp(type, "char") == 0){
            printf("Error: Wrong operands to binary %s and %s\n", prevType, type);
            rhsOfExp = "invalid";
        }

        else if(strcmp(type, "double") == 0){
            rhsOfExp = type;
            strcpy(prevType, type);
        }
        else{
            rhsOfExp = "float";
            strcpy(prevType, "float");
        }
    }

    else if(strcmp(prevType, "double") == 0){
        if(strcmp(type, "string") == 0 || strcmp(type, "char") == 0){
            printf("Error: Wrong operands to binary %s and %s\n", prevType, type);
            rhsOfExp = "invalid";
        }

        else{
            rhsOfExp = "double";
            strcpy(prevType, "double");
        }
    }

    else if(strcmp(prevType, "") == 0){
        rhsOfExp = type;
        strcpy(prevType, type);
    }

    

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

