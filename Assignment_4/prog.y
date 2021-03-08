%{
    #include<stdio.h>
    int yylex(void);
    int yyerror(char*);
    int success = 1;
%}


%union{
    char* str;
}

%token SEMICOLON COMMA ASSIGN IF ELSE AND OR NOT EQ GE LE LT GT NE WHILE RETURN ADD SUB INCLUDE
%token <str> LIBRARY ID INTEGER_CONSTANT FLOAT_CONSTANT INT FLOAT STRING_CONST STRING CHAR DOUBLE

%%
prog : importLib funcDef;
importLib : lib | ;
lib : '#' INCLUDE LT LIBRARY GT importLib {printf("%s : library\n", $4);};
funcDef : func funcDef | ;
func : type ID {printf("%s : Function_id\n", $2);} '(' argList ')' '{' block '}';
block : decList stmtList block | ;
argList : argList COMMA arg | arg |;
arg : type ID  {printf("%s : Argument_id\n", $2);} | type ID ASSIGN const {printf("%s : Argument_id\n", $2);};
decList : decl SEMICOLON decList |;
decl : type varList;
varList : ID COMMA varList {printf("%s : Varlist_id \n", $1);} |ID {printf("%s : Varlist_id \n", $1);} | ID ASSIGN const COMMA varList {printf("%s : Varlist_id \n", $1);} | ID ASSIGN const {printf("%s : Varlist_id \n", $1);};
type : INT {printf("%s : data_type \n", $1);} | FLOAT {printf("%s : data_type \n", $1);} | STRING {printf("%s : data_type \n", $1);} | CHAR {printf("%s : data_type \n", $1);} | DOUBLE {printf("%s : data_type \n", $1);};
const : INTEGER_CONSTANT {printf("%s : Integer constant\n", $1);} | FLOAT_CONSTANT {printf("%s : Float constant\n", $1);} | '"' STRING_CONST '"'  {printf("%s : String constant\n", $2);};
stmtList :  ;
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

