divide:
	; takes two numbers r16 and r17
	; sets r16 := r16 / r17, r17 := r16 % r17

	push r18
	ldi r18, 0 ; stores r16 / r17

divide_loop:
	cp r16, r17
	brlo divide_finish
	inc r18
	sub r16, r17
	rjmp divide_loop

divide_finish:
	mov r17, r16 ; r16 % r17
	mov r16, r18 ; r16 / r17

	pop r18
	ret
