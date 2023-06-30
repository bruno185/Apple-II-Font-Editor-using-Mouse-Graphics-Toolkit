;           lda #$4A
;           jsr $bef5
;           lda #$20
;           jsr $bef5

callstack
            dw $8000
ptrzp       equ 8

poke_event  
            bne goodevt
            rts                     ; event = 0 : rts

goodevt     inc callstack
            bne noinc1
            inc callstack+1
noinc1      
            cmp #$06
            bne no6
            nop
no6         ldx callstack
            stx ptrzp
            ldx callstack+1
            stx ptrzp+1
            ldy #$00
            sta (ptrzp),y 
            rts

test_getbuffer
            lda #1
            ldy #2
            jsr $E2F2
            lda #$00 
            ldy #$0a
dopoke      sta $100,y 
            dey 
            bne dopoke
            jsr $ED34
            rts

