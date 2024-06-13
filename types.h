#ifndef TYPES_H
#define TYPES_H

typedef enum {
    TYPE_INT,       //0
    TYPE_FLOAT,     //1
    TYPE_STRING,    //2
    TYPE_BOOL,      //3
    TYPE_FUNCTION,  //4
    TYPE_IF,        //5
    TYPE_FOR,       //6
    TYPE_WHILE,     //7
    TYPE_CONTINUE,  //8
    TYPE_BREAK,     //9
    TYPE_RETURN,    //10
    TYPE_ARITH,     //11
    TYPE_RELOP,     //12
    TYPE_ID,        //13
    TYPE_BLOCK,     //14
    TYPE_IF_ELSE,   //15
    TYPE_PROGRAM    //16
} type_t;

#endif