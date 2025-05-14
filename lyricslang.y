%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_VARIABLES 100

typedef struct {
    char* name;
    int value;
    int is_defined;
} Variable;

Variable symbolTable[MAX_VARIABLES];
int variableCount = 0;
int labelCount = 0;

FILE *tacFile;
FILE *asmFile;

extern FILE *yyin;
int yylex();
void yyerror(const char *s);

int getVariableValue(char *name);
void setVariable(char *name, int value);
int isVariableDefined(char *name);
%}

%union {
    int intval;
    char* strval;
}

%token <strval> IDENTIFIER STRING
%token <intval> NUMBER
%token SAY SET IFY NOPE DONE GT LT EQ PLUS MINUS MULT DIV OP CP OB CB ASK DO SEMICOLON CALL

%type <intval> expression
%type <strval> string

%left GT LT EQ
%left PLUS MINUS
%left MULT DIV

%%

program:
    statement_list
;

statement_list:
    statement
    | statement_list statement
;

statement:
      SAY expression SEMICOLON      { printf("%d\n", $2); if (tacFile) fprintf(tacFile, "print %d\n", $2); if (asmFile) fprintf(asmFile, "PRINT %d\n", $2); }
    | SAY string SEMICOLON         { printf("%s\n", $2); if (tacFile) fprintf(tacFile, "print %s\n", $2); if (asmFile) fprintf(asmFile, "PRINT %s\n", $2); }
    | SET IDENTIFIER expression SEMICOLON { setVariable($2, $3); }
    | IFY expression OB statement_list DONE { 
          if (tacFile) fprintf(tacFile, "if %d goto L%d\n", $2, ++labelCount);
          if (asmFile) fprintf(asmFile, "CMP %d, 0\nJNE L%d\n", $2, ++labelCount);
      }
    | IFY expression OB statement_list NOPE statement_list DONE { 
          if (tacFile) fprintf(tacFile, "if %d goto L%d\nelse goto L%d\n", $2, ++labelCount, ++labelCount);
          if (asmFile) fprintf(asmFile, "CMP %d, 0\nJNE L%d\nJMP L%d\n", $2, ++labelCount, ++labelCount);
      }
    | DO IDENTIFIER OP CP OB statement_list DONE { 
          if (tacFile) fprintf(tacFile, "func %s\n", $2); 
          if (asmFile) fprintf(asmFile, "FUNC %s\n", $2); 
      }
    | CALL IDENTIFIER SEMICOLON    { if (tacFile) fprintf(tacFile, "call %s\n", $2); if (asmFile) fprintf(asmFile, "CALL %s\n", $2); }
    | ASK IDENTIFIER SEMICOLON     { if (tacFile) fprintf(tacFile, "input %s\n", $2); if (asmFile) fprintf(asmFile, "INPUT %s\n", $2); }
;

expression:
      expression PLUS expression   { $$ = $1 + $3; if (tacFile) fprintf(tacFile, "t = %d + %d\n", $1, $3); if (asmFile) fprintf(asmFile, "ADD %d, %d\n", $1, $3); }
    | expression MINUS expression  { $$ = $1 - $3; if (tacFile) fprintf(tacFile, "t = %d - %d\n", $1, $3); if (asmFile) fprintf(asmFile, "SUB %d, %d\n", $1, $3); }
    | expression MULT expression   { $$ = $1 * $3; if (tacFile) fprintf(tacFile, "t = %d * %d\n", $1, $3); if (asmFile) fprintf(asmFile, "MUL %d, %d\n", $1, $3); }
    | expression DIV expression    { if ($3 == 0) { yyerror("Division by zero"); $$ = 0; } else { $$ = $1 / $3; if (tacFile) fprintf(tacFile, "t = %d / %d\n", $1, $3); if (asmFile) fprintf(asmFile, "DIV %d, %d\n", $1, $3); }}
    | expression GT expression     { $$ = $1 > $3; if (tacFile) fprintf(tacFile, "t = %d > %d\n", $1, $3); if (asmFile) fprintf(asmFile, "CMP %d, %d\nSETG t\n", $1, $3); }
    | expression LT expression     { $$ = $1 < $3; if (tacFile) fprintf(tacFile, "t = %d < %d\n", $1, $3); if (asmFile) fprintf(asmFile, "CMP %d, %d\nSETL t\n", $1, $3); }
    | expression EQ expression     { $$ = $1 == $3; if (tacFile) fprintf(tacFile, "t = %d == %d\n", $1, $3); if (asmFile) fprintf(asmFile, "CMP %d, %d\nSETE t\n", $1, $3); }
    | IDENTIFIER                   { if (!isVariableDefined($1)) { yyerror("Undefined variable"); $$ = 0; } else { $$ = getVariableValue($1); } }
    | NUMBER                       { $$ = $1; }
    | OP expression CP             { $$ = $2; }
;

string:
      STRING                        { $$ = $1; }
;

%%

int getVariableValue(char *name) {
    for (int i = 0; i < variableCount; i++) {
        if (strcmp(symbolTable[i].name, name) == 0) {
            return symbolTable[i].value;
        }
    }
    return 0;
}

int isVariableDefined(char *name) {
    for (int i = 0; i < variableCount; i++) {
        if (strcmp(symbolTable[i].name, name) == 0) {
            return symbolTable[i].is_defined;
        }
    }
    return 0;
}

void setVariable(char *name, int value) {
    for (int i = 0; i < variableCount; i++) {
        if (strcmp(symbolTable[i].name, name) == 0) {
            symbolTable[i].value = value;
            symbolTable[i].is_defined = 1;
            if (tacFile) fprintf(tacFile, "%s = %d\n", name, value);
            if (asmFile) fprintf(asmFile, "MOV %s, %d\n", name, value);
            return;
        }
    }
    if (variableCount < MAX_VARIABLES) {
        symbolTable[variableCount].name = strdup(name);
        symbolTable[variableCount].value = value;
        symbolTable[variableCount].is_defined = 1;
        if (tacFile) fprintf(tacFile, "%s = %d\n", name, value);
        if (asmFile) fprintf(asmFile, "MOV %s, %d\n", name, value);
        variableCount++;
    }
}

void yyerror(const char *s) {
    /* Silent error handling */
}

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            return 1;
        }
        yyin = file;
    } else {
        yyin = stdin;
    }

    tacFile = fopen("output.tac", "w");
    if (!tacFile) {
        return 1;
    }

    asmFile = fopen("output.asm", "w");
    if (!asmFile) {
        fclose(tacFile);
        return 1;
    }

    yyparse();

    fclose(tacFile);
    fclose(asmFile);
    if (yyin != stdin) {
        fclose(yyin);
    }
    return 0;
}