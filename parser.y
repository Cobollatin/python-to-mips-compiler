%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "symbol_table.h"
#include "mips.h"

void yyerror(const char *s);
int yylex(void);

struct ast_node *root = NULL;

%}

%locations
%union {
    int num;
    float flt;
    char *str;
    struct ast_node *node;
}

%token <num> INT
%token <flt> FLOAT
%token <str> STRING ID
%token IF ELSE FOR WHILE CONTINUE BREAK DEF RETURN
%token PLUS MINUS MULT DIV
%token ASSIGN PLUS_ASSIGN MINUS_ASSIGN
%token EQ NEQ LT GT LTE GTE
%token LPAREN RPAREN COLON ENDL INDENT DEDENT

%type <node> program statement declaration expression block else_clause

%left PLUS MINUS
%left MULT DIV
%left EQ NEQ LT GT LTE GTE

%%
program:
      program statement ENDL
    | program ENDL
    | /* empty production */ { printf("#Start of program\n"); $$ = create_program_node(); root = $$; }
    ;

statement:
      declaration { printf("#Declaration or assignment statement\n"); $$ = $1; }
    | expression { printf("#Expression statement\n"); $$ = $1; }
    | IF expression COLON ENDL block ENDL else_clause {
        printf("#If-else statement\n");
        if ($2->type != TYPE_BOOL) {
            yyerror("Condition in IF must be boolean");
        }
        $$ = create_if_else_node($2, $5, $7);
    }
    | FOR expression COLON ENDL block {
        printf("#For statement\n");
        if ($2->type != TYPE_INT) {
            yyerror("Condition in FOR must be integer");
        }
        $$ = create_for_node($2, $5);
    }
    | WHILE expression COLON ENDL block {
        printf("#While statement\n");
        if ($2->type != TYPE_BOOL) {
            yyerror("Condition in WHILE must be boolean");
        }
        $$ = create_while_node($2, $5);
    }
    | CONTINUE ENDL {
        printf("#Continue statement\n");
        $$ = create_continue_node();
    }
    | BREAK ENDL {
        printf("#Break statement\n");
        $$ = create_break_node();
    }
    | DEF ID LPAREN RPAREN COLON ENDL block {
        printf("#Function definition\n");
        if (symbol_exists($2)) {
            yyerror("Function already declared");
        }
        add_symbol($2, TYPE_FUNCTION);
        $$ = create_function_node($2, $7);
    }
    | RETURN expression ENDL {
        printf("#Return statement\n");
        if (current_function_return_type() != $2->type) {
            yyerror("Return type mismatch");
        }
        $$ = create_return_node($2);
    }
    ;

else_clause:
    ELSE COLON ENDL block { 
        printf("#Else block\n"); 
        $$ = $4; 
        }
    | /* empty production */ { printf("#No else block\n"); $$ = NULL; }
    ;

declaration:
    ID ASSIGN expression {
        printf("#Variable declaration or assignment: %s of type %d\n", $1, $3->type);
        if (!symbol_exists($1)) {
            add_symbol($1, $3->type);
        } else {
            printf("#Variable %s already declared, reassigning with type %d\n", $1, $3->type);
            update_symbol($1, $3->type);
        }
        $$ = create_id_node($1); // Return the variable node
    }
    ;

expression:
      INT { printf("#Integer: %d\n", $1); $$ = create_int_node($1); }
    | FLOAT { printf("#Float: %f\n", $1); $$ = create_float_node($1); }
    | STRING { printf("#String: %s\n", $1); $$ = create_string_node($1); }
    | ID {
        printf("#Identifier: %s\n", $1);
        if (!symbol_exists($1)) {
            yyerror("Undeclared variable");
        }
        $$ = create_id_node($1);
    }
    | expression PLUS expression {
        printf("#Addition\n");
        if ($1->type != $3->type) {
            yyerror("Type mismatch in addition");
        }
        $$ = create_arith_node('+', $1, $3);
    }
    | expression MINUS expression {
        printf("#Subtraction\n");
        if ($1->type != $3->type) {
            yyerror("Type mismatch in subtraction");
        }
        $$ = create_arith_node('-', $1, $3);
    }
    | expression MULT expression {
        printf("#Multiplication\n");
        if ($1->type != $3->type) {
            yyerror("Type mismatch in multiplication");
        }
        $$ = create_arith_node('*', $1, $3);
    }
    | expression DIV expression {
        printf("#Division\n");
        if ($1->type == TYPE_INT && $3->type == TYPE_INT) {
            $$ = create_arith_node('/', create_float_node((float)$1->value.int_val), create_float_node((float)$3->value.int_val));
        } else if ($1->type == TYPE_FLOAT && $3->type == TYPE_FLOAT) {
            $$ = create_arith_node('/', $1, $3);
        } else if ($1->type == TYPE_INT && $3->type == TYPE_FLOAT) {
            $$ = create_arith_node('/', create_float_node((float)$1->value.int_val), $3);
        } else if ($1->type == TYPE_FLOAT && $3->type == TYPE_INT) {
            $$ = create_arith_node('/', $1, create_float_node((float)$3->value.int_val));
        } else if ($1->type == TYPE_ID && $3->type == TYPE_INT) {
            type_t id_type = get_symbol_type($1->value.string_val);
            if (id_type != TYPE_INT && id_type != TYPE_FLOAT && id_type != TYPE_ARITH) {
                char buf[100];
                const char *err_msg = "Type mismatch in division. Types: %d and %d";
                snprintf(buf, 100, err_msg, id_type, TYPE_INT);
                yyerror(buf);
            }
            $$ = create_arith_node('/', $1, create_float_node((float)$3->value.int_val));
        } else if ($1->type == TYPE_ID && $3->type == TYPE_FLOAT) {
            type_t id_type = get_symbol_type($1->value.string_val);
            if (id_type != TYPE_INT && id_type != TYPE_FLOAT && id_type != TYPE_ARITH) {
                char buf[100];
                const char *err_msg = "Type mismatch in division. Types: %d and %d";
                snprintf(buf, 100, err_msg, id_type, TYPE_FLOAT);
                yyerror(buf);
            }
            $$ = create_arith_node('/', $1, $3);
        } else if ($1->type == TYPE_INT && $3->type == TYPE_ID) {
            type_t id_type = get_symbol_type($3->value.string_val);
            if (id_type != TYPE_INT && id_type != TYPE_FLOAT && id_type != TYPE_ARITH) {
                char buf[100];
                const char *err_msg = "Type mismatch in division. Types: %d and %d";
                snprintf(buf, 100, err_msg, TYPE_FLOAT, id_type);
                yyerror(buf);
            }
            $$ = create_arith_node('/', create_float_node((float)$1->value.int_val), $3);
        } else if ($1->type == TYPE_FLOAT && $3->type == TYPE_ID) {
            type_t id_type = get_symbol_type($3->value.string_val);
            if (id_type != TYPE_INT && id_type != TYPE_FLOAT && id_type != TYPE_ARITH) {
                char buf[100];
                const char *err_msg = "Type mismatch in division. Types: %d and %d";
                snprintf(buf, 100, err_msg, TYPE_FLOAT, id_type);
                yyerror(buf);
            }
            $$ = create_arith_node('/', $1, $3);
        } else if ($1->type == TYPE_ID && $3->type == TYPE_ID) {
            type_t id1_type = get_symbol_type($1->value.string_val);
            type_t id2_type = get_symbol_type($3->value.string_val);
            if ((id1_type != TYPE_INT && id1_type != TYPE_FLOAT && id1_type != TYPE_ARITH) || (id2_type != TYPE_INT && id2_type != TYPE_FLOAT && id2_type != TYPE_ARITH)) {
                char buf[100];
                const char *err_msg = "Type mismatch in division. Types: %d and %d";
                snprintf(buf, 100, err_msg, id1_type, id2_type);
                yyerror(buf);
            }
            $$ = create_arith_node('/', $1, $3);
        } else {
            yyerror("Type mismatch in division operation");
        }
    }
    | expression EQ expression {
        printf("#Equality check\n");
        if ($1->type != $3->type) {
            yyerror("Type mismatch in equality check");
        }
        $$ = create_relop_node("==", $1, $3);
    }
    | expression NEQ expression {
        printf("#Inequality check\n");
        if ($1->type != $3->type) {
            yyerror("Type mismatch in inequality check");
        }
        $$ = create_relop_node("!=", $1, $3);
    }
    | expression LT expression {
        printf("#Less-than check\n");
        if ($1->type != $3->type) {
            yyerror("Type mismatch in less-than check");
        }
        $$ = create_relop_node("<", $1, $3);
    }
    | expression GT expression {
        printf("#Greater-than check\n");
        if ($1->type != $3->type) {
            yyerror("Type mismatch in greater-than check");
        }
        $$ = create_relop_node(">", $1, $3);
    }
    | expression LTE expression {
        printf("#Less-than-or-equal check\n");
        if ($1->type != $3->type) {
            yyerror("Type mismatch in less-than-or-equal check");
        }
        $$ = create_relop_node("<=", $1, $3);
    }
    | expression GTE expression {
        printf("#Greater-than-or-equal check\n");
        if ($1->type != $3->type) {
            yyerror("Type mismatch in greater-than-or-equal check");
        }
        $$ = create_relop_node(">=", $1, $3);
    }
    | LPAREN expression RPAREN { $$ = $2; }
    ;

block:
    INDENT program DEDENT { $$ = $2; }
    ;

%%


int main(int argc, char **argv) {
    init_symbol_table();
    yyparse();
    generate_mips_code(root);
    return 0;
}
