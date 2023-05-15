CC=gcc
ASMBIN=nasm

all : asm cc link clean_build
asm : 
	$(ASMBIN) -o func.o -f elf -g -l func.lst func.asm
cc :
	$(CC) -m32 -c -g -O0 main.cpp &> errors.txt
link :
	$(CC) -m32 -g -o test main.o func.o

clean_build :
	rm *.o
	rm func.lst
	rm errors.txt	

clean :
	rm test

