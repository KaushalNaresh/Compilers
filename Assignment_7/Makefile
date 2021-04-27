all:
	flex lex.l
	bison -d prog.y -v
	gcc prog.tab.c lex.yy.c -o output -lfl -g
	./output < input_code.txt
