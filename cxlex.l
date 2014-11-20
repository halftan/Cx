%{
#include "stdio.h"
#include "string.h"
#include "malloc.h"
#include "cxyac.tab.h"
int yywrap(void);
int line=0;
void yyerror(char *);
void redirectInput(FILE *);
%}

%%
[ \t]	{;}
[\n]	{line++;}
"int"	{return SYM_int;}
"bool"	{return SYM_bool;}
"if"	{return SYM_if;}
"else"	{return SYM_else;}
"while"	{return SYM_while;}
"write"	{return SYM_write;}
"read"	{return SYM_read;}

"+"		{return SYM_plus;}
"-"		{return SYM_minus;}
"*"		{return SYM_times;}
"/"		{return SYM_slash;}
">"		{return SYM_gt;}
"<"		{return SYM_lt;}
"<="	{return SYM_lte;}
">="	{return SYM_gte;}
"=="	{return SYM_eql;}
"!="	{return SYM_neq;}
"="		{return SYM_become;}
"||"	{return SYM_or;}
"&&"	{return SYM_and;}
"!"		{return SYM_not;}
";"		{return SYM_semicolon;}
"("		{return SYM_lparen;}
")"		{return SYM_rparen;}
"{"		{return SYM_lbracket;}
"}"		{return SYM_rbracket;}
"/*"	{return SYM_lcomment;}
"*/"	{return SYM_rcomment;}

[A-Za-z]([A-Za-z]|[0-9])* {
	yylval.ident=(char *)malloc(strlen(yytext)+1);
	strcpy(yylval.ident,yytext);
	return SYM_ident;
}

[0-9]+ {
	yylval.number=atoi(yytext);
	return SYM_number;
}
.		{yyerror("unknown character");}
%%

void redirectInput(FILE *input){
	yyin=input;
	return;
}

int yywrap(void)
{
        return 1;
}