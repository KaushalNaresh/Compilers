# **Readme**
>## **Parser Using Flex And Bison**
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

This project simulates the working of Parser used by compilers to parse the input read from the file. I am implementing this Parser using flex (fast lexical analyzer) and Bison libraries. **Flex** reads the given input files (or its standard input if no file names are given) and prepare a symbol table and list of tokens which are then fed to parser prepared using **Bison**. Flex generates as output a C source file `lex.yy.c` and bison outputs `<file_name>.tab.c` both these files are compiled using gcc compiler. 

</div>

>## How to run
<div style="text-align: justify">

You need to install flex `sudo apt-get install flex` and must have gcc compiler for compilation of `lex.yy.c` and `<file_name>.tab.c` file.

I have prepared a makefile which contains all the necessary commands to compile and run `.l` and `.y` file with input given in `input_code.txt` In order to run this parser create a new folder and unzip the file provided `170030027.zip` After unzipping you will get 4 files `lex.l` , `prog.y`, `input_code.txt` and `Makefile` Now open console in the new folder you have created and enter the following command.

</div>

```bash
make
```  
<div style="text-align: justify">  

Once you enter the command it will print identifiers and datatypes as detected by parser. Along with this it will also print some common errors like *Invalid Token* whenever required.

</div>  

>## Terminal Output

```Shell
make
iostream.h : library
int : data_type
main : Function_id
int : data_type
h : Varlist_id
g : Varlist_id
f : Varlist_id
float : data_type
d : Varlist_id
string : data_type
s : Varlist_id
Parsing Successful
```
### Input Text File

```cpp
/* This is a test program*/
#include<iostream.h>

int main(){
	int f, g, h;
	float d;
	string s;
}
```

>## Further Queries

For further queries please contact the creator <naresh.kaushal.17003@iitgoa.ac.in>  
**Happy coding !!**



