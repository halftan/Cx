%{
#include "code.h"
#include "malloc.h"
#include "stdio.h"

%}

%union{
char *ident;
int number;
}

%token SYM_int SYM_bool
%token SYM_if SYM_else
%token SYM_while
%token SYM_write SYM_read
%token SYM_plus SYM_minus
%token SYM_times SYM_slash
%token SYM_lparen SYM_rparen
%token SYM_lbracket SYM_rbracket
%token SYM_lcomment SYM_rcomment
%token SYM_gt SYM_lt SYM_gte SYM_lte
%token SYM_eql SYM_neq SYM_become 
%token SYM_or SYM_and SYM_not SYM_semicolon
%token SYM_true SYM_false

%token <ID> SYM_ident
%token <NUM> SYM_number

%%

//	rules section

program:
	{lev--;}
	block
	;

block:
	{
		lev++;
		dx=3;
		levelReg[lev].tx0=tx;
		table[tx].adr=cx;
		gen(jmp,0,1);
		if(lev>LEVMAX)
			error(32);
	}
	SYM_lbracket
	decls{
		code[table[levelReg[lev].tx0].adr].a=cx;
		table[levelReg[lev].tx0].adr=cx;
		table[levelReg[lev].tx0].size=dx;
		levelReg[lev].cx0=cx;
		gen(ini,0,dx);
	}
	stmts{
		gen(opr,0,0);
		printf("\n");
	}
	SYM_rbracket
	;

decls:
	|decls decl
	;

decl:SYM_int aid SYM_semicolon
	|SYM_bool bid SYM_semicolon
	;

aid:SYM_ident{
	int i;
	strcpy(id,$1);
	i=position(id);
	if(i==0){
		error(0);
	}else{
		if(table[i].kind!=variable){
			error(12);
			i=0;
			}
		}
		$<number>$=i;
	}
	;

bid:SYM_ident{
	int i;
	strcpy(id,$1);
	i=position(id);
	if(i==0){
		error(0);
	}else{
		if(table[i].kind!=variable){
			error(12);
			i=0;
			}
		}
		$<number>$=i;
	}
	;

stmts:
	|stmts stmt
	;

stmt:
	aid SYM_become aexpr{
		int i;
		if($<number>2!=0){
			i=$<number>2;
			gen(sto,lev-table[i].level,table[i].adr);
		}
	}
	SYM_semicolon
	|bid SYM_become bexpr{
		int i;
		if($<number>2!=0){
			i=$<number>2;
			gen(sto,lev-table[i].level,table[i].adr);
		}
	}
	SYM_semicolon
	|SYM_if SYM_lparen bexpr SYM_rparen stmt SYM_semicolon
	|SYM_if SYM_lparen bexpr SYM_rparen stmt SYM_else stmt SYM_semicolon
	|SYM_while SYM_lparen bexpr SYM_rparen stmt SYM_semicolon
	|SYM_write aexpr SYM_semicolon{gen(opr,0,17);}
	|SYM_read aid SYM_semicolon{gen(opr,0,18);}
	|block
	;

aexpr:aterm SYM_plus aterm{gen(opr,0,2);}
	|aterm SYM_minus aterm{gen(opr,0,3);}
	|aterm
	;

aterm:afactor SYM_times afactor{gen(opr,0,4);}
	|afactor SYM_slash afactor{gen(opr,0,5);}
	|afactor
	;

afactor:aid
	|SYM_number{
		int num;
		num=$1;
		if(num>AMAX){
			error(31);
			num=0;
			}
		gen(lit,0,num);
	}
	|SYM_lparen aexpr SYM_rparen
	;

bexpr:
	bexpr SYM_or bterm{gen(opr,0,16);}
	|bterm
	;

bterm:bterm SYM_and bfactor{gen(opr,0,15);}
	|bfactor
	;

bfactor:bid
	|SYM_true
	|SYM_false
	|SYM_not bfactor{gen(opr,0,14);}
	|SYM_lparen bexpr SYM_rparen
	|rel
	;

rel:aexpr SYM_lt aexpr{gen(opr,0,10);}
	|aexpr SYM_lte aexpr{gen(opr,0,13);}
	|aexpr SYM_gt aexpr{gen(opr,0,12);}
	|aexpr SYM_gte aexpr{gen(opr,0,11);}
	|aexpr SYM_eql aexpr{gen(opr,0,8);}
	|aexpr SYM_neq aexpr{gen(opr,0,9);}
	;

%%

/////////////////////////////////////////////////////////////////////////////
// programs section
void yyerror(const char *s)
{
}
int main()
{
    if((fa1=fopen("./fa1.txt","w"))==NULL){
		printf("Cann't open file!\n");
		exit(0);
	}
	
	printf("Input file?\n");
	fprintf(fa1,"Input file?\n");
	scanf("%s",fname);
	fprintf(fa1,"%s",fname);
	if((fin=fopen(fname,"r"))==NULL){
		printf("Cann't open file according to given filename\n");
		exit(0);
	}
	redirectInput(fin);
	printf("List object code?[y/n]");
	scanf("%s",fname);
	fprintf(fa1,"\nList object code?\n");
	if(fname[0]=='y')
		listswitch=true;
	else
		listswitch=false;
	err=0;
	cx=0;
	if((fa=fopen("./fa.txt","w"))==NULL){
		printf("Cann't open fa.txt file!\n");
		exit(0);
	}
	if((fa2=fopen("./fa2.txt","w"))==NULL){
		printf("Cann't open fa2.txt file!\n");
		exit(0);
	}
	yyparse();
	fclose(fa);
	fclose(fa1);
	if(err==0)
		{
		listcode();
		interpret();
		}
	else
		printf("%d errors in this program\n",err);
	fclose(fin);
	getchar();
    return 0;
}