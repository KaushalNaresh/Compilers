all:
	flex lexer.l
	bison -d -v advanced_parser.y -t
	gcc advanced_parser.tab.c lex.yy.c -o output -lfl -g
	./output < input_code.txt
