%{
#include <bits/stdc++.h>
#include <unistd.h>
#define TRUE 1
#define FALSE 0
extern int lineCounter;
/* file for writing output byteCode */
ofstream fileOut("byteCode.j");
using namespace std;
typedef enum {INT_T, FLOAT_T, BOOL_T, VOID_T, ERROR_T} type_enum;

map<string,string> inst_list = {
	/* arithmetic operations */
	{"+", "add"},
	{"-", "sub"},
	{"/", "div"},
	{"*", "mul"},
	{"|", "or"},
	{"&", "and"},
	{"%", "rem"},

	/* relational operations */
	{"==", "if_icmpeq"},
	{"<=", "if_icmple"},
	{">=", "if_icmpge"},
	{"!=", "if_icmpne"},
	{">",  "if_icmpgt"},
	{"<",  "if_icmplt"}
};
vector<string> ListOFCode;
void addToListCode(string x);
void printCode(void);

void printLineNumber(int num)
{
	addToListCode(".line "+ to_string(num));
}

%}
%code requires {
	#include <vector>
	#include <map>
	#include <string>
	#include <iostream>

	using namespace std;
}
%union{
    int ival;
    int fval;
    int bval;
    char idval[100];
    char operval[50];
}
%start METHOD_BODY
%token <ival> INT
%token <fval> FLOAT
%token <bval> BOOL
%token <idval> IDENTIFIER
%token <operval> ADD_OP
%token <operval> MUL_OP
%token <operval> RELOP
%token <operval> BOOLEAN_OP
%token <operval> INCREMENT
%token <operval> DECREMENT
%token IF_WORD
%token ELSE_WORD
%token WHILE_WORD
%token FOR_WORD
%token INT_WORD
%token FLOAT_WORD
%token BOOLEAN_WORD
%token SEMICOLON
%token COLON
%token EQUAL
%token LEFT_BRACKET
%token RIGHT_BRACKET
%token LEFT_BRACKET_CURLY
%token RIGHT_BRACKET_CURLY
%token SYSTEM_OUT

%type <ival> goto

%%
METHOD_BODY : STATEMENT_LIST
;
STATEMENT_LIST : STATEMENT
| STATEMENT_LIST STATEMENT
;
STATEMENT : DECLARATION
| IF
| WHILE
| FOR
| ASSIGNMENT
;
DECLARATION : PRIMITIVE_TYPE IDENTIFIER SEMICOLON
;
PRIMITIVE_TYPE : INT_WORD
| FLOAT_WORD
;
IF : IF_WORD LEFT_BRACKET EXPRESSION RIGHT_BRACKET LEFT_BRACKET_CURLY STATEMENT RIGHT_BRACKET_CURLY ELSE_WORD LEFT_BRACKET_CURLY STATEMENT RIGHT_BRACKET_CURLY
;
WHILE : WHILE_WORD LEFT_BRACKET EXPRESSION RIGHT_BRACKET LEFT_BRACKET_CURLY STATEMENT RIGHT_BRACKET_CURLY
;
FOR : FOR_WORD LEFT_BRACKET ASSIGNMENT EXPRESSION SEMICOLON COUNTER RIGHT_BRACKET LEFT_BRACKET_CURLY STATEMENT RIGHT_BRACKET_CURLY
;
COUNTER : CHANGE IDENTIFIER
;
CHANGE : INCREMENT
| DECREMENT
;
ASSIGNMENT : IDENTIFIER EQUAL EXPRESSION SEMICOLON
;
EXPRESSION : SIMPLE_EXPRESSION
| SIMPLE_EXPRESSION RELOP SIMPLE_EXPRESSION
| SIMPLE_EXPRESSION BOOLEAN_OP SIMPLE_EXPRESSION
;
SIMPLE_EXPRESSION : TERM
| SIGN TERM
| SIMPLE_EXPRESSION ADD_OP TERM
;
TERM : FACTOR
| TERM MUL_OP FACTOR
;
FACTOR : IDENTIFIER
| NUM
| LEFT_BRACKET EXPRESSION RIGHT_BRACKET
;
NUM : INT
| FLOAT
;
SIGN : ADD_OP
;
goto:
{
	$$ = codeList.size();
	addToListCode("goto ");
}
;
%%

void addToListCode(string x)
{
	ListOFCode.push_back(x);
}

void printCode(void)
{
	for ( int i = 0 ; i < ListOFCode.size() ; i++)
	{
		printf(ListOFCode[i]+ "\n");
	}
}
main (int argv, char * argc[])
{
}
