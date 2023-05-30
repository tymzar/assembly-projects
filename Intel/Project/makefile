CC=g++
ASMBIN=nasm

build32 : asm cc link clean_build

build64: asm64 cc64 link64 clean_build64

asm : 
	$(ASMBIN) -f elf32 -g -l encodeRM4SCC.lst encodeRM4SCC.asm

cc :
	$(CC) -m32 -c -g -O0 main.cpp &> errors.txt

link :
	$(CC) -m32 -no-pie -g -o main32 main.o encodeRM4SCC.o


asm64 : 
	$(ASMBIN) -f elf64 -g -l encodeRM4SCC64.lst encodeRM4SCC64.asm

cc64 :
	$(CC) -m64 -c -g -O0 main.cpp &> errors.txt

link64 :
	$(CC) -m64 -no-pie -g -o main64 main.o encodeRM4SCC64.o


clean_build :
	rm *.o
	rm encodeRM4SCC.lst
	rm errors.txt	

clean_build64 :
	rm *.o
	rm encodeRM4SCC64.lst
	rm errors.txt	

clean :
	rm main32
	rm main64
