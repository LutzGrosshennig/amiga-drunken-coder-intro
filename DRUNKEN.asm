INTENA         = $9A
DMACON         = $96
DMACONR        = $02
VHPOSR         = $06

BLTCON0        = $40
BLTCON1        = $42
BLTCPTH        = $48
BLTBPTH        = $4C
BLTAPTH        = $50
BLTAPTL        = $52
BLTDPTH        = $54
BLTCMOD        = $60
BLTBMOD        = $62
BLTAMOD        = $64
BLTDMOD        = $66
BLTSIZE        = $58
BLTADAT        = $74
BLTBDAT        = $72
BLTAFWM        = $44
BLTALWM        = $46

COLOR00        = $180

; OFFSETS EXEC

FORBID         = -132
PERMIT         = -138
OPENLIBRARY    = -408
CLOSELIBRARY   = -414
ALLOCMEM       = -198
FREEMEM        = -210

; KONSTANTEN

EXECBASE       = 4
MOUSEBUTTON    = $BFE001
CHIPCLEAR      = $10002
SCREENX        = 352
SCREENY        = 256
PLANES         = 6
PLANESIZE      = (SCREENX*SCREENY)/8
PLAYFIELD      = PLANESIZE*PLANES

SCREENB        = SCREENX/8
SCREENW        = SCREENX/16

TEXTLAENGE     = TEXTEND1 - DEMOTEXT -1
SCROLLSPEED    = 1

ZEILE          = 183

NO_SHADOWS     = 10

SHADING        = 4
COPPERLINES    = 60
COP_START      = $E600

;----------------------------------------------------------

OPENLIB:MACRO *\NAME,*\BASE

       LEA     \NAME(PC),A1
       JSR     OPENLIBRARY(A6)
       MOVE.L  D0,\BASE

 ENDM

CLOSELIB:MACRO *\BASE

       MOVE.L  EXECBASE,A6
       MOVE.L  \BASE(PC),A1
       JSR     CLOSELIBRARY(A6)

 ENDM

WAIT_BLIT:MACRO

\1:    BTST    #14,DMACONR(A5)                 ;16
       BNE.S   \1                              ;

 ENDM

;------------  M A I N  -  P R O G R A M  -----------------

       CODE

START:

       MOVE.L  EXECBASE,A6
       JSR     FORBID(A6)

       OPENLIB GFXNAME,GFXBASE

       BSR     MT_INIT

       LEA     $DFF000,A5

       MOVE.W  #$20,$1DC(A5)   ; BACK TO PAL

       BSR     OPENSCR

       BSR     LINE_INIT

MAIN_LOOP:

       MOVE.W  $6(A5),D2
       AND.W   #$FF00,D2
       CMP.W   #$1000,D2
       BNE.S   MAIN_LOOP

       CMP.W   #8,ZAEHLER                      ;20
       BEQ     PUT_IT                          ;

BACKEBACK:

SCROLL_BAR:

       MOVEQ   #0,D4

       MOVE.L  DUMMYSCREEN1(PC),D1
       MOVE.L  DUMMYSCREEN11(PC),D0

       MOVE.L  #SCREENB*22,D2               ; Planesize

       MOVEQ   #2,D7

       WAIT_BLIT

       MOVE.L  D4,BLTAMOD(A5)               ; ALLE MOD = 0
       MOVE.L  D4,BLTCMOD(A5)
       MOVE.L  #$C9F00000,BLTCON0(A5)
 
SCROLL_LOOP:

       MOVEM.L D0/D1,BLTAPTH(A5)
       MOVE.W  #(64*22)+SCREENW,BLTSIZE(A5)

       ADD.L   D2,D0
       ADD.L   D2,D1
       
       WAIT_BLIT

       DBRA    D7,SCROLL_LOOP

;------------------------------------------------------- PLANES OR

       MOVE.L  DUMMYSCREEN1(PC),D0         ; A
       MOVE.L  DUMMYSCREEN2(PC),D1         ; B,D
 
       MOVE.W  #$09F0,BLTCON0(A5)          ; 1 PLANE DIREKT
 
       MOVEM.L D0/D1,BLTAPTH(A5)

       MOVE.W  #(64*22)+SCREENW,BLTSIZE(A5)

       ADD.L   D2,D0
       
       MOVEQ   #1,D7

       WAIT_BLIT

       MOVE.W  #$0DFC,BLTCON0(A5)

DOR_LOOP:

       MOVEM.L D0/D1,BLTAPTH(A5)
       MOVE.L  D1,BLTBPTH(A5)
       MOVE.W  #(64*22)+SCREENW,BLTSIZE(A5)

       ADD.L   D2,D0

       WAIT_BLIT

       DBRA    D7,DOR_LOOP

;---------------------------------------------- COKIE CUT

       MOVE.L  SCREENBASE(PC),D0        ; D
       ADD.L   #ZEILE*SCREENB,D0

       MOVE.L  DUMMYSCREEN1(PC),D3       ; B
       MOVE.L  DUMMYSCREEN2(PC),D1       ; A
       MOVE.L  BLABASE(PC),D5            ; C

       MOVE.L  #PLANESIZE,D2            ; 10240

       MOVEQ   #4,D7

       MOVE.W  #$0FCA,BLTCON0(A5)
 
C_SCROLL2_LOOP:

       MOVE.L  D1,BLTAPTH(A5)
       MOVE.L  D3,BLTBPTH(A5)
       MOVE.L  D5,BLTCPTH(A5)
       MOVE.L  D0,BLTDPTH(A5)
       MOVE.W  #(64*22)+SCREENW,BLTSIZE(A5)

       ADD.L   #SCREENB*22,D3
       ADD.L   D2,D0
       ADD.L   #SCREENB*22,D5

       WAIT_BLIT

       DBRA    D7,C_SCROLL2_LOOP

       MOVE.W  #SCREENB,BLTCMOD(A5)

CLS:

       MOVE.L  SHADOWSCREEN(PC),BLTDPTH(A5)    ; 28
       MOVE.L  #$01000000,BLTCON0(A5)
       MOVE.W  #(64*42)+SCREENW,BLTSIZE(A5)    ; 16

SCROLL_SHADOWS:

       LEA     SHADOW_DAT(PC),A0               ; 8
       MOVEQ   #NO_SHADOWS,D7                  ; 4
       MOVEQ   #8,D0                           ; 4

SHADOW_LOOP:                                   ;
       TST.W   (A0)                            ; 4
       BEQ.S   NO_SHADOW                       ;
       SUBQ.W  #4,(A0)                         ; 4
NO_SHADOW:                                     ;
       ADD.L   D0,A0                           ; 6
       DBRA    D7,SHADOW_LOOP                  ;

DO:
       LEA     SHADOW_DAT(PC),A4               ; 8
       MOVE.L  MULU4_TAB(PC),A0
       MOVE.L  MULU5_TAB(PC),A1
       MOVEQ   #NO_SHADOWS,D7                          ; 4
       MOVE.W  #$402,A6

       WAIT_BLIT

       MOVE.W  #-16,BLTAPTL(A5)
       MOVE.W  #-32,BLTAMOD(A5)
       MOVE.W  #SCREENB,BLTDMOD(A5)
       MOVE.W  #$41,BLTCON1(A5)
       MOVE.W  #$8000,BLTADAT(A5)

DO_LOOP:

       MOVE.W  (A4),D2                         ; 8
       TST.W   D2                              ; 4
       BEQ.S   NEXT_SHADOW                     ;
       MOVE.L  4(A4),A3                        ; 16
       MOVEQ   #21,D6                          ; 4

DO_LOOP2:

       MOVE.W  (A3)+,D4                        ; 8
       TST.W   D4                              ; 4
       BEQ.S   KEINE_DATEN                     ;

DRAWLINE:

       CMP.W   #7,D2                          ; 8
       BLO.S   RAUS                            ; 8/12
       CMP.W   #310,D2                         ; 8
       BHI.S   RAUS                            ; 8/12

FAST_LINE:

       MOVE.W  D2,D0           ; 4
       ADD.W   D0,D0           ; 4
       MOVE.W  0(A0,D0.W),D5   ; 12
       ADD.W   D0,D0           ; 4
       MOVE.L  0(A1,D0.W),D1   ; 16
       MOVE.W  D5,D0           ; 4

       WAIT_BLIT

       MOVE.L  D1,BLTCPTH(A5)
       MOVE.L  D1,BLTDPTH(A5)
       MOVE.W  D4,BLTBDAT(A5)
       MOVE.W  D0,BLTCON0(A5)
       MOVE.W  A6,BLTSIZE(A5)
RAUS:

KEINE_DATEN:

       ADDQ.W  #1,D2                           ; 4
       DBRA    D6,DO_LOOP2                     ;

NEXT_SHADOW:

       ADDQ.W  #8,A4                           ; 4
       DBRA    D7,DO_LOOP                      ;

BLUB:
       ADDQ.W  #1,ZAEHLER

       BSR     MT_MUSIC

       LEA     $DFF000,A5

       BTST    #6,MOUSEBUTTON
       BNE     MAIN_LOOP 
ENDE:
       BSR     CLOSESCR
ENDE1:

       BSR     MT_END

       CLOSELIB GFXBASE

       JSR     PERMIT(A6)

       MOVEQ   #0,D0
       RTS

;--------------------------

PUT_IT:
       BSR.S   SETCHAR
       BSR     SET_SHADOW
       BRA     BACKEBACK
;-------------------------

SETCHAR:

       MOVE.W  TEXTZAEHLER(PC),D0
       CMP.W   #TEXTLAENGE,D0
       BEQ.S   RESET_TEXT

       BSR     GET_ADRESS
       BSR     BLITBACKGROUND
       ADDQ.L  #1,TEXTPOINTER
       ADDQ.W  #1,TEXTZAEHLER
       CLR.W   ZAEHLER
       RTS

RESET_TEXT:

       MOVE.L  #DEMOTEXT,TEXTPOINTER
       CLR.W   TEXTZAEHLER
       BRA.S   SETCHAR

;----------------------------------------------------

SET_SHADOW:

       LEA     SHADOW_DAT(PC),A0               ; 8
       LEA     MULU3_TAB(PC),A1                ; 8
       LEA     CHAR_DATA(PC),A2                ; 8
       MOVEQ   #0,D0                           ; 4
       MOVEQ   #NO_SHADOWS,D7                          ; 4
       MOVE.B  CURRENT_SHADOW(PC),D0           ;12
       MOVEQ   #8,D1                           ; 4
                                               ;
SET_SH_LOOP:                                   ;
                                               ;
       TST.W   (A0)                            ; 4
       BEQ.S   FREIER_SCHATTEN                 ;
       ADD.L   D1,A0                           ; 6
       DBRA    D7,SET_SH_LOOP                  ;
BACK_SHADOW:
       RTS                                     ;
                                               ;
FREIER_SCHATTEN:                               ;
                                               ;
       CMP.B   #50,D0                          ; 8
       BEQ.S   BACK_SHADOW                     ;
       ADD.W   D0,D0                           ; 4
       MOVE.W  0(A1,D0.W),D0                   ;14
       ADD.L   A2,D0                           ; 8
       MOVE.L  D0,4(A0)                        ;16
       MOVE.W  #320,(A0)                       ; 8
       RTS

GET_ADRESS:

       LEA     MULU_TAB(PC),A1
       MOVE.L  TEXTPOINTER(PC),A0
       LEA     CHARSET_DATA,A2
       MOVEQ   #0,D0
       MOVE.B  (A0),D0
       CMP.B   #" ",D0
       BEQ.S   SET_BLANK

       SUB.B   #48,D0
       MOVE.B  D0,CURRENT_SHADOW
       ADD.W   D0,D0
       MOVE.W  0(A1,D0.W),D0
       ADD.L   A2,D0
       MOVE.L  D0,DATAPOINTER
       RTS

SET_BLANK:
       CLR.L   DATAPOINTER
       MOVE.B  #50,CURRENT_SHADOW
       RTS

;------------------------------------

BLITBACKGROUND:
  
       MOVEQ   #0,D4

       MOVE.L  DATAPOINTER(PC),D0
       BEQ.S   FASTBLIT

       MOVE.L  DUMMYSCREEN1(PC),D1
       ADD.L   #SCREENB-4,D1

       MOVE.L  #SCREENB*22,D2
       MOVEQ   #88,D3
       MOVEQ   #2,D7

       WAIT_BLIT

       MOVE.W  D4,BLTAMOD(A5)
       MOVE.W  #SCREENB-4,BLTDMOD(A5)
       MOVE.L  #$09F00000,BLTCON0(A5)

BLIT_LOOP:

       MOVEM.L D0/D1,BLTAPTH(A5)

       MOVE.W  #(64*22)+2,BLTSIZE(A5)

       ADD.L   D2,D1
       ADD.L   D3,D0

       WAIT_BLIT

       DBRA    D7,BLIT_LOOP

       RTS

;-------------------------

FASTBLIT:

       MOVE.L  DUMMYSCREEN1(PC),D0              ;
       ADD.L   #SCREENB-4,D0
       MOVE.L  #SCREENB*22,D1                  ;
       MOVEQ   #2,D7                           ;  4

       WAIT_BLIT                               ;

       MOVE.W  #SCREENB-4,BLTDMOD(A5)          ; 16
       MOVE.L  #$01000000,BLTCON0(A5)          ; 16

FASTBLIT_LOOP:

       MOVE.L  D0,BLTDPTH(A5)                  ; 28
       MOVE.W  #(64*22)+2,BLTSIZE(A5)          ; 16
       ADD.L   D1,D0                           ;

       WAIT_BLIT                               ;

       DBRA    D7,FASTBLIT_LOOP                ;
       RTS                                     ;

;==============================================================

COPY_DESERT:

       MOVE.L  #DESERT_DATA,D0
       MOVE.L  SCREENBASE(PC),D1

       MOVE.L  #PLANESIZE,D2
       MOVE.L  #(40*256),D3
       MOVEQ   #4,D7

       WAIT_BLIT

       MOVE.W  #0,BLTAMOD(A5)
       MOVE.W  #SCREENB-40,BLTDMOD(A5)
       MOVE.W  #0,BLTCON1(A5)
       MOVE.W  #$09F0,BLTCON0(A5)
 
DESERT_LOOP:

       MOVE.L  D0,BLTAPTH(A5)
       MOVE.L  D1,BLTDPTH(A5)
       MOVE.W  #(64*256)+20,BLTSIZE(A5)

       ADD.L   D3,D0
       ADD.L   D2,D1

       WAIT_BLIT

       DBRA    D7,DESERT_LOOP

COPY_BLA:

       MOVE.L  SCREENBASE(PC),D0
       ADD.L   #SCREENB*ZEILE,D0

       MOVE.L  BLABASE(PC),D1

       MOVE.L  #PLANESIZE,D2
       MOVE.L  #SCREENB*22,D3
       MOVEQ   #4,D7

       WAIT_BLIT

       MOVE.W  #0,BLTDMOD(A5)
       MOVE.W  #$09F0,BLTCON0(A5)
 
BLA_LOOP:

       MOVE.L  D0,BLTAPTH(A5)
       MOVE.L  D1,BLTDPTH(A5)
       MOVE.W  #(64*22)+SCREENW,BLTSIZE(A5)

       ADD.L   D3,D1
       ADD.L   D2,D0

       WAIT_BLIT

       DBRA    D7,BLA_LOOP

       RTS

;--------------------------------------

DO_RAINBOW:

       LEA     COPPER3,A0
       LEA     RAINBOW_COLORS(PC),A1
       MOVE.W  #COP_START,D0
       MOVEQ   #COPPERLINES-1,D7

RAINBOW_LOOP:
       MOVE.W  D0,D1
       ADD.W   #$3D,D1 ;41
       MOVE.W  D1,(A0)+
       MOVE.W  #$FFFE,(A0)+
       MOVE.W  #$0180,(A0)+
       MOVE.W  (A1)+,(A0)+
       ADD.W   #$9A,D1
       MOVE.W  D1,(A0)+
       MOVE.W  #$FFFE,(A0)+
       MOVE.W  #$0180,(A0)+
       CLR.W   (A0)+
       CMP.W   #$FFD7,D1
       BEQ.S   SET_JUMP
       ADD.W   #$0100,D0
BACK_RAINBOW:
       DBRA    D7,RAINBOW_LOOP
       RTS

SET_JUMP:

       MOVE.L  #$FFFEFFFE,(A0)+
       MOVEQ   #0,D0
       BRA.S   BACK_RAINBOW

;----------------------------

LINE_INIT:

       LEA     $DFF000,A5
       MOVE.L  SCREENBASE(PC),A0
       ADD.L   #PLANESIZE*5,A0
       MOVE.L  A0,PLANE_5

       MOVEQ   #%1111,D0
       SUBQ.W  #SCROLLSPEED,D0
       ROR.W   #4,D0
       MOVE.W  D0,CONTROL

       MOVE.L  SCREENBASE(PC),D1
       ADD.L   #(211*SCREENB)+(5*PLANESIZE),D1
       MOVE.L  D1,SHADOWSCREEN

       LEA     MULU_TAB(PC),A0
       MOVEQ   #49,D7
       MOVEQ   #0,D1
INIT_LOOP:                     ; SCROLLTEXT
       MOVE.L  D1,D0
       MULU    #440,D0
       MOVE.W  D0,(A0)+
       ADDQ.W  #1,D1
       DBRA    D7,INIT_LOOP

       LEA     MULU2_TAB(PC),A0
       MOVEQ   #34,D7
       MOVE.L  #210,D1
INIT2:                         ; LINIE
       MOVE.L  D1,D0
       MULU    #SCREENB,D0
       MOVE.W  D0,(A0)+
       ADDQ.W  #1,D1
       DBRA    D7,INIT2

       LEA     MULU3_TAB(PC),A0
       MOVEQ   #49,D7
       MOVEQ   #0,D1
INIT3:                         ; SCHATTEN
       MOVE.L  D1,D0
       MULU    #44,D0
       MOVE.W  D0,(A0)+
       ADDQ.W  #1,D1
       DBRA    D7,INIT3

       LEA     ALTITUDE(PC),A0
       MOVE.L  #319,D7
INIT4:
       SUB.B   #207,(A0)+
       DBRA    D7,INIT4

       MOVE.L  MULU4_TAB(PC),A0
       LEA     ALTITUDE(PC),A1
       LEA     MULU2_TAB(PC),A2
       MOVE.L  PLANE_5(PC),A3
       MOVE.L  MULU5_TAB(PC),A4
       MOVEQ   #0,D2
       MOVE.L  #319,D7

INIT5:
       MOVEQ   #0,D0
       MOVE.W  D2,D0
       MOVEQ   #0,D1
       MOVE.B  0(A1,D0.W),D1

       ADD.W   D1,D1
       MOVE.W  0(A2,D1.W),D1

       MOVE.L  D0,D5
       ASR.W   #3,D5
       AND.B   #$FE,D5
       ADD.L   D5,D1
       ADD.L   A3,D1
       MOVE.L  D1,(A4)+
       AND.W   #$F,D0
       ROR.W   #4,D0
       ADD.W   #$0BCA,D0
       MOVE.W  D0,(A0)+
       ADDQ.L  #1,D2
       DBRA    D7,INIT5

       WAIT_BLIT

       CLR.W   BLTBMOD(A5)
       MOVE.W  #SCREENB,BLTCMOD(A5)
       MOVE.L  #$FFFFFFFF,BLTAFWM(A5)
       RTS

;-------------------------------

OPENSCR:
       MOVE.L  EXECBASE,A6       ; SPEICHER IM CHIP RAM
       MOVE.L  #PLAYFIELD,D0  ; HOLEN
       MOVE.L  #CHIPCLEAR,D1
       JSR     ALLOCMEM(A6)
       MOVE.L  D0,SCREENBASE

       MOVE.L  #(SCREENB*22)*5,D0
       MOVE.L  #CHIPCLEAR,D1
       JSR     ALLOCMEM(A6)
       MOVE.L  D0,DUMMYSCREEN1
       ADDQ.L  #2,D0
       MOVE.L  D0,DUMMYSCREEN11

       MOVE.L  #(SCREENB*22)*1,D0
       MOVE.L  #CHIPCLEAR,D1
       JSR     ALLOCMEM(A6)
       MOVE.L  D0,DUMMYSCREEN2

       MOVE.L  #(SCREENB*22)*5,D0
       MOVE.L  #CHIPCLEAR,D1
       JSR     ALLOCMEM(A6)
       MOVE.L  D0,BLABASE

       MOVE.L  #320*4,D0
       MOVEQ   #0,D1
       JSR     ALLOCMEM(A6)
       MOVE.L  D0,MULU5_TAB

       MOVE.L  #320*2,D0
       MOVEQ   #0,D1
       JSR     ALLOCMEM(A6)
       MOVE.L  D0,MULU4_TAB

       MOVE.L  #POINTER_DATA,D0
       LEA     SPRITE_JMP,A0

       MOVE.W  D0,6(A0)
       SWAP    D0
       MOVE.W  D0,2(A0)

       LEA     DESERT_DATA,A0    ; FARB PALETTE IN DIE
       ADD.L   #(256*40)*5,A0
       LEA     COPPER2,A1        ; COPPERLISTE
       MOVEQ   #31,D7
       MOVE.L  #$180,D0
COLOR_LOOP:
       MOVE.W  D0,(A1)+
       MOVE.W  (A0)+,(A1)+
       ADDQ.L  #2,D0
       DBRA    D7,COLOR_LOOP

       MOVEQ   #PLANES-1,D7      ; BILDSCHIRM ADDRESSEN IN DIE
       MOVE.L  SCREENBASE(PC),D0 ; COPPERLISTE
       LEA     COPPER1,A0
       MOVE.W  #$E0,D1
POINTER_LOOP:

       MOVE.W  D1,(A0)
       ADDQ.W  #2,D1
       MOVE.W  D1,4(A0)
       ADDQ.W  #2,D1
       MOVE.W  D0,6(A0)
       SWAP    D0
       MOVE.W  D0,2(A0)
       SWAP    D0
       ADD.L   #PLANESIZE,D0
       ADDQ.L  #8,A0
       DBRA    D7,POINTER_LOOP

       LEA     $DFF000,A5

       BSR     DO_RAINBOW

       BSR     COPY_DESERT

       MOVE.L  GFXBASE,A0        ; COPPERLISTE EINSCHALTEN
       MOVE.W  #$0080,DMACON(A5)
       MOVE.L  $32(A0),OLDCOPPER
       MOVE.L  #NEWCOPPER,$32(A0)
       MOVE.W  #$8480,DMACON(A5)

       MOVE.L  SCREENBASE(PC),D0
       RTS

;--------------------------------------------------

       INCLUDE "NEWPT.ASM"

;--------------------------------------------------

CLOSESCR:

       MOVE.L  GFXBASE,A0        ; ALTE COPPERLISTE EINSCHALTEN
       MOVE.W  #$0480,DMACON(A5)
       MOVE.L  OLDCOPPER(PC),$32(A0)
       MOVE.W  #$8080,DMACON(A5)

       MOVE.L  EXECBASE,A6       ; SPEICHER FREIGEBEN
       MOVE.L  SCREENBASE(PC),A1
       MOVE.L  #PLAYFIELD,D0
       JSR     FREEMEM(A6)

       MOVE.L  DUMMYSCREEN1(PC),A1
       MOVE.L  #(SCREENB*22)*5,D0
       JSR     FREEMEM(A6)

       MOVE.L  DUMMYSCREEN2(PC),A1
       MOVE.L  #(SCREENB*22)*1,D0
       JSR     FREEMEM(A6)

       MOVE.L  BLABASE(PC),A1
       MOVE.L  #(SCREENB*22)*5,D0
       JSR     FREEMEM(A6)

       MOVE.L  MULU5_TAB(PC),A1
       MOVE.L  #320*4,D0
       JSR     FREEMEM(A6)

       MOVE.L  MULU4_TAB(PC),A1
       MOVE.L  #320*2,D0
       JMP     FREEMEM(A6)

;--------------------------------------

RAINBOW_COLORS:

       DS.W    SHADING,$0001
       DS.W    SHADING,$0002
       DS.W    SHADING,$0003
       DS.W    SHADING,$0004
       DS.W    SHADING,$0005
       DS.W    SHADING,$0006
       DS.W    SHADING,$0007
       DS.W    SHADING,$0008
       DS.W    SHADING,$0009
       DS.W    SHADING,$000A
       DS.W    SHADING,$000B
       DS.W    SHADING,$000C
       DS.W    SHADING,$000D
       DS.W    SHADING,$000E
       DS.W    SHADING,$000F

TEXTPOINTER:   DC.L    DEMOTEXT
DATAPOINTER:   DC.L    CHARSET_DATA
GFXBASE:       DC.L    0
OLDCOPPER:     DC.L    0
SCREENBASE:    DC.L    0
BASESCR:       DC.L    0
PLANE_5:       DC.L    0
SHADOWSCREEN:  DC.L    0
DUMMYSCREEN1:  DC.L    0
DUMMYSCREEN11: DC.L    0
DUMMYSCREEN2:  DC.L    0
BLABASE:       DC.L    0

MULU5_TAB:     DC.L    0
MULU4_TAB:     DC.L    0

SHADOW_DAT:    DS.L    30,0

POINTER_DATA:  DS.W    4,0

COUNTER:       DC.W    0
CONTROL:       DC.W    0
TEXTZAEHLER:   DC.W    0
ZAEHLER:       DC.W    0

MULU_TAB:      DS.W    50,0
MULU2_TAB:     DS.W    35,0
MULU3_TAB:     DS.W    50,0

 ALIGN.L

CHAR_DATA:
               IBYTES  "BIT/0-8.BIT"
               IBYTES  "BIT/DUM2.BIT"
               IBYTES  "BIT/A-I.BIT"
               IBYTES  "BIT/J-R.BIT"
               IBYTES  "BIT/S-Z.BIT"
               IBYTES  "BIT/DUM1.BIT"

CURRENT_SHADOW: DC.B 0

 ALIGN.L

ALTITUDE:

       DC.B    231,231,231,232,232,233,233,234,234,234    ;1
       DC.B    235,235,235,235,235,235,236,236,236,236    ;2
       DC.B    236,236,236,236,236,236,236,236,236,236    ;3
       DC.B    236,236,236,236,236,236,236,236,236,236    ;4
       DC.B    236,236,235,235,235,235,234,234,234,234    ;5
       DC.B    233,233,233,232,232,231,231,230,230,229    ;6
       DC.B    229,229,229,228,228,227,227,226,226,225    ;7
       DC.B    225,224,224,223,223,222,222,221,221,220    ;8
       DC.B    219,219,218,218,217,216,216,215,215,214    ;9
       DC.B    214,213,213,212,212,212,211,211,211,210    ;10
       DC.B    210,210,210,209,209,209,208,208,208,208    ;11
       DC.B    208,208,207,207,207,207,207,207,207,207    ;12
       DC.B    208,208,208,209,209,209,210,210,211,212    ;13
       DC.B    212,213,214,215,215,216,216,217,218,218    ;14
       DC.B    218,219,220,220,220,220,220,220,220,220    ;15
       DC.B    220,220,220,220,220,220,220,219,219,219    ;16
       DC.B    219,219,219,219,218,218,218,218,218,218    ;17
       DC.B    218,218,218,218,218,218,218,218,218,218    ;18
       DC.B    218,218,218,218,218,219,219,219,219,219    ;19
       DC.B    219,220,220,220,220,221,221,221,222,222    ;20
       DC.B    223,223,224,224,225,225,225,226,226,227    ;21
       DC.B    227,228,228,229,229,230,230,230,231,231    ;22
       DC.B    232,232,233,233,233,233,234,234,234,235    ;23
       DC.B    235,235,235,235,236,236,236,236,236,237    ;24
       DC.B    237,237,237,237,237,237,237,238,238,238    ;25
       DC.B    238,238,238,238,238,238,238,238,238,238    ;26
       DC.B    238,238,238,238,238,238,238,238,238,238    ;27
       DC.B    238,238,238,237,237,236,236,235,235,234    ;28
       DC.B    234,233,232,232,231,231,230,230,229,229    ;29
       DC.B    228,228,227,227,226,226,225,225,224,224    ;30
       DC.B    223,223,222,222,221,221,220,220,219,219    ;31
       DC.B    219,218,218,218,218,217,217,217,217,217    ;32
       DC.B    216,216,216,216,216,216,216,216,216,216    ;33

GFXNAME:       DC.B    "graphics.library",0

 ALIGN.L

DEMOTEXT:

               DC.B    "      YO = HERE COMEZ THE DRUNKEN = CODER = INTRO:"
               DC.B    " THIS IS OUR ENTRY FOR THE PARTY III INTRO COMPETITION:"
               DC.B    " CODING BY YEGGER; GFX BY ILLUSION; SOUND BY SNAKEY:"
               DC.B    " GREETINGS TO MNEMOTRON < SPREADPOINT >; LIGHTFORCE < X=TRADE >; BORIS O: < AD=PC >; CUBIC;"
               DC.B    " LEVI; MAC AND ALL THE OTHER LAMERS:"
               DC.B    " \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\  "

TEXTEND1:

 DATA

NEWCOPPER:

       DC.W    $8E,$2C89      ; Diplay Window etc
       DC.W    $90,$2CB5
       DC.W    $92,$38
       DC.W    $94,$D0

       DC.W    $100,$6200
       DC.W    $102,$0
       DC.W    $104,$0

       DC.W    $108,4              ;SCREENB-40
       DC.W    $10A,4              ;SCREENB-40

SPRITE_JMP:

       DC.W    $120,0
       DC.W    $122,0

COPPER1:


       DS.W    24,0

;       DC.W    $E0,0 ;1        ; Planes
;       DC.W    $E2,0
;       DC.W    $E4,0 ;2
;       DC.W    $E6,0
;       DC.W    $E8,0 ;3
;       DC.W    $EA,0
;       DC.W    $EC,0 ;4
;       DC.W    $EE,0
;       DC.W    $F0,0 ;5
;       DC.W    $F2,0
;       DC.W    $F4,0 ;6
;       DC.W    $F6,0

COPPER2:

       DS.W    64,0

COPPER3:

       DS.L    (4*COPPERLINES)+1,0

       DC.W    $FFFF,$FFFE

;--------------------------------------

 ALIGN.L

CHARSET_DATA:
       IBYTES  "BIT/CHARSET2.BIT"
         
 ALIGN.L
 
DESERT_DATA:
       IBYTES  "BIT/NEWDESERT.BIT"
 
 ALIGN.L
 
MT_DATA:
       IBYTES  "SFX/MOD.UNMEM"

       END
