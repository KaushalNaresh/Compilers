%{
#include "advanced_parser.tab.h"
// #include "head.h"
#include <stdlib.h>
#include <string.h>
%}

%%

[ \t]+ ;
"{"    { printf("Detected %s\n", yytext); return yytext[0]; }
"}"    { printf("Detected %s\n", yytext); return yytext[0];}
"("    { printf("Detected %s\n", yytext); return yytext[0];}
")"    { printf("Detected %s\n", yytext); return yytext[0];}
"="    { printf("Detected %s\n", yytext); return yytext[0]; }
","    { printf("Detected %s\n", yytext); return COMMA; }
";"    { printf("Detected %s\n", yytext); return SEMICOLON; }
">"    { printf("Detected %s\n", yytext); return '>';}
"<"    { printf("Detected %s\n", yytext); return '<';}
"=="   { printf("Detected %s\n", yytext); return EQ;}
">="|"<="|"!=" {printf("Detected %s\n", yytext); return RELOP;}
"||"   { printf("Detected %s\n", yytext); return OR; }
"&&"   { printf("Detected %s\n", yytext); return AND; }
"!"    { printf("Detected %s\n", yytext); return NOT; }
"if"   { printf("Detected %s\n", yytext); return IF; }
"while"   { printf("Detected %s\n", yytext); return WHILE; }
"+"|"-"|"/"|"*"    { printf("Detected %s\n", yytext); return yytext[0];}
"int"  { printf("Detected %s\n", yytext); yylval.sval = "int"; return INT; }
"float"  { printf("Detected %s\n", yytext); yylval.sval = "float"; return FLOAT; }
[0-9]+     {printf("Detected integer const : %s\n", yytext); yylval.ival = atoi(yytext); return INT_CONST; }
[0-9]+"."[0-9]+     { printf("Detected float const : %s\n", yytext); yylval.fval = (float)atoi(yytext); return FLOAT_CONST; }
[A-Za-z0-9]* { printf("Detected ID : %s\n", yytext);  
               yylval.sval = strdup(yytext); return ID; }
\n         { printf("Inside newline\n"); }
.          ;
%%
