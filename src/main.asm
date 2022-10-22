        processor 6502

        include "vcs.h"
        include "macro.h"

	SEG.U vars
	ORG $80

SpriteXPosition ds 1

        SEG code
        ORG $F000

Reset
; Clear RAM and all TIA registers

	ldx #0
	lda #0
Clear   sta 0,x
	inx
	bne Clear

	lda #$56
	sta COLUP0

	ldx #$80
	stx GRP0                ; modify sprite 0 shape
StartOfFrame

; Start of vertical blank processing

        lda #0
        sta VBLANK

        lda #2
        sta VSYNC

; 3 scanlines of VSYNCH signal...

        sta WSYNC
        sta WSYNC
        sta WSYNC

	lda SWCHA
	sta COLUBK

        lda #0
        sta VSYNC           

; 37 scanlines of vertical blank...

        REPEAT 37; scanlines
        sta WSYNC
        REPEND


	inc SpriteXPosition
	ldx SpriteXPosition
	cpx #160
	bcc LT160
	ldx #0
	stx SpriteXPosition
LT160
	jsr PositionSprite

        ; 192 scanlines of picture...
	REPEAT 191
	sta WSYNC
	REPEND

        lda #%01000010
        sta VBLANK                     ; end of screen - enter blanking

        ; 30 scanlines of overscan...
        REPEAT 30
        sta WSYNC
        REPEND

        jmp StartOfFrame

Divide15
.POS	SET 0
	REPEAT 256
	.byte (.POS / 15) + 1
.POS	SET .POS + 1
	REPEND

PositionSprite

        sta WSYNC

        ; Pass X register holding desired X position of sprite!

        ;lda Divide15,x			; xPosition / 15
        ;tax
SimpleLoop
	;dex
        ;bne SimpleLoop

        sta RESP0			; start drawing the sprite
        rts

        ORG $FFFA

        .word Reset          ; NMI
        .word Reset          ; RESET
        .word Reset          ; IRQ

    	END
