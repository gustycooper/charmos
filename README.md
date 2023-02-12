# Charm
Charm consists of several components. You can read more at *[Charm Guide](https://gusty.bike/charm.html)*.
* Charm Instruction Set Architecture - definition of registers, register conventions, instructions, and instruction format.
* Charm Assembly Language - definition of an assembly language programmers can use to write Charm assembly programs.
* Charm Assembler - chasm - an assembler that translates Charm assembly language to a file format compatible with the Charm Emulator.
* Charm Emulator - chemu - An emulation of the Charm ISA. The emulation consists of one CPU and main memory. The output of chasm can be loaded into chemu and executed. There are two versions of chemu.
  * chemut - Emulation uses stdin, stdout, and stderr in a terminal for control and display.
  * chemun - Emulation uses ncurses to create control and display windows in the terminal.
* Charm C Compiler - a compiler that translates C into Charm assembly. I modified [Rui Ueyamm's chibicc](https://github.com/rui314/chibicc) to generate Charm Assembly.
* Charm Linker - a linker that links multiple Charm .o files into a_out.o.

This version of Charm is developing an OS that manages processes. 
* Matt Nguyen and Gusty are working on this.
* We have chasm, chemu, and chpre.
* chpre does not have a makefile. gcc -o chpre chepre.c
* We do not have chibicc at this time.

This version of charm includes a third version of chemu
* charmweb - a web interface to the emulator created by Lauren Knight as an independent study.

The organization of chemu in this repo has the charweb files in the chemu folder, with the chemun and chemun files in the chemu/src folder.

This allows charmweb to share the chemu C source code without have to duplicate it in the charmweb folder.

The Python program building structure allows .py to reference [ src/command.c ], but it does not allow references such as [ ../chemu/command.c ] I would have preferred parallel folders, but the subfolder will work.
