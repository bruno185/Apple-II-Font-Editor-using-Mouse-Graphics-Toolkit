* 
* * * * MACROS * * * * 
*
        DO 0
cr      MAC             ; output CR
        lda #$8D
        jsr cout
        EOM
*
m_inc   MAC             ; inc 16 bits integer
        inc ]1
        bne m_incf
        inc ]1+1
m_incf  EOM

m_dec   MAC             ; dec 16 bits integer
        lda ]1
        bne m_decf
        dec ]1+1
m_decf  dec ]1
        EOM


* mov bytes from a memory address to another
* ]1 : start address
* ]2 : dest address
* ]3 : number of to move (<= 255)
movshort MAC
        ldx #$00
movml   lda ]1,x
        sta ]2,x
        inx
        cpx #]3
        bne movml
        EOM
*
*
* move n or 2n bytes 
* from memory pointed by ]1
* to memory pointed by ]2
* ]1 : start address
* ]2 : destination address
* ]3 : length to move
* ]4 : flag :
* =0 : 1 byte per element to move
* =1 : 2 bytes per element (length must be multiplied par 2)
memmov  MAC
        jmp mm1
mmstart hex 0000
mmdest  hex 0000
mmleng  hex 0000
* 
mm1     movshort sptr;mmstart;2         ; save sptr
        movshort ptr2;mmdest;2          ; save ptr2
*
        lda #<]1        ; put start address in sptr
        sta sptr
        lda #>]1
        sta sptr+1
        lda #<]2        ; put destination address in ptr2
        sta ptr2
        lda #>]2
        sta ptr2+1
        lda #]4         ; falg ?
        beq heightb
        lda ]3          ; length must be multiplied par 2
        asl
        sta mmleng      ; and stored in mmleng 
        lda ]3+1
        rol
        sta mmleng+1
        jmp domov0
heightb lda ]3          ; length stored in mmleng 
        sta mmleng
        lda ]3+1
        sta mmleng+1
domov0  ldy #$00
*
domov   lda (sptr),y    ; MOVE A BYTE
        sta (ptr2),y
        m_inc sptr      ; start pointer ++
        m_inc ptr2      ; dest pointer ++
        m_dec mmleng    ; length --
        lda mmleng      ; test length
        ora mmleng+1
        bne domov       ; finished ?

        movshort mmstart;sptr;2         ; restore sptr
        movshort mmdest;ptr2;2          ; restore ptr2
        EOM


* get value from array and index
* ]1 : array address (2 bytes)
* ]2 : address of index value (2 bytes)
* ]3 : array element value stored there (2 bytes)
getelem MAC
        jmp getele
goffset hex 0000
tmp     hex 0000
getele  lda #<]1        ; goffset = array address
        sta goffset
        lda #>]1
        sta goffset+1
        lda ]2          ; index x 2 (2 bytes per element)
        asl             ; stored in tmp
        sta tmp
        lda ]2+1
        rol
        sta tmp+1

        lda goffset     ; goffset = array addr. + index x 2
        clc
        adc tmp
        sta goffset
        lda goffset+1
        adc tmp+1
        sta goffset+1

        movshort goffset;ptr2;2 ; ptr2 points to array element
        ldy #$00
        lda (ptr2),y
        sta ]3
        iny
        lda (ptr2),y
        sta ]3+1
        EOM
*
* set value in array at index
* ]1 : array address (2 bytes)
* ]2 : address of index value (2 bytes)
* ]3 : value to store in array (2 bytes)
setelem MAC
        jmp setele
soffset hex 0000
stmp    hex 0000
setele  lda #<]1        ; soffset = array address
        sta soffset
        lda #>]1
        sta soffset+1

        lda ]2          ; index x 2 (2 bytes per element)
        asl             ; stored in stmp
        sta stmp
        lda ]2+1
        rol
        sta stmp+1
        lda soffset     ; soffset = array addr. + index x 2
        clc
        adc stmp
        sta soffset
        lda soffset+1
        adc stmp+1
        sta soffset+1
        movshort soffset;ptr2;2 ; ptr2 points to array element
        ldy #$00                ; poke value in array
        lda ]3
        sta (ptr2),y
        iny
        lda ]3+1
        sta (ptr2),y
        EOM
*
* Set CARRY if ]1 > ]2 (16 bits UNSIGNED values)
sup     MAC
        lda ]1+1
        cmp ]2+1
        beq egal        ; AH > BH see lo
        jmp supe        ; if A > B : C = 1, if A < B : C = 0
egal    lda ]1
        cmp ]2
        bne supe        ; A = B : C= 0; else C is set accordingly 
        clc 
supe    EOM
*
* Set CARRY if ]1 >= ]2 (16 UNSIGNED bits values)
supeq   MAC
        lda ]1+1
        cmp ]2+1
        beq egal2       ; hi(A) > hi (B) see lo
        jmp supeqe      ; if A >= B : C = 1, if A < B : C = 0
egal2   lda ]1
        cmp ]2
supeqe  EOM
*
* * Set CARRY if ]1 >= ]2 (16 bits SIGNED values)
ssupeq MAC
        lda ]1
        cmp ]2
        lda ]1+1
        sbc ]2+1
        bvc vneq        ; N eor V
        eor #$80
vneq    bmi doinfeq
        jmp dosupeq
doinfeq clc
        jmp ssup2eqe
dosupeq sec
ssup2eqe EOM
*
*
* Set CARRY if ]1 > ]2 (16 bits SIGNED values)
ssup MAC
        equal ]1;]2
        bcs doinf       ; clear C if equals
        lda ]1
        cmp ]2
        lda ]1+1
        sbc ]2+1
        bvc vn          ; N eor V
        eor #$80
vn      bmi doinf
        jmp dosup
doinf   clc
        jmp ssup2e
dosup   sec
ssup2e  EOM
*
*
* Set CARRY if ]1 = ]2 (16 bits values)
equal   MAC
        lda ]1
        cmp ]2
        bne noteq
        lda ]1+1
        cmp ]2+1
        bne noteq
        jmp okequal
noteq   clc
        jmp outeq
okequal sec
outeq   EOM

*
* print 16 bits value pointed by ]1
printm  MAC
        lda #"$"
        jsr cout
        ldx ]1+1
        jsr xtohex
        ldx ]1
        jsr xtohex
        EOM
*
* Display a 0 terminated string in argument
print   MAC             
        ldx #$00        
boucle  lda ]1,x
        beq finm
        ora #$80
        jsr cout
        inx
        jmp boucle
finm    EOM 
*
* Display string (length in 1st byte)
prnstr  MAC             
        ldy ]1
        beq prnste      ; no char.
        ldx #$00
lpstr   lda ]1+1,x
        ora #$80
        jsr cout
        inx
        dey
        bne lpstr
prnste  EOM
*
* 
* Set carry 
* 80 col : Carry = 1
* 40 col : Carry = 0
get80   MAC             
        lda col80
        bmi do80
        clc
        bcc do40        ; = jmp             
do80    sec
do40    EOM  

*
getlen  MAC             ; return string length in x
        ldx #$00
loopgetl lda ]1,x
        beq fgetlen
        inx
        jmp loopgetl
fgetlen  EOM
*
* Displays a 0 terminated string in argument 
* in center of screen
printc  MAC
        jmp mainpc
tempo   hex 00
mainpc  lda ]1       ; get length
        lsr             ; div 2 
        sta tempo
        get80           
        lda #$14        ; = half line
        bcc pc40
        lda #$28
pc40    sec
        sbc tempo
        tax 
        lda #" "        ; fill with spaces
esp     jsr cout
        dex
        bne esp
        prnstr ]1
        EOM
*
        FIN
*