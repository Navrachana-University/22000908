%{
#include <stdio.h>
#include <string.h>
#include "lyricslang.tab.h"
%}

%option noyywrap

%%
"SET"           { return SET; }
"SAY"           { return SAY; }
"IFY"           { return IFY; }
"NOPE"          { return NOPE; }
"DONE"          { return DONE; }
"DO"            { return DO; }
"ASK"           { return ASK; }
"CALL"          { return CALL; }
"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return MULT; }
"/"             { return DIV; }
"("             { return OP; }
")"             { return CP; }
"{"             { return OB; }
"}"             { return CB; }
">"             { return GT; }
"<"             { return LT; }
"=="            { return EQ; }
";"             { return SEMICOLON; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.strval = strdup(yytext); return IDENTIFIER; }
[0-9]+          { yylval.intval = atoi(yytext); return NUMBER; }
\"[^\"]*\"      { 
    size_t len = strlen(yytext) - 2; 
    yylval.strval = malloc(len + 1); 
    strncpy(yylval.strval, yytext + 1, len); 
    yylval.strval[len] = '\0'; 
    return STRING; 
}
[ \t\n]+        { /* Ignore whitespace */ }
.               { /* Ignore unknown characters silently */ }
%%