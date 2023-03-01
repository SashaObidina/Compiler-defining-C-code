%{
	#define _CRT_SECURE_NO_WARNINGS
	#pragma once
	#include <stdio.h>
	#include <ctype.h>
	#include <string.h>
	#include <stdlib.h>
	extern FILE *yyin;
	
	int error_line = 1;
	int error = 1;
	int begin_preproc = 0;
	int pragma_fl = 0;
	int include_fl = 0;
	int cycle_fl = 0;
	int switch_fl[100];
	int default_fl[100];
	int case_fl = 0;
	int switch_num = 0;
	int define_fl = 0;
	void check_identificator(char* id);
	void yyerror(char* str);
	void end_compiler();		
%}


%token CHAR INT FLOAT DOUBLE VOID BOOL SIZE_T ENUM STRUCT UNION //типы
%token REAL BINARY DECIMAL OCTAL HEX CHAR_CONST BOOL_CONST //константы
%token UNSIGNED SIGNED SHORT LONG //спецификаторы
%token CONST VOLATILE AUTO EXTERN STATIC REGISTER //квалификаторы
%token IF ELSE WHILE FOR DO SWITCH CASE GOTO DEFAULT BREAK CONTINUE RETURN SIZEOF TYPEDEF EMPTY //операторы
%token INCLUDE DEFINE UNDEF IFDEF IFNDEF ELIF ENDIF IF_PP ELSE_PP PRAGMA LINE ERROR ERROR_ //директивы препроцессора
%token MULT DIV MOD ADD SUBSTR ASSIGN_MULT ASSIGN_DIV ASSIGN_MOD ASSIGN_ADD ASSIGN_SUBSTR  //математические операторы
%token GRADE_AND GRADE_OR XOR LOG_AND LOG_OR NOT LEFT RIGHT ASSIGN_AND ASSIGN_OR ASSIGN_XOR ASSIGN_NOT ASSIGN_LEFT ASSIGN_RIGHT //математические операторы
%token LEAST BIGGER ASSIGN_LEAST ASSIGN_BIGGER //математические операторы
%token ASSIGN IF_ASSIGN //математические операторы
%token TILDA ASSIGN_TILDA //математические операторы
%token ARROW DOT QUESTION DOUBLE_DOT //знаки
%token INCR DECR //математические операторы
%token FILE_PATH //путь к файлу/имя файла
%token PP_STR //строка для директив препроцессора
%token IDENTIFIER STRING //идентификатор и строка
%token NEW_LINE //переход на новую строку

%start begin

%%

begin:
	begin_ {printf("//begin\n"); error = 0;}
begin_:  
	program {printf("//program\n");}
	| begin_ program {printf("//begin_ program\n");};

program: 
	function {printf("//function\n");} 
	| declaration {printf("//declaration\n");} 
	| struct_union_enum_declaration {printf("//struct_union_enum_declaration\n");}
	| preprocessor {printf("//preprocessor\n");};

preprocessor:
	pp {printf("pp");};

pp:
	for_preproc {printf("for_preproc\n");}
	| pp for_preproc {printf("pp for_preproc\n");};

for_preproc:
	for_preproc_if
		{
			printf("for_preproc_if\n");
			begin_preproc = 0;
		};
	| preproc_string
		{
			printf("preproc_string\n");
			begin_preproc = 0;
		};

for_preproc_if:
	preproc_if preproc_elif preproc_else preproc_endif
	| preproc_if preproc_elif preproc_endif
	| preproc_if preproc_else preproc_endif
	| preproc_if preproc_endif;

preproc_if:
	IF_PP expr_cond NEW_LINE pp
	| IF_PP expr_cond NEW_LINE
	| IFDEF IDENTIFIER NEW_LINE pp
	| IFDEF IDENTIFIER NEW_LINE
	| IFNDEF IDENTIFIER NEW_LINE pp
	| IFNDEF IDENTIFIER NEW_LINE;  

preproc_elif:
	preproc_elif_single
	| preproc_elif preproc_elif_single;

preproc_elif_single:
	ELIF expr_cond NEW_LINE
	| ELIF expr_cond NEW_LINE pp;

preproc_else:
	ELSE_PP NEW_LINE
	| preproc_else pp;

preproc_endif:
	ENDIF NEW_LINE
	| ENDIF;
	//{printf("ENDIF");}; 

preproc_include:
	INCLUDE FILE_PATH NEW_LINE
		{
			//printf("//include file_path new_line");
			include_fl = 0;
		};

preproc_define:
        DEFINE IDENTIFIER preproc_token NEW_LINE
	| DEFINE IDENTIFIER NEW_LINE;

preproc_undef:
        UNDEF IDENTIFIER NEW_LINE;

preproc_line:
	LINE constant FILE_PATH NEW_LINE
	| LINE constant NEW_LINE;

preproc_error:
	ERROR_ preproc_token NEW_LINE;
	| ERROR;

preproc_pragma:
	PRAGMA preproc_token NEW_LINE
	| PRAGMA NEW_LINE;

preproc_string:
	preproc_include
	| preproc_define
	//{printf("define");}
	| preproc_undef
	| preproc_error
	| preproc_line
	| preproc_pragma {pragma_fl = 0;}
	| NEW_LINE; //{printf("new_line");}

preproc_token:
	for_preproc_token
	| preproc_token for_preproc_token;

for_preproc_token:
	IDENTIFIER {printf("//identifier in for_preproc_token ");}
	| constant
	| STRING
	| PP_STR;


pointer:
	for_pointer
	| MULT pointer;

for_pointer:
	MULT
	| MULT const_volatile;

specificators:
        memory_spec
	| type_spec
	| memory_spec type_spec
	| type_spec memory_spec;

memory_spec:
	EXTERN
	| STATIC
	| REGISTER
	| AUTO;

type_spec:
	simple_type
	| const_volatile simple_type; 

simple_type:
	CHAR 
	| UNSIGNED CHAR
	| SIGNED CHAR
	| INT
	| UNSIGNED INT
	| SIGNED INT
	| SHORT
	| UNSIGNED SHORT
	| SHORT INT
	| UNSIGNED SHORT INT
	| SIGNED SHORT INT
	| LONG
	| LONG LONG
	| LONG INT
	| LONG LONG INT
	| SIGNED LONG INT
	| UNSIGNED LONG
	| UNSIGNED LONG LONG
	| UNSIGNED LONG INT
	| UNSIGNED LONG LONG INT 
	| FLOAT 
	| DOUBLE
	| LONG DOUBLE
	| BOOL
	| SIZE_T
	| VOID {printf("VOID ");}
	| STRUCT IDENTIFIER
	| ENUM IDENTIFIER;

const_volatile:
	CONST
	| VOLATILE;

one_decl:
	IDENTIFIER {printf("//identifier in one_decl ");}
	| one_decl_in_scopes
	| for_array {printf("//for_array\n");}
	| one_decl for_array
	| '(' many_params ')'
	| one_decl '(' many_params ')'
	| one_decl '(' ')';

one_decl_in_scopes:
	'(' one_decl ')'
	| '(' pointer one_decl')';

for_array:
	square_scopes
	| for_array square_scopes;

square_scopes:                     
	'[' ']'
	| '[' expr_cond ']';

many_params:
	one_param          
	| many_params ',' one_param;

one_param:
	specificators pointer
	| specificators pointer one_decl
	| specificators
	| specificators one_decl;	

function:
	specificators pointer one_decl '(' ')' '{' for_func_body '}'
	| specificators one_decl '(' ')' '{' for_func_body '}' 
	| specificators pointer one_decl '(' many_params ')' '{' for_func_body '}'
	| specificators one_decl '(' many_params ')' '{' for_func_body '}'
	| specificators pointer one_decl '(' ')' '{' '}'
	| specificators one_decl '(' ')' '{' '}'
	| specificators pointer one_decl '(' many_params ')' '{' '}'
	| specificators one_decl '(' many_params ')' '{' '}';

/*func_body:
	'{' '}' {printf("//'{' '}'\n");}
	|'{' for_func_body '}' {printf("'{' for_func_body '}'\n");};*/

for_func_body:
	for_func_body_one
	| for_func_body for_func_body_one;

for_func_body_one:
	declaration  {printf("declaration\n"); }
	| expr_assign ';'
	| switch_op  {}
	| '{' '}'
	| '{' for_func_body '}'
	| ';'
	| if_op {printf("first if_op");}
	| while_op {printf("while_op"); }
	| for_op {printf("for_op"); }
	| do_op ';' {printf("do_op"); }
	| goto_op {printf("goto_op");} 
	| return_op ';' {printf("return_op"); } 
	| break_continue_op ';' {printf("break_continue_op");};

break_continue_op:
	BREAK {printf("//BREAK;\n"); //if (!cycle_fl) yyerror("incorrect BREAK");
	}
	| CONTINUE  {printf("//CONTINUE;\n"); //if (!cycle_fl) yyerror("incorrect CONTINUE");
	};
	
if_op:
	IF '(' ')' for_func_body_one 
	| IF '(' sp_expr ')' for_func_body_one
	| IF '(' ')' for_func_body_one ELSE for_func_body_one
	| IF '(' sp_expr ')' for_func_body_one ELSE for_func_body_one; 

while_op:
	WHILE '(' sp_expr ')' for_func_body_one;

do_op:
	DO for_func_body_one WHILE '(' sp_expr ')' {printf("//do-while\n");};

for_op:
	FOR '(' ';' ';' ')' for_func_body_one
	| FOR '(' ';' ';' sp_expr ')' for_func_body_one
	| FOR '(' ';' sp_expr ';' ')' for_func_body_one
	| FOR '(' ';' sp_expr ';' sp_expr ')' for_func_body_one
	| FOR '(' sp_expr ';' ';' ')' for_func_body_one
	| FOR '(' sp_expr ';' ';' sp_expr ')' for_func_body_one
	| FOR '(' sp_expr ';' sp_expr ';' ')' for_func_body_one
	| FOR '(' sp_expr ';' sp_expr ';' sp_expr ')' for_func_body_one;

sp_expr:
	specificators expr
	|  expr;

switch_op:
	SWITCH '(' expr ')' '{' for_switch_op '}' {printf("//SWITCH '(' expr ')' '{' for_switch_op '}' "); switch_fl[switch_num] = 0; default_fl[switch_num] = 0; switch_num--;};

for_switch_op:
	CASE expr_cond ':' {case_fl = 0;}
	| CASE expr_cond ':' for_func_body_one {printf("sw_fl: %d, ", switch_fl[switch_num]); case_fl = 0;}
	| DEFAULT ':' for_func_body_one {if (!(switch_fl[switch_num] == 1 && default_fl[switch_num] == 1)) {printf("sw: %d", switch_fl[switch_num]); printf("def: %d", default_fl[switch_num]); yyerror("incorrect or repeating DEFAULT");}}
	| for_switch_op for_switch_op; 	

goto_op:
	IDENTIFIER ':' for_func_body_one
	| GOTO IDENTIFIER;

return_op:
	RETURN
	| RETURN expr;

expr:
	expr_assign
	| expr_assign ',' expr_assign;

expr_assign:
	expr_cond {printf("expr_cond");}
	| expr_unary assign_op expr_assign;

expr_cond:
        expr_binary {printf("//expr_binary");};
	| expr_binary QUESTION expr_binary DOUBLE_DOT expr_binary;

expr_unary:
	for_expr_unary {printf("//for_expr_unary");}
	| unary_op expr_unary {printf("//unary_op expr_unary");}
	| expr_unary '[' expr ']'
	| expr_unary '(' ')'
	| expr_unary '(' expr ')'
	| expr_unary DOT expr_unary
	| expr_unary ARROW expr_unary
	| incr_decr
	| for_sizeof
	| '(' specificators ')' expr_unary 
	| '(' specificators pointer ')' expr_unary
	| specificators '(' expr_unary ')';

for_expr_unary:
	constant {printf("constant in expr_unary");}
	| '(' expr ')' {printf("'(' expr ')'");}
	| STRING; //{printf("STRING in for_expr_unary");}
	//| CHAR_CONST
	//| IDENTIFIER;

unary_op:
	GRADE_AND
	| pointer
	| ADD
	| SUBSTR
	| TILDA
	| NOT;

/*for_pointer:
	pointer
	| GRADE_AND
	| for_pointer for_pointer;*/

for_sizeof:
	SIZEOF expr_unary
	| SIZEOF '(' specificators ')'
	| SIZEOF '(' specificators pointer ')';

incr_decr:
	expr_unary INCR
	| expr_unary DECR
	| INCR expr_unary
	| DECR expr_unary;

expr_binary:
	expr_unary {printf("//expr_unary");}
	| expr_binary assign_op expr_cond
	//| expr_binary IF_ASSIGN expr_cond
	| expr_binary unary_op expr_cond {printf("expr_binary unary_op expr_cond");}
	//| expr_binary LEAST expr_cond 
	//| expr_binary BIGGER expr_cond
	| expr_binary binary_op expr_cond {printf("expr_binary binary_op expr_cond");}
	| expr_binary DOT expr_cond
	| expr_binary ARROW expr_cond {printf("expr_binary ARROW expr_cond");}
	//| expr_binary MULT expr_cond
	//| expr_binary DIV expr_cond
        // | expr_binary XOR expr_cond
	//| expr_binary LOG_OR expr_cond
	//| expr_binary GRADE_OR expr_cond
	//| expr_binary LOG_AND expr_cond
        | expr_binary ',' expr_cond
	| expr_binary '[' expr ']' {printf("expr_binary '[' expr ']'");}
	//| expr_binary LEFT expr_cond
	//| expr_binary RIGHT expr_cond
	| '(' simple_type ')' expr_cond
	| '(' simple_type pointer ')' expr_cond
	| '(' expr_binary ')' {printf("'(' expr_binary ')'");};

binary_op:
	LEAST
	| BIGGER
	| MOD
	| DIV
	| XOR
	| LOG_OR
	| GRADE_OR
	| LOG_AND
	| LEFT
	| RIGHT;

assign_op:
      	ASSIGN //{printf("ASSIGN");}
	| IF_ASSIGN
	| ASSIGN_MULT 
	| ASSIGN_DIV
	| ASSIGN_MOD 
	| ASSIGN_ADD 
	| ASSIGN_SUBSTR
	| ASSIGN_AND 
	| ASSIGN_OR 
	| ASSIGN_XOR 
	| ASSIGN_NOT 
	| ASSIGN_LEFT 
	| ASSIGN_RIGHT
        | ASSIGN_LEAST 
	| ASSIGN_BIGGER
	| ASSIGN_TILDA;

/*address_struct:
	'.'
	| ARROW;*/

declaration:
	for_declaration ';'; 

for_declaration:
	specificators for_declaration_one
	| for_declaration ',' for_declaration_one;

for_declaration_one:
	pointer one_decl
	| one_decl
	| pointer one_decl ASSIGN init
	| one_decl ASSIGN init
	| pointer one_decl ASSIGN '{' init '}'
	| one_decl ASSIGN '{' init '}';

init:
	expr_cond
	//| init ',' expr_cond
	//| init ','
	//| init ',' expr_cond
	| init ',' expr_cond
	| init ','; 

struct_union_enum_declaration:
	struct_union ';'
	| enum ';'
	| for_struct_union_enum_declaration ';';

for_struct_union_enum_declaration:
	struct_union one_decl
	| enum one_decl
	| for_struct_union_enum_declaration ',' one_decl;

struct_union:
	struct_union_type IDENTIFIER '{' for_struct_union '}'
	| struct_union_type '{' for_struct_union '}';

struct_union_type:
	STRUCT
	| UNION; 

for_struct_union:
	for_declaration ';'
	| for_struct_union for_declaration ';';

enum:
	ENUM IDENTIFIER '{' for_enum '}' 
	| ENUM '{' for_enum '}';

for_enum:
	one_enum
	| for_enum ',' one_enum;

one_enum:
	IDENTIFIER {printf("//identifier in one_enum ");}
	| IDENTIFIER '=' expr_cond {printf("//identifier in one_enum with '=' ");}
;

constant:
	float_const
	| int_const
	| enum_const
	| symbol_const
	| BOOL_CONST;

float_const:                                   
	REAL; 

int_const:
	DECIMAL
	| BINARY
	| OCTAL
	| HEX;

enum_const:                            //константа перечисления
	IDENTIFIER {printf("//identifier in enum ");};

symbol_const:                          //символьная константа   
	CHAR_CONST;


%%

FILE* yyin = NULL;

int for_keyword(char* keyword)
{
        if (!strcmp(keyword, "volatile")) return 1;
	else if (!strcmp(keyword, "register")) return 2;
	else if (!strcmp(keyword, "continue")) return 3;
	else if (!strcmp(keyword, "typedef")) return 4;
	else if (!strcmp(keyword, "default")) return 5;
	else if (!strcmp(keyword, "double")) return 6;
	else if (!strcmp(keyword, "size_t")) return 7;
	else if (!strcmp(keyword, "struct")) return 8;
	else if (!strcmp(keyword, "extern")) return 9;
	else if (!strcmp(keyword, "static")) return 10;
	else if (!strcmp(keyword, "switch")) return 11;
	else if (!strcmp(keyword, "return")) return 12;
	else if (!strcmp(keyword, "sizeof")) return 13;
	else if (!strcmp(keyword, "switch")) return 14;
	else if (!strcmp(keyword, "float")) return 15;
	else if (!strcmp(keyword, "union")) return 16;
	else if (!strcmp(keyword, "const")) return 17;
	else if (!strcmp(keyword, "while")) return 18;
	else if (!strcmp(keyword, "break")) return 19;
	else if (!strcmp(keyword, "empty")) return 20;
	else if (!strcmp(keyword, "false")) return 21;
	else if (!strcmp(keyword, "char")) return 22;
	else if (!strcmp(keyword, "void")) return 23;
	else if (!strcmp(keyword, "bool")) return 24;
	else if (!strcmp(keyword, "enum")) return 25;
	else if (!strcmp(keyword, "auto")) return 26;
	else if (!strcmp(keyword, "else")) return 27;
	else if (!strcmp(keyword, "case")) return 28;
	else if (!strcmp(keyword, "goto")) return 29;
	else if (!strcmp(keyword, "true")) return 30;
	else if (!strcmp(keyword, "int")) return 31;
	else if (!strcmp(keyword, "for")) return 32;
	else if (!strcmp(keyword, "if")) return 33;
	else if (!strcmp(keyword, "do")) return 34;
	else if (!strcmp(keyword, "typedef")) return 35;
	else if (!strcmp(keyword, "unsigned")) return 36;
	else if (!strcmp(keyword, "signed")) return 37;
	else if (!strcmp(keyword, "short")) return 38;
	else if (!strcmp(keyword, "long")) return 39;
	else return 0;
}

int for_directive(char* directive)
{
        if (!strcmp(directive, "include")) return 1;
	else if (!strcmp(directive, "define")) return 2;
	else if (!strcmp(directive, "pragma")) return 3;
	else if (!strcmp(directive, "ifndef")) return 4;
	else if (!strcmp(directive, "undef")) return 5;
	else if (!strcmp(directive, "error")) return 6;
	else if (!strcmp(directive, "ifdef")) return 7;
	else if (!strcmp(directive, "endif")) return 8;
	else if (!strcmp(directive, "line")) return 9;
	else if (!strcmp(directive, "elif")) return 10;
	else if (!strcmp(directive, "else")) return 11;
	else if (!strcmp(directive, "if")) return 12;
	else return 0;
}

int isbinary(char sym)
{
    	if (sym == '0'|| sym == '1') 
		return 1;
	else return 0;
}

int isoctal(char sym)
{
       if (sym >= '0' && sym <= '7') 
		return 1;
	else return 0;
}

int ishex(char sym)
{       
        if (isdigit(sym) || (sym >= 'a' && sym <= 'f') || (sym >= 'A' && sym <= 'F')) 
		return 1;
	else return 0;
}

int digit_yyin(char sym)
{       
	if (sym == '0') 
	{      
		sym = fgetc(yyin);
		if (isoctal(sym)) //8я
		{      
			while (isoctal(sym))
			{
				sym = fgetc(yyin);
			} 
			ungetc(sym, yyin);
			return 8;
		}
		else if (sym == 'b' || sym == 'B') //2я
		{       
			sym = fgetc(yyin);
			if (!isbinary(sym))
				yyerror("incorrect binary number");
			while (isbinary(sym))
			{ 
				sym = fgetc(yyin);
				printf("sym: %c", sym);
			}
			ungetc(sym, yyin);
			return 2;
		}
		else if (sym == 'x' || sym == 'X') //16я
		{       
			sym = fgetc(yyin);	
			if (!ishex(sym))
			yyerror("incorrect hex number");
			while (ishex(sym))
				sym = fgetc(yyin);
			ungetc(sym, yyin);
			return 16;
		}
		else if (sym == '.')
		{
		        sym = fgetc(yyin);
			if (!isdigit(sym)) //yyerror("incorrect real number");
			{
				ungetc(sym, yyin);
				return 1; //REAL
			}
			else
			{
				while(isdigit(sym))
					sym = fgetc(yyin);
				if (sym == 'e' || sym == 'E')
				{
					sym = fgetc(yyin);
					if (sym == '+' || sym == '-') sym = fgetc(yyin);
					if (!isdigit(sym)) yyerror("incorrect real number");
					else
					{
						while(isdigit(sym))
							sym = fgetc(yyin);
						ungetc(sym, yyin);
						return 1; //REAL
					}
				}
				else 
				{
					ungetc(sym, yyin);
					return 1;
				}	
			}
		}
		else if (isdigit(sym)) 
			yyerror("incorrect number (must be binary or octal or hex number system)"); 
		else 
		{
			ungetc(sym, yyin); 
			return 10;
		}      	       
	}
	else
	{
		int exp = 0;
		while(isdigit(sym) || sym == 'e' || sym == 'E')
			sym = fgetc(yyin);
		if (sym == 'e' || sym == 'E') 
		{
			if (exp) yyerror("incorrect real number");
			else exp = 1;
		}               
		if (sym == '.') //смотрим real с целой частью
		{
			sym = fgetc(yyin);
			if (!isdigit(sym)) yyerror("incorrect real number");
			else
			{
				while(isdigit(sym))
					sym = fgetc(yyin);
				if (sym == 'e' || sym == 'E') 
				{
					if (exp) yyerror("incorrect real number");
					sym = fgetc(yyin);
					if (sym == '+' || sym == '-') sym = fgetc(yyin);
					if (!isdigit(sym)) yyerror("incorrect real number");
					else
					{
						while(isdigit(sym))
							sym = fgetc(yyin);
						ungetc(sym, yyin);
						return 1; //REAL
					}
				}
				else 
				{
					ungetc(sym, yyin);
					return 1;
				}	
			}	
		}
		else
		{
			ungetc(sym, yyin);
			return 10;
		}
	}	
				
}

int ifdigit(char sym)
{
	if (sym >= '0' && sym <= '9')
		return 1;
	else return 0;
}

int yylex()
{
	int i = 0;
       	char sym = fgetc(yyin);
	if (!error && sym != EOF && sym != ' ' && sym != '\n' && sym != '\t' && sym != '\r') error = 1;
	printf("sym: %c!", sym);
	if (sym == EOF) printf("\nerror: %d", error);
	while (sym != EOF)
	{
		//printf("sym: %c, ", sym);
		if (sym == '#')
		{
			char directive[50];
			int k = 0;
			sym = fgetc(yyin);
			if (islower(sym)) //ищем директивы препроцессора
			{
				directive[0] = sym;
				k++;
				sym = fgetc(yyin);
				while (islower(sym))
				{
					directive[k] = sym;
					k++;
					sym = fgetc(yyin);				
				}
				ungetc(sym, yyin);
				directive[k] = '\0';
				int dir = for_directive(directive);
				
				if (dir == 1) {printf("include"); begin_preproc = 1; include_fl = 1; return INCLUDE;}
				else if (dir == 2) {printf("define"); begin_preproc = 1; define_fl = 1; return DEFINE;}
				else if (dir == 3) {printf("pragma"); begin_preproc = 1; pragma_fl = 1; return PRAGMA;}
				else if (dir == 4) {printf("ifndef"); begin_preproc = 1; return IFNDEF;}
				else if (dir == 5) {printf("undef"); begin_preproc = 1; return UNDEF;}
				else if (dir == 6) {printf("error"); begin_preproc = 1; return ERROR;}
				else if (dir == 7) {printf("ifdef"); begin_preproc = 1; return IFDEF;}
				else if (dir == 8) {printf("endif"); begin_preproc = 1; return ENDIF;}
				else if (dir == 9) {printf("line"); begin_preproc = 1; return LINE;}
				else if (dir == 10) {printf("elif"); begin_preproc = 1; return ELIF;}
				else if (dir == 11) {printf("else"); begin_preproc = 1; return ELSE_PP;}
				else if (dir == 12) {printf("if"); begin_preproc = 1; return IF_PP;}
				
				else if (dir == 0) 
				{ 
					yyerror("incorrect preprocessor directive");
				}
			}
			else yyerror("incorrect preprocessor directive");		
		}
		if (islower(sym) || isupper(sym) || isdigit(sym) || sym == '_') 
		{
			char keyword[50];
			int k = 0;
			if (islower(sym)) //ищем ключевые слова
			{
				//printf("dostalo vse x2\n");
				keyword[0] = sym;
				k++;
				sym = fgetc(yyin);
				printf("%c!", sym);
				if (!islower(sym) && !isupper(sym) && !isdigit(sym) && sym!='_')
				{      //printf("dostalo vse x3\n");
					ungetc(sym, yyin);
					printf("//identifier ");
					return IDENTIFIER;
				}
				/*sym = fgetc(yyin);
				printf("%c,", sym)*/
				while (islower(sym) || sym == '_')
				{
					keyword[k] = sym;
					k++;
					sym = fgetc(yyin);
					printf("%c!", sym);				
				}
				if (isupper(sym) || islower(sym) || sym == '_' || isdigit(sym))
				{
					while (isdigit(sym) || isupper(sym) || islower(sym) || sym == '_') 
						sym = fgetc(yyin);
					ungetc(sym, yyin);  
					return IDENTIFIER;
				}
				else ungetc(sym, yyin);
				keyword[k] = '\0';
				int k_w = for_keyword(keyword);
				printf("k_w = %d ",k_w);
				if (k_w == 0) 
				{
					sym = fgetc(yyin); 
					printf("%c!", sym);
					if (!islower(sym) && !isupper(sym) && !isdigit(sym) && sym != '_')
					{      printf("dostalo vse x3\n");
						ungetc(sym, yyin);
						printf("//identifier ");
						return IDENTIFIER;
					}
					while(islower(sym) || isupper(sym) || isdigit(sym) || sym == '_')
					{	
						sym = fgetc(yyin);
						printf("%c!", sym);
					}
					ungetc(sym, yyin);
					//printf("//identifier ");
					return IDENTIFIER; 
				}
				else
				{
					if (k_w == 1) return VOLATILE;
					else if (k_w == 2) return REGISTER;
					else if (k_w == 3) return CONTINUE;
					//else if (k_w == 4) return TYPEDEF;
					else if (k_w == 5) {default_fl[switch_num]++; return DEFAULT;}
					else if (k_w == 6) return DOUBLE;
					else if (k_w == 7) return SIZE_T;
					else if (k_w == 8) return STRUCT;
					else if (k_w == 9) return EXTERN;
					else if (k_w == 10) return STATIC;
					else if (k_w == 11) {if (switch_num == 0) {switch_num++; switch_fl[switch_num] = 1; return SWITCH;} else if (case_fl == 1) {switch_num++; switch_fl[switch_num] = 1; return SWITCH;} else yyerror ("incorrect_switch");}
					else if (k_w == 12) return RETURN;
					else if (k_w == 13) return SIZEOF;
					else if (k_w == 14) return SWITCH;
					else if (k_w == 15) return FLOAT;
					else if (k_w == 16) return UNION;
					else if (k_w == 17) return CONST;
					else if (k_w == 18) {printf("return WHILE\n"); return WHILE;}
					else if (k_w == 19) return BREAK;
					//else if (k_w == 20) return EMPTY;
					else if (k_w == 21) return BOOL_CONST;
					else if (k_w == 22) return CHAR;
					else if (k_w == 23) return VOID;
					else if (k_w == 24) {printf("bool"); return BOOL;}
					else if (k_w == 25) return ENUM;
					else if (k_w == 26) return AUTO;
					else if (k_w == 27) return ELSE;
					else if (k_w == 28) {case_fl = 1; return CASE;}
					else if (k_w == 29) return GOTO;
					else if (k_w == 30) return BOOL_CONST;
					else if (k_w == 31) return INT;
					else if (k_w == 32) {return FOR;}
					else if (k_w == 33) {printf("//if"); return IF;}
					else if (k_w == 34) {return DO;}
					else if (k_w == 35) return TYPEDEF;
					else if (k_w == 36) return UNSIGNED;
					else if (k_w == 37) return SIGNED;
					else if (k_w == 38) return SHORT;
					else if (k_w == 39) return LONG;
				}	
			}
			else if (ifdigit(sym)) //обработка числа
			{       
				int res = digit_yyin(sym);
				if (res == 2) 
				{
					sym = fgetc(yyin);
					if (sym == 'l' || sym == 'u' || sym == 'L' ||sym == 'U');
					else if (!islower(sym) || !isupper(sym)) ungetc(sym, yyin);
					else yyerror("incorrect binary number");
					printf("BINARY;");
			 		return BINARY;
				}
				else if (res == 1)
				{
					sym = fgetc(yyin);
					if (sym == 'l' || sym == 'f' || sym == 'L' ||sym == 'F');
					else if (!islower(sym) || !isupper(sym)) ungetc(sym, yyin);
					else yyerror("incorrect real number");
					return REAL;
				}
				else if (res == 8)
				{
					sym = fgetc(yyin);
					if (sym == 'l' || sym == 'u' || sym == 'L' ||sym == 'U');
					else if (!islower(sym) || !isupper(sym)) ungetc(sym, yyin);
					else yyerror("incorrect octal number");
			 		return OCTAL;
				}
				else if (res == 10) 
				{
					sym = fgetc(yyin);
					if (sym == 'l' || sym == 'u' || sym == 'L' ||sym == 'U');
					else if (!islower(sym) || !isupper(sym)) ungetc(sym, yyin);
					else yyerror("incorrect decimal number");
			 		return DECIMAL;
				}
				else if (res == 16)
				{
					sym = fgetc(yyin);
					if (sym == 'l' || sym == 'u' || sym == 'L' ||sym == 'U');
					else if (!islower(sym) || !isupper(sym)) ungetc(sym, yyin);
					else yyerror("incorrect hex number");
			 		return HEX;
				}			
			}
			else 
			{
				while (islower(sym) || isupper(sym) || isdigit(sym) || sym == '_')
				{
					sym = fgetc(yyin);	
				}
				ungetc(sym, yyin);
				printf("//identifier ");
				return IDENTIFIER;
			}		 
		}
		if (sym == '*')
		{
			sym = fgetc(yyin); 
			if (sym == '=')
				return ASSIGN_MULT;
			else
			{
				ungetc(sym, yyin);
				return MULT;
			}
		}
		if (sym == '/') 
		{	
			sym = fgetc(yyin);  
			if (sym == '/') 		
			{       //printf("comment");
				while (sym != '\n' && sym != EOF) 
		        	{	
					sym = fgetc(yyin); 
					//printf("sym: %c", sym);
				}
				if (sym == '\n') error_line++;
				sym = fgetc(yyin);
			}
			else if (sym == '*') 
			{       
				int comment_end = 0;
				do
				{
					sym = fgetc(yyin); 
					if (sym == EOF) yyerror("incorrect comment");
					else if (sym == '\n') error_line++;
					else if (sym == '*')
					{	
						sym = fgetc(yyin);
			                        if (sym == '/') comment_end = 1;
						else if (sym == EOF) yyerror("incorrect comment");
						else ungetc(sym, yyin);
					}
				}while(!comment_end);
				/*char new_sym = fgetc(yyin); cur_sym = new_sym;
				while ((sym != '*') && (new_sym != '/') && sym != EOF && new_sym != EOF)
				{
					if (sym == '\n') error_line++; 
					
		        		sym = new_sym;
					new_sym = fgetc(yyin); //printf("new_sym: %c", new_sym); 
					cur_sym = new_sym;
				}
				if ((sym == EOF) || (new_sym == EOF))
				{
					yyerror("incorrect comment");
				}
				sym = fgetc(yyin);*/
				sym = fgetc(yyin);		
			}
			else if (sym == '=') //*=
			{
				return ASSIGN_DIV;
			}
			else
			{
				ungetc(sym, yyin);
				return DIV;
			}	 	
		}
		if (sym == '%')
		{
			sym = fgetc(yyin);
			if (sym == '=')           
				return ASSIGN_MOD;
			else
			{
				ungetc(sym, yyin);
				return MULT;
			}
		}
		if (sym == '+') 
		{
			int sym = fgetc(yyin);
			if (sym == '+')
				return INCR;
			else if (sym == '=')
				return ASSIGN_ADD;		
			else 
			{
				ungetc(sym, yyin);
				return ADD;
			}
		}
		if (sym == '-') 
		{
			int sym = fgetc(yyin);
			if (sym == '-')
				return DECR;
			else if (sym == '=')
				return ASSIGN_SUBSTR;
			else if (sym == '>') 
				return ARROW;		
			else 
			{
				ungetc(sym, yyin);
				return SUBSTR;
			}
		}
		if (sym == '.')
		{
			sym = fgetc(yyin);
			if (!isdigit(sym)) 
			{
				ungetc(sym, yyin);
				//printf("here");
				return DOT;
			}
			else
			{
				while(isdigit(sym))
					sym = fgetc(yyin);
				if (sym == 'e' || sym == 'E')
				{
					sym = fgetc(yyin);
					if (sym == '+' || sym == '-') sym = fgetc(yyin);
					else sym = fgetc(yyin);
					if (!isdigit(sym)) yyerror("incorrect real number");
					else
					{
						while(isdigit(sym))
							sym = fgetc(yyin);
						ungetc(sym, yyin);
						{
							sym = fgetc(yyin);
							if (sym == 'l' || sym == 'f' || sym == 'L' ||sym == 'F');
							else if (!islower(sym) || !isupper(sym)) ungetc(sym, yyin);
							else yyerror("incorrect real number");
			 				return REAL;
						}
					}
				}
				else 
				{
					//sym = fgetc(yyin);
					if (sym == 'l' || sym == 'f' || sym == 'L' || sym == 'F');
					else if (!islower(sym) || !isupper(sym)) ungetc(sym, yyin);
					else yyerror("incorrect real number");//{ungetc(sym, yyin); printf("//its real"); return REAL;}
					printf("//its real");
					return REAL;
				}	
			}
		}
		if (sym == ':' || sym == ',' || sym == ';' || sym == '{' || sym == '}' || sym == '[' || sym == ']' || sym == '(' || sym == ')')
		{
			//printf("here");
			if (sym == ',' || sym == '(') printf("dostalo vse\n");
			return sym;
		}
		if (sym == '<')
		{
			//printf("include_fl = %d", include_fl);
			sym = fgetc(yyin); 
			if (sym == '>')
				yyerror("using <>");
			printf("incl_fl = %d;", include_fl);
			if (include_fl || pragma_fl)
			{
				while (sym != '>')
				{
					sym = fgetc(yyin);
					//printf("new_sym: %d\n", new_sym);
					if (sym == '\n' || sym == EOF)
					{
						yyerror("incorrect file path in #include");
					}	
				}
				//printf("file_path");
				return FILE_PATH;
			}
			if (sym == '<')
			{
				int new_sym = fgetc(yyin);
				if (new_sym == '=')
					return ASSIGN_LEFT;
				else
				{
					ungetc(new_sym, yyin);
					return LEFT;	
				}	
			}
			else if (sym == '=')
				return ASSIGN_LEAST;
			else
			{
				ungetc(sym, yyin);
				printf("least");
				return LEAST;
			}
		}
		if (sym == '>')
		{       printf("bigger!");
			int sym = fgetc(yyin);
			if (sym == '>')
			{
				int new_sym = fgetc(yyin);
				if (new_sym == '=')
					return ASSIGN_RIGHT;
				else
				{
					ungetc(new_sym, yyin);
					return RIGHT;	
				}	
			}
			else if (sym == '=')
				return ASSIGN_BIGGER;
			else
			{
				ungetc(sym, yyin);
				return BIGGER;
			}	
		}
		if (sym == '~')
		{
			sym = fgetc(yyin);
			if (sym == '=')
				return ASSIGN_TILDA;
			else
			{
				ungetc(sym, yyin);
				return TILDA;
			}	
		}
		if (sym == '&') 
		{
			int sym = fgetc(yyin); 
			if (sym == '=')
				return ASSIGN_AND;
			else if (sym == '&')
				return LOG_AND;
			else
			{
				ungetc(sym, yyin);
				return GRADE_AND;
			}	
		}
		if (sym == '|') 
		{
	        	sym = fgetc(yyin); 
			if (sym == '=')
				return ASSIGN_OR;
			else if (sym == '|')
				{printf("LOG_OR"); return LOG_OR;}
			else
			{
				ungetc(sym, yyin);
				return GRADE_OR;
			}
		}
		if (sym == '^') 
		{
			sym = fgetc(yyin); 
			if (sym == '=')
				return ASSIGN_XOR;
			else
			{
				ungetc(sym, yyin);
				return XOR;
			}
		} 
		if (sym == '!')
		{
			sym = fgetc(yyin); 
			if (sym == '=')
				return ASSIGN_NOT;
			else
			{
				ungetc(sym, yyin);
				return NOT;
			}
		}
		if (sym == '=')
		{
			sym = fgetc(yyin); 
			if (sym == '=')
				return IF_ASSIGN;
			else
			{
				ungetc(sym, yyin);
				printf("assign");
				return ASSIGN;
			}
		}
		if (sym == '\"') 
		{
			if (include_fl || pragma_fl)
			{
				sym = fgetc(yyin); 
				if (sym == '"')
				yyerror("incorrect file path in #include or #pragma");
				else
				{
					while (sym != '"')
					{
						sym = fgetc(yyin); 
						if ((sym == '\n') || (sym == EOF))
						{
							yyerror("incorrect file path in #include or #pragma");
						}
					}
					return FILE_PATH;
				}	
			}
			sym = fgetc(yyin);
			if (sym == '\"') return STRING; 
			while ((sym != '\"') && (sym != EOF) && (sym != '\n'))
			{
				sym = fgetc(yyin);
				printf("%c!", sym);
			}	
			if (sym == '\n' || sym == EOF)
			{
				yyerror("incorrect string");
			}
			else if (sym == '\"') 
			{      
				printf("STRING"); 
				return STRING;	
			}	
		}
		if (sym == 39) //char ('b')
		{
			sym = fgetc(yyin);
			if (sym == 39) return CHAR_CONST;
			if (sym == 92) //'\n'
			{
				sym = fgetc(yyin);
				if ((sym == '0') || (sym == 'a') || (sym == 'b') || (sym == 't') || 
					(sym == 'n') || (sym == 'v') || (sym == 'f') || (sym == 'r') || 
					(sym == '"') || (sym == 39) || (sym == 92))
				{
					sym = fgetc(yyin);
					if (sym == 39)
						return CHAR_CONST;
				}
				yyerror("incorrect char");	
			}
			else if (sym != '\n' && sym != EOF)
			{
                 		sym = fgetc(yyin); 
		        	if (sym != 39)
					yyerror("incorrect char");
				else return CHAR_CONST;
			}
			else yyerror("incorrect char");
		}
		if (sym == '\n')
		{
			error_line++;
			if (begin_preproc) return NEW_LINE;
			else sym = fgetc(yyin);
		}
		if (sym == ' ' || sym == '\t' || sym == '\r')
		{
			sym = fgetc(yyin);
			printf("%c!", sym); 
		}
		if (sym == '?') return QUESTION;
		if (sym == ':') return DOUBLE_DOT;
		//else {yyerror("incorrect_symbol");}
		
	}   
	if (sym == EOF) end_compiler();		
}


void yyerror(char* str)
{
	if (yylval == '\n') error_line--;
	printf("\nERROR: %s (line %d);\n", str, error_line);
	printf("\nIt's not C code.\n");
	exit(0);
}

void end_compiler()
{
	if (!error) 
		printf("\nIt's C code.\n");
	else 
		printf("\nIt's not C code.\n");
	exit(0);
}

int main(int argc, char* argv[])
{
	for (int i = 0; i < 100; i++) 
	{
		switch_fl[i] = 0;
		default_fl[i] = 0;
	}
	if (argc != 2)
	{
		printf("ERROR: number of arguments.\n");
		return;
	}
	yyin = fopen(argv[1], "r");

	if (yyin)
	{
	        yyparse();
	}
	else
	{
		printf("ERROR: opening file %s.\n", argv[1]);
	}
        fclose(yyin);
	return 0;
}
