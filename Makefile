all:
	flex lex.l
	gcc lex.yy.c -o output -lfl
	./output < input_code.txt 
