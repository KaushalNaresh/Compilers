# **Readme**
>## **Lexical Analyser Using Python**
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

This project simulates the working of Lexical analyzer used by compilers to get the tokens and to prepare the symbol table after reading the input code file. I am implementing this Lexical Analyzer using Python.

</div>

>## How to run
<div style="text-align: justify">

To run this lexical analyzer on your machine you need to download python3. Move the zip file provided `170030027.zip` to the folder location where you want to unzip it. After unzipping you will get 3 files `170030027.py` (source code) and `readme.txt` (readme) and `input_code.txt` (sample input code) 

</div>

```bash
python 170030027.py
```  
<div style="text-align: justify">  

After pressing enter you can see the output on your terminal. First table lists all tokens with their type (Keyword, Identifier, Num or const) Second is the symbol table which prints all the identifiers along with their data types provided that its the function name, variable name.

</div>  

>## Terminal Output

```Shell
SYMBOL TABLE

lexeme - DataType
add - int
c - int
a - int


TOKEN TABLE

Token - type
int - Keyword
add - Identifier
c - Identifier
a - Identifier
return - Keyword
main - Identifier
2 - Num
3 - Num
```
### Input Text File

```cpp
/* This is a test program*/
int add(int c){
	int a;
    return a;
}
int main(){
    add(2, 3);
}
```

>## Further Queries

For further queries please contact the creator <naresh.kaushal.17003@iitgoa.ac.in>  
**Happy coding !!**



