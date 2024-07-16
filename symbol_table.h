#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

#define MAX_SYMBOLS 512

typedef struct {  
    double* numVal;  
    char* strVal;            
    char *identifier;
    DataType dataType;
    int pos;            
} SymbolEntry;

extern SymbolEntry symbolTable[MAX_SYMBOLS];
extern int currentIndex;

int findSymbol(int currentIndex, char *identifier, SymbolEntry symbolTable[]);

#endif // SYMBOL_TABLE_H
