%{
    #include<stdio.h>
    int MAX = 30;
    int yylex(void);
    int yyerror(char*);
    int success = 1;
    int count_of_if = 0;
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
func : type ID {printf("%s : Function_id\n", $2);} '(' argList ')' funcBlock ;
funcBlock : '{' decList stmtList '}' | SEMICOLON;
argList : argList COMMA arg | arg |;
arg : type ID  {printf("%s : Argument_id\n", $2);} | type ID ASSIGN const {printf("%s : Argument_id\n", $2);};
decList : decl decList | decl |;
decl : type varList SEMICOLON;
varList : ID COMMA varList {printf("%s : Varlist_id \n", $1);} |ID {printf("%s : Varlist_id \n", $1);} | ID ASSIGN const COMMA varList {printf("%s : Varlist_id \n", $1);} | ID ASSIGN const {printf("%s : Varlist_id \n", $1);};
type : INT {printf("%s : data_type \n", $1);} | FLOAT {printf("%s : data_type \n", $1);} | STRING {printf("%s : data_type \n", $1);} | CHAR {printf("%s : data_type \n", $1);} | DOUBLE {printf("%s : data_type \n", $1);};
const : INTEGER_CONSTANT {printf("%s : Integer constant\n", $1);} | FLOAT_CONSTANT {printf("%s : Float constant\n", $1);} | '"' STRING_CONST '"'  {printf("%s : String constant\n", $2);} | CHAR_CONSTANT {printf("%s : Char constant\n", $1);};
stmtList : stmt stmtList | stmt |;
stmt : assignStmt | ifStmt | whileStmt | printStmt;
printStmt : PRINT '(' const COMMA varList ')' SEMICOLON;
assignStmt : ID ASSIGN EXP SEMICOLON {printf("%s : Assignment_id \n", $1);};
EXP : EXP ADD TERM | EXP SUB TERM | TERM;
TERM : TERM MULTIPLY FACTOR | TERM DIVIDE FACTOR | FACTOR;
FACTOR : ID {printf("%s : Expression_id \n", $1);} | const;
ifStmt : IF {printf("%d If Statement \n", count_of_if); count_of_if += 1; } '(' bExp ')' block if_or_else_or_elsif;
if_or_else_or_elsif : ifStmt | ELSE_IF {printf("else if Statement \n");} '(' bExp ')' block if_or_else_or_elsif | ELSE {printf("else Statement for %d if \n", count_of_if-1); count_of_if -= 1;} block |;
bExp : EXP relop EXP | NOT {printf("Not Expression \n");} '(' bExp ')' | bExp AND {printf("And Expression \n");} bExp | bExp OR {printf("Or Expression \n");} bExp;
relop : LT | GT | EQ | NE | LE | GE; 
whileStmt : WHILE {printf("While Statement \n");} '(' bExp ')' block;
block : '{' decList stmtList '}' | decl | stmt | SEMICOLON;
%%

int main(int argc, char **argv){
    yyparse();
    if(success)
    	printf("Parsing Successful\n");
    return 0;
}

int yyerror(char *s){
    fprintf(stderr, "%s\n", s);
    success = 0;
    return 0;
}

