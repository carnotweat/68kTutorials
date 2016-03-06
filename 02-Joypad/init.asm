; ******************************************************************
; Sega Megadrive ROM header
; ******************************************************************
	dc.l   $00FFE000      	; Initial stack pointer value
	dc.l   EntryPoint      ; Start of program
	dc.l   Exception       ; Bus error
	dc.l   Exception       ; Address error
	dc.l   Exception       ; Illegal instruction
	dc.l   Exception       ; Division by zero
	dc.l   Exception       ; CHK exception
	dc.l   Exception       ; TRAPV exception
	dc.l   Exception       ; Privilege violation
	dc.l   Exception       ; TRACE exception
	dc.l   Exception       ; Line-A emulator
	dc.l   Exception       ; Line-F emulator
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Spurious exception
	dc.l   Exception       ; IRQ level 1
	dc.l   Exception       ; IRQ level 2
	dc.l   Exception       ; IRQ level 3
	dc.l   HBlankInterrupt ; IRQ level 4 (horizontal retrace interrupt)
	dc.l   Exception       ; IRQ level 5
	dc.l   VBlankInterrupt ; IRQ level 6 (vertical retrace interrupt)
	dc.l   Exception       ; IRQ level 7
	dc.l   Exception       ; TRAP #00 exception
	dc.l   Exception       ; TRAP #01 exception
	dc.l   Exception       ; TRAP #02 exception
	dc.l   Exception       ; TRAP #03 exception
	dc.l   Exception       ; TRAP #04 exception
	dc.l   Exception       ; TRAP #05 exception
	dc.l   Exception       ; TRAP #06 exception
	dc.l   Exception       ; TRAP #07 exception
	dc.l   Exception       ; TRAP #08 exception
	dc.l   Exception       ; TRAP #09 exception
	dc.l   Exception       ; TRAP #10 exception
	dc.l   Exception       ; TRAP #11 exception
	dc.l   Exception       ; TRAP #12 exception
	dc.l   Exception       ; TRAP #13 exception
	dc.l   Exception       ; TRAP #14 exception
	dc.l   Exception       ; TRAP #15 exception
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)

; size    012345678901234567890123456789012345678901234567
	dc.b "SEGA GENESIS    "									; Console name - 16
	dc.b "(C)db   2016.MAR"									; Copyright holder and release date - 16
	dc.b "DB JOYPAD TUTORIAL                              "	; Domestic name - 48
	dc.b "DB JOYPAD TUTORIAL                              "	; International name - 48
	dc.b "GM JPTUTORIAL-01"									; Version number - 48
	dc.w $1234												; Checksum
	dc.b "J               "									; I/O support - 16
	dc.l $00000000											; Start address of ROM
	dc.l __end												; End address of ROM
	dc.l $00FF0000											; Start address of RAM
	dc.l $00FFFFFF											; End address of RAM
	dc.l $00000000											; SRAM enabled
	dc.l $00000000											; Unused
	dc.l $00000000											; Start address of SRAM
	dc.l $00000000											; End address of SRAM
	dc.l $00000000											; Unused
	dc.l $00000000											; Unused
	dc.b "                                        "			; Notes (unused)
	dc.b "JUE             "									; Country codes

EntryPoint:           ; Entry point address set in ROM header

; ************************************
; Test reset button
; ************************************
	tst.w 	$00A10008  				; Test mystery reset (expansion port reset?)
	bne.w 	Main          			; Branch if Not Equal (to zero) - to Main
	tst.w 	IO_CTRL_EXP  			; Test reset button
	bne.w 	Main          			; Branch if Not Equal (to zero) - to Main

; ************************************
; Clear RAM
; ************************************
	move.l 	#$00000000, D0     		; Place a 0 into d0, ready to copy to each longword of RAM
	move.l 	#$00000000, A0     		; Starting from address $0, clearing backwards
	move.l 	#$00003FFF, D1     		; Clearing 64k's worth of longwords (minus 1, for the loop to be correct)
.Clear:
	move.l 	D0, -(A0)           	; Decrement the address by 1 longword, before moving the zero from d0 to it
	dbra 	D1, .Clear          	; Decrement d0, repeat until depleted
	
; ************************************
; Write TMSS
; ************************************
	move.b 	IO_VERSIONNO, D0      	; Move Megadrive hardware version to d0
	andi.b 	#$0F, D0           		; The version is stored in last four bits, so mask it with 0F
	beq.s 	.SkipTMSS              	; If version is equal to 0, skip TMSS signature
	move.l 	#'SEGA', CTRL_TMSS 		; Move the string "SEGA" to $A14000
.SkipTMSS:

; ************************************
; Init Z80
; ************************************
	move.w 	#$0100, CTRL_Z80BUSREQ 	; Request access to the Z80 bus, by writing $0100 into the BUSREQ port
	move.w 	#$0100, CTRL_Z80RESET  	; Hold the Z80 in a reset state, by writing $0100 into the RESET port

.WaitZ80:
	btst 	#$0, CTRL_Z80BUSREQ    	; Test bit 0 of A11100 to see if the 68k has access to the Z80 bus yet
	bne.s 	.WaitZ80                ; If we don't yet have control, branch back up to Wait
	
	move.l 	#Z80Data, A0        	; Load address of data into a0
	move.l 	#Z80_RAM, A1     		; Copy Z80 RAM address to a1
	move.l 	#Z80DataEnd-Z80Data, D0 ; Auto-calculate size of transfer using labels
.CopyZ80:
	move.b 	(A0)+, (A1)+        	; Copy data, and increment the source/dest addresses
	dbra 	D0, .CopyZ80

	move.w 	#$0000, CTRL_Z80RESET  ; Release reset state
	move.w	#$0000, CTRL_Z80BUSREQ ; Release control of bus

; ************************************
; Init PSG
; ************************************
	move.l 	#PSGData, A0        	; Load address of PSG data into a0
	move.l 	#$03, D0           		; 4 bytes of data
.CopyPSG:
	move.b 	(A0)+, VDP_PSG   		; Copy data to PSG RAM
	dbra 	D0, .CopyPSG
	
; ************************************
; Init VDP
;	DO 		- iterations
;	D1.uw 	- register number in VDP
;	D1.lw 	- register value
;	A0 		- pointer to VDP register value array 
; ************************************
	move.l 	#VDPRegisters, A0   	; Load address of register table into a0
	move.l 	#24, D0           		; 24 registers to write
	move.l 	#$00008000, d1     		; 'Set register 0' command (and clear the rest of d1 ready)

.CopyVDP:
	move.b 	(A0)+, D1           	; Move register value to lower byte of d1
	move.w 	D1, VDP_CTRL     		; Write command and value to VDP control port
	add.w 	#$0100, D1          	; Increment register #
	dbra 	D0, .CopyVDP

; ************************************
; Init IO Ports
; ************************************
	move.b 	#$40, IO_CTRL_1	  		; Controller port 1 CTRL, TH = output
	move.b 	#$40, IO_CTRL_2	 		; Controller port 2 CTRL, TH = output
	move.b 	#$00, IO_CTRL_EXP 		; EXP port CTRL
	move.b	#$40, IO_DATA_1			; Idle with TH = '1'
	move.b	#$40, IO_DATA_2			; Idle with TH = '1'	

; ************************************
; Cleanup
; ************************************
	move.l 	#$00FF0000, A0     		; Move address of first byte of ram (contains zero, RAM has been cleared) to a0
	movem.l (A0), D0-D7/A1-A7  		; Multiple move zero to all registers
	move.l 	#$00000000, A0     		; Clear a0

	; Init status register (no trace, supervisor mode, all interrupt levels enabled, clear condition code bits)
	move 	#$2000, SR

; ************************************
; Main
; ************************************
Main:
	jmp __main 						; Begin external main

HBlankInterrupt:
	rts
VBlankInterrupt:
	addi.l	#1, D7					; increment d7 as Vint counter
   	rts

WaitVBlankStart:
   	move.w 	VDP_CTRL, D0 			; Move VDP status word to d0
   	andi.w 	#$0008, D0    			; AND with bit 4 (vblank), result in status register
	bne.s	WaitVBlankStart 		; Branch if not equal (to zero)
   	rts
 
WaitVBlankEnd:
   	move.w 	VDP_CTRL, D0 			; Move VDP status word to d0
   	andi.w 	#$0008, D0     			; AND with bit 4 (vblank), result in status register
   	beq.s	WaitVBlankEnd   		; Branch if equal (to zero)
   	rts

Exception:
   	stop #$2700 					; Halt CPU
   
Z80Data:
   	dc.w $af01, $d91f
   	dc.w $1127, $0021
   	dc.w $2600, $f977
   	dc.w $edb0, $dde1
   	dc.w $fde1, $ed47
   	dc.w $ed4f, $d1e1
   	dc.w $f108, $d9c1
   	dc.w $d1e1, $f1f9
   	dc.w $f3ed, $5636
   	dc.w $e9e9, $8104
   	dc.w $8f01
Z80DataEnd:

PSGData:
   	dc.w $9fbf, $dfff
   
VDPRegisters:
	dc.b $04 ; 0: Horiz. interrupt off, display on
	dc.b $74 ; 1: Vert. interrupt on, screen blank off, DMA on, V28 mode (40 cells vertically), Genesis mode on
   	dc.b $30 ; 2: Pattern table for Scroll Plane A at $C000 (bits 3-5)
   	dc.b $40 ; 3: Pattern table for Window Plane at $10000 (bits 1-5)
   	dc.b $05 ; 4: Pattern table for Scroll Plane B at $A000 (bits 0-2)
   	dc.b $70 ; 5: Sprite table at $E000 (bits 0-6)
   	dc.b $00 ; 6: Unused
   	dc.b $00 ; 7: Background colour - bits 0-3 = colour, bits 4-5 = palette
   	dc.b $00 ; 8: Unused
   	dc.b $00 ; 9: Unused
   	dc.b $00 ; 10: Frequency of Horiz. interrupt in Rasters (number of lines travelled by the beam)
   	dc.b $00 ; 11: External interrupts off, V/H scrolling on
   	dc.b $81 ; 12: Shadows and highlights off, interlace off, H40 mode (64 cells horizontally)
   	dc.b $34 ; 13: Horiz. scroll table at $D000 (bits 0-5)
   	dc.b $00 ; 14: Unused
   	dc.b $00 ; 15: Autoincrement off
   	dc.b $01 ; 16: Vert. scroll 32, Horiz. scroll 64
   	dc.b $00 ; 17: Window Plane X pos 0 left (pos in bits 0-4, left/right in bit 7)
   	dc.b $00 ; 18: Window Plane Y pos 0 up (pos in bits 0-4, up/down in bit 7)
   	dc.b $00 ; 19: DMA length lo byte
   	dc.b $00 ; 20: DMA length hi byte
   	dc.b $00 ; 21: DMA source address lo byte
   	dc.b $00 ; 22: DMA source address mid byte
   	dc.b $00 ; 23: DMA source address hi byte, memory-to-VRAM mode (bits 6-7)
