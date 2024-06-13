#include "symbol_table.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_SYMBOLS 100

typedef struct {
    char* name;
    type_t type;
} symbol;

static symbol symbol_table[MAX_SYMBOLS];
static int symbol_count = 0;
static type_t current_function_type = TYPE_INT; // Default type

void init_symbol_table() {
    symbol_count = 0;
}

int symbol_exists(const char* name) {
    for(int i = 0; i < symbol_count; i++) {
        if(strcmp(symbol_table[i].name, name) == 0) {
            return 1;
        }
    }
    return 0;
}

void add_symbol(const char* name, type_t type) {
    if(symbol_count < MAX_SYMBOLS) {
        symbol_table[symbol_count].name = strdup(name);
        symbol_table[symbol_count].type = type;
        symbol_count++;
    }
    else {
        fprintf(stderr, "Symbol table overflow\n");
    }
}

void update_symbol(const char* name, type_t type) {
    for(int i = 0; i < symbol_count; i++) {
        if(strcmp(symbol_table[i].name, name) == 0) {
            symbol_table[i].type = type;
            return;
        }
    }
    fprintf(stderr, "Symbol not found\n");
}

type_t get_symbol_type(const char* name) {
    for(int i = 0; i < symbol_count; i++) {
        if(strcmp(symbol_table[i].name, name) == 0) {
            return symbol_table[i].type;
        }
    }
    return TYPE_INT; // Default type if not found
}

type_t current_function_return_type() {
    return current_function_type;
}
