%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int compteurSi = 0, compteurTest = 0, compteurWhile = 0, compteurFor = 0;
extern FILE *yyout;

char *header="extern printf, scanf \nsection .data\n; declaration des variables en memoire\na: dd 0\nb: dd 0\nc: dd 0\nd: dd 0\nfmt:db \"%d\", 10, 0 \nfmtlec:db \"%d\", 0\nsection .text\nglobal_start\n\n_start:\n\n";
char *trailer="mov eax,1 ; sys_exit \nmov ebx,0; Exit with return code of 0 (no error)\nint 80h";
char *add=" ; addition\npop eax\npop ebx\nadd eax,ebx\npush eax\n\n";
char *mul=" ;multiplication\npop eax\npop ebx\nmul ebx\npush eax\n\n";
char *affec=" ;affectation\npop eax\nmov";
char *take=" ;recuperation en memoire\nmov eax,";
char *affec1=";affectation\n";
char *afficher1=";afficher\nmov eax,";
char *afficher2="\npush eax\npush dword fmt\ncall printf\n\n";
char *lire1=";lire\npush ";
char *lire2="\npush dword fmtlec\ncall scanf\n\n";
char *cmp="pop ebx\npop eax\ncmp eax, ebx\n\n";
char *cmpEgal;
char *testGene;
char *cmpDifferent;
char *cmpSuperieur;
char *cmpInferieur;
char *tmp1,*tmp2;
int sinonVu=0;

int yyerror(char *s);
int yylex(void);


%}

%token INTEGER
%token PRINT
%token VARIABLE
%token SI
%token ALORS
%token SINON
%token FSI
%token FSIN
%token READ
%token WHILE
%token DONE
%token DO
%token FOR
%token TO
%token EQUALS
%token LESS_THAN
%token GREATHER_THAN
%token NOT_EQUALS

%%
program:
    program_body {printf("Aucune erreur de syntaxe detectee\n\n"); }

program_body:
    stat
    |stat program_body

stat:
    bloc
    |blocSi
    |blocWhile
    |blocFor

bloc:
    instr ';'
    |instr ';' bloc

instr:
    VARIABLE '=' E {fprintf(yyout,"%s [%c], eax\n\n", affec, $1); }
    | PRINT VARIABLE {fprintf(yyout,"%s [%c] %s", afficher1, $2, afficher2);}
    | READ VARIABLE {fprintf(yyout,"%s %c %s", lire1, $2, lire2);}
    | VARIABLE '=' cond {fprintf(yyout,"%s [%c], eax\n\n", affec, $1); }

blocWhile:
    WHILE etiquetWhile exp_bool LOOP blocIntWhile ENDWHILE {fprintf(yyout,";************ **** ****Reduction du bloc while\n");}

blocIntWhile:
    bloc
    |blocSi
    |blocSi blocIntWhile
    |bloc blocIntWhile

etiquetWhile:
    {
        compteurWhile++;
        fprintf(yyout,";********Lieu de l'etiquete while\n");
        fprintf(yyout,"debutWhile%d:\n", compteurWhile);
    }

LOOP:
    DO {fprintf(yyout,";************ **** ****Reduction du do\n");}

exp_bool:
    cond {
        fprintf(yyout,";************ **** ****Reduction de la condition\n");
        fprintf(yyout,"pop eax\ncmp eax,1\njne finWhile%d\n", compteurWhile);
    }

ENDWHILE:
    DONE {
        fprintf(yyout,";************ **** ****Reduction du done\n");
        fprintf(yyout,"jmp debutWhile%d\nfinWhile%d:\n", compteurWhile, compteurWhile);
    }

blocSi:
    SI cond alo bloc finSi
    | SI cond alo bloc sino bloc finSi {fprintf(yyout,";Condition detectee 2\n");}

finSi:
    FSI {
        if(sinonVu) {
            fprintf(yyout,"suite%d:\n", compteurSi);
            fprintf(yyout,";Reduction du fsis%d\n", compteurSi);
            sinonVu=0;
        } else {
            fprintf(yyout,"sinon%d:\n", compteurSi);
            fprintf(yyout,";Reduction du fsi%d\n", compteurSi);
        }
    }


alo:
    ALORS {
        compteurSi++;
        fprintf(yyout,";Reduction du alors%d\n", compteurSi);
        fprintf(yyout,"pop eax\ncmp eax,1\njne sinon%d\n", compteurSi);
    }

sino:
    SINON {
        fprintf(yyout,"jmp suite%d\nsinon%d:\n", compteurSi, compteurSi);
        fprintf(yyout,";Reduction du sinon%d\n", compteurSi);
        sinonVu=1;
    }

cond:
    '(' F EQUALS F ')' {
        compteurTest++;
        cmpEgal = ";Teste d'égalité\n";			
        fprintf(yyout,"%s%sjne test%d\npush 1\njmp fintest%d \ntest%d:\npush 0\nfintest%d:\n\n\n",cmpEgal,cmp,compteurTest,compteurTest,compteurTest,compteurTest);  
    }		      
    | '(' F NOT_EQUALS F ')' {
        compteurTest++;
        cmpDifferent=";Teste de différence\n";			
        fprintf(yyout,"%s%sjne test%d\npush 0\njmp fintest%d \ntest%d:\npush 1\nfintest%d:\n\n\n",cmpDifferent,cmp,compteurTest,compteurTest,compteurTest,compteurTest);
    }		      
    | '(' F LESS_THAN F ')'  {
        compteurTest++;
        cmpInferieur=";Teste d'infériorité\n";
        fprintf(yyout,"%s%sjge test%d\npush 1\njmp fintest%d \ntest%d:\npush 0\nfintest%d:\n\n\n",cmpInferieur,cmp,compteurTest,compteurTest,compteurTest,compteurTest);		       	      
    }
    | '(' F GREATHER_THAN F ')'  {
        compteurTest++;
        cmpSuperieur=";Teste de superiorité\n";		       		       
        fprintf(yyout,"%s%sjg test%d\npush 0\njmp fintest%d \ntest%d:\npush 1\nfintest%d:\n\n\n",cmpSuperieur,cmp,compteurTest,compteurTest,compteurTest,compteurTest);
    }

E:
   T;
   | E '+' T { fprintf(yyout,"%s ",add); }


T:
   F ;
   | T '*' F { fprintf(yyout,"%s ",mul); }

F:  
    INTEGER { fprintf(yyout,"push %d\n",$1);}
    | VARIABLE  { fprintf(yyout,"%s [%c] \npush eax\n",take,$1);}   

blocFor:
    FOR VARIABLE '=' E TO E DO blocIntFor DONE {
        fprintf(yyout, ";*************** ***** ****Reduction du bloc for\n");
        fprintf(yyout, "mov eax, [%c]\n", $2); // Initialisation de la variable de boucle
        fprintf(yyout, "mov ecx, %d\n", $5);  // Valeur de fin de la boucle
        fprintf(yyout, "for_start_%d:\n", compteurFor);
        fprintf(yyout, "cmp eax, ecx\n");
        fprintf(yyout, "jg for_end_%d\n", compteurFor); // Sortie de la boucle si condition vraie
        fprintf(yyout, "; Instructions du corps de la boucle for\n");
        fprintf(yyout, "inc eax\n"); // Incrémentation de la variable de boucle
        fprintf(yyout, "jmp for_start_%d\n", compteurFor); // Retour au début de la boucle
        fprintf(yyout, "for_end_%d:\n", compteurFor); // Étiquette de fin de boucle
        compteurFor++;
    }

blocIntFor:
    bloc
    |bloc blocIntFor
    |blocSi blocIntFor
    |blocWhile blocIntFor
    |blocFor blocIntFor

%%

int main(void)
{
    yyout = fopen("yemba.asm", "w");
    fprintf(yyout, "%s", header);

    yyparse();

    fprintf(yyout, "%s", trailer);
    fclose(yyout);
    return 0;
}

int yyerror(char *str)
{
    printf("Error parsing %s\n", str);
    return 0;
}