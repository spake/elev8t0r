AVRASM2 = wine tools/AvrAssembler2/avrasm2.exe -I tools/AvrAssembler2/Appnotes

elev8t0r.hex: elev8t0r.asm
	$(AVRASM2) -fI -W+ie -C V3 -o '$@' '$^'
