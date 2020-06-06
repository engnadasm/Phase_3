%{
#include <bits/stdc++.h>
#include <unistd.h>
#define TRUE 1
#define FALSE 0

extern int yylex();
extern int yyparse();
extern FILE *yyin;
extern int lineCounter;
int labelsCount = 0;

using namespace std;

/* file for writing output byteCode */
ofstream fileOut("byteCode.j");

typedef enum {INT_TYPE, FLOAT_TYPE, ERROR_TYPE, BOOL_TYPE} type_enum;
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
void generateHeader();
void generateFooter();
string getRelop(string relop);
void printLineNumber(int num)
{
	addCode(".line "+ to_string(num));
}
void addToNext(vector<int> *list, int n)
{//nada
	for(int i = 0 ; i < list->size() ; i++)
	{
		ListOFCode[(*list)[i]] = ListOFCode[(*list)[i]] + "L_"+to_string(n);
	}
}
vector<int> * checkTFList(vector<int> *list1, vector<int> *list2)
{//nada
	if(list1 && list2){
		vector<int> *list = new vector<int> (*list1);
		list->insert(list->end(), list2->begin(),list2->end());
		return list;
	}else if(list1)
	{
		return list1;
	}else if (list2)
	{
		return list2;
	}else
	{
		return new vector<int>();
	}
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
    char* idval;
    char* operval;
	struct{
        int dType;
	}expr_type;
	struct {
		vector<int> *nextList;
	} stmt_type;
    int dType;
    struct {
		vector<int> *trueList, *falseList;
	} boolexpr_type;
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
%type <ival> init_label

%type <dType> primitive_type
%type <expr_type> expression
%type <expr_type> simple_expression
%type <expr_type> term
%type <expr_type> factor
%type <expr_type> num
%type <stmt_type> statement

%type <stmt_type> if
%type <stmt_type> WHILE
%type <stmt_type> FOR
%type <boolexpr_type> boolean_exp
%type <stmt_type> statement_list
%%
method_body : {generateHeader();} statement_list init_label {addToNext($2.nextList,$3); generateFooter();}
;
statement_list : statement
			        |
			   statement init_label statement_list {addToNext($1.nextList,$2); $$.nextList = $3.nextList;}
;
statement : declaration {$$.nextList = new vector<int>();}
                | if {$$.nextList = $1.nextList;}
				|
				WHILE {$$.nextList = $1.nextList;}
				|
				FOR
				|
				assignment {$$.nextList = new vector<int>();}
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
primitive_type  : INT_WORD { $$ = INT_TYPE;}
					|
				FLOAT_WORD { $$ = FLOAT_TYPE;}
					|
					BOOLEAN_WORD {$$ = BOOL_TYPE;}
;
boolean_exp: BOOL
{if($1){//means bool is true
    $$.trueList = new vector<int> ();
    $$.trueList->push_back(ListOFCode.size());
    $$.falseList = new vector<int>();
    addCode("goto ");
} else {//means bool is false
    $$.trueList = new vector<int> ();
    $$.falseList= new vector<int>();
    $$.falseList->push_back(ListOFCode.size());
    addCode("goto ");
}
}
| boolean_exp BOOLEAN_OP init_label boolean_exp
{if(!strcmp($2, "&&")){
    addToNext($1.trueList,$3);
    $$.trueList = $4.trueList;
    $$.falseList = checkTFList($1.falseList, $4.falseList);
}else if(!strcmp($2, "||")){
    addToNext($1.falseList,$3);
    $$.trueList = checkTFList($1.trueList, $4.trueList);
    $$.falseList = $4.falseList;
}
}
| expression RELOP expression
{
string relop($2);
$$.trueList = new vector<int>();
$$.trueList->push_back(ListOFCode.size());
$$.falseList = new vector<int>();
$$.falseList->push_back(ListOFCode.size() + 1);
addCode(getRelop(relop) + " ");
addCode("goto ");
}
;
//     1        2               3           4           5                   6           7         8     9                       10      11                  12          13          14
if : IF_WORD LEFT_BRACKET boolean_exp RIGHT_BRACKET LEFT_BRACKET_CURLY init_label statement_list goto RIGHT_BRACKET_CURLY ELSE_WORD LEFT_BRACKET_CURLY init_label statement_list RIGHT_BRACKET_CURLY
{
addToNext($3.trueList,$6);
addToNext($3.falseList,$12);
$$.nextList = checkTFList($7.nextList, $13.nextList);
$$.nextList->push_back($8);
}
;
WHILE : init_label WHILE_WORD LEFT_BRACKET boolean_exp RIGHT_BRACKET LEFT_BRACKET_CURLY init_label statement_list RIGHT_BRACKET_CURLY
{
addCode("goto L_" + to_string($1));
addToNext($8.nextList, $1);
addToNext($4.trueList, $7);
$$.nextList = $4.falseList;
}
;
FOR : FOR_WORD LEFT_BRACKET assignment boolean_exp SEMICOLON COUNTER RIGHT_BRACKET LEFT_BRACKET_CURLY statement_list RIGHT_BRACKET_CURLY
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
					yyerror("assignment: Type checking Error");
				}
			}else{
				string err = "identifier: "+var+" isn't declared in this scope";
				yyerror(err.c_str());
			}
		}
;
expression : simple_expression {$$.dType = $1.dType;}
| boolean_exp
;
simple_expression : term {$$.dType = $1.dType;}
					|
					sign term
					{
						$$.dType = $2.dType;
						if($2.dType == INT_TYPE)
						{
							addCode("imul");
						}
						else if ($2.dType == FLOAT_TYPE)
						{
							addCode("fmul");
						}
					}
					|
					simple_expression ADD_OP term
					{if($1.dType == $3.dType)
						{
							$$.dType = $1.dType;
							if($1.dType == INT_TYPE)
							{
								addCode("i" + inst_list[string($2)]);
							}
							else if ($1.dType == FLOAT_TYPE)
							{
								addCode("f" + inst_list[string($2)]);
							}
						}
						else
						{
							yyerror("simple_expression ADD_OP term: Type checking Error");
						}
					}
;
term : factor {$$.dType = $1.dType;}
		|
	   term MUL_OP factor
       {
			if($1.dType == $3.dType)
			{
				$$.dType = $1.dType;
				if($1.dType == INT_TYPE)
				{
					addCode("i" + inst_list[string($2)]);
				}
				else if ($1.dType == FLOAT_TYPE)
				{
				addCode("f" + inst_list[string($2)]);
				}
			}
			else
			{
			yyerror("term MUL_OP factor : Type checking Error");
			}
		}
;
factor : IDENTIFIER
		{
	     string var($1);
		  if(IsDeclared(var))
		{
			$$.dType = symTab[var].second;
			if(symTab[var].second == INT_TYPE)
			{
				addCode("iload " + to_string(symTab[var].first));
			}else if (symTab[var].second == FLOAT_TYPE)
			{
				addCode("fload " + to_string(symTab[var].first));
			}
		}
		else
		{
			string err = "identifier: "+var+" isn't declared in this scope";
			yyerror(err.c_str());
			$$.dType = ERROR_TYPE;
		}
		}
			|
		num{$$.dType = $1.dType;}
			|
			LEFT_BRACKET expression RIGHT_BRACKET {$$.dType = $2.dType;}
;
num : INT {$$.dType = INT_TYPE;  addCode("ldc "+to_string($1));}
	   |
	  FLOAT{$$.dType = FLOAT_TYPE; addCode("ldc "+to_string($1));}
;
sign : ADD_OP  {
				if(string($1) == "-"){addCode("ldc -1");}
				else{addCode("ldc 1");}
			   }
;
init_label:
{
	$$ = labelsCount;
	addCode("L_"+to_string(labelsCount++) + ":");
}
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
string getRelop(string relop)
{
if(inst_list.find(relop) != inst_list.end())
{
return inst_list[relop];
}
return "";
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
