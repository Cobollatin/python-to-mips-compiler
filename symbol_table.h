#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include "types.h"

void init_symbol_table();
int symbol_exists(const char *name);
void add_symbol(const char *name, type_t type);
void update_symbol(const char *name, type_t type);
type_t get_symbol_type(const char *name);
type_t current_function_return_type();

#endif
