# **Readme**
>## **Lexical Analyser Using Flex**
> Name : Naresh Kumar Kaushal  
> Id : 170030027, Department : CSE, Term : Fourth Year  
> Course Instructor : Dr. Sudakshina Dutta
***

>## Table of Contents
1. [About](#about)
2. [How to run](#how-to-run)
3. [Terminal Output](#terminal-output)
4. [Further Queries](#further-queries)

>## About  
<div style="text-align: justify">

This project simulates the working of Lexical analyzer used by compilers to get the tokens and to prepare the symbol table after reading the input code file. I am implementing this Lexical Analyzer using flex (fast lexical analyzer). **Flex** reads the given input files (or its standard input if no file names are given) for a description of the scanner to generate. The description is in the form of pairs of regular expressions and C code, called rules. Flex generates as output a C source file `lex.yy.c` 

</div>

>## How to run
<div style="text-align: justify">

You need to install flex `sudo apt-get install flex` and must have gcc compiler for compilation of `lex.yy.c` file.

I have prepared a makefile which contains all the necessary commands to compile and run `.l` file with input given in `input_code.txt` In order to run this lexical analyzer create a new folder and unzip the file provided `170030027.zip` After unzipping you will get 3 files `lex.l` , `input1.txt` and `Makefile` Now open console in the new folder you have created and enter the following command.

</div>

```bash
make
```  
<div style="text-align: justify">  

Once you enter the command it will print list of tokens with their type i.e. Keywords, Identifier, special character, Arithmatic Operator or Relational Operator. Along with stream of token it will also print some common errors like *Variable not decalred* whenever required. After the list of tokens it will print symbol table with lexeme and datatype.

</div>  

>## Terminal Output

```Shell
make
Comments are ignored
void : KeyWord
add : Identifier
( : special_char
int : KeyWord
c : Identifier
) : special_char
{ : special_char
return : Keyword
a : Identifier
; : special_char
} : special_char
int : KeyWord
main : Identifier
( : special_char
) : special_char
{ : special_char
add : Identifier
( : special_char
2 : Integer
, : special_char
3 : Integer
) : special_char
; : special_char
} : special_char

Number of entries in symbol table is 2
c - int
a -
```
### Input Text File

```cpp
/* This is a test program*/
void add(int c){
    return a;
}
int main(){
    add(2, 3);
}
```

>## Further Queries

For further queries please contact the creator <naresh.kaushal.17003@iitgoa.ac.in>  
**Happy coding !!**



