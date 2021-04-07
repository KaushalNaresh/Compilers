# **Readme**
>## **Semantic Analysis Using Flex And Bison**
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

This project simulates the working of Semantic Analyser used by compilers. I am implementing semantic analyser using flex (fast lexical analyzer) and Bison libraries. **Flex** reads the given input files (or its standard input if no file names are given) and generates list of tokens which are then fed to parser prepared using **Bison** which parses the input code using grammar and along with symbol table varify the correctness of the code semantically. Flex generates as output a C source file `lex.yy.c` and bison outputs `<file_name>.tab.c` both these files are then compiled using gcc compiler. 

</div>

>## How to run
<div style="text-align: justify">

You need to install flex `sudo apt-get install flex` and must have gcc compiler for compilation of `lex.yy.c` and `<file_name>.tab.c` file.

I have prepared a makefile which contains all the necessary commands to compile and run `.l` and `.y` file with input given in `input_code.txt` In order to run this parser unzip the file provided `Naresh_Kaushal.zip` After unzipping you will get a folder Naresh_Kaushal which contains 2 folders  
1. `extra` folder contains `Makefile`, `input_code.txt`, `readme.pdf`  
2. `c_assignment5_170030027` folder contains `lex.l` , `prog.y`.   

First you need to make new folder and put all the files in one folder. Now open console in the new folder you have created and enter the following command.

</div>

```bash
make
```  
<div style="text-align: justify">  

Once you enter the command it will print tokens detected by parser according to the grammar rules. It also gives warning and errors in few cases like if variable is not declared, invalid operands to binary, invalid assignment like string to int etc. And at last it will print all the enteries of symbol table. 

</div>  

>## Terminal Output

```Shell
bison -d prog.y -v
prog.y: warning: 10 shift/reduce conflicts [-Wconflicts-sr]
prog.y: warning: 8 reduce/reduce conflicts [-Wconflicts-rr]
flex lex.l
gcc prog.tab.c lex.yy.c -o output -lfl -g
./output < input_code.txt
int : data_type 
main : Function_id
int : data_type
a : Varlist_id
float : data_type
c : Varlist_id
b : Varlist_id
b : Expression_id
c : Expression_id
Warning: float is assigned to int value
a : Assignment_id
0 If Statement 
a : Expression_id
b : Expression_id
b : Expression_id
c : Expression_id
Warning: float is assigned to int value
a : Assignment_id
else Statement for 0 if
b : Expression_id
c : Expression_id
Warning: float is assigned to int value
a : Assignment_id
While Statement
a : Expression_id
b : Expression_id
a : Expression_id
c : Expression_id
d : Expression_id 
Error: d not declared
a : Assignment_id
Parsing Successful

Entries in symbol table :
main int
a int
c float
b float
```
### Input Text File

```cpp
/*This is the sample code */
#include<bits/stdc++.h>
int main()
{
    int a;
    float b, c;
    a = b + c;
    if(a>b){ a = b + c;}else{ a = b - c; }
    while(a<b){ a = a+c+d;}
}
```

>## Further Queries

For further queries please contact the creator <naresh.kaushal.17003@iitgoa.ac.in>  
**Happy coding !!**



