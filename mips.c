#include <stdio.h>
#include "mips.h"
#include "ast.h"


void print_node_type(struct ast_node* node) {
    if(node == NULL) {
        return;
    }
    if(node->left != NULL) {
        print_node_type(node->left);
    }
    if(node->right != NULL) {
        print_node_type(node->right);
    }
    printf("Node type: %d\n", node->type);
}

void generate_mips_code(struct ast_node* root) {
    printf("Generating MIPS code...\n");
    print_node_type(root);
}