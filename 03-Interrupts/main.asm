; ************************************
; Title
; ************************************
;
;    Title:          main.asm
;    Author:         René Richard
;    Description:
;        
;    Target Hardware:
;        Sega Genesis / Megadrive
;    Assembler:
;        ASMX
;
; LICENSE
; 
;    This file is part of 68kTutorials.
;    68kTutorials is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.
;    68kTutorials is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;    You should have received a copy of the GNU General Public License
;    along with 68kTutorials.  If not, see <http://www.gnu.org/licenses/>.
;
; ************************************
; COMPILER OPTIONS
; ************************************
	LIST MACRO
	LIST NOSYM
	LIST NOTEMP

; ************************************
; SYSTEM DEFINES
; ************************************
	include 'sys/sysDef.asm'
	include 'sys/sysRAM.asm'

; ************************************
; MACROS
; ************************************
	include	'sys/sysMacros.asm'

; ************************************
; HEADER AND STARTUP CODE
; ************************************
	include 'header.asm'
	include 'sys/sysInit.asm'
	include 'sys/sysInterrupts.asm'
	include 'sys/sysJoypad.asm'

; ************************************
; USER PROGRAM
; ************************************
__main:
	include 'tutorial03.asm'
__end:

; debug in MESS using
; mess genesis -cart out/rom.bin -window -debug
