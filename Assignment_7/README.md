# **Readme**
>## **Intermediate Code Generator**
> Name : Naresh Kumar Kaushal  
> Id : 170030027, Department : CSE, Term : Fourth Year  
> Course Instructor : Dr. Sudakshina Dutta
***

>## Table of Contents
1. [About](#about)
2. [How to run](#how-to-run)
3. [Terminal Output](#terminal-output)
4. [Intermediate Code](#intermediate-code)
5. [Further Queries](#further-queries)

>## About  
<div style="text-align: justify">

This project simulates the process of generating IR code by compilers. I am generating IR using flex (fast lexical analyzer) and Bison libraries. **Flex** reads the given input files (or its standard input if no file names are given) and generates list of tokens which are then fed to parser prepared using **Bison** which parses the input code using grammar and along with symbol table varify the correctness of the code semantically. Flex then generates as output a C source file `lex.yy.c` and bison outputs `<file_name>.tab.c` both these files are then compiled using gcc compiler. After compilation ends `<file_name>.ll` file is generated which when run with `lli` compiler gives the output of the code if any.

</div>

>## How to run
<div style="text-align: justify">

You need to install flex `sudo apt-get install flex` and must have gcc compiler for compilation of `lex.yy.c` and `<file_name>.tab.c` file. Apart from these we also need lli compiler from [llvm.org](https://releases.llvm.org/) and clang using `sudo apt-get install clang`

I have prepared a makefile which contains all the necessary commands to compile and run `.l` and `.y` file with input given in `input_code.txt` In order to run this parser unzip the file provided `Naresh_Kaushal.zip` After unzipping you will get a folder Naresh_Kaushal which contains 2 folders  
1. `extra` folder contains `Makefile`, `input_code.txt`, `readme.pdf`  
2. `c_assignment7_170030027` folder contains `lex.l` , `prog.y`.   

First you need to make new folder and put all the files in one folder. Now open console in the new folder you have created and enter the following command.

</div>

```bash
make
```  
<div style="text-align: justify">  

Once you enter the command it will print tokens detected by parser according to the grammar rules. It also gives warning and errors in few cases like if variable is not declared, invalid operands to binary, invalid assignment like string to int etc. And at last it will print all the enteries of symbol table. Apart from output given on console it will also generate `.ll` file which contains the generated intermediate code.

This project simulates limited features of IR code generation. It uses only int and float as datatype and no implicit conversions take place. Instructions which are available in this IR code generator are load, store, alloca, add nsw, mul nsw, fadd and fmul. Fully functional IR code generator requires significant time and knowledge about various instructions that are available in llvm. 

</div>  

>## Terminal Output

```Shell
flex lex.l
bison -d prog.y -v
prog.y: warning: 5 reduce/reduce conflicts [-Wconflicts-rr]
gcc prog.tab.c lex.yy.c -o output -lfl -g
./output < input_code.txt
int : data_type
main : Function_id
int : data_type
b : Varlist_id
a : Varlist_id
float : data_type
d : Varlist_id 
c : Varlist_id
6 : Integer constant
a : Assignment_id
7.0 : Float constant
c : Assignment_id 
a : Expression_id
8 : Integer constant
b : Assignment_id 
c : Expression_id
6 : Integer constant
d : Assignment_id
Parsing Successful

Entries in symbol table :
main int
b int
a int
d float
c float
```

>## Intermediate Code

```llvm
; ModuleID = 'prog.c'
source_filename = "prog.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main() #0 {
	%1 = alloca i32, align 4
	%2 = alloca i32, align 4
	%3 = alloca float, align 4
	%4 = alloca float, align 4
	store i32 6, i32* %1, align 4
	store float 7.0.000000e+00, float* %3, align 4
	%5 = load i32, i32* %1, align 4
	%6 = mul nsw i32 %5, 8
	store i32 %6, i32* %2, align 4
	%7 = load float, float* %3, align 4
	%8 = fmul float %7, 6.000000e+00
	store float %8, float* %4, align 4
	ret i32 0
}

attributes #0 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.0-4ubuntu1 "}

```


### Input Text File

```cpp
/*This is the sample code */
int main()
    beg
        int a, b;
        float c, d;
        a = 6;
        c = 7.0;
        b = a*8;
        d = c*6;
    end
```

>## Further Queries

For further queries please contact the creator <naresh.kaushal.17003@iitgoa.ac.in>  
**Happy coding !!**



