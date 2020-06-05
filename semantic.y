%{
#include <bits/stdc++.h>
#include <unistd.h>
extern int lineCounter;
/* file for writing output byteCode */
ofstream fileOut("byteCode.j");
using namespace std;
typedef enum {INT_TYPE, FLOAT_TYPE} type_enum;
map<string, pair<int,type_enum> > symTab;
int variablesNum = 1;/*used to assign Number for new local variable*/
vector<string> ListOFCode;
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
/* --------------- functions prototype -------------------*/
void printCode(void);
void addLocalVar(string name, int type);/*add new local variable to symbol table*/
bool IsDeclared(string name);/*check if variable is in symTab*/
void addCode(string code);
void yyerror(const char * s);
void printLineNumber(int num)
{
	addCode(".line "+ to_string(num));
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
	int dType;
}
%start method_body
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
%type <dType> primitive_type
%type <dType> expression
%type <dType> simple_expression
%type <dType> term
%type <dType> factor
%type <dType> num
%%
method_body : {generateHeader();} statement_list {generateFooter();}
;
statement_list : statement
			        |
			   statement statement_list
;
statement : declaration {$$.nextList = new vector<int>();}
				| 
				if {$$.nextList = $1.nextList;}
				| 
				WHILE
				| 
				FOR
				|
				assignment {$$.nextList = $1.nextList;}
;
declaration : primitive_type  IDENTIFIER SEMICOLON 
				{
					string var($2);
					if($1 == INT_TYPE){
						addLocalVar(var, INT_TYPE);
					}else if ($1 == FLOAT_TYPE){
						addLocalVar(var, FLOAT_TYPE);
					}
				}
;
primitive_type  : INT_WORD { $$ = INT_TYPE}
					|
				FLOAT_WORD { $$ = FLOAT_TYPE}
;
if : IF_WORD LEFT_BRACKET expression RIGHT_BRACKET LEFT_BRACKET_CURLY STATEMENT RIGHT_BRACKET_CURLY ELSE_WORD LEFT_BRACKET_CURLY STATEMENT RIGHT_BRACKET_CURLY
;
WHILE : WHILE_WORD LEFT_BRACKET EXPRESSION RIGHT_BRACKET LEFT_BRACKET_CURLY STATEMENT RIGHT_BRACKET_CURLY
;
FOR : FOR_WORD LEFT_BRACKET assignment EXPRESSION SEMICOLON COUNTER RIGHT_BRACKET LEFT_BRACKET_CURLY STATEMENT RIGHT_BRACKET_CURLY
;
COUNTER : CHANGE IDENTIFIER
;
CHANGE : INCREMENT
| DECREMENT
;
assignment : IDENTIFIER EQUAL expression SEMICOLON
			{
				string var($1);
			if(IsDeclared(var)){
				if($3.dType == symTab[var].second){
					if($3.dType == INT_TYPE)
					{
						addCode("istore " + to_string(symTab[var].first));
					}
					else if ($3.dType == FLOAT_TYPE)
					{
						addCode("fstore " + to_string(symTab[var].first));
					}
				}else{
					yyerror("Type checking Error");
				}
			}else{
				string err = "identifier: "+var+" isn't declared in this scope";
				yyerror(err.c_str());
			}
		}
;
expression : simple_expression {$$.dType = $1.dType;}
| simple_expression RELOP simple_expression
| simple_expression BOOLEAN_OP simple_expression
;
simple_expression : term {$$.dType = $1.dType;}
| sign term {$$.dType = $2.dType;}
| simple_expression ADD_OP term
;
term : factor {$$.dType = $1.dType;}
| term MUL_OP factor
;
factor : IDENTIFIER
| num{$$.dType = $1.dType;}
| LEFT_BRACKET expression RIGHT_BRACKET
;
num : INT {$$.Type = INT_TYPE;  addCode("ldc "+to_string($1));} 
	   |
	  FLOAT{$$.Type = FLOAT_TYPE; addCode("ldc "+to_string($1));}
;
sign : ADD_OP
;
goto:
{
	$$ = ListOFCode.size();
	addCode("goto ");
}
;
%%


void printCode(void)
{
	for ( int i = 0 ; i < ListOFCode.size() ; i++)
	{
		fileOut<<ListOFCode[i]<<endl;
	}
}
/*---------------------------Main--------------------------*/
// stuff from lex that yacc needs to know about:
extern int yylex();
extern int yyparse();
extern FILE *yyin;
main (int argv, char * argc[])
{
	// open a file handle to a particular file:
	FILE *myfile = fopen("program.txt", "r");
	// make sure it is valid:
	if (!myfile) {
		cout << "I can't open a.snazzle.file!" << endl;
		return -1;
	}
	// set lex to read from it instead of defaulting to STDIN:
	yyin = myfile;
	// parse through the input until there is no more:
	do {
		yyparse();
	} while (!feof(yyin));
	printCode();
}
void addLocalVar(string name, int type)
{
	if(IsDeclared(name))
	{
		string error = "variable: "+name+" was declared before";
		yyerror(error.c_str());
	}else{
		symTab[name] = make_pair(variablesNum++,(type_enum)type);
	}
		
}
bool IsDeclared(string name)
{
	return (symTab.find(name) != symTab.end());
}
void addCode(string code)
{
	ListOFCode.push_back(code);
}
void generateHeader()
{
	addCode(".source program.txt");
	addCode(".class public test\n.super java/lang/Object\n"); //code for defining class
	addCode(".method public <init>()V");
	addCode("aload_0");
	addCode("invokenonvirtual java/lang/Object/<init>()V");
	addCode("return");
	addCode(".end method\n");
	addCode(".method public static main([Ljava/lang/String;)V");
	addCode(".limit locals 100\n.limit stack 100");
	addCode(".line 1");
}

void generateFooter()
{
	addCode("return");
	addCode(".end method");
}
void yyerror(const char * s)
{
	printf("error@%d: %s\n",lineCounter, s);
}