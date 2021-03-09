all:
	bison -d prog.y
	flex lex.l
	gcc prog.tab.c lex.yy.c -o output -lfl
	./output < input_code.txt
