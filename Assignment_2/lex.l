%{
    #include <stdio.h>
    #include<stdbool.h>
    #include<string.h>
    #define MAX 24
    int count = 0;
    int not_var_count = 0;
    void add_symb_tab(char name[], char type[]);
    void cache(char token[]);
    char keywords[MAX][50] = {"short", "float", "double", "bool", "char", "signed", "unsigned", "for",
                              "while", "do", "return", "void", "switch", "break", "case", "continue",
                              "goto", "long", "static", "union", "default", "int", "if", "else"};
    char dataType[][50] = {"short", "float", "double", "bool", "char", "signed", "unsigned"};
    struct map
    {
        char lexeme[50];
        char type[50];
    };
    struct map symb_tab[MAX];
    char prevType[50];
    char id_not_var[MAX][50];
    bool isPrevId = false;
    bool isVar = true;
    char globalId[50] = "";
    bool isRepeated = false;
%}

/*
*   Definitions
*/

%option stack
%s variableScope
%s funcArgs
%x singleLineComment
%x strings
kwords  "for"|"while"|"do"|"return"|"switch"|"break"|"case"|"continue"|"goto"|"static"|"union"|"default"|"if"|"else"|"include"|"iostream"|"using"|"namespace"|"std"|"cout"|"cin"
dtype   "short"|"float"|"double"|"bool"|"char"|"signed"|"unsigned"|"int"|"void"|"long"
digit [0-9]
letter [a-zA-Z]
us [_]
us_letter_or_digit {us}|{digit}|{letter}
us_or_letter {us}|{letter}
special_char "{"|"}"|"["|"]"|"("|")"|","|";"|"#"
Arithmatic_Operator "="|"+="|"-="|"/="|"*="|"+"|"-"|"*"|"/"
Relational_Operator ">"|"<"|"<="|">="|"==" 
variable_ending ";"| Arithmatic_Operator | Relational_Operator|","
tabs_space_newline [\t \n]
/*
*   RULES
*/

%%
\/\*([^*]|\*\/[^/])*\*\/                    {
                                                printf("Comments are ignored\n");
                                            }
[-]?{digit}+                                {
                                                printf("%s : Integer\n", yytext);
                                            }
[-]?{digit}+"."{digit}+                     {
                                                printf("%s : float\n", yytext);
                                            }
{kwords}                                    {
                                                printf("%s : Keyword\n", yytext);
                                            }
{dtype}                                     {
                                                strcat(prevType, yytext);
                                                strcat(prevType, " ");
                                                printf("%s : KeyWord\n",yytext);
                                            }
\"                                          {
                                                yy_push_state(strings);
                                            }
<strings>{
                                            [^\"]*                                  printf("strings %s\n", yytext);
                                            \"                                      {
                                                                                        yy_pop_state();
                                                                                    }
}
"("                                         {
                                                if(!isRepeated && isPrevId){
                                                    count --;
                                                    strcpy(symb_tab[count].lexeme, "");
                                                    strcpy(symb_tab[count].lexeme, "");
                                                }
                                                isRepeated = false;
                                                isPrevId = false;
                                                memset(prevType,'\0', sizeof(prevType)); 
                                                cache(globalId);
                                                strcpy(globalId, "");
                                                printf("%s : special_char\n", yytext);
                                                yy_push_state(funcArgs);
                                            }
<funcArgs>{
                                            ","                                    {
                                                                                        printf("%s : special_char\n", yytext);
                                                                                        memset(prevType,'\0', sizeof(prevType));
                                                                                        isPrevId = false;
                                                                                    }
                                            ")"                                     {
                                                                                        printf("%s : special_char\n", yytext);
                                                                                        memset(prevType,'\0', sizeof(prevType));
                                                                                        isPrevId = false;
                                                                                        yy_pop_state();
                                                                                    }
}
"{"                                         {
                                                printf("%s : special_char\n", yytext);
                                                yy_push_state(variableScope);  
                                            }
  
<funcArgs,variableScope>{
                                            {us_or_letter}{us_letter_or_digit}*     {
                                                                                        printf("%s : Identifier\n", yytext);
                                                                                        add_symb_tab(yytext, prevType);
                                                                                        isPrevId = true; 
                                                                            
                                                                                    }
                                            ";"                                     {
                                                                                        printf("%s : special_char\n", yytext);
                                                                                        isPrevId = false;
                                                                                        memset(prevType,'\0', sizeof(prevType));
                                                                                    }
                                            "}"                                     {
                                                                                        printf("%s : special_char\n", yytext);
                                                                                        yy_pop_state();
                                                                                    }
                                            ","                                     {
                                                                                        printf("%s : special_char\n", yytext);
                                                                                        isPrevId = false;
                                                                                    }                                                                                       
}
{us_or_letter}{us_letter_or_digit}*         {  
                                                printf("%s : Identifier\n", yytext);
                                                add_symb_tab(yytext, prevType); 
                                                strcpy(globalId, yytext);
                                                isPrevId = true; 
                                            }
","                                         {
                                                printf("%s : special_char\n", yytext);
                                                isPrevId = false;
                                            }
";"                                         {
                                                printf("%s : special_char\n", yytext);
                                                isPrevId = false;
                                                memset(prevType,'\0', sizeof(prevType));
                                            }                                           
{tabs_space_newline}
{special_char}                              {
                                                printf("%s : Special Character\n", yytext);
                                            }
{Arithmatic_Operator}                       {
                                                printf("%s : Arithmetic Operator\n", yytext);
                                            }
{Relational_Operator}                       {
                                                printf("%s : Relational Operator\n", yytext);
                                            }

%%

/*
*   storing non_variables in cache
*/

void cache(char* token){    
    bool isPresent = false;
    for(int i = 0; i < not_var_count; i++){
        if(strcmp(id_not_var[i], token)){
            isPresent = true;
            break;
        }
    }
    if(!isPresent){
        strcpy(id_not_var[not_var_count], token);
        not_var_count++;
    }
}

/*
* Creating the symbol table
*/

void add_symb_tab(char* name, char* dtype){

    for(int i = 0; i < not_var_count; i++){    // checking if identifier is function name
        if(strcmp(name, id_not_var[i]) == 0){
            isRepeated = true;
            return;
        }
    }   

    bool declared = false;
    if(isPrevId){
        for(int i = 0; i <= count-1; i++){    // To check if variable is declared
            if(strcmp(symb_tab[i].lexeme, name) == 0){
                declared = true;
                return;
            }
        }
    }

    if(isPrevId && !declared){
        printf("%s not declared\n", name);
        strcpy(symb_tab[count].lexeme, name);
        strcpy(symb_tab[count].type, "");
        count++;
        return;
    }

    bool isPresent = false;
    for(int i = 0; i <= count-1; i++){       // Store variable in symbol Table
        if(strcmp(symb_tab[i].lexeme, name) == 0){
            isPresent = true;
            break;
        }
    }

    if(!isPresent){
        strcpy(symb_tab[count].lexeme, name);
        strcpy(symb_tab[count].type, dtype);
        count ++;
    }
}

/*
*   Main Function
*/

int main()
{
    yylex();
    printf("\nNumber of entries in symbol table is %d\n",count);

    for(int i = 0; i <= count-1; i++){
        printf("%s - %s\n", symb_tab[i].lexeme, symb_tab[i].type);
    }
}
