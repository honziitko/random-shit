SRC=xor-linked-list

build/$(SRC) : build/$(SRC).o build/helper.o
	cc -o build/$(SRC) build/$(SRC).o build/helper.o -static -static-libgcc -no-pie

build/$(SRC).o : $(SRC).asm
	@mkdir build -p
	fasm $(SRC).asm build/$(SRC).o

build/helper.o : helper/$(SRC).c
	cc -o build/helper.o helper/$(SRC).c -c
