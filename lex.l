%{
#include <bits/stdc++.h>
#include "y.tab.h"
int lineCounter = 1;
extern int printLineNumber(int num);
%}
letter [a-zA-Z]
digit [0-9]
id {letter}({letter}|{digit})*
digits {digit}+
bool "&&"|"||"
intnum "-"?{digits}
floatnum "-"?{digits}.{digits}("E"{digits}+)?
relop "=="|"!="|">"|">="|"<"|"<="
assign "="
addop "+"|"-"
mulop "*"|"/"
binary "true"|"false"
%%
"if" {return IF_WORD;}
"else" {return ELSE_WORD;}
"while" {return WHILE_WORD;}
"for" {return FOR_WORD;}
"boolean" {return BOOLEAN_WORD;}
"int" {return INT_WORD;}
"float" {return FLOAT_WORD;}
";" {return SEMICOLON;}
"," {return COLON;}
"(" {return LEFT_BRACKET;}
")" {return RIGHT_BRACKET;}
"{" {return LEFT_BRACKET_CURLY;}
"}" {return RIGHT_BRACKET_CURLY;}
"++" {return INCREMENT;}
"--" {return DECREMENT;}
"System.out.println" {return SYSTEM_OUT;}
\n {lineCounter++;printLineNumber(lineCounter);}
{addop}	{yylval.operval = strdup(yytext); return ADD_OP;}
{mulop}	{yylval.operval = strdup(yytext); return MUL_OP;}
{intnum}	{yylval.ival = atoi(yytext); return INT;}
{floatnum}	{yylval.fval = atof(yytext); return FLOAT;}
{relop} {yylval.operval = strdup(yytext); return RELOP;}
{bool} {yylval.operval = strdup(yytext); return BOOLEAN_OP;}
{binary} {if(!strcmp(yytext,"true")){ yylval.bval = 1;} else { yylval.bval = 0;} return BOOL;}
{id} {yylval.idval = strdup(yytext);return IDENTIFIER;}
{assign} {return EQUAL;}
%%
int yywrap() {
   return -1;
}
