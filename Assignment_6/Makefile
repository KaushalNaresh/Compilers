all:
	bison -d prog.y -v
	flex lex.l
	gcc prog.tab.c lex.yy.c -o output -lfl -g
	./output < input_code.txt
