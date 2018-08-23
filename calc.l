%{
	#include <stdio.h>
	#include "calc.tab.h"
%}

%option yylineno

digit	([0-9])
Id      [a-z][a-zA-Z0-9]*
WId		[A-Z0-9][a-zA-Z0-9]*

%%

"print"	{return TOK_PRINT;}

"main"  { return TOK_MAIN; }

"float" {return TOK_FLOAT; };

";"	{	return TOK_SEMICOLON;	}

"-"	{	return TOK_SUB;	}

"*"	{	return TOK_MUL;	} 

"{" {   return TOK_LEFTFLOWERBRACE;  }

"}" {   return TOK_RIGHTFLOWERBRACE; } 

"(" {	return TOK_LEFTROUNDBRACE; }

")" { 	return TOK_RIGHTROUNDBRACE;}

"=" { 	return TOK_EQUALTO;	}


[ \n] 	{  yylineno++; }

[\t \r]+ { }
	
{digit}+\.{digit}+  {
	sscanf(yytext, "%f", &(yylval.float_val));
	return TOK_FLOATNUM;
	}

{Id}+ 	{
		strcpy(yylval.id.variable_name, yytext);
		yylval.id.variable_value=-1.0;
		yylval.id.is_initialized=0;
		yylval.id.deletion_flag=0;
		return TOK_IDENTIFIER;
        }

{WId}+ {
			fprintf(stderr, "Lexical analysis error: %s\n", yytext);
			exit(1);
		}
        
.	{
		fprintf(stderr, "Lexical analysis error: %s\n", yytext);
		exit(1);
	}

%%

int yyerror(char *s)
{
    fprintf(stderr, "Parsing error: line %d\n", yylineno);
    return 0;
}


