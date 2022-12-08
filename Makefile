all: turing_machine_emulator translator
	rm turing_machine_emulator.o
turing_machine_emulator: turing_machine_emulator.o
	ld -m elf_x86_64 turing_machine_emulator.o -o turing_machine_emulator
turing_machine_emulator.o: turing_machine_emulator.asm
	as --64 -c turing_machine_emulator.asm -o turing_machine_emulator.o
translator: translator.cpp
	g++ -std=c++11 translator.cpp -o translator
