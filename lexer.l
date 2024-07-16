%option noyywrap

%{
#include "parser.tab.h"
extern YYSTYPE yylval;
%}

%option yylineno

%%

"print"                                                  return PRINT;
"+"                                                      return ADD;
":"                                                      return BLOCK_START;
"-"                                                      return SUBTRACT;
"*"                                                      return MULTIPLY;
"/"                                                      return DIVIDE;
"="                                                      return EQUAL;
"("                                                      return OPENPAREN;
")"                                                      return CLOSEPAREN;
"while"                                                  return WHILE;
"if"                                                     return IF;
"else"                                                   return ELSE;
"["|"]"                                                  return ARRAY;
";"                                                      return SEMICOLON;
"and"                                                    return AND;
"or"                                                     return OR;
"not"                                                    return NOT;
"<"                                                      return LESS;
">"                                                      return GREATER;
"!="                                                     return NOTEQUAL;
"=="                                                     return EQUALS;
">="                                                     return GREATEREQUAL;
"<="                                                     return LESSEQUAL;
"+="                                                     return ADDEQUAL;
"-="                                                     return SUBTRACTEQUAL;
"{"                                                      return OPENBRACE;
"}"                                                      return CLOSEBRACE;
"True"|"False"                                           { yylval.stringVal = strdup(yytext); return BOOLEAN; }
"def"                                                    return FUNCTION;
"return"                                                 return RETURN;
"break"                                                  return BREAK;
"continue"                                               return CONTINUE;
[0-9]+                                                   { yylval.intVal = atoi(yytext); return NUMERIC; }
[0-9]+\.[0-9]+                                           { yylval.floatVal = atof(yytext); return DECIMALNUMERIC; }
_?[a-zA-Z][a-zA-Z0-9_]*                                  { yylval.stringVal = strdup(yytext); return IDENTIFIER; }
\n                                                       { /* Ignore line break */ }
#.*                                                      { /* Ignore comments */ }
\"[a-zA-Z0-9 ]*?\"                                       { yylval.stringVal = strdup(yytext); return STRING; }
""                                                       return EMPTY;
^[" "]*                                                  { yylval.intVal = strlen(yytext); return TABS; }

%%

void yyerror(const char *str)
{
    fprintf(stderr,"Error | Line: %d\n%s\n", yylineno, str);
}
