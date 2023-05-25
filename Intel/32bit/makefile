CC=g++
ASMBIN=nasm

all : asm cc link clean_build

asm : 
	$(ASMBIN) -f elf32 -g -l encodeRM4SCC.lst encodeRM4SCC.asm

cc :
	$(CC) -m32 -c -g -O0 main.cpp &> errors.txt

link :
	$(CC) -m32 -no-pie -g -o test main.o encodeRM4SCC.o

clean_build :
	rm *.o
	rm encodeRM4SCC.lst
	rm errors.txt	

clean :
	rm test
