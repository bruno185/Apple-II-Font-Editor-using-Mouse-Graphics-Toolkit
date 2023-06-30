;divisor = $58     ;$59 used for hi-byte
;dividend = $fb	  ;$fc used for hi-byte
;remainder = $fd	  ;$fe used for hi-byte
;result = dividend ;save memory by reusing divident to store the result

    org $800

divide	lda #0	        ;preset remainder to 0
	sta remainder
	sta remainder+1
	ldx #16	        ;repeat for each bit: ...

divloop	asl dividend	;dividend lb & hb*2, msb -> Carry
	rol dividend+1	
	rol remainder	;remainder lb & hb * 2 + msb from carry
	rol remainder+1
	lda remainder
	sec
	sbc divisor	;substract divisor to see if it fits in
	tay	        ;lb result -> Y, for we may need it later
	lda remainder+1
	sbc divisor+1
	bcc skip	;if carry=0 then divisor didn't fit in yet

	sta remainder+1	;else save substraction result as new remainder,
	sty remainder	
	inc result	;and INCrement result cause divisor fit in 1 times

skip	dex
	bne divloop	
	rts


divisor     dw 18
dividend    dw 16
remainder   dw 0
result      equ dividend