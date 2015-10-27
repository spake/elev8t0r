AVRASM2 = wine tools/AvrAssembler2/avrasm2.exe -I tools/AvrAssembler2/Appnotes
PROGRAM = tools/programmer/program.sh

elev8t0r.hex: elev8t0r.asm
	$(AVRASM2) -fI -W+ie -C V3 -o '$@' '$^'


.PHONY: clean program

program: elev8t0r.hex
	$(PROGRAM) elev8t0r.hex

clean:
	rm -f elev8t0r.hex

