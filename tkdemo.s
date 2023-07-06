*
*********************************
*                               *
*  Mouse Graphics Toolkit Demo  *
*  ==>>   Font explorer    <<=  *
*                               * 
*********************************
*
            org $800
            put equates
            put equ 
            put macros 
            dsk tkdemo
*
TK_call     MAC                     ; Mouse Graphics Toolkit (including Gaphic Primitives)
            jsr ToolMLI
            dfb ]1                  ; command ID (1 byte)
            da  ]2                  ; address of parameter(s), 0 if no paramter
            EOM 
*
SystemFont      equ $8800           ; Font file is loaded at this address par Startup basic program.
SystemFontE     equ SystemFont+1283 ; End of font data in memory
SaveBuffer      equ $A000           ; Location of buffer for saving screen data
RingBell        equ $FBDD           ; ROM routine 
MonitorEntry    equ 65385           ; ROM routine (= -151)

InDesktop       equ 0               ; IDs of events
InMenu          equ 1
InContent       equ 2
InDrag          equ 3
InGrow          equ 4
InClose         equ 5
InThumb         equ 5
;
UseInterrupts   equ 0 ; Yes

start       equ *
            ;Main2Aux start;prgend
    
            lda #0                              ; set flag to 0 to load original system font
            sta LoadFlag
            jsr LoadFont                        ; load font to $8800
            Main2Aux SystemFont;SystemFontE     ; save original font data to AUX
;
; set up the desk top
;
            lda #0
            sta Quit                    ; init quit flag
            ; TK_call SetZP1;DoNotSave    ; program seems to work without this call.
            ; SetZP1 : sets the preservation status for part of zero page.
            ; Parameters :
                ; preserve: byte (input) 
                    ; 0: Save part of zero page now; restore it later with another call to this routine.
                    ; $80: Restore the part of zero page previously saved, and continue co save and restore
                    ; it on each call Co the primitives.
            * !! if SetZP1 is called, FOUT does not work properly !!

            TK_call StartDeskTop;TheDesk        
            ; StartDeskTop : initializes the mouse and Mouse Graphics Tool Kit routines.
            ; set monochorme double hires, draw desktop (without menus), init miuse and cursor.
            ; Parameters : 
                ; machine ID
                    ; byte1 : $06 - //e or //c
                    ; byte2 : subsidiary ID byte
                        ; $EA - //e
                        ; $EA - //e with revised ROM
                        ; $00 - //c
                ; op_sys : 0 : ProDOS ; 1 : Pascal
                ; slot num (input/output) byte Mouse Slot
                ; use_interrupts (input/output) byte mouse operation:
                    ; 0: passive
                    ; 1: interrupt
                ; sysfontptr (input) pointer location of system font
                ; savearea (input) pointer location of buffer for saving screen data
                ; savesize (input) integer size of save area, in bytes
                    
            TK_call InitMenu;CharList   
            ; InitMenu : specifies the special characters to be used by menus
            ; Parameters :
                ; solid_char (Input) byte : ascii value of character to use as the solid-apple in menu
                ; open_char (Input) byte : ascii value of character to use as the open-apple in menu
                ; check_char (Input) byte : ascii value of character to use as the default checkmark in menu item lists
                ; control_char (Input) byte : ascii value of character to use as the diamond (for control characters) in menu
                ; inactive_char (input) byte : ascii value of character to use around inactive items

            ; The values used by the tool kit if InitMenu is not called are :
                ; Solid Char 30
                ; Open Char 31
                ; Check Char 29
                ; Control Char 01
                ; Inactive Char 127
            ; ==> this call is not necessary, since default values are used !

            TK_call SetMenu;TheMenu     
            ; SetMenu : initializes and displays the menu bar
            ; Parameter : pointer to a_menubar (menubar structure)

            TK_call ShowCursor;0
            ; ShowCursor : makes the mouse cursor visible
            ; Parameters : None.

            jsr SetChecks ; Initialize the Window Test Menu checkmarks.
            ; check all bits from window window option byte.
            ; and set checkmark to the corresponding menu item if bit is set to 1.

********************************************
*
* This is the start of the Main Loop
* The main loop is controlled by a flag
* called Quit.  As long as Quit is zero,
* the loop continues. When it is non-zero,
* control passes to the quitting routine.
*
********************************************
Demo_1 equ *
            lda Quit            ; quit flag
            beq Demo_1_1        ; = 0 ==> main loop
;
            jmp Killer          ; <> 0 ==> exit
;
Demo_1_1 equ *
            TK_call GetEvent;TheEvent ; Get the next event
            ; Returns the next event from the event queue
            ; Parameters :
                ; event (output) type_event (= event record)
* Event record : 
        ; evt_kind : byte;
        ; bytel
        ; byte2
        ; byte3
        ; byte4
; 
    ; evt_kind : the event type, which is one of the following:
            ; no_event = 0;
            ; button_down = 1;
            ; button_up = 2;
            ; key_down = 3;
            ; drag = 4;
            ; apple_key = 5;
            ; update_event = 6;
    *
    ; Event types 7.. 127 are reserved for standard eventa which may be
    ; added in future versions of the Tool Kit. The user may define his
    ; own event types In the range 128..255 and poat these to the event
    ; queue.
    ; "Bytel, byte2, byte3, and byte4" contain information according to
    ; the event type:
    ; 
        ; for no_event, button_down, button__up, drag, and apple_key events:
                ; bytel and byte2 are the low-order and high-order bytes,
                ; respectively, of the x-posltion of the mouse in mouse or
                ; desktop coordinates.
                ; byte3 and byte4 are the low-order and high-order bytes,
                ; respectively, of the y-position of the mouse in mouse or
                ; desktop coordinates.
        ; for key__down events:
                ; bytel Is the Ascil value of the key
                ; byte2 is the key modifiers
                ; bit 1: open-apple down
                ; bit 2: solid-apple down
                ; byte3 snd byte4 are not used.
        ; for update events:
                ; bytel is the window id of the window requiring an update.
                ; byte2, byte3, and byte4 are not used.
*
*
            lda TheEvent ; Transfer control to appropriate part of program
            ; get 1st byte of Event reconrd = event type.

            cmp #ButnDown       ; mouse button down ?
            bne Demo_3          ; no : check next event type
            jsr HandleButton    ; yes : gosub HandleButton
            jmp Demo_1          ; and loop 
;
Demo_3      cmp #KeyPress       ; key pressed event ?
            bne Demo_4          ; no : check next event type
            jsr HandleKeypress  ; yes : gosub HandleKeypress
            jmp Demo_1          ; and loop 
;
Demo_4      cmp #UpdateEvt      ; update event ?
            bne Demo_5          ; no : loop
            jsr HandleUpdate    ; yes : gosub HandleUpdate 
            jmp Demo_1          ; loop
;
Demo_5      jmp Demo_1 ; ignore all other events 
                                ; ignore : no_event ; button_up ; drag ; apple_key ; (+ user events)
;
;
ClearUpdates equ *
            ; removes all update events from queue and process them.
            ; other events stay in the event queue.
            TK_call PeekEvent;TheEvent
            ; PeekEvent : returns the next event in the queue without removing it.
            ; Parameter : event (output) type_event
            lda EvtType
            cmp #UpdateEvt      ; uodate event ?
            bne Update_1        ; no : rts
            TK_call GetEvent;TheEvent   ; yes : get the update event (removed from queue)
            jsr HandleUpdate    ; process update
            jmp ClearUpdates    ; loop (until no update event left in the queue)

HandleUpdate equ *
            TK_call BeginUpdate;UpdateID ; Returned in first event byte
            ; BeginUpdate : sets the current port to the grafport of a window which needs to be redrawn.
            ; Parameter : byte2 of event record, ID of window which needs to be redrawn.
            bne Update_1 ; if error skip it!
            lda UpdateID        ; window ID in A, needed by DrawIt routine.
            jsr DrawIt
            TK_call EndUpdate;0
            ; EndUpdate : Restores the current port to its value prior to the corresponding BeginUpdate.
            ; Parameters : None

            ************** following code added to demo program **************
            ; if not : bad draw of the window below, after drag of top window.
            lda UpdateID
            sta GWParms 
            TK_call GetWinPort;GWParms
            TK_call SetPort;TempPort 
            ******************************************************************
Update_1    rts
;
DrawItB equ *                                   ; Set port to window whose ID is in A
                                                ; then draw its content
            ; set grafport 
            sta GWParms ; Get the port for the current window
            ; A = window ID 
            TK_call GetWinPort;GWParms
            ; GetWinPort : returns the grafport corresponding to a window's visible area.
            ; Parameter : pointer to a struture : window ID (1st byte), TempPort (next bytes) : pointer to an empty grafport
            ; populated by GetWinPort call.
            ; Parameters :
                ; window_id (input) byte : ID of the window of Interest
                ; a_grafport (output) portptr : location of adjusted grafport
            TK_call SetPort;TempPort ; Set the port there
            ; SetPort : sets the current port to the specified GrafPort.
            ; PArameter : GrafPort;
            lda GWParms ; Get the window id in A
;
DrawIt equ * ; Refresh window whose id is passed in A-Reg
            ; DrawIt is called directly by update process. In this case, no need for setting grafport,
            ; since it's done by BeginUpdate call.
            ; Otherwise, DrawIt follows DrawItB, which set the right port.
            cmp SampleWindow
            bne DrawIt_1
            jmp DrawWin1                    ; draw Sample Window
DrawIt_1    cmp EditFontW
            bne DrawIt_2
            jmp DrawWin2                    ; draw Edit Window
DrawIt_2    cmp CharsWindow
            bne DrawIt_3
            jmp DrawWin3                    ; draw display font Window
DrawIt_3    cmp TestWindow                  ; unused now !!
            bne DrawIt_4
            jmp DrawWin4                    ; rts (not implemented)
DrawIt_4    cmp DialogWindow
            bne DrawIt_5
            jmp DrawWin5                    ; draw About dialog window
DrawIt_5    cmp AlertWindow
            bne DrawIt_6
            jmp DrawWin6                    ; draw Alert window 
DrawIt_6    cmp MessageBox
            bne DrawIt_7                    ; draw message  Yes/No window                   
            jmp DrawWin7
DrawIt_7    jsr RingBell
            rts ; Should never get here!
;
DrawWin1    equ *                              ; Sample Window
            TK_call MoveTo;lazypt
            TK_call DrawText;lazyfox
            TK_call MoveTo;lazyptC
            TK_call DrawText;lazyfoxC
 
            rts
lazyfox     da lazy_txt+1
lazy_txt    str 'the lazy fox jumps over the brown dog'
lazypt      dw 10,10
lazyfoxC     da lazy_txtC+1
lazy_txtC    str 'THE LAZY FOX JUMPS OVER THE BROWN DOG'
lazyptC      dw 10,20

DrawWin2 equ *                                  ; EditFontW   
            TK_call HideCursor;0

            TK_call SetPattern;White 
            TK_call PaintRect;bwRect            ; empty window contet with white
            TK_call SetPattern;Black

            TK_call MoveTo;MyPoint              ; move pen to position 
            ; MoveTo : Moves the current pen location to tha specified point (x, y: integer)
            ; Parameters :
                ; a_point: point (input) new pen location (x, y: integer)
            TK_call DrawText;MyText             ; draw a string (Character : ...)

ShowChar
            ldx DispChar                        ; get ascii value of char to display
            jsr GetCharVal                      ; get all 9 bytes of this char in MyChar array
            jsr InitRect                        ; set bitmaps view loc top left = BasePoint
            ldx #00                             ; init rom counter 
            stx row

ShowChar_1  lda MyChar,x                        ; get a byte of the char in var TheChar
            sta TheChar                         ; save it in a var
            ldy #07                             ; init lsr counter 
            sty col 
ShowChar_2  
            lsr TheChar                         ; get a bit from TheChar
            bcc ShowChar_3                      ; bit = 0 : paint a white rectangle

            jsr MakeRect                        ; set up aRect var
            jsr InsetRect                       ; make it smaller 1 pixel
            TK_call PaintRect;aRect             ; paint it black 

ShowChar_3  dec col 
            beq nextline                        ; 7 lsr ?
            jsr MoveRectX                       ; no : move view loc of bitmaps 18 pixels right
            jmp ShowChar_2                      ; loop 
nextline    
            jsr IntiRectX                       ; new line of bitmaps
                                                ; set box.x to BasePoint.x
            jsr MoveRectY                       ; move bitmaps down 
            ldy #7                              ; re-init lsr counter
            sty col
            inc row                             ; next line
            ldx row
            cpx #9                              ; all 9 lines done ?
            bne ShowChar_1

            TK_call FrameRect;edit_r            ; show bounding box
            TK_call FrameRect;refresh_r

            TK_call MoveTo;RefrPt
            TK_call DrawText;LabelRefr

            TK_call ShowCursor;0
            rts

MakeRect                                    ; Set up aRect var 
                                            ; top.left coner : same as aRectTopLeft view loc
                                            ; bottom.down.x = top.left.x + gapx ; bottom.down.y = top.left.y + gapy 
            lda aRectTopLeft                   ; top.left.x
            sta aRect
            lda aRectTopLeft+1
            sta aRect+1
            
            lda aRectTopLeft+2                 ; top.left.y
            sta aRect+2
            lda aRectTopLeft+3
            sta aRect+3  

            lda aRectTopLeft                   ; bottom.down.x
            clc
            adc #gapx
            sta aRect+4
            lda aRectTopLeft+1
            adc #00
            sta aRect+5

            lda aRectTopLeft+2                 ; bottom.down.y
            clc
            adc #gapy
            sta aRect+6
            lda aRectTopLeft+3
            adc #00
            sta aRect+7
            rts

InsetRect                                   ; make aRect 1 pixel smaller in all directions
            inc aRect
            bne :1
            inc aRect+1
:1
            inc aRect+2
            bne :2
            inc aRect+3
:2
            lda aRect+4
            bne :22
            lda aRect+5
            ;beq zero ; branch when num = $0000 (num is not decremented in that case)
            beq :3
            dec aRect+5
:22         dec aRect+4
:3
            lda aRect+6
            bne :33
            lda aRect+7
            ;beq zero ; branch when num = $0000 (num is not decremented in that case)
            beq :3
            dec aRect+7
:33         dec aRect+6

            rts
; 
gapx        equ 18
gapy        equ 10
InitRect                                        ; copy data fom BasePoint
                                                ; to aRectTopLeft view loc
            ldx #00                             ; top.left.x
:1          lda BasePoint,x                     
            sta aRectTopLeft,x        
            inx 
            cpx #4
            bne :1
            rts 

MoveRectX   lda aRectTopLeft                    ; x
            clc
            adc #gapx                           ; add 18 + 2 (for space between blocs) 
            sta aRectTopLeft
            lda aRectTopLeft+1
            adc #0
            sta aRectTopLeft+1
            rts

MoveRectY                                       ; move bitmap view loc 10 pix down
            lda aRectTopLeft+2                  ; move top.left corner down 10 pixels
            clc 
            adc #gapy                           ; add 10 + 1 (for space between blocs)  
            sta aRectTopLeft+2
            lda aRectTopLeft+3
            adc #00
            sta aRectTopLeft+3          
            rts

IntiRectX                                      ; copy BasePoint.x to aRectTopLeft.x
            ldx #00
:1          lda BasePoint,x                     
            sta aRectTopLeft,x         
            inx 
            cpx #2                              ; x : 16 bit integer
            bne :1 
            rts  

TheChar     ds 1     
BasePoint   dw 10,30
aRect       dw 10,30,70,50
row         ds 1
col         ds 1
Black       dfb 0,0,0,0,0,0,0,0,0               ; black pattern
White       ds 8,$FF                            ; white pattern

aRectTopLeft dw 50,50                           ; view location on current port


MyPoint     dw 10,10                            ; pen position var
MyText      dw MyTextData
            dfb 14                              ; length of string to draw
MyTextData  asc 'Character : '
DispChar    asc 'B'
            asc ' '                             ; to erase previous wider char
;
;
DeltaX      equ 10
DeltaY      equ 10
K1          equ 6 ; put these temporary counters on zero page
K2          equ 7


* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
* make display font faster
* make charracters clickable

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
;
DrawWin6 
            TK_call MoveTo;AlertPt1 
            TK_call DrawText;fontloaded
            TK_call MoveTo;AlertPt2 
            TK_call DrawText;MsgClic 

            TK_call FlushEvents;0

getev       TK_call GetEvent;TheEvent
            lda EvtType
            beq getev
            cmp #ButnUp
            beq getev                           ; to flush this kinf of event 
            TK_call CloseWindow;AlertWindow
            rts
AlertPt1    dw 75,11
AlertPt2    dw 40,22
fontloaded  da fload+1
fload       str 'Working font loaded !' 
fontsaved   da fsave+1
fsave       str 'Working font saved !' 
MsgClic     da msgc+1
msgc        str '-- click the mouse or press a key --'
*
*
DrawWin7
            jsr DoYesNoMsg                      ; Draw box and process user's choice (Yes/No)
            rts
            
DoYesNoMsg
            ; display MessageBox content
            TK_call SetPenMode;pencopy
            TK_call SetPattern;Black  
            TK_call MoveTo;MsgPt1
            TK_call DrawText;question 
            TK_call FrameRect;MsgRectYes
            TK_call MoveTo;MsgPt2
            TK_call DrawText;yesLabel 
            TK_call FrameRect;MsgRectNo
            TK_call MoveTo;MsgPt3
            TK_call DrawText;noLabel 

            ; track click in rects ou Y/N keys
getev2      TK_call GetEvent;TheEvent
            lda EvtType
            cmp #KeyPress
            bne nextevtype
            lda EvtKey 
            cmp #'Y'
            beq OKsave
            cmp #'y'
            beq OKsave
            cmp #'N'
            beq NoSave
:1          cmp #'n'
            beq NoSave
            jsr RingBell
            jmp getev2
nextevtype
            cmp #ButnDown
            bne getev2
            jmp TrackYesNo
            rts

OKsave      
            lda #1
            sta YesNoResult
            TK_call SetPenMode;xSrcXOR
            TK_call SetPattern;White
            TK_call PaintRect;MsgRectYes 
            jmp outMsg

NoSave      lda #0
            sta YesNoResult      
            TK_call SetPenMode;xSrcXOR
            TK_call SetPattern;White
            TK_call PaintRect;MsgRectNo 

outMsg      TK_call CloseWindow;MessageBox
            TK_call SetPenMode;pencopy
            TK_call SetPattern;Black
            rts
            
TrackYesNo
            lda MessageBox
            sta winid
            ldx #00
:2          lda MouseX,x                    ; copy point in sreen coordinate 
            sta screenx,x                   ; to screenx/screeny input parameter
            inx
            cpx #04
            bne :2
            TK_call ScreenToWindow;win_coord

            sup windowx;MsgRectYes
            bcc outYes
            sup windowx;MsgRectYes+4
            bcs outYes
            sup windowy;MsgRectYes+2
            bcc outYes
            sup windowy;MsgRectYes+6
            bcs outYes 
            jmp OKsave
outYes
            sup windowx;MsgRectNo
            bcc outNO
            sup windowx;MsgRectNo+4
            bcs outNO
            sup windowy;MsgRectNo+2
            bcc outNO
            sup windowy;MsgRectNo+6
            bcs outNO
            jmp NoSave
 
outNO       jsr RingBell
            jmp getev2 

MsgPt1      dw 34,11
MsgPt2      dw 60,32
MsgPt3      dw 195,32
MsgRectYes  dw 40,22,100,33
MsgRectNo   dw 170,22,230,33
question    da qtext+1
qtext       str 'Erase and replace WORK.FONT file ?'
yesLabel    da yestext+1
yestext     str 'Yes'
noLabel     da  notext+1
notext      str 'No'
YesNoResult ds 1
*
*
*
DrawWin4    equ *                            ; "TestWindow"
            rts

WordOut equ *                   ; Displays the word in X,A as hex at current pen loc
                                ; High byte is in X, Low byte is in A.
            pha ; save low byte
            txa
            pha
            jsr Dollar
            pla
            jsr ByteOut2
            pla ; get it back and go thru Byte Out again.
            jmp ByteOut2
ByteOut equ * ; Displays the byte in a-reg as hex at
; current pen location.
            pha ; save it a momment
            jsr Dollar                      ; draw a $ char
            pla ; get it back
ByteOut2    jsr Bin2Hex                     ; convert byte to 2 chars (in X, Y)
            stx BO2                         ; save first char
            sty BO1                         ; save second char
            TK_call DrawText;BO             ; draw the 2-chars string
            rts
BO          dw BO1                          ; pointer to the string
            dfb 2                           ; string ength = 2
BO1         dfb 0                           ; byte 1 of string
BO2         dfb 0                           ; byte 2 of string
Comma       equ * ; Displays a comma at the current pen loc
            TK_call DrawText;CommaParms
            rts    
CommaParms  dw *+3                          ; pointer to the string (= ',')
            dfb 1                           ; string length = 1
            dfb ','

Dollar equ * ; Displays a dollar sign at the current pen loc
            TK_call DrawText;DollarParms
            rts
DollarParms dw *+3                          ; pointer to the string(= '$')
            dfb 1                           ; string length = 1
            dfb '$'

NewLine equ * ; Increments W4FirstPoint and does a moveto
            clc
            lda W4FirstPoint+2              
            adc #8
            sta W4FirstPoint+2
NewLine_1   TK_call MoveTo;W4FirstPoint
            rts
Tab equ * ; Increments the X cooridinate of W4FirstPoint by A-reg
            clc
            adc W4FirstPoint                ; add A to current value of W4FirstPoint
            sta W4FirstPoint
            jmp NewLine_1
TempText    dw 0                            ; storage for DrawText parameter
            dfb 0
W4FirstPoint dw 10,0
                                            ; labels for Test window 
W4_L1       dw *+3
            str 'Window ID: '
W4_L2       dw *+3
            str 'Option Byte: '
W4_L3       dw *+3
            str 'Window Title: '
W4_L4       dw *+3
            str 'Control Options (H,V): '
W4_L5       dw *+3
            str 'H Thumb Max & Pos: '
W4_L6       dw *+3
            str 'V Thumb Max & Pos: '
W4_L7       dw *+3
            str 'Window Status: '
W4_L8       dw *+3
            str 'Reserved: '
W4_L9       dw *+3
            str 'H & V Minimums: '
W4_L10      dw *+3
            str 'H & V Maximums: '
W4_L11      dw *+3
            str 'Window Graf Port--'
W4_L12      dw *+3
            str 'View Loc: '
W4_L13      dw *+3
            str 'Map Loc & Width: '
W4_L14      dw *+3
            str 'Clip Rect: '
W4_L15      dw *+3
            str 'Pattern: '
W4_L16      dw *+3
            str 'Pen Location: '
W4_L17      dw *+3
            str 'Pen Size: '
W4_L18      dw *+3
            str 'Pen Mode: '
W4_L19      dw *+3
            str 'TextBG: '
W4_L20      dw *+3
            str 'Font Address: '
           
;;
;; Bin2Hex translates the binary number in the A-Register to
;; two ascii digits in X & Y (high nibble in Y, low in X)
;;
Bin2Hex     equ *
            tax                             ; save value in X
            and #$F0                        ; get hi nibble
            lsr a                           ; shift it to low nibble
            lsr a
            lsr a
            lsr a
            jsr Nib2Ascii                   ; convert nibble to ascii char
            tay                             ; save ascii char in Y
            txa                             ; rastore value
            and #$0f                        ; get low nibble
            jsr Nib2Ascii                   ; convert nibble to ascii char
            tax                             ; copy it to Y 
            rts
Nib2Ascii   equ *
            cmp #10                         ; compare value to 10 
            bcc N2A_1                       ; < 10 : add '0'
            clc                             ; >= 10 : add 7 + '0'
            adc #7                          
N2A_1       adc #'0'
            rts
;
NumLines    equ 8
StartingY   equ 15
DrawWin5    equ *                           ; About dialog window
            lda #0
            sta K1                          ; init K1 var to 0
            lda #StartingY                  ; init YStart var to 15
            sta YStart
DW5_1       ldx K1
            lda StrTableLow,x               ; get low byte of pointer to DrawText parameter
            sta W5TextPatch                 ; set it. Self modifying code !!
            lda StrTableHi,x                ; get hi byte of pointer to DrawText parameter
            sta W5TextPatch+1               ; set it. Self modifying code !!
            TK_call MoveTo;XStart           ; set pen position. XStart = 10, YStart = 15
            jsr ToolMLI
            dfb DrawText
W5TextPatch dw $FFFF                        ; modified by code above
            clc
            lda YStart                      ; add DeltaY to Y position var 
            adc #DeltaY
            sta YStart
            inc K1                          ; inc K1 (= offet in pointer tables) 
            lda K1
            cmp #NumLines                   ; < 8 ?
            bcc DW5_1                       ; yes : loop
            rts
XStart      dw 10                           ; var for x pen position
YStart      dw 0                            ; var for y pen position
StrTableLow db L1,L2,L3,L4,L5,L6,L7,L8      ; table of low byte of string addresses
;StrTableHi  db <L1,<L2,<L3,<L4,<L5,<L6,<L7,<L8
StrTableHi  db >L1,>L2,>L3,>L4,>L5,>L6,>L7,>L8  ; table of hi byte of string addresses
L1          dw *+3
            str 'Font Editor for Mouse Graphics Tool Kit '
L2          dw *+3
            str '   '                       ; empty line
L3          dw *+3
            str 'This program demonstrates the use of the'
L4          dw *+3
            str 'Mouse Graphics Tool Kit.  Now you can do'
L5          dw *+3
            str 'things on an Apple // that you thought'
L6          dw *+3
            dfb 45
;     123456789012345678901234567890123
            asc 'were only possible on a Macintosh'
            dfb 16,17 ; the TM chars in the font.
            asc ' or a GS'
            dfb 16,17 ; the TM chars in the font.
L7          dw *+3
            str ' '                         ; empty line
L8          dw *+3
            str 'Click in this window to continue or hit a key.'
*
* Date for drawing windows
*
pencopy     dfb 0
xSrcCOPY    dfb 4                           ; penmode = notpencopy : Copy inverse pen to destination.
xSrcXOR     dfb 2                           ; penmode = penBIC  : Bit Clear (BIC) pen with destination ((NOT pen) 
                                            ; AND destination))


* polygon list struture :
; db : nb. of vertices
; db polylast :  0 ; $80 if not last.EvtKe
; dw X of vertice 1
; dw Y of vertice 1
; dw X of vertice 2
; dw Y of vertice 2
; ...
*
* Data for Setting up the window port
*
GWParms     dfb 0 ; window id
            dw TempPort ; port i want to use
TempPort    ds PortLength,0

;
;
HandleKeypress equ *
            lda EvtKey ; Returned in event byte 1
            ; in Event, bytel (after event type) is the Ascil value of the key
            sta MenuCmd+2 ; Check to see if its a menu key.
            ; input 1 for MenuKey command
            lda EvtMods ; Returned in event byte 2
            ; EvtMods (= key_mods) : key modifiers, as returned by GetEvent.
                ; 0 - no modifier
                ; 1 • open-apple key
                ; 2 - solid-apple key
                ; 3 - both apple keys
            sta MenuCmd+3
            ; input 2 for MenuKey command
            TK_call MenuKey;MenuCmd
            ; MenuKey : finds the menu item corresponding to a typed keyboard character.
            ; menu ID : byte1 of MenuCmd
            ; menu item : byte2 of MenuCmd (= MenuCmd+1)
            ; Parameters
                ; menu Id (output) byte : ID of the menu in which the key is a shortcut keystroke. 
                ; If the key is not a shortcut keystroke, menu_id is set to 0.
                ; menu_item (output) byte : number of the item for which the key is a shortcut keystroke. If the key
                ; is not a shortcut keystroke, menu_item is set to 0.
                ; which_key (input) byte :  ascii value of the keyboard character
                ; key mods (input) byte : key modifiers, as returned by GetEvent:
                        ;  0 - no modifier
                        ;  1 • open-apple key
                        ;  2 - solid-apple key
                        ;  3 - both apple keys
;
HandleMenu  equ * ; Takes result from menu commands and acts accordingly.

            ; Each menu has a user-assigned menu id and its menu items are numbered
            ; sequentially, beginning at 1. When a menu is selected, the program
            ; performs a specific task according to this Information, and then
            ; dehighlights the menu by calling the Tool Kit HiliteMenu routine.

            ; The programmer should call MenuSelect when the mouse is clicked in
            ; the menu bar. MenuSelect then handles all aspects of the display of
            ; the pull-down menus until the mouse button is released. When control
            ; is returned to the program, the menu id and menu_item parameters are
            ; set to reflect the user's selection.
            ; If the user makes a selection, MenuSelect leaves the menu title
            ; highlighted. The program should then perform the appropriate task and
            ; dehighlight the menu title via a call to HiliteMenu.

            lda MenuCmd     ; If no selection was made, menu_id (= MenuCmd) is set to 0.
            ;bne *+3
            bne HM_1
            TK_call FrontWindow;OnTop               ; get top window
            lda OnTop                               ; in A
            cmp EditFontW                           ; = EditFontW ?
            bne HM_exit                             ; no : rts
            lda MenuChar                            ; get ascii value of key
            sta DispChar                            ; set it for draw function for this window
            lda EditFontW
            jmp DrawItB                             ; draw window (+SetPort)

HM_exit     rts 
;
HM_1
            cmp #1 ; find out which menu
            ; first menu (Apple menu) ID = 1 
            bne Menu_1
            jsr h_menu_1        ; Apple menu
            jmp Menu_Done
;
Menu_1      cmp #2
            bne Menu_2
            jsr h_menu_2        ; File menu
            jmp Menu_Done
;
Menu_2      cmp #3
            bne Menu_3
            jsr h_menu_3        ; Edit menu
            jmp Menu_Done
;
Menu_3 cmp #4
            bne Menu_7
            jsr h_menu_4        ; Font menu
            jmp Menu_Done
;
Menu_7      jsr RingBell        ; should never get here
;
Menu_Done equ *
            TK_call HiLiteMenu;MenuCmd
            ; Turns highlighting of a menu on or off (toggles)
            ; here, turns highlighting off, since the action is finished.
            rts
;
h_menu_1    equ *                               ; Apple  menu (1 item)
            TK_call OpenWindow;DialogWindow     ; Show About box
            lda DialogWindow
            jsr DrawItB                         ; Draw it
M1_1        TK_call GetEvent;TheEvent           ; get a mouse down or keypress event
            lda EvtType
            cmp #KeyPress
            beq M1_2
            cmp #ButnDown
            bne M1_1
            TK_call FindWindow;FWParms
            lda FindResult
            cmp #InContent
            bne M1_1
            lda WindowFound
            cmp DialogWindow
            bne M1_1
;M1_2        TK_call CloseWindow;WindowFound    ; this is a bug !! If call after KeyPress event, 
                                                ; WindowFound is not defined, the windows will not close.
M1_2        TK_call CloseWindow;DialogWindow    ; Close About box
            rts
;
h_menu_2    equ *                               ; File menu
            lda MenuItem
            cmp #4                              ; Enter monitor
            bne M2_1
            lda #$40
            sta Quit

M2_1        cmp #5                              ; Quit
            bne M2_2
            lda #$80
            sta Quit

M2_2        cmp #3                              ; Reset menu
            bne M2_3
            Aux2Main SystemFont;SystemFontE 
            rts

M2_3        cmp #1                              ; Load working font
            bne M2_4

            lda question                        ; Save Message string
            sta saveQtext
            lda question+1
            sta saveQtext+1
            lda qtext                           ; save mesage length
            sta saveQtext+2

            lda #<Conftext+1                    ; set load confirmation message
            sta question
            lda #>Conftext+1
            sta question+1  
            lda Conftext
            sta qtext

            TK_call OpenWindow;MessageBox

            lda MessageBox
            jsr DrawItB                         ; draw content and process user's choice

            lda saveQtext                       ; restore message string and string length
            sta question
            lda saveQtext+1
            sta question+1
            lda saveQtext+2
            sta qtext            

            lda YesNoResult                     ; get user'a choice
            bne :1                              ; user answered no : rts
            rts    
:1          lda #1                              ; user answered yes : load font
            sta LoadFlag                        ; flag for WORK font
            jsr LoadFont                        ; load font in memory
            jsr ClearUpdates                    ; ofrce update of window below, if any.
            TK_call OpenWindow;AlertWindow      ; loading completed message 
            lda AlertWindow
            jmp DrawItB                         ; draw loading completed message and exit

M2_4        cmp #2                              ; Save working font
            bne M2_5
            TK_call OpenWindow;MessageBox       ; open message box
            lda MessageBox
            jsr DrawItB                         ; draw content and process user's choice                   
            lda YesNoResult                     ; get user'a choice
            beq M2_5                            ; no : rts
            jsr SaveFont                        ; yes : save current work font
            jsr ClearUpdates                    ; ofrce update of window below, if any.
            TK_call OpenWindow;AlertWindow      ; loading completed message 

            lda fontloaded                      ; Save Message string
            sta saveQtext
            lda fontloaded+1
            sta saveQtext+1
            lda fload                           ; save mesage length
            sta saveQtext+2

            lda #<fsave+1                       ; set save confirmation message
            sta fontloaded
            lda #>fsave+1
            sta fontloaded+1  
            lda fsave
            sta fload

            lda AlertWindow
            jmp DrawItB                         ; draw loading completed message and exit

            lda saveQtext                       ; restore message string and string length
            sta fontsaved
            lda saveQtext+1
            sta fontsaved+1
            lda saveQtext+2
            sta fsave    

M2_5        rts                                 ; should never get here
;
h_menu_3    equ *                               ; Edit menu
end_menu_3  rts                                 ; not implemented
;
h_menu_4    equ *
            lda MenuItem
            cmp #4
            bcs m4_2 ; Its not one of the first three 
            ; menu item 1 opens windows with ID = 1
            ; menu item 2 opens windows with ID = 2
            ; menu item 3 opens windows with ID = 3

            TK_call FrontWindow;OnTop ; Need to know whats on top
            ; Returns the id of the front window
            lda OnTop               ; A= IDof window on top.
            cmp MenuItem            ; if top window = menu item : rts
            beq end_menu_3 ; a local rts
;
            jsr UncheckWindow           
            ; uncheck item of top window, it won't the top window since another menu item has be selected
            TK_call SelectWindow;MenuItem ; Try selecting it
            ; Brings the specified window to the front of the desktop.
            ; SelectWindow does not generate an update event. It is the
            ; programmer's responsibility to draw the content area of the window
            ; after he calls SelectWindow.
            beq m4_1 ; It was open since no error occurred
            lda MenuItem                ; get menu item number (1 to 3)
            asl a ; Multiply by 2
            tax
            lda WinfoTable,x
            ; WinfoTable : array of pointers to windows structure (windows ID 1 to 3).
            sta wptr
            lda WinfoTable+1,x
            sta wptr+1                  ; save pointer to chosen window structure in wptr / wptr+1
                                        ; self modifying code, wptr / wptr+1 are bytes of OpenWindow call. 
            jsr ToolMLI
            dfb OpenWindow              ; Open window 
wptr        dw $FFFF ; Gets set above.
            ; OpenWindow : initializes a window and brings it to the front of the desktop
            ; Parameters :
                ; a_winfo (input) winfo for the window to initialize
                        
                ; OpenWindow does not generate an update event. Instead the tool kit
                ; expects that the program will display the window's contents
                ; immediately after it is open.
                ; The actual a_vinfo parameter must remain fixed in memory while the
                ; window is open.
                ; Valid window IDs are 1..255
                ; A window's view location must be specified so that when it is opened,
                ; a functional part of its drag bar is on the screen.
                ; OpenWindow does not generate an update event. It Is the programmer's
                ; responsibility to draw the content area of the window after he calls

m4_1        lda MenuItem                ; check selected menu item 
            jsr CheckWindow
            jmp DrawItB ; Display its contents
;
****** Menu 4, item > 3 (Drag, Grow, Hide)
;
m4_2        cmp #5                      ; item #5 (Drag) in Windows menu
            bne m4_4
            TK_call KeyBoardMouse;0 ; Signal that the next call to Drag or Grow is Fake
            ; Specifies that a mouse operation is to be performed via the keyboard.
            ; FakeMouse signals that the next action (either DragWindow, or GrowWlndow) 
            ; will be performed via the keyboard.
            ; DragWindow or GrowWlndow should be called immediately or very soon after FakeMouse.
            TK_call FrontWindow;OnTop ; Find what window is on top
            ; Returns the id of the front window
            lda OnTop                   ; window ID in A 
            beq m4_3 ; if zero then there were none on desk
            ; 0 = no window on desktop
            sta DragParms               ; prepare DragWindow call, set window ID
            TK_call DragWindow;DragParms ; Drag It.
            ; DragWindow : Interacts with the mouse while dragging a window outline after a click in the drag bar.
            ; mouvement of mouse move the window.
            ; When DragWindow is called to move the window without the mouse, 
            ; the mouse position need not be valid.
            ; DragParms : uses event record in memory (global var)
            ; Parameters : 
                ; window ID 
                ; dragx, dragy : starting pos of mouse (coordinates in screen coordinates)
                ; output : ItMoved (byte : 1 for yes, 0 for no)
            ; Not specified in documentation : when called from keyboard, an update event is generated
            ; if ItMoved = 1
m4_3        rts
;
m4_4        cmp #6                      ; item #6 (Grow) in Windows menu
            bne m4_6
            TK_call KeyBoardMouse;0 ; Signal that the next call to Drag or Grow is Fake
            ; Specifies that a mouse operation is to be performed via the keyboard.
            TK_call FrontWindow;GrowParms ; Find what window is on top
            ; Returns the id of the front window
            ; GrowParms : 
            lda GrowParms
            beq m4_5 ; if zero then there were none on desk.
            TK_call GrowWindow;GrowParms ; Grow it.
            ; Interacts with the mouse and re-sizes a window after a click in the grow box.
            ; When GrowWindow is called for growing the window from the keyboard, the mouse position need not be valid.
            ; (<==> the grow box must not be out of the screen ?)
            ; GrowParms : uses event record in memory (global var)
            ; Parameters : 
                ; window ID 
                ; mousex, mousey : starting pos of mouse (coordinates in screen coordinates)
                ; output : ItGrew (byte : 1 for yes, 0 for no)
            ; Not specified in documentation : when called from keyboard, an update event is generated
            ; if ItGrew = 1
m4_5        rts
;
m4_6        cmp #7                      ; item #6 (Hide) in Windows menu
            bne m4_7                    ; exit 
            TK_call FrontWindow;WindowFound ; Param used by DoClose
            lda WindowFound
            beq m4_7                    ; window ID = 0 : no window to hide
            jmp DoClose_1
m4_7        rts
;
CheckWindow equ * ; preserves a-reg containing item number
            ; item number = window ID
            sta CheckParms+1
            TK_call CheckItem;CheckParms
            ; CheckItem : dsplays or removes a checkmark next to a menu Item
            ; Parameters :
                ; menu_id (input) byte ID of the menu containing the item
                ; menu_item (input) byte number of the item to be checked
                ; check (input) :
                    ; byte 0: erase the checkmark
                    ; byte 1: display the checkmark
            lda CheckParms+1
            rts
CheckParms  dfb 4 ; Menu ID
            dfb 0 ; Item Number
            dfb 1 ; Check It (vs uncheck it)
;
UncheckWindow equ * ; preserves a-reg containing item number
            sta UncheckParms+1          ; save top window ID in CheckItem call parameters
            ; NB : windows ID = menu 4 item number (1 to 3) 
            TK_call CheckItem;UncheckParms
            ; uncheck menu item, corresponding to windows on top
            ; CheckItem : displays or removes a checkmark next to a menu Item
            ; Parameters :
                ; menu_id (input) byte ID of the menu containing the item
                ; menu_item (input) byte number of the item to be checked
                ; check (input) :
                    ; byte 0: erase the checkmark
                    ; byte 1: display the checkmark
            lda UncheckParms+1
            rts
UncheckParms dfb 4 ; Menu ID
            dfb 0 ; Item Number
            dfb 0 ; Uncheck It (vs check it)
;


SetChecks   equ *
; check all bits from window window option byte
; and set checkmark to the corresponding menu item if bit is set to 1.
            jsr ClearUm                         ; erase all checkmarks in menu 6 
            lda TestWindow+1                    ; Window Option Byte
            and #%00000001 ; Dialog             ; get dialog bit in window window option byte
            beq Set_1
            lda #2                              ; bit = 1  : set check mark for corresponding menu item.
            jsr Check1
Set_1       lda TestWindow+1                    ; Window Option Byte
            and #%00000010 ; Go Away Box
            beq Set_2
            lda #3
            jsr Check1
Set_2       lda TestWindow+4                    ; Horizontal Scroll Option Byte
            and #%10000000 ; H-Scroll Present
            beq Set_3
            lda #4
            jsr Check1
Set_3       lda TestWindow+5                    ; Vertical Scroll Option Byte
            and #%10000000 ; V-Scroll Present
            beq Set_4
            lda #5
            jsr Check1
Set_4       lda TestWindow+4                    ; Horizontal Scroll Option Byte
            and #%01000000 ; H-Thumb Present
            beq Set_5
            lda #6
            jsr Check1
Set_5       lda TestWindow+5                    ; Vertical Scroll Option Byte
            and #%01000000 ; V-Thumb Present
            beq Set_6
            lda #7
            jsr Check1
Set_6       lda TestWindow+4                    ; Horizontal Scroll Option Byte
            and #%00000001 ; H-Scroll Active
            beq Set_7
            lda #8
            jsr Check1
Set_7       lda TestWindow+5                    ; Vertical Scroll Option Byte
            and #%00000001 ; V-Scroll Active
            beq Set_8
            lda #9
            jsr Check1
Set_8       lda TestWindow+1                    ; Window Option Byte
            and #%00000100 ; Grow Box Present
            beq Set_9
            lda #10
            jsr Check1
Set_9       rts

ClearUm equ *                               
            ; erase all the checkmarks from item 2 to 10 in menu 6 ("Windo Test") 
            lda #2                          ; start at item 2
            sta K1
ClearUm_1   lda K1
            sta ClearParms+1
            TK_call CheckItem;ClearParms
            ; CheckItem : displays or removes a checkmark next to a menu Item.
            ; Parameters :
                ; menu_id (Input) byte ID of the menu containing the item
                ; menu_item (input) byte number of the item to be checked
                ; check (Input) byte 0: erase the checkmark ; 1: display the checkmark
            inc K1
            lda K1
            cmp #11                         ; < 11 ?
            bcc ClearUm_1                   ; yes loop
            rts
ClearParms dfb 6,0,0                        ; menu id - (Window Test) ; item set by program ; check : erase

Check1      equ *
            ; set checkmark for one menu item. Input : menu item in A 
            sta Check1Parms+1               ; set item
            TK_call CheckItem;Check1Parms
            ; CheckItem : displays or removes a checkmark next to a menu Item.
            rts
Check1Parms dfb 6,0,1                       ; menu 6 ; item set by program ; check : display the checkmark
;
h_menu_7    equ *
            rts
;
HandleButton equ *  ; Handle mouse button down event
            TK_call FindWindow;FWParms ; Takes the mouse pos which starts at byte 1 of TheEvent
            ; FindWindow : Finds the topmost window at a specified mouse position.
            ; Parameters :

                ; mouse_x (input) integer x-coordinate of mouse (in screen coordinates)
                ; mouse_y (input) integer y-coordinate of mouse (in screen coordinates)

                ; which_area (output) byte area of screen
                    ; 0: desktop
                    ; 1: menubar
                    ; 2: content of a window
                    ; 3: drag bar of a window
                    ; 4: grow box of front window
                    ; 5: close box of front window
                
                ; window_id (output) byte ID of window (if which_area is 2..5)

            lda FindResult ; (TheEvent+5) 
            ; = which_area byte 
            bne HButton_1 ; Not just on the desktop 
            ; 0: desktop
            rts ; just on the desktop
;
HButton_1   cmp #InMenu         ; 1: menubar
            bne HButton_2
            TK_call MenuSelect;MenuCmd
            ; MenuSelect Interacts with the mouse to select an item from a pulldown menu
            ; Parameters :
            ; byte1 = MenuCmd = id of selected menu. If no selection was made, menu_id is set to 0.
            ; byte2 = MenuItem = id of selected item.
            jmp HandleMenu
;
HButton_2   cmp #InContent      ; 2: content of a window
            bne HButton_3
            jmp DoContent
;
HButton_3   cmp #InDrag         ; 3: drag bar of a window
            bne HButton_4
            jmp DoDrag
;
HButton_4   cmp #InGrow         ; 4: grow box of front window
            bne HButton_5
            jmp DoGrow
;
HButton_5   cmp #InClose        ; 5: close box of front window
            bne HButton_6
            jmp DoClose
;
;
HButton_6   rts ; should never get here!
            ; since all possible values of which_area are processed
;
DoContent   equ *
            TK_call FrontWindow;OnTop
            ; FrontWindow : returns the ID of the front window.
            lda OnTop                       ; top window ID in A
            cmp WindowFound ; second byte of find result (TheEvent+7)
                                            ; Error : it's TheEvent+6 !!!
                                            ; = window_ID of previous FindWindow call
            beq Content_1                   ; user cliqued in top window ?     
            jsr UncheckWindow               ; no : put a back window on top
                                            ; uncheck menu item corresponding to the top window
            TK_call SelectWindow;WindowFound ; Was not on top so select it
                                            ; select window user clicked in
            lda WindowFound
            jsr CheckWindow                 ; update checks in menu
            jmp DrawItB                     ; redraw window content ans exit !!
;
;
; This is where we do control stuff.
Content_1   lda WindowFound
            sta OnTop ; Get Ready for FindControl which trashes WindowFound
                                            ; yes, since FindControl and FindWindow parameters
                                            ; use the same place in memory.
            TK_call FindControl;FCParms
            ; FindControl : returns the control area corresponding to the specified coordinates
            ; in the front window
            ; Parameters :
                ; mouse_x (input) integer Mouse Position X (in screen coordinates)
                ; mouse_y (input) integer Mouse Position Y (in screen coordinates)

                ; which_ctl (output) byte corresponding control area
                    ; 0: not a control
                    ; 1: vertical scroll bar
                    ; 2: horizontal scroll bar
                    ; 3: dead zone

                ; which_part (output) byte corresponding control part
                ; (meaning depends on the value of the which_ctl parameter)
                    ; 0: inactive scrollbar
                    ; 1: up-arrow or left-arrow
                    ; 2: down-arrow or right-arrow
                    ; 3: page-up or page-left region
                    ; 4: page-down or page-right region
                    ; 5: thumb

            lda FindResult                  ; = which_ctl of FindControl output parameter
            bne :1
            jmp DoClickIn                   ; which_ctl = 0 : click in content of a window

:1          sta TrackParms
            lda WhichPart                   ; which_part of FindControl output parameter
            cmp #InThumb ; vertical scroll bar, thumb
            bne Content_2                   ; not in Thumb : exit
            TK_call TrackThumb;TrackParms
            ; TrackThumb : interacts with the mouse after a click in the thumb of a scrollbar in
            ; the front window.
            ; Parameters :
                ; which_ctl (input) byte control area:
                    ; 1: vertical scrollbar
                    ; 2: horizontal scrollbar

                ; mousex (input) integer x-coordinate of mouse (acreen coordinates)
                ; mousey (input) integer y-coordinate of mouse (screen coordinates)

                ; thumbpos (output) byte position the thumb moved to thumbmoved (output) byte :
                    ; 0: No it did not move.
                    ; 1: Yes it moved.

            lda ThumbMoved                  ; did user move thumb ?
            beq Content_2                   ; no : exit.
            lda ThumbResult                 ; yes. ThumbResult = thumbpos output parameter
            sta ThumbPos                    ; set parameter for next call (UpdateThumb)
            TK_call UpdateThumb;ThumbParms
            ; UpdateThumb : redisplays the thumb in the specified position 
            ; in a scrollbar of the front window
            ; Parameters :
                ; which_ctl (input) byte control area:
                    ; 1: vertical scrollbar
                    ; 2: horizontal scrollbar
                ; thumbpos (input) byte thumb value reflecting the new thumb position

Content_2   rts

******************************************************************************
DoClickIn                                   ; after click in EditFontW content
            ; jsr RingBell
            lda OnTop                       ; get top window
            cmp EditFontW                   ; = EditFontW ?
            beq DC_2                        ; yes : proceed with a click in EditFontW
            rts                             ; no : exit
DC_2        sta win_coord                   ; populate parameters for ScreenToWindow call
            ldx #00
:2          lda MouseX,x                    ; copy point in sreen coordinate 
            sta screenx,x                   ; to screenx/screeny input parameter
            inx
            cpx #04
            bne :2
            TK_call ScreenToWindow;win_coord
            ; ScreenToWindow : Converts screen coordinates to window coordinates
            ; Parameters :
                ; wlndow_id (input) byte : ID of the window of interest
                ; screenx (input) integer : screen x-coordinate
                ; screeny (input) integer : screen y-coordinate
                ; windowx (output) integer : corresponding window x-coordinate
                ; windowy (output) integer : corresponding window y-coordinate

                                                    ; Test bounding box
            sup windowx;edit_r_tl_x
            bcc outEditBox
            sup windowx;edit_r_bd_x
            bcs outEditBox
            sup windowy;edit_r_tl_y
            bcc outEditBox
            sup windowy;edit_r_bd_y
            bcs outEditBox 
            jmp inbox

outEditBox  
            sup windowx;refresh_r
            bcc outRefr
            sup windowx;refresh_r+4
            bcs outRefr
            sup windowy;refresh_r+2
            bcc outRefr
            sup windowy;refresh_r+6
            bcs outRefr 

            TK_call SetPenMode;xSrcXOR
            TK_call SetPattern;White
            TK_call PaintRect;refresh_r
            TK_call PaintRect;refresh_r
            ;TK_call PaintRect;refresh_r
            ;TK_call PaintRect;refresh_r
            ;TK_call PaintRect;refresh_r

            TK_call SetPenMode;pencopy
            jmp DrawWin2
outRefr     
            jmp RingBell


inbox       TK_call MoveTo;tmppt                    ; move pen  
            jsr DodivX                              ; divide windowx-margin by gapx
            lda dividend                            ; dividend = result of division
            sta SquareX                             ; save it to SquareX var (= X coord. of clicked square)
            ;jsr ByteOut2                           ; debug
            ;lda dividend+1                         ; useless : SquareX should be in [0..7] (chars are 7 bits wide)
            ;sta SquareX+1

            jsr DodivY                              ; divide windowx-margin by gapx
            lda dividend                            ; dividend = result of division
            sta SquareY                             ; save it to SquareY var (= Y coord. of clicked square)
            ;jsr ByteOut2                           ; debug
            ;lda dividend+1                         ; useless : SquareX should be in [0..8] (chars are 9 bits high)
            ;sta SquareY+1
                                                    ;
                                                    ; Find corresponding byte in font data
; font-record
    ; fonttype: byte (0 for regular-width, $80 for double-width)
    ; lastchar: byte (ASCII value of last char in font; 0..255)
    ; height: byte (height of font, in rows of pixels; 1..16)
    ; charwidth: array [0..lastchar] of byte 
        ; (each entry contains the width of the corresponding character;  0..7 for regular-width fonts, 
        ; 0..14 for douhle-width fonts. The widths specify the number of dots to display horizontally 
        ; when the character is drawn.)
    ; charimage: (for regular-width fonts)
        ; array [1..height] of
        ; array [0..lastchar] of bits

; In this case; we have a regular-width font :
; fonttype = 0
; lastchar = 128
; height = 9

            lda SquareY                             ; get SquareY
            asl                                     ; *2
            tax
            lda bfontTable,x                        ; get address in table
            clc
            adc DispChar                            ; add offset = ascii value of char.
            sta getByte+1                           ; modify lda operand below (low byte)
            lda bfontTable+1,x
            adc #0
            sta getByte+2                           ; modify lda operand below (high byte)
            
getByte     lda $FFFF                               ; get bye in font data
            sta TheByte
            ;jsr ByteOut2                            ; debug
            
                                                    ; Prepare color inversion of square (black <-> white)
                                                    ; by setting coordinate of square to paint
            jsr InitRect                            ; init. aRect coordinates
            jsr MakeRect                            ; make a rect

                                                    ; Adjust aRect position
                                                    ; to make it match the clicked square
            ldx SquareX
DoRectX     ;cpx #0                                  ; shift rect right SquareX times
            beq DoRectY
            jsr ShitRectR
            dex 
            jmp DoRectX 
DoRectY     ldx SquareY
DoRectY2    cpx #0                                  ; shift rect down SquareY times
            beq DoRectF
            jsr ShitRectD
            dex
            jmp DoRectY2 
DoRectF     jsr InsetRect                           ; make aRect smaller
            ldx SquareX
            lda BitTable,x                          ; get bit to poke
            and TheByte
            beq DoSetB
                                                    ; poke modified value in font data
DoClearB                                            ; bit to poke = 1 ==> 0
            lda BitTable,x
            eor #$FF
            and TheByte
            jsr DoPoke                              ; store new value in font data 
            pha                                     ; and on stack  
            TK_call SetPattern;White                ; paint inverted square
            TK_call PaintRect;aRect
            beq EndClick

DoSetB                                              ; bit to poke = 0 ==> 1
            lda TheByte
            ora BitTable,x
            jsr DoPoke                              ; store new value in Font data
            pha                                     ; and on stack  
            TK_call SetPattern;Black                ; paint inverted square
            TK_call PaintRect;aRect

EndClick    TK_call DrawText;LabelByte
            pla                                     ; get value back from stack
            jsr ByteOut2                            ; print it                           
            rts
 
DoPoke      ldx getByte+1                           ; get address of byte in font data
            stx $06                                 ; setup a pointer in ZP with it
            ldx getByte+2
            stx $07
            ldy #0
            sta ($06),y                             ; poke value at this address
            rts

ShitRectR   lda aRect                               ; shift aRect right gapx pixels
            clc
            adc #gapx
            sta aRect
            lda aRect+1
            adc #0
            sta aRect+1

            lda aRect+4
            clc
            adc #gapx
            sta aRect+4
            lda aRect+5
            adc #0
            sta aRect+5
            rts            

ShitRectD   lda aRect+2                             ; shift aRect down gapy pixels
            clc
            adc #gapy
            sta aRect+2
            lda aRect+3
            adc #0
            sta aRect+3

            lda aRect+6
            clc
            adc #gapy
            sta aRect+6
            lda aRect+7
            adc #0
            sta aRect+7
            rts   

BitTable    db %00000001
            db %00000010
            db %00000100
            db %00001000
            db %00010000
            db %00100000
            db %01000000

TheByte     ds 1

tmppt       dw 100,10
LabelByte   dw LByte
            dfb 8
LByte       asc 'Byte : $'

win_coord   equ *
winid       equ *
screenx     equ *+1
screeny     equ *+3
windowx     equ *+5
windowy     equ *+7
            ds 9
edit_r      equ *   
edit_r_tl_x dw 10
edit_r_tl_y dw 30
edit_r_bd_x dw 136
edit_r_bd_y dw 120

refresh_r   dw 200,30,290,42
LabelRefr   dw RefrStr
            dfb 14
RefrStr     asc 'Refresh Window'
RefrPt      dw 204,41


bfontTable  da SystemFont+3+128
            da SystemFont+3+128+128
            da SystemFont+3+128+128+128
            da SystemFont+3+128+128+128+128
            da SystemFont+3+128+128+128+128+128
            da SystemFont+3+128+128+128+128+128+128
            da SystemFont+3+128+128+128+128+128+128+128
            da SystemFont+3+128+128+128+128+128+128+128+128
            da SystemFont+3+128+128+128+128+128+128+128+128+128

SquareX     dw 0
SquareY     dw 0    

DodivX      lda windowx
            sec
            sbc edit_r_tl_x
            sta dividend
            lda windowx+1
            sbc edit_r_tl_x+1
            sta dividend+1
            lda #gapx
            sta divisor
            lda #0
            sta divisor+1
            jsr divide 
            rts

DodivY      lda windowy
            sec
            sbc edit_r_tl_y
            sta dividend
            lda windowx+1
            sbc edit_r_tl_y+1
            sta dividend+1
            lda #gapy
            sta divisor
            lda #0
            sta divisor+1
            jmp divide             
;
divide	    lda #0	        ;preset remainder to 0
            sta remainder
            sta remainder+1
            ldx #16	        ;repeat for each bit: ...

divloop	    asl dividend	;dividend lb & hb*2, msb -> Carry
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

skip	    dex
            bne divloop	
            rts
divisor     dw 3
dividend    dw 10
remainder   dw 0
result      equ dividend
;
;
DoDrag equ *
            TK_call FrontWindow;OnTop
            ; Returns the id of the front window.
            lda OnTop
            cmp WindowFound ; second byte of find result (TheEvent+7)
                                            ; Error : it's TheEvent+6 !!!
                                            ; WindowFound is set by Findwindow call 
                                            ; when a mouse button down event occurs (see Handlebutton) 
                                            ; It is set to the top window where the user clicked.
            beq DoDrag_1                    ; drag bar of top window cliked ?
            jsr UncheckWindow               ; no 
                                            ; update menu check marks
            TK_call SelectWindow;WindowFound ; Was not on top so select it
            ; SelectWindow : Brings the specified window to the front of the desktop.
            ; SelectWindow does not generate an update event. It is the
            ; programmer's responsibility to draw the content area of the window
            ; after he calls SelectWindow.
            ; Parameter :
                ; window_id (input) byte ID of the window to bring to the front.
            lda WindowFound                 ; get window ID
            jsr CheckWindow                 ; update menu check marks
DoDrag_1    lda WindowFound                 ; get window ID again
            sta DragParms                   ; prepare parameter for DragWindow call
            TK_call DragWindow;DragParms
            ; DragWindow : Interacts with the mouse while dragging a window outline 
            ; after a click in the drag bar
            ; Parameters :
                ; window id (input) byte ID of the window to drag
                ; dragx (input) integer starting pos of mouse (x-coordinate in screen coordinates)
                ; dragy (input) integer starting pos of mouse (y-coordlnate in screen coordinates)
                ; ItMoved (output) byte : 1 for yes, 0 for no
;
            lda ItMoved                     ; get flag 
            beq DoDrag_2 ; no it did not move
            jmp ClearUpdates                ; ClearUpdates removes all update events from queue 
                                            ; and process them. And exit.
                                            ; not in documentation : DragWindow generates update events.
DoDrag_2    lda WindowFound                 ; get here if user did not move the window.
            cmp OnTop                       ; drag bar of top window clicked ?
            beq DoDrag_3                    ; yes : rts
            jmp DrawItB                     ; no : redraw window 
                                            ; (previous SelectWindow call does not generate update events)
DoDrag_3    rts
;
DoGrow equ *
            lda WindowFound
            sta GrowParms
            TK_call GrowWindow;GrowParms
            ; Interacts with the mouse and re-sizes a window after a click in the
            ; grow box (of the front window)
            ; Parameters :
                ; window_id (input) byte ID of the window to grow
                ; mousex (input) integer starting pos of mouse (x-coordinate in screen coordinates)
                ; mousey (input) integer starting pos of mouse (y-coordinate in screen coordinates)
                ; ItGrew (output) byte 1 for yes 0 for no
            rts
;
DoClose equ *
            TK_call TrackGoAway;TheStat
            ; Interacts with the mouse after a click in the close box (of the front window)
            ; The programmer calls TrackGoAway when he gets a button_down event in
            ; the close box. The routine inverts the close box to provide feedback
            ; to the user, and then tracks the mouse until the button is released.
            ; If the mouse leaves the box, then the box Is restored to its original
            ; form. If the button is released in the close box, the goaway
            ; parameter is set to true, and the user should call CloseWindow. If
            ; the button is released outside the close box, the goaway parameter is
            ; set to false, and the user should leave the window as is.
            ; Parameters :
                ; goaway (output) byte 0: don't close the window ; 1: clese the window
            lda TheStat
            beq DoClose_2                       ; user did not close window  : rts
DoClose_1   TK_call CloseWindow;WindowFound
            ; Removes a window from the desktop
            ; A window_id of 0 specifies the front window.
            ; CloseWindow generates an update event for any windows which were
            ; covered by the removed window.

            ; Parameters :
                ; window_id (input) byte ID of the window to close.
;
            lda WindowFound                     ; get clicked window
            jsr UncheckWindow                   ; uncheck menu item corresponding to the window to close
            TK_call FrontWindow;OnTop           ; get window now on top (if any)
            lda OnTop                           ; get it's ID
            beq DoClose_2                       ; ID = 0 : no window => rts
            jsr CheckWindow                     ; check menu item corresponding to the window now on top
DoClose_2   rts
*
*
*
*
;;
;; Killer is the routine that terminates the program.
;; It does all the necessary clean up for quitting
;; cleanly.
;;
Killer      equ *
            TK_call CloseAll;0 ; Close all the windows ; 
            ; CloseAll : closes all windows on the desktop
            ; Parameters : None
            TK_call StopDeskTop;0
            ; StopDeskTop : eactivates the mouse and Mouse Graphics Tool Kit routines
            ; Parameters : None
            TK_call SetSwitches;TextSwitch ; Turn off graphics/turn on text.
            ; SetSwicches : sets the soft switches in the Apple II.
            ; Parameters :
                ; Bits :
                    ; 4-7 not used
                    ; 3 
                        ; 0: TEXT Off (SC050) graphics on
                        ; 1: TEXT On (SC051) cext on
                    ; 2 
                        ; 0: MIXED Off (SC052) mixed mode off
                        ; 1: MIXED On (SC053) mixed mode on
                    ; 1 
                        ; 0: PAGE2 Off ($C054) page 1
                        ; 1: PAGE2 On (SC055) page 2
                    ; 0 
                        ; 0: HIRES Off (SC056) hi-res off
                        ; 1: HIRES On (SC057) hi-res on

            TK_call SetZP1;SaveZP ; Restore zero page
            ; SetZP1 : sets the preservation status for part of zero page.
            ; Parameters:
                ; preserve: byte (input) 
                    ; 0: Save part of zero page now; restore it later with another call to this routine.
                    ; $80: Restore the part of zero page previously saved, and continue co save and restore
                    ; it on each call Co the primitives.
;
            bit Quit ; if High bit is set then do ProDOS quit
            bmi Killer_1 ; else just clear the screen and enter monitor.
            jsr $C300 ; Clear the text screen.
            jmp MonitorEntry                        ; goto monitor (= call -151)
Killer_1    jsr $BF00                               ; ProDOS MLI call
            dfb $65
            dw quit_params
            brk ; if we get here something is wrong!
*
quit_params dfb 4                                   ; standard ProDOS quit call paramters
            dw 0,0,0,0
TextSwitch  dfb 8                                   ; bit 3 on : text on
*
*
*
*
Quit        dfb 0 ; Global quit flag. High bit set => quit.
;
TheDesk     dfb $06,$EA ;machine ID
            dfb $0 ;ProDOS
            dfb $0                                  ; mouse slot
InterruptFlag dfb UseInterrupts ; no interupts
            dw SystemFont                           ; memory location of font
            dw SaveBuffer                           ; location of buffer for saving screen data
            ; dw 4000 ; save area size
            dw 1024 ; save area size                ; saving memory ???
            * To be tested : move SaveBuffer to 9200 (to 9500), to free A000 to AFFF

;
; Menu Initialization Stuff
CharList    dfb 30 ; Solid Apple
            dfb 31 ; Open Apple
            dfb 29 ; Check Mark
            dfb 1 ; Control character
            dfb 127 ; Inactive character
*
*** Windows ***
*
* Information about any window ia conveyed to the Tool Kit 
* in a window Information structure (winfo). It Is the programmer's responsibility
* to initialize this structure properly. As with the menu data structures,
* many of the fields determine the initial status of the window; after the 
* initial setup, the programmer updatea the winfo by means of procedure calls

*** winfo  record ***
* window_id: byte
* 
* Window Option Byte :
    * dialog: boolean; {bit 0)
    * goawaybox: boolean
    * growbox: boolean
    * reservel: boolean
    * reaerve2: boolean
    * reserve!: boolean
    * reserved: boolean
    * reserves: boolean; (bit 7}
* 
* title_ptr: *title_str
* 
* Horizontal Scroll Option Byte :
    * hactlve: boolean; (bit 0}
    * reserve6: boolean
    * reserve7: boolean
    * reserveS: boolean
    * reserve9: boolean
    * reservlO: boolean
    * hthumb: boolean
    * hacrollbar: boolean; (bit 7}
* 
* Vertical Scroll Option Byte :
    * vactive: boolean; {bit 0}
    * reservll: boolean
    * reservl2: boolean
    * reservl3: boolean
    * reservli: boolean
    * reservl5: boolean
    * vthurab: boolean
    * vscrollbar: boolean; {bit 7}
* 
* hthumbmax: byte
* hthumbpos: byte
* vthumbmax: byte
* vthumbpos: byte
* 
* reservl6: boolean; {bit 0}
* reservI7: boolean
* reservl8: boolean
* reservl9: boolean
* reserv20: boolean
* reserv21: boolean
* reserv22: boolean
* win_open: boolean; {bit 7}
* 
* reserv23: byte
* 
* mincontwidth: integer
* maxcontwidth: integer
* mincontlength: Integer
* maxcontlength: integer
* windowport: grafport
* nextwinfo: pointer

WinfoTable dw 0,SampleWindow,EditFontW,CharsWindow
;
SampleWindow dfb 1,%00000110 ; Has GoAway and Grow boxes
            dw SampleStr
            dfb $80,$80 ;ctrl options
            dfb 3,0 ; H-ThumbMax and H-Thumb Pos
            dfb 3,0 ; V-ThumbMax and V-Thumb Pos
            dfb 0,0 ; Status Byte & Reserved
;
            dw 100,25
            dw 300,100
;
            dw 30,30 ;window port
            dw $2000,$80
            dw 0,0,280,36
            ds 8,$FF
            dfb $FF,0 ; and & or mask
            dw 0,0
            dfb 1,1
            dfb 0,$7F
            dw SystemFont
;
            dw 0 ;link to next window
;
;
EditFontW dfb 2,%00000110 ; Has GoAway and Grow Boxes
            dw EditFontWStr
            dfb $80,$80 ; ctrl options
            dfb 3,0 ; H-ThumbMax and H-Thumb Pos
            dfb 3,0 ; V-ThumbMax and V-Thumb Pos
            dfb 0,0 ; Window Option Byte and Reserved
;
            dw 100,100
            dw 500,180
;
            dw 30,27 ;window port
            dw $2000,$80
bwRect      dw 0,0,300,130
            ds 8,$FF
            dfb $FF,0 ; and & or masks
            dw 0,0
            dfb 1,1
            dfb 0,$7F
            dw SystemFont
;
            dw 0 ;link to next window
;
;
CharsWindow dfb 3,%00000010 ; Has GoAway but no Grow Box
            dw CharsStr
            dfb 0,0 ; ctrl options
            dfb 0,0 ; H-ThumbMax and H-Thumb Pos
            dfb 0,0 ; V-ThumbMax and V-Thumb Pos
            dfb 0,0 ; Window Option Byte and Reserved
;
            dw 100,100
            dw 500,180
;
            dw 20,90 ;window port
            dw $2000,$80
            dw 0,0,180,90
            ds 8,$FF
            dfb $FF,0 ; and & or masks
            dw 0,0
            dfb 1,1
            dfb 0,$7F
            dw SystemFont
;
            dw 0 ;link to next window
;
;
TestWindow  dfb 4,%00000110 ; Has GoAway & Grow Boxes
            dw TestStr
            dfb $80,$80 ; Ctrl options
            dfb 3,0 ; H-ThumbMax and H-Thumb Pos
            dfb 3,0 ; V-ThumbMax and V-Thumb Pos
            dfb 0,0 ; Window Option Byte and Reserved
;
            dw 100,100
            dw 500,180
;
            dw 30,40 ;window port
            dw $2000,$80
            dw 0,0,240,130
            ds 8,$FF
            dfb $FF,0 ; And & Or masks
            dw 0,0
            dfb 1,1
            dfb 0,$7F
            dw SystemFont
;
            dw 0 ;link to next window
;
;
DialogWindow dfb 5,%00000001 ; Dialog Box
            dw 0
            dfb 0,0 ;ctrl options
            dfb 0,0 ; H-ThumbMax and H-Thumb Pos
            dfb 0,0 ; V-ThumbMax and V-Thumb Pos
            dfb 0,0 ; Window Option Byte and Reserved
;
            dw 100,100
            dw 500,180
;
            dw 150,30 ;window port
            dw $2000,$80
            dw 0,0,264,100
            ds 8,$FF
            dfb $FF,0 ; and & or masks
            dw 0,0
            dfb 1,1
            dfb 0,$7F
            dw SystemFont
;
            dw 0 ;link to next window


AlertWindow dfb 6,%00000001                         ; Alert Box
            dw 0                                    ; no title
            dfb 0,0 ;ctrl options
            dfb 0,0 ; H-ThumbMax and H-Thumb Pos
            dfb 0,0 ; V-ThumbMax and V-Thumb Pos
            dfb 0,0 ; Window Option Byte and Reserved
;
            dw 100,100
            dw 500,180
;
            dw 150,30 ;window port
            dw $2000,$80
            dw 0,0,260,25                           ; size ?
            ds 8,$FF
            dfb $FF,0 ; and & or masks
            dw 0,0
            dfb 1,1
            dfb 0,$7F
            dw SystemFont
            dw 0 ;link to next window

MessageBox  dfb 7,%00000001                         ; Alert Box
            dw 0                                    ; no title
            dfb 0,0 ;ctrl options
            dfb 0,0 ; H-ThumbMax and H-Thumb Pos
            dfb 0,0 ; V-ThumbMax and V-Thumb Pos
            dfb 0,0 ; Window Option Byte and Reserved
;
            dw 100,100
            dw 500,180
;
            dw 150,30 ;window port
            dw $2000,$80
            dw 0,0,260,40                           ; size ?
            ds 8,$FF
            dfb $FF,0 ; and & or masks
            dw 0,0
            dfb 1,1
            dfb 0,$7F
            dw SystemFont
            dw 0 ;link to next window

;
SampleStr    str 'Sample '
EditFontWStr str 'Edit font'
CharsStr    str 'Display Font'
TestStr     str 'Test Window'
;
;
VScroll     dfb 1,1
HScroll     dfb 2,1
VCtrl       dfb 1,0,0,0
HCtrl       dfb 2,0,0,0
OnTop       dfb 0
;
************************************************************
*
* Many of the tool kit calls require that the mouse
* coordinates be passed back to the tool kit. Since
* the mouse coordinates are originally provided in
* the event parameters, using the same memory to pass
* parameters to the tool kit saves us the trouble of
* moving the information around.
*
* Below I equate many labels to the same memory. When
* I use them in the code I try to indicate (in a comment
* that they refer to this shared area).
*
*
* The event parameter is five bytes long. The first byte
* is the event type.  The remaining bytes depend on the
* value of the first byte.
*
* For
*
************************************************************
TheEvent equ *
EvtType equ *
DragParms equ *
GrowParms equ *
ThumbParms equ *
TrackParms equ *
MouseX equ *+1
FWParms equ *+1
FCParms equ *+1
UpdateID equ *+1
ThumbPos equ *+1
EvtKey equ *+1
EvtMods equ *+2
MouseY equ *+3
WindowFound equ *+6
ItMoved equ *+5 ; Returned by DragWindow
FindResult equ *+5                  ; = which_area output parameter of FindWindow call
                                    ; or which_ctl output parameter of FindControl call
ThumbResult equ *+5
WhichPart equ *+6                   ; = which_part output parameter of FindControl call 
                                    ; or window_ID output parameter of FindWindow call
ThumbMoved equ *+6
            ds 5,0 ; 5 bytes for the event
            ds 2,0 ; 2 bytes for find results and tracking
*

*
MenuCmd dfb 0
MenuItem dfb 0
MenuChar dfb 0
MenuMods dfb 0
;
TheStat ds 1 ;room to return status
;
TheItem dfb 1,1,1 ; that is checked
;
FldrStr dfb 13
            asc 'System Folder'
;;
TheMenu     dfb 4,0                     ; number of menus, (7 in this program) + reserved byte.
            dfb 1,0 ;Apple mblock       ; menu 1 ID + disable flag
            dw AppleStr,AppleMenu       ; title pointer + pointer to menu
            ds 6,0                      ; 6 reserved bytes
            dfb 2,0 ;File mblock        ... and so on for each menu
            dw FileStr,FileMenu
            ds 6,0
            dfb 3,0 ;Edit mblock
            dw EditStr,EditMenu
            ds 6,0
            dfb 4,0                     ; Windows menu
            dw FontStr,FontMenu
            ds 6,0

;
;
AppleMenu   dfb 1                       ; number of items In the menu
            ds 5,0                      ; 5 reserved bytes
            dfb 0,0,0,0                 ;About_ iblock
                                        ; byte 1 : 
                                            ; open_apple : boolean; (bit 0)
                                            ; solid_apple : boolean;
                                            ; item has_mark : boolean;
                                            ; reaerve2 : boolean;
                                            ; reserve3 : boolean;
                                            ; item_is_checked : boolean;
                                            ; item_is_filler : boolean;
                                            ; disable_flag : boolean; (bit 7)

                                        ; byte 2 : mark_char 
                                        ; charl : byte;
                                        ; char2 : byte;
                                        ; "Charl" and "char2" are the Ascii values of the characters which are
                                        ; shortcut keystrokes for the menu item

            dw AppleItem1               ; pointer to item string
;
FileMenu    dfb 5
            ds 5,0
            dfb 0,0,0,0 
            dw FileItemLoad
            dfb 0,0,0,0 
            dw FileItemSave
            dfb 0,0,0,0 
            dw FileItemReset            
            dfb 0,0,0,0                 ; Monitor Entry
            dw FileItem1
            dfb 3,0,'Q','q' ; Quit
            dw FileItem2
;
EditMenu    dfb 7
            ds 5,0
            dfb 3,0 ;Undo
            asc 'Zz'
            dw EditItem1
            dfb 3,0 ;Cut
            asc 'Xx'
            dw EditItem2
            dfb 3,0 ;Copy
            asc 'Cc'
            dw EditItem3
            dfb 3,0 ;Paste
            asc 'Vv'
            dw EditItem4
            dfb 0,0,0,0 ;Clear
            dw EditItem5
            dfb 0,0,0,0 ;Select All
            dw EditItem6
            dfb 0,0,0,0 ;Show Clipboard
            dw EditItem7
;
FontMenu    dfb 7
            ds 5,0
            dfb 0,0,0,0
            dw WindowItem1
            dfb 0,0,0,0
            dw WindowItem2
            dfb 0,0,0,0
            dw WindowItem3
            dfb $40,0,0,0
            dw 0
            dfb 3,0,'D','d'
            dw WindowItem5
            dfb 3,0,'G','g'
            dw WindowItem6
            dfb 3,0,'H','h'
            dw WindowItem7
;

;
AppleStr dfb 1,30 ;AppleChar
FileStr str 'File'
EditStr str 'Edit'
FontStr str 'Font'
MTStr str 'Menu Test'
WTStr str 'Window Test'
DummyStr str 'Dummy'
;
AppleItem1 str 'About Font Editor... '
;
FileItem1 str 'Enter Monitor'
FileItem2 str 'Quit'
FileItemLoad str 'Load working font'
FileItemSave str 'Save working font'
FileItemReset str 'Reset system font'
;
EditItem1 str 'Undo'
EditItem2 str 'Cut'
EditItem3 str 'Copy'
EditItem4 str 'Paste'
EditItem5 str 'Clear'
EditItem6 str 'Select All'
EditItem7 str 'Show Clipboard'
;
WindowItem1 str 'Sample text'
WindowItem2 str 'Edit Font'
WindowItem3 str 'Display Font '
WindowItem5 str 'Drag'
WindowItem6 str 'Grow'
WindowItem7 str 'Hide'

;
DoNotSave dfb 0
SaveZP dfb $80


WaitForKeyPress equ *                                   ; wait a key from user
                jsr Bell                                ; play a sound
Wait            equ *
                bit kbdstrb                             ; test keybord input
                bpl Wait                                ; loop while no key pressed
                lda kbd                                 ; get kes value
                rts

GetCharVal      
                ldy #00
                lda CharBase_1,x
                sta MyChar,y
                iny
                lda CharBase_2,x
                sta MyChar,y
                iny
                lda CharBase_3,x
                sta MyChar,y
                iny
                lda CharBase_4,x
                sta MyChar,y
                iny
                lda CharBase_5,x
                sta MyChar,y
                iny
                lda CharBase_6,x
                sta MyChar,y
                iny
                lda CharBase_7,x
                sta MyChar,y
                iny
                lda CharBase_8,x
                sta MyChar,y
                iny
                lda CharBase_9,x
                sta MyChar,y
                rts

CharBase_1      equ SystemFont+3+128
CharBase_2      equ CharBase_1+128
CharBase_3      equ CharBase_2+128
CharBase_4      equ CharBase_3+128
CharBase_5      equ CharBase_4+128
CharBase_6      equ CharBase_5+128
CharBase_7      equ CharBase_6+128
CharBase_8      equ CharBase_7+128
CharBase_9      equ CharBase_8+128

MyChar          ds 9
MyChar2         ds 9
MyCharwidth     ds 1


error       brk                     ; display en error message here
            rts
tfont       str 'TEST.FONT'
            dfb 0
workfont    asc 'WORK'
testfont    asc 'TEST'


openparam   dfb 3
            dw path
            dw $8E00                ; ATTENTION !!!!!
refnum      ds 1

readparam
            dfb 4
refnum2     ds 1
            dw $8800
            dw 1283
            dw 0

closeparam
            dfb 1
refnum3     ds 1

DoPrefix
          jsr MLI                   ; Setprefix call, prefix ==> "path"
          hex c7
          da prefix
          bcc suitegp
          jsr error
          bra men
suitegp
          lda path                  ; get prefix length
          beq noprefix              ; length = 0 : prefix not set
          jmp goodpfx               ; > 0 prefix is already set : rts
noprefix
          lda devnum                ; last used slot/drive 
          sta unit                  ; param of online MLI call
men       jsr MLI
          hex c5                    ; on_line call : get prefix in path var
          da onlinep
          bcc suite
          jsr error
          bra men                   ; loop if error l'erreur (user need to put good floppy in drive)
suite     lda path
          and #$0f                  ; length in low nibble
          sta path
          tax
l1        lda path,x
          sta path+1,x              ; shift 1 byte
          dex
          bne l1
          inc path
          inc path                  ; long = long + 2  for starting and ending /
          ldx path
          lda #$af
          sta path,x                ; / at the end of prefix
          sta path+1                ; / at the beginning of prefix

          jsr MLI                   ; set_prefix
          hex c6
          da prefix
          bcc goodpfx
          jsr error
goodpfx   rts

prefix    hex 01
          da path

path      ds 256

onlinep   hex 02
unit      ds 1
          da path

LoadFont
            jsr DoPrefix            ; set prefix in path var (strating and ending with /) 

            ldx #3
            lda LoadFlag            ; test LoadFlag
            beq workl

            
testl       lda workfont,x          ; LoadFlag <> 0  : set 'WORK.TEST' as file name
            sta tfont+1,x 
            dex  
            bpl testl
            jmp LoadStart

workl       lda testfont,x          ; LoadFlag = 0  : set 'TEST.TEST' as file name (system font)
            sta tfont+1,x 
            dex  
            bpl workl

LoadStart
            ldy #0                  ; add file name string to prefix
            ldx path                ; get prefix length
:1          inx                     ; set x index to next position in prefix
            lda tfont+1,y           ; read char in file name string
            beq DoOpen              ; if value = 0 : exit loop
            sta path,x              ; store char at the end of prefix string
            iny                     ; next char
            jmp :1                  ; loop

DoOpen                              ; adjust prefix length
            lda path                ; by adding file name length
            clc
            adc tfont               ; file name length
            sta path

            jsr MLI                 ; open file 
            dfb open
            da openparam
            bcc DoLoad
            jmp error
DoLoad                              ; load it in memory
            lda refnum              ; copy ref num of open file for next MLI calls
            sta refnum2             ; for read call 
            sta refnum3             ; for close call

            jsr MLI
            dfb read
            da readparam
            bcc CloseFile
            jmp error

CloseFile                           ; and close file
            jsr MLI
            dfb close
            da closeparam
            rts

LoadFlag    ds 1




saveQtext   ds 3
Conftext    str 'Changes will be lost, can you confirm?'



SaveFont    
            jsr DoPrefix            ; set prefix in path var (strating and ending with /

            ldx #3
testl2      lda workfont,x          ; set 'WORK.TEST' as file name
            sta tfont+1,x 
            dex  
            bpl testl2

            ldy #0                  ; add file name string to prefix
            ldx path                ; get prefix length
:1          inx                     ; set x index to next position in prefix
            lda tfont+1,y           ; read char in file name string
            beq DoOpen2             ; if value = 0 : exit loop
            sta path,x              ; store char at the end of prefix string
            iny                     ; next char
            jmp :1                  ; loop

DoOpen2                             ; adjust prefix length
            lda path                ; by adding file name length
            clc
            adc tfont               ; file name length
            sta path

            jsr MLI                 ; open file 
            dfb open
            da openparam
            bcc DoSave
            jmp error

DoSave                              ; save file to disk 
            lda refnum              ; copy ref num of open file for next MLI calls
            sta refnum4             ; for write call 
            sta refnum3             ; for close call

            jsr MLI
            dfb write
            da writeparam
            bcc CloseFile2
            jmp error

CloseFile2                          ; and close file
            jsr MLI
            dfb close
            da closeparam

            rts

writeparam
            dfb 4
refnum4     ds 1
            da SystemFont
            dw 1283
            ds 2                       

prgend  equ *