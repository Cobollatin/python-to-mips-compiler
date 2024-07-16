#ifndef AST_H
#define AST_H

#include <stdbool.h>
#include <stdio.h>

extern FILE* yyout;

typedef enum {
    INVALID_NODE = 0,
    NEW_NODE, // 1
    NODE_ADD, // 2
    NODE_SUBTRACT, // 3
    NODE_MULTIPLY, // 4
    NODE_DIVIDE, // 5
    NODE_PRINT, // 6
    NODE_ASSIGN, // 7
    NODE_CHAIN, // 8
    NODE_EQUAL, // 9
    NODE_GREATER, // 10
    NODE_LESS, // 11
    NODE_GREATER_EQUAL, // 12
    NODE_LESS_EQUAL, // 13
    NODE_ADD_EQUAL, // 14
    NODE_SUBTRACT_EQUAL, // 15
    NODE_NOT_EQUAL, // 16
    NODE_IF, // 17
    NODE_ELSE, // 18
    NODE_WHILE, // 19
    NODE_AND, // 20
    NODE_OR, // 21
    NODE_CONCAT, // 22
    NODE_FOR, // 23
    NODE_RANGE // 24
} NodeType;

typedef enum {
    TYPE_NUMERIC = 0,
    TYPE_DECIMAL, // 1
    TYPE_TEXT, // 2
    TYPE_BOOL, // 3
    TYPE_STRING // 4
} DataType;

typedef struct ast {
    struct ast* left;
    struct ast* right;
    NodeType nodeType;
    double value;
    char* valueStr;
    DataType type;
    int result;
    int varName;
    int depth;
} AST;

void newline();
void printFunction(AST* n);
void printVariables();
int findReg();
int findTmpReg();
void clearReg(AST* left, AST* right);
void clearTmpReg(AST* n);
AST* createEmptyNode();
AST* createTerminalNode(double value);
AST* createTerminalNodeStr(char* value);
AST* createRangeNode(int start, int end);
AST* createNonTerminalNode(AST* left, AST* right, NodeType nodeType);
AST* createVariableTerminal(double value, int pos);
void assignDepth(AST* n, int depth);
void handleNewNode(AST* n);
void handleBinaryOperation(AST* n, const char* operation, int localLabelCounter, int nodeDepth);
void handleComparisonOperation(AST* n, const char* operation, const char* movCondition, int localLabelCounter, int nodeDepth);
void handlePrint(AST* n, int localLabelCounter, int nodeDepth);
void handleAssign(AST* n, int localLabelCounter, int nodeDepth);
AST* handleIf(AST* n, int localLabelCounter, int nodeDepth);
AST* handleFor(AST* n, int localLabelCounter, int nodeDepth);
AST* handleWhile(AST* n, int localLabelCounter, int nodeDepth);
AST* checkNodeValue(AST* n, int localLabelCounter, int currentDepth);
void checkAST(AST* n);

#endif // AST_H
