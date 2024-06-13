#ifndef AST_H
#define AST_H

#include "types.h"

struct ast_node {
    type_t type;
    union {
        int int_val;
        float float_val;
        char* string_val;
        struct {
            char* name;
            struct ast_node* params;
            struct ast_node* body;
        } function;
        struct {
            struct ast_node* condition;
            struct ast_node* then_branch;
            struct ast_node* else_branch;
        } if_else;
    } value;
    struct ast_node* left;
    struct ast_node* right;
};

struct ast_node* create_int_node(int value);
struct ast_node* create_float_node(float value);
struct ast_node* create_string_node(char* value);
struct ast_node* create_id_node(char* name);
struct ast_node* create_arith_node(char op, struct ast_node* left, struct ast_node* right);
struct ast_node* create_relop_node(char* op, struct ast_node* left, struct ast_node* right);
struct ast_node* create_if_node(struct ast_node* condition, struct ast_node* body);
struct ast_node* create_if_else_node(struct ast_node* condition, struct ast_node* then_branch, struct ast_node* else_branch);
struct ast_node* create_for_node(struct ast_node* condition, struct ast_node* body);
struct ast_node* create_while_node(struct ast_node* condition, struct ast_node* body);
struct ast_node* create_continue_node();
struct ast_node* create_break_node();
struct ast_node* create_program_node();
struct ast_node* create_function_node(char* name, struct ast_node* body);
struct ast_node* create_return_node(struct ast_node* value);
struct ast_node* create_empty_node();
float get_float_value(struct ast_node* node);

#endif
