;
; equate file for interfacing to toolkit/graphics
;
ToolMLI equ $4000

;
; constants
;
SrcCopy     equ 0
SrcOr       equ 1
SrcXor      equ 2
SrcBic      equ 3
SrcNotCopy  equ 4
SrcNotOr    equ 5
SrcNotXor   equ 6
SrcNotBic   equ 7
;
NullEvent   equ 0
ButnDown    equ 1
ButnUp      equ 2
KeyPress    equ 3
DragEvent   equ 4
AplKeyDown  equ 5
UpdateEvt   equ 6
;
; grafport structure
;
viewloc     equ 0
;portbits equ viewloc+4
portbits    equ 4
;portwidth equ portbits+2
portwidth   equ 6
;portrect equ portwidth+2
portrect    equ 8
;penpat equ portrect+8
penpat      equ 16
penloc      equ penpat+10
pensize     equ penloc+4
penmode     equ pensize+2
txback      equ penmode+1
txfont      equ txback+1
;
PortLength  equ txfont+2

;
; command bytes
;
InitGraf    equ 1
SetSwitches equ InitGraf+1
;
InitPort    equ SetSwitches+1
SetPort     equ InitPort+1
GetPort     equ SetPort+1
SetPortBits equ GetPort+1
SetPenMode  equ SetPortBits+1
SetPattern  equ SetPenMode+1
SetColorMasks equ SetPattern+1
SetPenSize  equ SetColorMasks+1
SetFont     equ SetPenSize+1
SetTextBG   equ SetFont+1
;
Move        equ SetTextBG+1
MoveTo      equ Move+1
Line        equ MoveTo+1
LineTo      equ Line+1
PaintRect   equ LineTo+1
FrameRect   equ PaintRect+1
InRect      equ FrameRect+1
PaintBits   equ InRect+1
PaintPoly   equ PaintBits+1
FramePoly   equ PaintPoly+1
InPoly      equ FramePoly+1
;
TextWidth   equ InPoly+1
DrawText    equ TextWidth+1
;
;SetZP1 equ DrawText+1
SetZP1      equ 26
SetZP2      equ SetZP1+1
GetVersion  equ SetZP2+1
;
StartDeskTop equ GetVersion+1
StopDeskTop equ StartDeskTop+1
SetUserHook equ StopDeskTop+1
AttachDriver equ SetUserHook+1
ScaleMouse  equ AttachDriver+1
KeyBoardMouse equ ScaleMouse+1
;
SetCursor   equ KeyBoardMouse+1
ShowCursor  equ SetCursor+1
HideCursor  equ ShowCursor+1
ObscureCursor equ HideCursor+1
GetCursorAdr equ ObscureCursor+1
;
CheckEvents equ GetCursorAdr+1
GetEvent    equ CheckEvents+1
FlushEvents equ GetEvent+1
PeekEvent   equ FlushEvents+1
PostEvent   equ PeekEvent+1
SetKeyEvent equ PostEvent+1
;
InitMenu    equ SetKeyEvent+1
SetMenu     equ InitMenu+1
MenuSelect equ SetMenu+1
MenuKey     equ MenuSelect+1
HiLiteMenu  equ MenuKey+1
DisableMenu equ HiLiteMenu+1
DisableItem equ DisableMenu+1
CheckItem   equ DisableItem+1
SetMark     equ CheckItem+1
;
OpenWindow equ SetMark+1
CloseWindow equ OpenWindow+1
CloseAll    equ CloseWindow+1
GetWinPtr   equ CloseAll+1
GetWinPort  equ GetWinPtr+1
SetWinPort  equ GetWinPort+1
BeginUpdate equ SetWinPort+1
EndUpdate   equ BeginUpdate+1
FindWindow  equ EndUpdate+1
FrontWindow equ FindWindow+1
SelectWindow equ FrontWindow+1
TrackGoAway equ SelectWindow+1
DragWindow  equ TrackGoAway+1
GrowWindow  equ DragWindow+1
ScreenToWindow equ GrowWindow+1
WindowToScreen equ ScreenToWindow+1
;
FindControl equ WindowToScreen+1
SetCtlMax   equ FindControl+1
TrackThumb  equ SetCtlMax+1
UpdateThumb equ TrackThumb+1
ActivateCtl equ UpdateThumb+1
;
