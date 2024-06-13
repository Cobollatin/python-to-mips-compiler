#include "ast.h"
#include "symbol_table.h"
#include <stdlib.h>
#include <string.h>

struct ast_node* create_int_node(int value) {
    struct ast_node* node = (struct ast_node*)malloc(sizeof(struct ast_node));
    node->type = TYPE_INT;
    node->value.int_val = value;
    node->left = node->right = NULL;
    return node;
}

struct ast_node* create_float_node(float value) {
    struct ast_node* node = (struct ast_node*)malloc(sizeof(struct ast_node));
    node->type = TYPE_FLOAT;
    node->value.float_val = value;
    node->left = node->right = NULL;
    return node;
}

struct ast_node* create_string_node(char* value) {
    struct ast_node* node = (struct ast_node*)malloc(sizeof(struct ast_node));
    node->type = TYPE_STRING;
    node->value.string_val = strdup(value);
    node->left = node->right = NULL;
    return node;
}

struct ast_node* create_id_node(char* name) {
    struct ast_node* node = (struct ast_node*)malloc(sizeof(struct ast_node));
    node->type = TYPE_ID;
    node->value.string_val = strdup(name);
    node->left = node->right = NULL;
    return node;
}

struct ast_node* create_arith_node(char op, struct ast_node* left, struct ast_node* right) {
    struct ast_node* node = (struct ast_node*)malloc(sizeof(struct ast_node));
    node->type = TYPE_ARITH;
    node->value.int_val = op;
    node->left = left;
    node->right = right;
    return node;
}

struct ast_node* create_relop_node(char* op, struct ast_node* left, struct ast_node* right) {
    struct ast_node* node = (struct ast_node*)malloc(sizeof(struct ast_node));
    node->type = TYPE_RELOP;
    node->value.string_val = strdup(op);
    node->left = left;
    node->right = right;
    return node;
}

struct ast_node* create_if_node(struct ast_node* condition, struct ast_node* body) {
    struct ast_node* node = (struct ast_node*)malloc(sizeof(struct ast_node));
    node->type = TYPE_IF;
    node->value.if_else.condition = condition;
    node->value.if_else.then_branch = body;
    node->value.if_else.else_branch = NULL;
    return node;
}

struct ast_node* create_if_else_node(struct ast_node* condition, struct ast_node* then_branch, struct ast_node* else_branch) {
    struct ast_node* node = (struct ast_node*)malloc(sizeof(struct ast_node));
    node->type = TYPE_IF_ELSE;
    node->value.if_else.condition = condition;
    node->value.if_else.then_branch = then_branch;
    node->value.if_else.else_branch = else_branch;
    return node;
}

struct ast_node* create_for_node(struct ast_node* condition, struct ast_node* body) {
    struct ast_node* node = (struct ast_node*)malloc(sizeof(struct ast_node));
    node->type = TYPE_FOR;
    node->value.if_else.condition = condition;
    node->value.if_else.then_branch = body;
    return node;
}

struct ast_node* create_while_node(struct ast_node* condition, struct ast_node* body) {
    struct ast_node* node = (struct ast_node*)malloc(sizeof(struct ast_node));
    node->type = TYPE_WHILE;
    node->value.if_else.condition = condition;
    node->value.if_else.then_branch = body;
    return node;
}

struct ast_node* create_continue_node() {
    struct ast_node* node = (struct ast_node*)malloc(sizeof(struct ast_node));
    node->type = TYPE_CONTINUE;
    return node;
}

struct ast_node* create_break_node() {
    struct ast_node* node = (struct ast_node*)malloc(sizeof(struct ast_node));
    node->type = TYPE_BREAK;
    return node;
}

struct ast_node* create_program_node() {
    struct ast_node* node = (struct ast_node*)malloc(sizeof(struct ast_node));
    node->type = TYPE_PROGRAM;
    node->left = node->right = NULL;
    return node;
}

struct ast_node* create_function_node(char* name, struct ast_node* body) {
    struct ast_node* node = (struct ast_node*)malloc(sizeof(struct ast_node));
    node->type = TYPE_FUNCTION;
    node->value.function.name = strdup(name);
    node->value.function.body = body;
    return node;
}

struct ast_node* create_return_node(struct ast_node* value) {
    struct ast_node* node = (struct ast_node*)malloc(sizeof(struct ast_node));
    node->type = TYPE_RETURN;
    node->value.if_else.then_branch = value;
    return node;
}

struct ast_node* create_empty_node() {
    struct ast_node* node = (struct ast_node*)malloc(sizeof(struct ast_node));
    node->type = TYPE_BLOCK;
    node->left = node->right = NULL;
    return node;
}

float get_float_value(struct ast_node* node) {
    if(node->type == TYPE_INT) {
        return (float)node->value.int_val;
    }
    else if(node->type == TYPE_FLOAT) {
        return node->value.float_val;
    }
    else if(node->type == TYPE_ID) {
        // We evaluate its int_val and its float_val as the same, we return the one that is not null
        if(node->value.int_val != 0) {
            return (float)node->value.int_val;
        }
        else {
            return node->value.float_val;
        }
    }
}