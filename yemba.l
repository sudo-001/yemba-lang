%{
#include<stdio.h>
#include "simple.h"
%}

entier [0-9]+
operateur \+|\*|\=|\;|\=\=|\!\=|\<|\>
parenthese \(|\)
variable a|b|c|d

%%
{entier} { yylval=atoi(yytext); return INTEGER; }
{operateur} {
    if (strcmp(yytext, "==") == 0) return EQUALS;
    if (strcmp(yytext, "<") == 0) return LESS_THAN;
    if (strcmp(yytext, ">") == 0) return GREATHER_THAN;
    if (strcmp(yytext, "!=") == 0) return NOT_EQUALS;
    return *yytext;
}
{parenthese} {return *yytext; }
{variable} { yylval = *yytext; return VARIABLE; }
leti {return PRINT;}
yi {return SI;}
lɔ {return ALORS; }
lelʉ {return SINON; }
lemakyi {return FSI; }
letɔ̄ŋ {return READ; }
lijɛt {return WHILE; }
leghʉ {return DO; }
lemak {return DONE; }
ligʉe {return FOR; }
leko {return TO; }
[\n] ;
[ ] ;
[\t] ;
. {printf("Parse error (lex) + %s -\n", yytext); }

%%

/* flex -o yemba.yy.c yemba.l
gcc -pedantic -wall -02 yemba.yy.c -o yemba -lfl
Utilisation : echo "12+6*8" | ./yemba */