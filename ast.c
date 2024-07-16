#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h> 
#include <time.h>
#include "ast.h"
#include "symbol_table.h"

int labelCount = 0;
int ifLabelCount = 0;  
int whileLabelCount = 0;
int maxRecords = 32;

// By default, we have 32 records to control free (true) or occupied (false) records
bool records[32] = {[0 ... 29] = true, [30 ... 31] = false}; // Records 30 and 31 are reserved by default for printing
bool tmpRecords[10] = {[0 ... 7] = true, [8 ... 9] = true}; // Records 30 and 31 are reserved by default for printing

void newline() {
    fprintf(yyout, "li $v0, 4\n");                      
    fprintf(yyout, "la $a0, newline\n");                
    fprintf(yyout, "syscall\n");
}

void printFunction(struct ast *n) {
    fprintf(yyout, "li $v0, 2\n"); 
    fprintf(yyout, "add.s $f12, $f31, $f%d\n", n->result); 
    fprintf(yyout, "mov.s $f30, $f12\n");
    fprintf(yyout, "syscall\n");
    newline(); 
}

void printVariables() {
    fprintf(yyout, "\n.data\n");
    fprintf(yyout, "newline: .asciiz \"\\n\"\n"); 
    fprintf(yyout, "zero: .float 0.0\n"); 
    for (int i = 0; i < currentIndex; i++) {
        if (symbolTable[i].numVal != NULL) {
            fprintf(yyout, "var_%d: .float %.3f\n", symbolTable[i].pos, *symbolTable[i].numVal);
        }
    }
}

int findReg() {
    int position = 0;
    while (position <= (maxRecords - 1) && records[position] == 0) {
        position++;
    }
    records[position] = false;
    return position;
}

int findTmpReg() {
    int position = 0;
    while (position <= 9 && tmpRecords[position] == 0) {
        position++;
    }
    tmpRecords[position] = 0;
    return position;
}

void clearReg(struct ast *left, struct ast *right) { 
    records[left->result] = true; 
    if (right != NULL) records[right->result] = true; 
}

void clearTmpReg(struct ast* n) { 
    tmpRecords[n->result] = true;
}

struct ast *createEmptyNode() {
    return NULL;
}

struct ast *createTerminalNode(double value) {                   
    struct ast *n = malloc(sizeof(struct ast));
    n->left = NULL; n->right = NULL; n->value = value; n->nodeType = NEW_NODE; n->depth = -1;
    n->varName = currentIndex;
    symbolTable[currentIndex].identifier = "_";
    symbolTable[currentIndex].dataType = TYPE_DECIMAL;
    symbolTable[currentIndex].numVal = malloc(sizeof(double));
    *symbolTable[currentIndex].numVal = value;
    symbolTable[currentIndex].pos = currentIndex;
    currentIndex++;
    return n;
}

struct ast *createTerminalNodeStr(char* value) {                   
    struct ast *n = malloc(sizeof(struct ast));
    n->left = NULL; n->right = NULL; n->valueStr = value; n->nodeType = NEW_NODE; n->depth = -1;
    return n;
}

struct ast *createNonTerminalNode(struct ast *left, struct ast *right, NodeType nodeType) {     
    struct ast *n = malloc(sizeof(struct ast));
    n->left = left; n->right = right; n->nodeType = nodeType;
    n->depth = -1;
    return n;
}

struct ast *createVariableTerminal(double value, int pos) {                                               
    struct ast *n = malloc(sizeof(struct ast));
    n->left = NULL; n->right = NULL; n->nodeType = NEW_NODE; n->value = value;
    n->depth = -1;
    n->varName = pos;
    return n;
}

bool nodeIsType(struct ast *attr, NodeType type) {
    return attr->nodeType == type;
}

void assignDepth(struct ast *n, int depth) {
    if (n != NULL && n->nodeType != INVALID_NODE && n->depth == -1) {
      n->depth = depth;
      assignDepth(n->left, depth);
      assignDepth(n->right, depth);
    }
}

void handleNewNode(struct ast *n) {
    n->result = findReg();
    fprintf(yyout, "lwc1 $f%d, var_%d\n", n->result, n->varName);
}

void handleBinaryOperation(struct ast *n, const char *operation, int localLabelCounter, int nodeDepth) {
    n->result = findReg();
    checkNodeValue(n->left, localLabelCounter, nodeDepth);
    checkNodeValue(n->right, localLabelCounter, nodeDepth);
    fprintf(yyout, "%s $f%d, $f%d, $f%d\n", operation, n->result, n->left->result, n->right->result);
    clearReg(n->left, n->right);
}

void handleComparisonOperation(struct ast *n, const char *operation, const char *movCondition, int localLabelCounter, int nodeDepth) {
    n->result = findTmpReg();
    checkNodeValue(n->left, localLabelCounter, nodeDepth);
    checkNodeValue(n->right, localLabelCounter, nodeDepth);
    fprintf(yyout, "li $t%d, 1\n", n->result); 
    fprintf(yyout, "%s $f%d, $f%d\n", operation, n->left->result, n->right->result); 
    fprintf(yyout, "%s $t%d, $0\n", movCondition, n->result); 
    clearReg(n->left, n->right);
}

void handlePrint(struct ast *n, int localLabelCounter, int nodeDepth) {
    checkNodeValue(n->left, localLabelCounter, nodeDepth);
    printFunction(n->left);
}

void handleAssign(struct ast *n, int localLabelCounter, int nodeDepth) {
    checkNodeValue(n->left, localLabelCounter, nodeDepth); 
    fprintf(yyout, "swc1 $f%d, var_%d\n", n->left->result, n->varName);
    clearReg(n->left, NULL);
}

void handleIf(struct ast *n, int localLabelCounter, int nodeDepth) {
    int c = ifLabelCount++;
    fprintf(yyout, "_IF_START_%d:\n", c);
    checkNodeValue(n->left, localLabelCounter, nodeDepth);
    fprintf(yyout, "beqz $t%d _ELSE_START_%d\n", n->left->result, c);
    struct ast* newContextNode = checkNodeValue(n->right, localLabelCounter+1, nodeDepth+1);
    fprintf(yyout, "j _IF_END_%d\n", n->left->result);
    fprintf(yyout, "_ELSE_START_%d:\n", c);
    if (newContextNode != NULL && newContextNode->depth == nodeDepth) {
        if (nodeIsType(newContextNode, NODE_ELSE)) {
            newContextNode = checkNodeValue(newContextNode->left, localLabelCounter+1, nodeDepth);
        } else if (nodeIsType(newContextNode, NODE_CHAIN) && nodeIsType(newContextNode->left, NODE_ELSE)) {
            newContextNode = checkNodeValue(newContextNode->left, localLabelCounter+1, nodeDepth);
            if (newContextNode != NULL && (newContextNode->depth) >= 0) {
                struct ast* newChain = createNonTerminalNode(newContextNode, n->right, NODE_CHAIN);
                newChain->depth = newContextNode->depth;
                return;
            }
        } 
    }
    fprintf(yyout, "_ELSE_END_%d:\n", c);
    fprintf(yyout, "_IF_END_%d:\n", c);
    clearTmpReg(n->left);
}

void handleWhile(struct ast *n, int localLabelCounter, int nodeDepth) {
    int c = whileLabelCount++;
    fprintf(yyout, "_WHILE_START_%d:\n", c);
    checkNodeValue(n->left, localLabelCounter+1, nodeDepth);
    fprintf(yyout, "beqz $t%d _WHILE_END_%d\n", n->left->result, c);
    fprintf(yyout, "_WHILE_BLOCK_%d:\n", c);
    struct ast* newContextNode = checkNodeValue(n->right, localLabelCounter+1, nodeDepth+1);
    fprintf(yyout, "j _WHILE_START_%d\n", n->left->result);
    fprintf(yyout, "_WHILE_END_%d:\n", c);
    clearTmpReg(n->left);
}

struct ast* checkNodeValue(struct ast *n, int localLabelCounter, int currentDepth) {
    if (n == NULL || n->nodeType == INVALID_NODE) return NULL;
    int nodeDepth = n->depth;

    fprintf(yyout, "# Handling node type: %d\n", n->nodeType);
    fprintf(yyout, "# Current depth: %d\n", currentDepth);
    fprintf(yyout, "# Node depth: %d\n", nodeDepth);

    if (nodeDepth < currentDepth) {
        return n;
    }
    struct ast* newContextNode = NULL;

    switch (n->nodeType) {
        case NEW_NODE:
            handleNewNode(n);
            break;
        
        case NODE_ADD:
            handleBinaryOperation(n, "add.s", localLabelCounter, nodeDepth);
            break;

        case NODE_SUBTRACT:
            handleBinaryOperation(n, "sub.s", localLabelCounter, nodeDepth);
            break;

        case NODE_MULTIPLY:
            handleBinaryOperation(n, "mul.s", localLabelCounter, nodeDepth);
            break;

        case NODE_DIVIDE:
            handleBinaryOperation(n, "div.s", localLabelCounter, nodeDepth);
            break;

        case NODE_PRINT:
            handlePrint(n, localLabelCounter, nodeDepth);
            break;

        case NODE_ASSIGN:
            handleAssign(n, localLabelCounter, nodeDepth);
            break;

        case NODE_CHAIN:
            newContextNode = checkNodeValue(n->left, localLabelCounter, nodeDepth); 
            if (newContextNode != NULL && (newContextNode->depth) >= 0) {
                struct ast* newChain = createNonTerminalNode(newContextNode, n->right, NODE_CHAIN);
                newChain->depth = newContextNode->depth;
                return newChain;
            }
            newContextNode = checkNodeValue(n->right, localLabelCounter, n->left->depth);  
            if (newContextNode != NULL && (newContextNode->depth) >= 0) {
                return newContextNode;
            }
            break;

        case NODE_EQUAL:
            handleComparisonOperation(n, "c.eq.s", "movf", localLabelCounter, nodeDepth);
            break;

        case NODE_GREATER:
            handleComparisonOperation(n, "c.le.s", "movt", localLabelCounter, nodeDepth);
            break;

        case NODE_LESS:
            handleComparisonOperation(n, "c.lt.s", "movf", localLabelCounter, nodeDepth);
            break;

        case NODE_GREATER_EQUAL:
            handleComparisonOperation(n, "c.lt.s", "movt", localLabelCounter, nodeDepth);
            break;

        case NODE_LESS_EQUAL:
            handleComparisonOperation(n, "c.le.s", "movf", localLabelCounter, nodeDepth);
            break;

        case NODE_NOT_EQUAL:
            handleComparisonOperation(n, "c.eq.s", "movt", localLabelCounter, nodeDepth);
            break;

        case NODE_ADD_EQUAL:
            checkNodeValue(n->left, localLabelCounter, nodeDepth);
            checkNodeValue(n->right, localLabelCounter, nodeDepth);
            clearReg(n->left, n->right);
            break;

        case NODE_SUBTRACT_EQUAL:
            checkNodeValue(n->left, localLabelCounter, nodeDepth);
            checkNodeValue(n->right, localLabelCounter, nodeDepth);
            clearReg(n->left, n->right);
            break;

        case NODE_IF: 
            handleIf(n, localLabelCounter, nodeDepth);
            break;

        case NODE_WHILE: 
            handleWhile(n, localLabelCounter, nodeDepth);
            break;

        case NODE_AND:
            handleBinaryOperation(n, "and", localLabelCounter, nodeDepth);
            break;

        case NODE_OR:
            handleBinaryOperation(n, "or", localLabelCounter, nodeDepth);
            break;

        case NODE_CONCAT:
            // Handle NODE_CONCAT case if necessary
            break;

        default:
            return NULL;
    }

    if (newContextNode != NULL && (newContextNode->depth) >= 0) {
        if (newContextNode->depth == nodeDepth) {
            return checkNodeValue(newContextNode, localLabelCounter, newContextNode->depth);
        }
    }
    return newContextNode;
}

void checkAST(struct ast *n) {
    printVariables();
    fprintf(yyout, "\n.text\n");
    fprintf(yyout, "lwc1 $f31, zero\n");
    checkNodeValue(n, labelCount, 0);
    fprintf(yyout, "EXIT:\n");
}
