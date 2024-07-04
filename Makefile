all: main

yemba: yemba.y yemba.l
	bison --defines=simple.h -v -o yemba.tab.c yemba.y
	flex -o yemba.yy.c yemba.l
	gcc yemba.yy.c yemba.tab.c -o yemba -lfl

main: main.o yemba
	ld -s -o main main.o -melf_i386 -I/lib/ld-linux.so.2 -lc

main.o: main.asm
	nasm -f elf -o main.o yemba.asm

main.asm: main.su yemba
	cat main.su | ./yemba
	