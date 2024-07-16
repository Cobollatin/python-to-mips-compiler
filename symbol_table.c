#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"

#define MAX_SYMBOLS 512

SymbolEntry symbolTable[MAX_SYMBOLS];
int currentIndex = 0;

int findSymbol(int currentIndex, char *identifier, SymbolEntry symbolTable[]) {
    int foundIndex = -1;
    int i = 0;
    while (i < currentIndex) {
        if (i >= MAX_SYMBOLS) {
            printf("Overflow when searching for symbol %s\n", identifier);
            break;
        }

        if (strcmp(symbolTable[i].identifier, identifier) == 0 && strcmp("_", identifier) != 0) {
            foundIndex = i;
            break;
        }
        i++;
    }
    return foundIndex;
}
