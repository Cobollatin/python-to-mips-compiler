/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_PARSER_TAB_H_INCLUDED
# define YY_YY_PARSER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    MULTIPLY = 258,                /* MULTIPLY  */
    IF = 259,                      /* IF  */
    ELSE = 260,                    /* ELSE  */
    WHILE = 261,                   /* WHILE  */
    NEWLINE = 262,                 /* NEWLINE  */
    EMPTY = 263,                   /* EMPTY  */
    BLOCK_START = 264,             /* BLOCK_START  */
    DIVIDE = 265,                  /* DIVIDE  */
    ADD = 266,                     /* ADD  */
    SUBTRACT = 267,                /* SUBTRACT  */
    EQUAL = 268,                   /* EQUAL  */
    OPENPAREN = 269,               /* OPENPAREN  */
    CLOSEPAREN = 270,              /* CLOSEPAREN  */
    PRINT = 271,                   /* PRINT  */
    NOT = 272,                     /* NOT  */
    LESS = 273,                    /* LESS  */
    GREATER = 274,                 /* GREATER  */
    NOTEQUAL = 275,                /* NOTEQUAL  */
    EQUALS = 276,                  /* EQUALS  */
    GREATEREQUAL = 277,            /* GREATEREQUAL  */
    LESSEQUAL = 278,               /* LESSEQUAL  */
    ADDEQUAL = 279,                /* ADDEQUAL  */
    SUBTRACTEQUAL = 280,           /* SUBTRACTEQUAL  */
    OPENBRACE = 281,               /* OPENBRACE  */
    CLOSEBRACE = 282,              /* CLOSEBRACE  */
    FUNCTION = 283,                /* FUNCTION  */
    RETURN = 284,                  /* RETURN  */
    BREAK = 285,                   /* BREAK  */
    CONTINUE = 286,                /* CONTINUE  */
    ARRAY = 287,                   /* ARRAY  */
    SEMICOLON = 288,               /* SEMICOLON  */
    FOR = 289,                     /* FOR  */
    RANGE = 290,                   /* RANGE  */
    IN = 291,                      /* IN  */
    COMMA = 292,                   /* COMMA  */
    INDEX = 293,                   /* INDEX  */
    NUMERIC = 294,                 /* NUMERIC  */
    TABS = 295,                    /* TABS  */
    DECIMALNUMERIC = 296,          /* DECIMALNUMERIC  */
    IDENTIFIER = 297,              /* IDENTIFIER  */
    STRING = 298,                  /* STRING  */
    BOOLEAN = 299,                 /* BOOLEAN  */
    OR = 300,                      /* OR  */
    AND = 301                      /* AND  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 14 "parser.y"

    int intVal;
    float floatVal;
    char *stringVal;
    struct attributes {
        int numeric;
        float numericDecimal;
        char *strVal;
        int type;
        struct ast *n;
    } attr;

#line 123 "parser.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_PARSER_TAB_H_INCLUDED  */
