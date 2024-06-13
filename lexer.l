%{

#include "parser.tab.h"
#include <string.h>
int indent_level = 0;
int prev_indent_level = 0;
int pending_dedent = 0;

int calculate_indent(const char *text) {
    int count = 0;
    for (int i = 0; text[i] != '\0'; ++i) {
        if (text[i] == ' ') {
            count++;
        } else if (text[i] == '\t') {
            count += 4; // Assuming tab is 4 spaces
        } else {
            break;
        }
    }
    return count;
}
%}

%option yylineno

DIGIT       [0-9]
LETTER      [a-zA-Z]
ID          {LETTER}({LETTER}|{DIGIT})*
NUMBER      {DIGIT}+
FLOAT       {DIGIT}+"."{DIGIT}+
STRING      \"(\\.|[^\"])*\"

%%

"if"            { return IF; }
"else"          { return ELSE; }
"for"           { return FOR; }
"while"         { return WHILE; }
"continue"      { return CONTINUE; }
"break"         { return BREAK; }
"def"           { return DEF; }
"return"        { return RETURN; }
"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return MULT; }
"/"             { return DIV; }
"="             { return ASSIGN; }
"+="            { return PLUS_ASSIGN; }
"-="            { return MINUS_ASSIGN; }
"=="            { return EQ; }
"!="            { return NEQ; }
"<"             { return LT; }
">"             { return GT; }
"<="            { return LTE; }
">="            { return GTE; }
"("             { return LPAREN; }
")"             { return RPAREN; }
":"             { return COLON; }
{ID}            { yylval.str = strdup(yytext); return ID; }
{NUMBER}        { yylval.num = atoi(yytext); return INT; }
{FLOAT}         { yylval.flt = atof(yytext); return FLOAT; }
{STRING}        { yylval.str = strdup(yytext); return STRING; }
"#"[^\n]*       { /* Ignore single-line comments */ }
"/*"([^*]|\*[^/])*"*/" { /* Ignore multi-line comments */ }
\n              { return ENDL; }
^[ \t]*\n       { return ENDL; }  // Handle empty lines
^[ \t]*         {
                    int indent = calculate_indent(yytext);
                    if (pending_dedent > 0) {
                        pending_dedent--;
                        return DEDENT;
                    } else if (indent > indent_level) {
                        prev_indent_level = indent_level;
                        indent_level = indent;
                        return INDENT;
                    } else if (indent < indent_level) {
                        prev_indent_level = indent_level;
                        indent_level = indent;
                        pending_dedent = (prev_indent_level - indent) / 4;
                        return DEDENT;
                    }
                }
[ \t\r]+        { /* Ignore whitespace */ }

%%

int yywrap() {
    return 1;
}

void yyerror(const char *str)
{
    fprintf(stderr,"Error | Line: %d\n%s\n",yylineno,str);
}