Project Title:  
LyricsLang – A Millennial-Inspired Custom Language Compiler

Description:  
This project implements a custom compiler for a modern slang-based programming language called LyricsLang, built using Flex (Lex) and Bison (Yacc). The language features fun and relatable keywords like SET, SAY, IFY, NOPE, DONE, ASK, and CALL.

The compiler performs:
- Lexical Analysis (Flex)
- Syntax Analysis (Bison)
- Code Generation for:
  - Three Address Code (output.tac)
  - Assembly-like Code (output.asm)

Supported features:
- Variable declaration and assignment
- Arithmetic operations
- Conditional statements (IFY / NOPE)
- Input and Output (ASK / SAY)
- Function definitions (DO) and function calls (CALL)
- String and integer operations

Developed By:  
Name: RISHI MATHUR 
Roll Number: 22000908 

Files Included:
- lyricslang.l         → Lexical analyzer
- lyricslang.y         → Syntax analyzer + code generation
- output.tac           → Generated three-address code
- output.asm           → Generated assembly-like code
- README.txt           → Project documentation
- 22000908_CD_LAB_MAUNUAL.docx       → Lab manual 

How to Compile and Run:

Step 1: Install Flex and Bison (if not already installed)
sudo apt install flex bison

Step 2: Compile the project
flex lyricslang.l  
bison -d lyricslang.y  
gcc lex.yy.c lyricslang.tab.c -o lyricslang

Step 3: Run the compiler
./lyricslang input.txt

Step 4: View the generated output
cat output.tac  
cat output.asm

Note:
- Make sure your input file (input.txt) is written in LyricsLang syntax.
- Ensure input.txt is in the same directory while running the compiler.
