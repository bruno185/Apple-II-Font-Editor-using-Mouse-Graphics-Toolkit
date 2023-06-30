            TK_call HideCursor;0
            ******** to prevent display bug on update ********
                ;lda MyWindow
                ;sta GWParms ; Get the port for the current window
                ;TK_call GetWinPort;GWParms
                ;TK_call SetPort;TempPort ; Set the port there  
            **************************************

            TK_call MoveTo;MyPoint              ; move pen to position 
            ; MoveTo : Moves the current pen location to tha specified point (x, y: integer)
            ; Parameters :
                ; a_point: point (input) new pen location (x, y: integer)
            TK_call DrawText;MyText             ; draw a string (Character : ...)

ShowChar
            ldx DispChar                        ; get ascii value of char to display
            jsr GetCharVal                      ; get all 9 bytes of this char in MyChar array
            jsr InitBitBox                      ; set bitmaps view loc top left = BasePoint
            ldx #00 
            stx row 

ShowChar_1  lda MyChar,x                        ; get a byte of the char in var TheChar
            sta TheChar                         ; save it in a var
            ldy #07                             ; init lsr counter 
            sty col 

ShowChar_2  lsr TheChar                         ; get a bit from TheChar
            bcc paintWhite                      ; bit = 0 : paint a white rectangle
            TK_call PaintBits;BlackBits         ; paint it black
            bra ShowChar_3                      ; always jmp (unless error in PaintBits call)
paintWhite  TK_call PaintBits;WhiteBits         ; or paint it white

ShowChar_3  dec col 
            beq nextline                        ; 7 lsr ?
            jsr MoveBitsX                       ; no : move view loc of bitmaps 18 pixels right
            jmp ShowChar_2                      ; loop 
             

nextline    
            jsr IntiBitBoxX                     ; new line of bitmaps
                                                ; set box.x to BasePoint.x
            jsr MoveBitsY                       ; move bitmaps down 
            ldy #7                              ; re-init lsr counter
            sty col
            inc row                             ; next line
            ldx row
            cpx #9
            bne ShowChar_1
            TK_call ShowCursor;0
            rts

InitBitBox                                      ; copy data fom BasePoint
                                                ; to BlackBits and WhiteBits view loc
            ldx #00                             ; top.left.x
:1          lda BasePoint,x                     
            sta BlackBits,x
            sta WhiteBits,x            
            inx 
            cpx #4
            bne :1
            rts 

MoveBitsX                                       ; move bitmaps view loc 18 pixels right
            lda BlackBits                       ; x
            clc
            adc #20                             ; add 18 + 2 (for space between blocs) 
            sta BlackBits
            sta WhiteBits
            lda BlackBits+1
            adc #0
            sta BlackBits+1
            sta WhiteBits+1   
            rts

MoveBitsY                                       ; move bitmap view loc 10 pix down
            lda BlackBits+2                     ; move top.left corner down 10 pixels
            clc 
            adc #11                             ; add 10 + 1 (for space between blocs)  
            sta BlackBits+2
            sta WhiteBits+2 
            lda BlackBits+3
            adc #00
            sta BlackBits+3
            sta WhiteBits+3             
            rts

IntiBitBoxX                                     ; set box.x to BasePoint.x
            ldx #00                             ; 
:1          lda BasePoint,x                     
            sta BlackBits,x
            sta WhiteBits,x            
            inx 
            cpx #2
            bne :1 

            rts  


DrawWin3    equ *                           ; CharsWindow
                                            ; display 128 chars (ascii 0 to 127), 8 rows of 16 chars
            ldx #3
DW3_1       lda OrigCharPoint,x             ; copy OrigCharPoint (dw 10,13) to CharPoint (4 bytes)
            sta CharPoint,x                 ; CharPoint = pen position
            dex
            bpl DW3_1
            lda #0
            sta CurChar                     ; init CurChar var to 0 (CurChar = ascii value of char to display)
            sta K1                          ; save it to K1 var = char counter, from 0 to 15 (16 chars)
            sta K2                          ; save it to K2 var = line counter, from 0 to 7 (8 lines)
DW3_2       TK_call MoveTo;CharPoint        ; move pen to position 
            ; MoveTo : Moves the current pen location to tha specified point (x, y: integer)
            ; Parameters :
            ; a_point: point (input) new pen location (x, y: integer)
            TK_call DrawText;TextData       ; draw a char
            ; DrawText : Draws the text scored at the specified address at the current pen
            ; locacion. Text is drawn in either black or whice, wich the
            ; background in the inverse color. (See SetTextBG.)
            ; Parameters:
                ; textptr: pointer (input) address of text
                ; textlen: byte (input) number of characters to use

            inc CurChar ; increment the current character
            clc ; calculate the new X position
            lda CharPoint
            adc #DeltaX                     ; +16 pixels to the right
            sta CharPoint                   ; update CharPoint 
            inc K1 ; increment the inner loop counter 
                                            ; next char
            lda K1
            cmp #16 ; check to see if inner loop is done.
                                            ; 16 chars drawn ?
            bcc DW3_2                       ; no : loop (draw the next char on the same line)
            lda OrigCharPoint ; reset x coordinate 
            sta CharPoint
            lda OrigCharPoint+1
            sta CharPoint+1
            clc ; calculate a new Y coordinate
            lda CharPoint+2
            adc #DeltaY                     ; +16 pixels down
            sta CharPoint+2
            lda #0 ; reset inner loop counter
            sta K1
            inc K2                          ; next line
            lda K2
            cmp #8                          ; 8 lines done ?
            bcc DW3_2                       ; no loop
            rts                             ; yes : exit
OrigCharPoint dw 10,13                      ; x and y strating position (in pixels)
CharPoint   dw 0,0                          ; pen position var
TextData    dw CurChar                      ; char var : pointer to char(s) to draw
            dfb 1                           ; length of string to draw
CurChar     dfb 0                           ; char value var


            
            ;TK_call SetPenMode;ModeCopy
            TK_call SetPenMode;xSrcXOR
            TK_call PaintBits;TestBits          ; 
             
            TK_call SetPenMode;ModeCopy
            TK_call SetPattern;Black
            TK_call FrameRect;myRect
            TK_call SetPattern;White
            TK_call PaintRect;myRect1
            TK_call SetPattern;Black
            TK_call PaintRect;myRect2