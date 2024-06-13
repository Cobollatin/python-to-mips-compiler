echo ========================================
echo = Building the parser
bison -d -v parser.y
echo ========================================
echo = Building the lexer
flex -o lex.yy.c lexer.l
echo ========================================
echo = Building the compiler
gcc lex.yy.c parser.tab.c ast.c symbol_table.c mips.c  -o compiler -lfl -ly
echo ========================================
echo = Running the compiler
./compiler < test.py > output.asm