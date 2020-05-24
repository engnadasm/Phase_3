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
void printLineNumber(int num)
{
	addLineCode(".line "+ to_string(num));
}
%}


%token <ival> INT
%token <fval> FLOAT
%token <bval> BOOL
%token <idval> IDENTIFIER
%token <aopval> ARITH_OP
%token <aopval> RELA_OP
%token <aopval> BOOL_OP

%token IF_WORD
%token ELSE_WORD
%token WHILE_WORD
%token FOR_WORD

%token INT_WORD
%token FLOAT_WORD
%token BOOLEAN_WORD

%token SEMI_COLON
%token EQUALS

%token LEFT_BRACKET
%token RIGHT_BRACKET
%token LEFT_BRACKET_CURLY
%token RIGHT_BRACKET_CURLY

%token SYSTEM_OUT

%%

%%
main (int argv, char * argc[])
{
}