%{
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "ast.h"
#include "symbol_table.h"

int yylex(void);
void yyerror(const char *);
%}

%union {
    int intVal;
    float floatVal;
    char *stringVal;
    struct attributes {
        int numeric;
        float numericDecimal;
        char *strVal;
        int type;
        struct ast *n;
    } attr;
}

%{
    extern FILE *yyout;
    extern FILE *yyin;
%}

%token MULTIPLY IF ELSE WHILE NEWLINE EMPTY BLOCK_START DIVIDE ADD SUBTRACT EQUAL OPENPAREN CLOSEPAREN PRINT NOT LESS GREATER NOTEQUAL EQUALS GREATEREQUAL LESSEQUAL ADDEQUAL SUBTRACTEQUAL OPENBRACE CLOSEBRACE FUNCTION RETURN BREAK CONTINUE ARRAY SEMICOLON FOR RANGE IN COMMA INDEX

%token <intVal> NUMERIC 
%token <intVal> TABS 
%token <floatVal> DECIMALNUMERIC 
%token <stringVal> IDENTIFIER 
%token <stringVal> STRING 
%token <stringVal> BOOLEAN

%type <attr> statements statement types expression assignment print condition loop command

%left MULTIPLY DIVIDE ADD SUBTRACT EQUALS OR AND

%start code 
%%

code : statements {
    checkAST($1.n);
};

statements : statement | statements statement {
    $$.n = createNonTerminalNode($1.n, $2.n, NODE_CHAIN);
    if ($1.n != NULL) {
        $$.n->depth = $1.n->depth;
    } else if ($2.n != NULL) {
        $$.n->depth = $2.n->depth;
    } 
};

statement : TABS command {
    $$ = $2;
    assignDepth($$.n, $1);
} | command {
    $$ = $1;
    assignDepth($$.n, 0);
};

command : assignment | print | condition | loop;

condition: IF expression BLOCK_START statements {
    if ($2.type == TYPE_BOOL) {
        $$.n = createNonTerminalNode($2.n, $4.n, NODE_IF);
    } else {
        yyerror("syntax error: invalid type for IF condition");
    }
} | ELSE BLOCK_START statements {
    $$.n = createNonTerminalNode($3.n, createEmptyNode(), NODE_ELSE);
};

loop: WHILE expression BLOCK_START statements {
    if ($2.type == TYPE_BOOL) {
        $$.n = createNonTerminalNode($2.n, $4.n, NODE_WHILE);
    } else {
        yyerror("syntax error: invalid type for WHILE condition");
    }
} | FOR INDEX IN RANGE OPENPAREN NUMERIC COMMA NUMERIC CLOSEPAREN BLOCK_START statements {
    if ($6 < $8) {
        $$.n = createNonTerminalNode(createRangeNode($6, $8), $11.n, NODE_FOR);
    } else {
        yyerror("syntax error: invalid range for FOR loop");
    }
}; 

assignment : IDENTIFIER EQUAL expression {
    int idx = currentIndex;
    int pos = findSymbol(currentIndex, $1, symbolTable);
    if (pos == -1) {
        symbolTable[idx].identifier = $1;
        symbolTable[idx].dataType = $3.type;
        if ($3.type == TYPE_NUMERIC || $3.type == TYPE_BOOL) {
            symbolTable[idx].numVal = malloc(sizeof(double));
            *symbolTable[idx].numVal = $3.numeric;
        } else if ($3.type == TYPE_DECIMAL) {
            symbolTable[idx].numVal = malloc(sizeof(double));
            *symbolTable[idx].numVal = $3.numericDecimal;
        } else if ($3.type == TYPE_STRING) {
            symbolTable[idx].strVal = $3.strVal;
        }
        symbolTable[idx].pos = idx;
        currentIndex++;
    } else {
        idx = pos;
    }
    $$.n = createNonTerminalNode($3.n, createEmptyNode(), NODE_ASSIGN);
    $$.n->varName = symbolTable[idx].pos;
};

expression : expression ADD types {
    if ($1.type == TYPE_NUMERIC && $3.type == TYPE_NUMERIC) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_ADD);
        $$.type = TYPE_NUMERIC;
        $$.numeric = $1.numeric + $3.numeric;
    } else if ($1.type == TYPE_DECIMAL && $3.type == TYPE_DECIMAL) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_ADD);
        $$.type = TYPE_DECIMAL;
        $$.numericDecimal = $1.numericDecimal + $3.numericDecimal;
    } else if ($1.type == TYPE_NUMERIC && $3.type == TYPE_DECIMAL) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_ADD);
        $$.type = TYPE_DECIMAL;
        $$.numericDecimal = $1.numeric + $3.numericDecimal;
    } else if ($1.type == TYPE_DECIMAL && $3.type == TYPE_NUMERIC) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_ADD);
        $$.type = TYPE_DECIMAL;
        $$.numericDecimal = $1.numericDecimal + $3.numeric;
    } else if ($1.type == TYPE_STRING && $3.type == TYPE_STRING) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_CONCAT);
        $$.type = TYPE_STRING;
        $$.strVal = malloc(strlen($1.strVal) + strlen($3.strVal) + 1);
        strcpy($$.strVal, $1.strVal);
        strcat($$.strVal, $3.strVal);
    } else {
        yyerror("ERROR due to type failure");
    }
} | expression SUBTRACT types {
    if ($1.type == TYPE_NUMERIC && $3.type == TYPE_NUMERIC) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_SUBTRACT);
        $$.type = TYPE_NUMERIC;
        $$.numeric = $1.numeric - $3.numeric;
    } else if ($1.type == TYPE_DECIMAL && $3.type == TYPE_DECIMAL) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_SUBTRACT);
        $$.type = TYPE_DECIMAL;
        $$.numericDecimal = $1.numericDecimal - $3.numericDecimal;
    } else if ($1.type == TYPE_NUMERIC && $3.type == TYPE_DECIMAL) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_SUBTRACT);
        $$.type = TYPE_DECIMAL;
        $$.numericDecimal = $1.numeric - $3.numericDecimal;
    } else if ($1.type == TYPE_DECIMAL && $3.type == TYPE_NUMERIC) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_SUBTRACT);
        $$.type = TYPE_DECIMAL;
        $$.numericDecimal = $1.numericDecimal - $3.numeric;
    } else {
        yyerror("ERROR due to type failure");
    }
} | expression MULTIPLY types {
    if ($1.type == TYPE_NUMERIC && $3.type == TYPE_NUMERIC) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_MULTIPLY);
        $$.type = TYPE_NUMERIC;
        $$.numeric = $1.numeric * $3.numeric;
    } else if ($1.type == TYPE_DECIMAL && $3.type == TYPE_DECIMAL) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_MULTIPLY);
        $$.type = TYPE_DECIMAL;
        $$.numericDecimal = $1.numericDecimal * $3.numericDecimal;
    } else if ($1.type == TYPE_NUMERIC && $3.type == TYPE_DECIMAL) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_MULTIPLY);
        $$.type = TYPE_DECIMAL;
        $$.numericDecimal = $1.numeric * $3.numericDecimal;
    } else if ($1.type == TYPE_DECIMAL && $3.type == TYPE_NUMERIC) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_MULTIPLY);
        $$.type = TYPE_DECIMAL;
        $$.numericDecimal = $1.numericDecimal * $3.numeric;
    } else {
        yyerror("ERROR due to type failure");
    }
} | expression DIVIDE types {
    if ($1.type == TYPE_NUMERIC && $3.type == TYPE_NUMERIC) {
        if ($3.numeric == 0) {
            yyerror("Syntax error: Division by zero\n");
        }
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_DIVIDE);
        $$.type = TYPE_NUMERIC;
        $$.numeric = $1.numeric / $3.numeric;
    } else if ($1.type == TYPE_DECIMAL && $3.type == TYPE_DECIMAL) {
        if ($3.numericDecimal == 0.0) {
            yyerror("Syntax error: Division by zero\n");
        }
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_DIVIDE);
        $$.type = TYPE_DECIMAL;
        $$.numericDecimal = $1.numericDecimal / $3.numericDecimal;
    } else if ($1.type == TYPE_NUMERIC && $3.type == TYPE_DECIMAL) {
        if ($3.numericDecimal == 0.0) {
            yyerror("Syntax error: Division by zero\n");
        }
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_DIVIDE);
        $$.type = TYPE_DECIMAL;
        $$.numericDecimal = $1.numeric / $3.numericDecimal;
    } else if ($1.type == TYPE_DECIMAL && $3.type == TYPE_NUMERIC) {
        if ($3.numeric == 0.0) {
            yyerror("Syntax error: Division by zero\n");
        }
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_DIVIDE);
        $$.type = TYPE_DECIMAL;
        $$.numericDecimal = $1.numericDecimal / $3.numeric;
    } else {
        yyerror("ERROR due to type failure");
    }
} | expression EQUALS types {
    if ($1.type == TYPE_NUMERIC && $3.type == TYPE_NUMERIC) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_EQUAL);
        $$.type = TYPE_BOOL;
        $$.numeric = $1.numeric == $3.numeric;
    } else if ($1.type == TYPE_DECIMAL && $3.type == TYPE_DECIMAL) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_EQUAL);
        $$.type = TYPE_BOOL;
        $$.numeric = $1.numericDecimal == $3.numericDecimal;
    } else if ($1.type == TYPE_NUMERIC && $3.type == TYPE_DECIMAL) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_EQUAL);
        $$.type = TYPE_BOOL;
        $$.numeric = $1.numeric == $3.numericDecimal;
    } else if ($1.type == TYPE_DECIMAL && $3.type == TYPE_NUMERIC) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_EQUAL);
        $$.type = TYPE_BOOL;
        $$.numeric = $1.numericDecimal == $3.numeric;
    } else {
        yyerror("ERROR due to type failure");
    }
} | expression AND types {
    if ($1.type == TYPE_BOOL && $3.type == TYPE_BOOL) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_AND);
        $$.type = TYPE_BOOL;
        $$.numeric = $1.numeric && $3.numeric;
    }
} | expression OR types {
    if ($1.type == TYPE_BOOL && $3.type == TYPE_BOOL) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_OR);
        $$.type = TYPE_BOOL;
        $$.numeric = $1.numeric || $3.numeric;
    }
} | expression GREATER types {
    if ($1.type == TYPE_NUMERIC && $3.type == TYPE_NUMERIC) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_GREATER);
        $$.type = TYPE_BOOL;
        $$.numeric = $1.numeric > $3.numeric;
    } else if ($1.type == TYPE_DECIMAL && $3.type == TYPE_DECIMAL) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_GREATER);
        $$.type = TYPE_BOOL;
        $$.numeric = $1.numericDecimal > $3.numericDecimal;
    } else if ($1.type == TYPE_NUMERIC && $3.type == TYPE_DECIMAL) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_GREATER);
        $$.type = TYPE_BOOL;
        $$.numeric = $1.numeric > $3.numericDecimal;
    } else if ($1.type == TYPE_DECIMAL && $3.type == TYPE_NUMERIC) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_GREATER);
        $$.type = TYPE_BOOL;
        $$.numeric = $1.numericDecimal > $3.numeric;
    } else {
        yyerror("ERROR due to type failure");
    }
} | expression LESS types {
    if ($1.type == TYPE_NUMERIC && $3.type == TYPE_NUMERIC) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_LESS);
        $$.type = TYPE_BOOL;
        $$.numeric = $1.numeric < $3.numeric;
    } else if ($1.type == TYPE_DECIMAL && $3.type == TYPE_DECIMAL) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_LESS);
        $$.type = TYPE_BOOL;
        $$.numeric = $1.numericDecimal < $3.numericDecimal;
    } else if ($1.type == TYPE_DECIMAL && $3.type == TYPE_NUMERIC) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_LESS);
        $$.type = TYPE_BOOL;
        $$.numeric = $1.numericDecimal < $3.numeric;
    } else if ($1.type == TYPE_NUMERIC && $3.type == TYPE_DECIMAL) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_LESS);
        $$.type = TYPE_BOOL;
        $$.numeric = $1.numeric < $3.numericDecimal;
    } else {
        yyerror("ERROR due to type failure");
    }
} | expression GREATEREQUAL types {
    if ($1.type == TYPE_NUMERIC && $3.type == TYPE_NUMERIC) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_GREATER_EQUAL);
        $$.type = TYPE_BOOL;
        $$.numeric = $1.numeric >= $3.numeric;
    } else if ($1.type == TYPE_DECIMAL && $3.type == TYPE_DECIMAL) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_GREATER_EQUAL);
        $$.type = TYPE_BOOL;
        $$.numeric = $1.numericDecimal >= $3.numericDecimal;
    } else if ($1.type == TYPE_DECIMAL && $3.type == TYPE_NUMERIC) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_GREATER_EQUAL);
        $$.type = TYPE_BOOL;
        $$.numeric = $1.numericDecimal >= $3.numeric;
    } else if ($1.type == TYPE_NUMERIC && $3.type == TYPE_DECIMAL) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_GREATER_EQUAL);
        $$.type = TYPE_BOOL;
        $$.numeric = $1.numeric >= $3.numericDecimal;
    } else {
        yyerror("ERROR due to type failure");
    }
} | expression LESSEQUAL types {
    if ($1.type == TYPE_NUMERIC && $3.type == TYPE_NUMERIC) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_LESS_EQUAL);
        $$.type = TYPE_BOOL;
        $$.numeric = $1.numeric <= $3.numeric;
    } else if ($1.type == TYPE_DECIMAL && $3.type == TYPE_DECIMAL) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_LESS_EQUAL);
        $$.type = TYPE_BOOL;
        $$.numeric = $1.numericDecimal <= $3.numericDecimal;
    } else if($1.type == TYPE_NUMERIC && $3.type == TYPE_DECIMAL) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_LESS_EQUAL);
        $$.type = TYPE_BOOL;
        $$.numeric = $1.numeric <= $3.numericDecimal;
    } else if($1.type == TYPE_DECIMAL && $3.type == TYPE_NUMERIC) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_LESS_EQUAL);
        $$.type = TYPE_BOOL;
        $$.numeric = $1.numericDecimal <= $3.numeric;
    } else {
        yyerror("ERROR due to type failure");
    }
} | expression NOTEQUAL types {
    if ($1.type == TYPE_NUMERIC && $3.type == TYPE_NUMERIC) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_NOT_EQUAL);
        $$.type = TYPE_BOOL;
        $$.numeric = $1.numeric != $3.numeric;
    } else if ($1.type == TYPE_DECIMAL && $3.type == TYPE_DECIMAL) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_NOT_EQUAL);
        $$.type = TYPE_BOOL;
        $$.numeric = $1.numericDecimal != $3.numericDecimal;
    } else if ($1.type == TYPE_NUMERIC && $3.type == TYPE_DECIMAL) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_NOT_EQUAL);
        $$.type = TYPE_BOOL;
        $$.numeric = $1.numeric != $3.numericDecimal;
    } else if ($1.type == TYPE_DECIMAL && $3.type == TYPE_NUMERIC) {
        $$.n = createNonTerminalNode($1.n, $3.n, NODE_NOT_EQUAL);
        $$.type = TYPE_BOOL;
        $$.numeric = $1.numericDecimal != $3.numeric;
    } else {
        yyerror("ERROR due to type failure");
    }
} | SUBTRACT expression { 
    if ($2.type == TYPE_DECIMAL) {
        $2.numericDecimal = -$2.numericDecimal ;
        $$ = $2; 
    } else if ($2.type == TYPE_NUMERIC) {
        $2.numeric = -$2.numeric ;
        $$ = $2; 
    } else {
        yyerror("ERROR in negation operation ");
    }
} | OPENPAREN expression CLOSEPAREN { $$ = $2; }
| types { $$ = $1; }
;

types: IDENTIFIER { 
    int pos = findSymbol(currentIndex, $1, symbolTable);
    if (pos != -1) {
        int reg = symbolTable[pos].pos;
        if (symbolTable[pos].dataType == TYPE_NUMERIC && symbolTable[pos].numVal != NULL) {
            $$.type = symbolTable[pos].dataType;
            $$.numeric = (int)*symbolTable[pos].numVal;
            $$.n = createVariableTerminal(*symbolTable[pos].numVal, reg);
        } else if (symbolTable[pos].dataType == TYPE_DECIMAL && symbolTable[pos].numVal != NULL) {
            $$.type = symbolTable[pos].dataType;
            $$.numericDecimal = (float)*symbolTable[pos].numVal;
            $$.n = createVariableTerminal(*symbolTable[pos].numVal, reg);
        }
    } else {
        int message_len = snprintf(NULL, 0, "Variable \"%s\" has not been registered before\n", $1);
        char* message = (char*)malloc(message_len + 1);
        sprintf(message, "Variable \"%s\" has not been registered before\n", $1);
        yyerror(message);
    }
} | NUMERIC {
    $$.numeric = $1;
    $$.n = createTerminalNode($1);
    $$.type = TYPE_NUMERIC;
} | DECIMALNUMERIC {
    $$.numericDecimal = $1;
    $$.n = createTerminalNode($1);
    $$.type = TYPE_DECIMAL;
} | STRING {
    $$.strVal = $1 + 1;
    $$.strVal[strlen($$.strVal) - 1] = '\0';
    $$.n = createTerminalNodeStr($$.strVal);
    $$.type = TYPE_STRING;
} | BOOLEAN {
    if (strcmp($1, "true") == 0) {
        $$.numeric = 1;
    } else if (strcmp($1, "false") == 0) {
        $$.numeric = 0;
    } else {
        yyerror("BOOLEAN FAILURE");
    }
    $$.n = createTerminalNode($$.numeric);
    $$.type = TYPE_BOOL;
};

print: PRINT OPENPAREN expression CLOSEPAREN {
    $$.n = createNonTerminalNode($3.n, createEmptyNode(), NODE_PRINT);
} | PRINT OPENBRACE expression CLOSEBRACE {
    $$.n = createNonTerminalNode($3.n, createEmptyNode(), NODE_PRINT);
};

%%

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *file = fopen(argv[1], "rt");
        if (!file) {
            fprintf(stderr, "Could not open %s\n", argv[1]);
            return 1;
        }
        yyin = file;
    } else {
        yyerror("No input file provided\n");
        return 1;
    }
    if (argc > 2) {
        FILE *file = fopen(argv[2], "w");
        if (!file) {
            fprintf(stderr, "Could not open %s\n", argv[2]);
            return 1;
        }
        yyout = file;
    } else {
        yyout = fopen("./output.asm", "wt");
    }
    yyparse();

    fclose(yyin);
    fclose(yyout);

    return 0;
}
