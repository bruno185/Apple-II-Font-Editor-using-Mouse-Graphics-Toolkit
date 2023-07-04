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


DrawWin1 equ *                              ; SampleWindow
                                            ; display a polygon
            TK_call SetPenMode;xSrcXOR
            ; SetPenMode  : sets the current pen mode to the specified mode. 
            ; Parameter :
            ; penmode (input) : integer (the high byte is ignored).
            ; xSrcXOR is a pointer to pen mode. Points to value 2, "penXOR"
            ; Pen modes :
                ; Mode 0 (pencopy): Copy pen to destination.
                ; Mode 1 (penOR): Overlay (OR) pen and destination.
                ; Mode 2 (penXOR): Exclusive or (XOR) pen with destination.
                ; Mode 3 (penBIC): Bit Clear (BIC) pen with destination ((NOT pen) AND destination).
                ; Mode 4 (notpencopy): Copy inverse pen to destination.
                ; Mode 5 (nocpenOR): Overlay (OR) inverse pen wich destination.
                ; Mode 6 (notpenXOR): Exclusive or (XOR) inverse pen with destination.
                ; Mode 7 (notpenBIC): Bit Clear (BIC) inverse pen with destination (pen AND destination)

            TK_call PaintPoly;xPolygon
            ; PaintPoly : paints (fills) the interior of the specified polygon(s) 
            ; with the current pattern.
            ; Parameters : xPolygon : pointer to a polygon structure (see below)
            ; Due to a restriction in the polygon-drawing algorithm, a polygon list
            ; cannot have more than eight peaks. (The mathematical term is strict 
            ; local maxima).
            ; A polygon is a list of vercices, each of which is a point. Polygons in
            ; the graphics primicives are defined as a list that contains one or more
            ; polygons. For each polygon in the list, there is a paramecer named
            ; LastPoly that determines whecher that polygon is the last one in the
            ; list. 
            rts
xPolygon    dfb 3,0                         ; 3 vertices, 0 : no next polygon
            dw 10,10,100,100,40,100         ; (x,y) for each vertice

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

copymaintoaux           ; copy program to AUX memory
                lda #>start
                sta $3d         ; source high
                sta $43         ; dest high
                lda #<start      
                sta $3c         ; source low
                sta $42         ; dest low
                lda #>prgend    ; source end low
                sta $3f 
                lda #<prgend    ; source end high
                sta $3e
                sec             ; main to aux
                jsr AUXMOV      ; move
                rts

DrawWin4    equ *                            ; "TestWindow"
                                            ; display all the parameters of this window
            lda #10                         ; init W4FirstPoint to postion 10,10 
                                            ; high byte of each integer is allways 0
            sta W4FirstPoint
            sta W4FirstPoint+2
            TK_call MoveTo;W4FirstPoint     ; set pen position to W4FirstPoint
;
            TK_call DrawText;W4_L1          ; draw label "Window ID:"
            lda TestWindow                  ; window ID in A, to be drawn
            jsr ByteOut                     ; draw window ID value in hex representation
            jsr NewLine                     ; add 8 to y value of W4FirstPoint and move pen to this position
;
            TK_call DrawText;W4_L2          ; same with "Option Byte"
            lda TestWindow+1
            jsr ByteOut                     ; draw value in hex representation
            jsr NewLine
;
            TK_call DrawText;W4_L3          ; "Window Title"
                                            ; TestWindow+2/+3 : pointer to str (with length in fist byte)
            lda TestWindow+2                ; copy string pointer to var TempText
            sta TempText
            sta K1                          ; and to K1 var, in ZP
            lda TestWindow+3
            sta TempText+1
            sta K1+1
            ldy #0
            lda (K1),y                      ; get sting length byte 
            sta TempText+2                  ; poke length in third byte of parameter 
            inc TempText                    ; inc pointer to string, to skip mength byte
            bne *+5
            inc TempText+1
            TK_call DrawText;TempText       ; display string
            jsr NewLine                     ; increments W4FirstPoint move pen position      
;
            TK_call DrawText;W4_L4          ; "Control Options (H,V)" (2 bytes)
            lda TestWindow+4                ; get 1st value 
            jsr ByteOut                     ; draw value in hex representation 
            jsr Comma                       ; draw a comme
            lda TestWindow+5                ; get 2nd value 
            jsr ByteOut                     ; draw it 
            jsr NewLine
;   
            TK_call DrawText;W4_L5          ; "H Thumb Max & Pos"
            lda TestWindow+6
            jsr ByteOut
            jsr Comma
            lda TestWindow+7
            jsr ByteOut
            jsr NewLine
;
            TK_call DrawText;W4_L6          ; V Thumb Max & Pos
            lda TestWindow+8
            jsr ByteOut
            jsr Comma
            lda TestWindow+9
            jsr ByteOut
            jsr NewLine
;
            TK_call DrawText;W4_L7          ; "Window Status"
            lda TestWindow+10
            jsr ByteOut
            jsr NewLine
;
            TK_call DrawText;W4_L8          ; "Reserved"
            lda TestWindow+11
            jsr ByteOut
            jsr NewLine
;
            TK_call DrawText;W4_L9          ; "H & V Minimums"
            lda TestWindow+12
            ldx TestWindow+13
            jsr WordOut                     ; Displays the word in X,A as hex 
            jsr Comma
            lda TestWindow+14
            ldx TestWindow+15
            jsr WordOut
            jsr NewLine
;
            TK_call DrawText;W4_L10         ; "H & V Maximums"
            lda TestWindow+16
            ldx TestWindow+17
            jsr WordOut
            jsr Comma
            lda TestWindow+18
            ldx TestWindow+19
            jsr WordOut
            jsr NewLine
;
            TK_call DrawText;W4_L11         ; "Window Graf Port--"
            jsr NewLine
            lda #50                         ; indent 50 pixels
            jsr Tab                         ; Increments the X cooridinate of W4FirstPoint by A-reg 
                                            ; all next lines will be indented
;
            TK_call DrawText;W4_L12         ; "View Loc"
            lda TestWindow+20
            ldx TestWindow+21
            jsr WordOut
            jsr Comma
            lda TestWindow+22
            ldx TestWindow+23
            jsr WordOut
            jsr NewLine
;
            TK_call DrawText;W4_L13         ; "Map Loc & Width"
            lda TestWindow+24
            ldx TestWindow+25
            jsr WordOut
            jsr Comma
            lda TestWindow+26
            ldx TestWindow+27
            jsr WordOut
            jsr NewLine
;
            TK_call DrawText;W4_L14         ; "Clip Rect"
            lda TestWindow+28
            ldx TestWindow+29
            jsr WordOut
            jsr Comma
            lda TestWindow+30
            ldx TestWindow+31
            jsr WordOut
            jsr Comma
            lda TestWindow+32
            ldx TestWindow+33
            jsr WordOut
            jsr Comma
            lda TestWindow+34
            ldx TestWindow+35
            jsr WordOut
            jsr NewLine
;
            TK_call DrawText;W4_L15 ; Pattern
            ; Pattern : 8 bytes 
            lda #0                          ; init counter
            sta K1                          ; in K1 var
W4_1        ldx K1
            lda TestWindow+36,X             ; get value
            jsr ByteOut                     ; draw it in hex
            jsr Comma                       ; draw a comma
            inc K1
            lda K1                          ; next byte
            cmp #8                          ; < 8 ?
                                            ; Error : should be cmp #7 !!
                                            ; 9 values are printed instead of 8
            bcc W4_1                        ; yes : loop
            ldx K1                          ; no
            lda TestWindow+36,X             ; draw last value
            jsr ByteOut                     ; without comma
            jsr NewLine
;
            TK_call DrawText;W4_L16         ; "Pen Location"
            lda TestWindow+46
            ldx TestWindow+47
            jsr WordOut
            jsr Comma
            lda TestWindow+48
            ldx TestWindow+49
            jsr WordOut
            jsr NewLine
;
            TK_call DrawText;W4_L17         ; "Pen Size"
            lda TestWindow+50
            jsr ByteOut
            jsr Comma
            lda TestWindow+51
            jsr ByteOut
            jsr NewLine
;
            TK_call DrawText;W4_L18         ; "Pen Mode"
            lda TestWindow+52
            jsr ByteOut
            jsr NewLine
;
            TK_call DrawText;W4_L19         ; "TextBG"
            lda TestWindow+53
            jsr ByteOut
            jsr NewLine
;
            TK_call DrawText;W4_L20         ; "Font Address"
            lda TestWindow+54
            ldx TestWindow+55
            jsr WordOut
            jsr NewLine
            rts

h_menu_6    equ *                               ; menu "Window Test" 
            lda MenuItem
            cmp #1                              ; 1st item = "Open Test Window"
            bne M6_2
M6_1        TK_call OpenWindow;TestWindow
            ; Initializes a window and brings it to the front of the desktop.
            ; Parameters :
                ; a_winfo (input) winfo for the window to initialize

            lda TestWindow                      ; get TestWindow ID
            jmp DrawItB                         ; draw content and exit 

M6_2        cmp #11                             ; there are 10 item in this menu
            bcc *+5                             ; if menu item not < 11 then rts
            jmp M6_11
            TK_call CloseWindow;TestWindow      ; if item > 1 and < 11 then close TestWindow
            ; CloseWindow : removes a window from the desktop (generate update events)
            jsr ClearUpdates                    ; process any update event
            lda MenuItem
            cmp #2                              ; if menu item = 2 ("Dialog")
            bne M6_3
            lda TestWindow+1                    ; then force bit in window window option byte to make it a Dialog box
            eor #%00000001 ; Dialog Box
            sta TestWindow+1
            jmp M6_1                            ; and reopen TestWindow, draw it and rts (see above)
M6_3        cmp #3                              ; if if menu item = 3 ("Go Away Present")
            bne M6_4
            lda TestWindow+1                    ; then force bit in winfow window option byte to make a close box 
            eor #%00000010 ; Go Away Box
            sta TestWindow+1
            jmp M6_12                           ; and update checkmark, reopen TestWindow, draw it and rts (see above)
M6_4        cmp #4                              ; same with "H-Scroll Present"
            bne M6_5
            lda TestWindow+4
            eor #%10000000 ; H Scroll Bar Present
            sta TestWindow+4
            jmp M6_12
M6_5        cmp #5                              ; same with "V-Scroll Present"
            bne M6_6
            lda TestWindow+5
            eor #%10000000 ; V Scroll Bar Present
            sta TestWindow+5
            jmp M6_12
M6_6        cmp #6                              ; same with "H-Thumb Present"
            bne M6_7
            lda TestWindow+4
            eor #%01000000 ; H Thumb Present
            sta TestWindow+4
            jmp M6_12
M6_7        cmp #7                              ; same with "V-Thumb Present"
            bne M6_8
            lda TestWindow+5
            eor #%01000000 ; V Thumb Present
            sta TestWindow+5
            jmp M6_12
M6_8        cmp #8                              ; same with "H-Scroll Active"
            bne M6_9
            lda TestWindow+4
            eor #%00000001 ; H Scroll Active
            sta TestWindow+4
            jmp M6_12
M6_9        cmp #9                              ; same with "V-Scroll Active"
            bne M6_10
            lda TestWindow+5
            eor #%00000001 ; V Scroll Active
            sta TestWindow+5
            jmp M6_12
M6_10       cmp #10                              ; same with "Grow Box Present"
            bne M6_11
            lda TestWindow+1
            eor #%00000100 ; Grow Box Present
            sta TestWindow+1
            jmp M6_12
M6_11       rts

M6_12       jsr SetChecks                       ; update checkmarks
            jmp M6_1                            ; jump back to reopen TestWindow and draw its content.


Menu_5      cmp #6
            bne Menu_6
            jsr h_menu_6        ; Handle Window Test menu
            jmp Menu_Done
;
Menu_6      cmp #7
            bne Menu_7
            jsr h_menu_7        ; Handle Dummy menu
            jmp Menu_Done

Menu_4      cmp #5
            bne Menu_5
            jsr h_menu_5        ; Handle Menu Test menu
            jmp Menu_Done
;

h_menu_5 equ *                                  ; Menu Test
            lda MenuItem
            bne m5_1
            rts
m5_1        cmp #1 ; Clear Menu
            bne m5_2
            jmp ClearMenu
m5_2        cmp #2 ; Disable Menu
            bne m5_3
            jmp DisMenu
m5_3        cmp #3 ; Enable Menu
            bne m5_4
            jmp EnMenu
m5_4        cmp #4 ; Disable Items
            bne m5_5
            jmp DisItems
m5_5        cmp #5 ; Enable Items
            bne m5_6
            jmp EnItems
m5_6        cmp #6 ; CheckItems
            bne m5_7
            jmp CkItems
m5_7        cmp #7 ; UncheckItems
            bne m5_8
            jmp UnckItems
m5_8        cmp #8 ; Change Marks
            bne m5_9
            jmp ChangeMarks
m5_9        cmp #9 ; Restore marks
            bne m5_10
            jmp RestoreMarks
m5_10       rts



;
ClearMenu   equ *
            jsr EnMenu                  ; enable menu 7
            jsr EnItems                 ; enable some items
            jsr RestoreMarks
            jmp UnckItems
;
DisMenu     equ *
            TK_call DisableMenu;DisParms
            ; Disables or enables selection and highlighting of an entire menu.
            ; Parameters :
                ; menu_ld (input) byte ID of the menu to be disabled
                ; disable (input) byte 0: enable the menu ; 1: disable the menu
            rts
DisParms    dfb 7,1                     ; disable menu 7
;
EnMenu      equ *
            TK_call DisableMenu;EnParms
            ; Disables or enables selection and highlighting of an entire menu.
            ; Parameters :
                ; menu_ld (input) byte ID of the menu to be disabled
                ; disable (input) byte 0: enable the menu ; 1: disable the menu            
            rts
EnParms     dfb 7,0                     ; enable menu 7
;
DisItems    equ *
            ldx #1                      ; to disable items (to store in disable byte param.)
            jmp DisEnItems
;
EnItems     equ *
            ldx #0                      ; to enable items (to store in disable byte param.)
            jmp DisEnItems
;
DisEnItems  equ *
            lda #3                      ; item 3 to be disabled
            jsr DisIt                   ; disable iy
            lda #5                      ; item 5 to be disabled
            jsr DisIt                   ; disable iy
            lda #7                      ; item 7 to be disabled
            jmp DisIt                   ; disable iy
;
DisIt       equ *
            stx DisItParms+2            ; store disable byte in parameters  
            sta DisItParms+1            ; store menu item in parameters  
            TK_call DisableItem;DisItParms
            ; Disables or enables selection and highlighting of a single menu item.
            ; Parameters :
                ; menu_id (input) byte ID of the menu containing the item to be disabled.
                ; menu_ltem (input) byte number of the item to be disabled,
                ; disable (input) byte 0: enable the menu item ; 1: disable the menu item
            ldx DisItParms+2
            rts
DisItParms  dfb 7,0,0                   ; modoifed by code above
;
CkItems equ *
            ldx #1                      ; set check parameter for CheckItem call (1 : display the checkmark)
            jmp CkUnckItems
;
UnckItems equ *
            ldx #0                      ; set check parameter for CheckItem call (0 : erase the checkmark)
            jmp CkUnckItems
;
CkUnckItems equ *
            lda #1                      ; set menu item parameter for CheckItem call (item 1)
            jsr CkIt
            lda #4                      ; set menu item parameter for CheckItem call (item 4)
            jsr CkIt
            lda #8                      ; set menu item parameter for CheckItem call (item )
            jsr CkIt
            lda #9                      ; set menu item parameter for CheckItem call (item 1)
            jmp CkIt
;
CkIt equ *
            stx CkItParms+2                     ; set check parameter 
            sta CkItParms+1                     ; set menu item
            TK_call CheckItem;CkItParms
            ; CheckItem : Displays or removes a checkmark next to a menu Item.
            ; Parameters :
                ; menu_id (input) byte ID of the menu containing the item
                ; menu_item (input) byte number of the item to be checked
                ; check (input) :
                    ; byte 0: erase the checkmark
                    ; byte 1: display the checkmark
            ldx CkItParms+2
            rts
CkItParms   dfb 7,0,0                           ; parameter : menu id 7, menu item and check parameters 
                                                ; are set by program (above).
;
ChangeMarks equ *
            ; change some menu items checkmarks.
            TK_call SetMark;Mark8
            ; Sets the character used for the checkmark for a specific menu item.
            ; Parameters :
                ; menu_ld (input) byte ID of the menu containing the item
                ; item_num (input) byte number of the item to be changed
                ; set_char (input) byte 0: use the standard checkmark ; 1: set the checkmark to mark_char
                ; mark_char (input) byte ascii value of the character to use as the checkmark for this item
            TK_call SetMark;Mark9
            ; same, with different checkmark chars.
            rts
Mark8       dfb 7,8,1,'#'                       ; menu 7, item 8, use defined char, # = mark char.
Mark9       dfb 7,9,1,'*'                       ; menu 7, item 9, use defined char, * = mark char.
RestoreMarks equ *
            ; restore menu items checkmarks by dafault.
            TK_call SetMark;Unmark8
            ; Sets the character used for the checkmark for a specific menu item.
            TK_call SetMark;Unmark9
            ; Sets the character used for the checkmark for a specific menu item.
            rts
Unmark8     dfb 7,8,0,0                         ; menu 7, item 8, use standard char, 0 (could be any value)
Unmark9     dfb 7,9,0,0                         ; menu 7, item 9, use standard char, 0 (could be any value)
;
