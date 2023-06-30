************ ROM routines ************ 
home            equ $FC58       ; clear text screen, reset margins
text            equ $FB2F       ; text mode
Bell            equ $FBDD       ; play a sound
cout            equ $FDED       ; print char in A
vtab            equ $FC22       ; vert. tab, value must be in CV ($25)
getln           equ $FD6A       ; read line of input (=> X = length, buffer = $200)
getlnz          equ $FD67       ; = return + getln
getln1          equ $FD6F       ; = getln without prompt 
bascalc         equ $FBC1       ; calc. address of line in A, put address in $28/$29
crout           equ $FD8E       ; print carriage return 
clreop          equ $FC42       ; clear from cursor to end of page
clreol          equ $FC9C       ; clear from cursor to end of line
prntx           equ $F944       ; prints X in hex (2 digits)
prbyte          equ $FDDA       ; prints A in hex (2 digits)
printax         equ $F941       ; Prints current contents of the A and X in hex
prntyx          equ $F940       ; Prints current contents of the Y and X in hex
rdkey           equ $FD0C       ; wait for keypress
wait            equ $FCA8       ; monitor delay
AUXMOV          equ $C311
OUTPORT         equ $FE95
prnxy           equ $F940
*
************ ROM switches ************  
RAMRDON         equ $C003       ; read aux  
RAMRDOFF        equ $C002       ; read main
RAMWRTOFF       equ $C004       ; write to main
RAMWRTON        equ $C005       ; write to aux
ALTCHARSET0FF   equ $C00E 
ALTCHARSET0N    equ $C00F
kbd             equ $C000       ; ascii code of last key pressed (+ 128 if strobe not cleared) 
kbdstrb         equ $C010
col80off        equ $C00C
col80on         equ $C00D
80col           equ $C01F 	 
*
************ page 0 ************  
cv              equ $25
ch              equ $24 
basl            equ $28
wndlft          equ $20
wndwdth         equ $21
wndtop          equ $22         ; Top Margin (0 - 23, 0 is default, 20 in graphics mode)
wndbtm          equ $23 
prompt          equ $33
*
ourch           equ $57B      ; Cursor's column position minus 1 (HTAB's place) in 80-column mode
ourcv           equ $5FB      ; 80 col vertical pos
*
************ ProDOS ************ 
GETBUFR         equ $bef5
FREEBUFR        equ $BEF8 
devnum          equ $BF30       ; last used device here, format : DSSS0000 
RSHIMEM         equ $BEFB
*
************ MLI calls (ProDOS) ************
MLI             equ $BF00
create          equ $C0
destroy         equ $C1
online          equ $C5
getprefix       equ $c7
setprefix       equ $c6
open            equ $C8
close           equ $CC
read            equ $CA
write           equ $CB
setmark         equ $ce
geteof          equ $d1 
quit            equ $65
*
************ FP routines ************
float           equ $E2F2       ; Converts SIGNED integer in A/Y (high/lo) into FAC 
GIVAYF          equ $E2F2       ; idem
FLOAT2          equ $EBA0       ; "Float2" entry point (https://6502disassembly.com/a2-rom/Applesoft.html#SymLDAB7)
                                ; Float UNSIGNED value in FAC+1,2 (hi,low)
                                ; X-reg = exponent ; C=0 to make value negative, C=1 to make value positive

PRNTFAC         equ $ED2E       ; Prints number in FAC (in decimal format). FAC is destroyed
FIN             equ $EC4A       ; FAC = expression pointed TXTPTR
FNEG            equ $EED0       ; FAC = - FAC
FABS            equ $EBAF       ; FAC = ABS(FAC)
F2INT16         equ $E752       ; FAC to 16 bits int in A/Y and $50/51 (low/high)
FADD            equ $E7BE       ; FAC = FAC + ARG 
FSUBT           equ $E7AA       ; FAC = FAC - ARG
FMULT           equ $E97F       ; Move the number pointed by Y,A into ARG and fall into FMULTT 
FMULTT          equ $E982       ; FAC = FAC x ARG
FDIVT           equ $EA69       ; FAC = FAC / ARG
RND             equ $EFAE       ; FAC = random number
FOUT            equ $ED34       ; Create a string at the start of the stack ($100−$110)
MOVAF           equ $EB63       ; Move FAC into ARG. On exit A=FACEXP and Z is set
CONINT          equ $E6FB       ; Convert FAC into a single byte number in X and FACLO
YTOFAC          equ $E301       ; Float y 
MOVMF           equ $EB2B       ; Routine to pack FP number. Address of destination must be in Y
                                ; (high) and X (low). Result is packed from FAC                             
QUINT           equ $EBF2       ; convert fac to 16bit INT at $A0 and $A1 (fac+3/fac+4)
STROUT          equ $DB3A       ; 
LINPRT          equ $ED24       ; Converts the unsigned hexadecimal number in X (low) and A (high) into a decimal number and displays it.

* A intégrer :
*FSUB = $E7A7    OVERFLOW = $E8D5        ONE = $E913        FLOG = $E941    CONUPK = $E9E3  MUL10 = $EA39 
* FDIV = $EA66        DIVERR = $EAE1        MOVFM = $EAF9    FLOAT = $EB93        FCOMP = $EBB2      
* FINT = $EC23   SQR = $EE8D        FPWRT = $EE9    FEXP = $EF09      FCOS = $EFEA    FSIN = $EFF1  FTAN = $F03A 
* PIHALF = $F066   FATN = $F09E        
*
************ Applesoft BASIC ************
TXTTAB          equ $67         ; $67/$68 address of beginning of BASIC Program ($0801 is default)
PRGEND          equ $AF         ; $AF/$B0 address of end of Applesoft program plus 1 or 2 of BASIC  
VARTAB          equ $69         ; $69/$6A address of beginning of simple variables, just after Basic prog. (unless modified by LOMEN)
ARYTAB          equ $6B         ; $6B/$6C addresse of beginning of array variables, just after simple variables
STREND          equ $6D         ; $6D/$6E addresse of end of array variables
MEMSIZ          equ $73         ; $73/$74 : top of string data, set by HIMEM: (usually $9600),
FRETOP          equ $6F         ; $6F/$70 bottom of string data, growing downwards 
CHRGOT          equ $B7         ; get char pointed by TXTPTR in A
CHRGET          equ $B1         ; advance TXTPRT and read char
TXTPTR          equ $B8         ; pointer $B8/$B9 used in chrget and chrgot
CHKCOM          equ $DEBE       ; check for comma and move TXTPTR forward
FRMNUM          equ $DD67       ; eval num. value, variable, expression pointed by TXTPTR, advance TXTPTR
GETADR          equ $E752       ; convert FAC to integer (to Y,A)
FRMEVL          equ $DD7B       ; evaluate any expression, result in FAC.
FRESTR          equ $E5FD       ; check if epression is a string. A = length, pointer in $5E/$5F
ERRDIR          equ $E306       ; illegal direct if not running

PTRGET          equ $DFE3       ; On entry, TXTPTR must be pointing to the first character of the variable's name. 
* finds an Applesoft variable's memory address and puts a pointer to it in VARPNT ($83-$84) and in A/Y (low/hi). 
* The variable's name is left in VARNAM ($81-$82). It will work with any type of variable (integer, array element, string..)
* If the variable does not already exist, PTRGET will create it for you
* Advances TXTPTR.
* Set : vartype equ $11 ; str$=$ff, num=$00 
* set : numtype equ $12 ; int =$80, real = $00

CHKNUM         equ $DD6A      ; verifies that the most recent var found by PTRGET was numeric.
 *  https://www.brutaldeluxe.fr/documentation/thesourcerorsapprentice/thesourcerorsapprentice_v1n1.pdf
 * Type mismatch error if var not numeric
