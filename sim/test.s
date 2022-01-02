.text
main:   add		t6, x0, x0
        beq		t6, x0, finish

# This shouldn't be reached
deadend: beq	t6, x0, deadend        

finish:
        lw		t4, 0(x0)
        lw		t5, 4(x0)
        sw		t5, 0xFF(t4)
        beq		t6, x0, deadend

