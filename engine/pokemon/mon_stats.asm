DrawPlayerHP:
	ld a, $1
	jr DrawHP

DrawEnemyHP:
	ld a, $2

DrawHP:
	ld [wWhichHPBar], a
	push hl
	push bc
	; box mons have full HP
	ld a, [wMonType]
	cp BOXMON
	jr z, .at_least_1_hp

	ld a, [wTempMonHP]
	ld b, a
	ld a, [wTempMonHP + 1]
	ld c, a

; Any HP?
	or b
	jr nz, .at_least_1_hp

	xor a
	ld c, a
	ld e, a
	ld a, 6
	ld d, a
	jp .fainted

.at_least_1_hp
	ld a, [wTempMonMaxHP]
	ld d, a
	ld a, [wTempMonMaxHP + 1]
	ld e, a
	ld a, [wMonType]
	cp BOXMON
	jr nz, .not_boxmon

	ld b, d
	ld c, e

.not_boxmon
	predef ComputeHPBarPixels
	ld a, 6
	ld d, a
	ld c, a

.fainted
	ld a, c
	pop bc
	ld c, a
	pop hl
	push de
	push hl
	push hl
	call DrawBattleHPBar
	pop hl

; Print HP
	bccoord 1, 1, 0
	add hl, bc
	ld de, wTempMonHP
	ld a, [wMonType]
	cp BOXMON
	jr nz, .not_boxmon_2
	ld de, wTempMonMaxHP
.not_boxmon_2
	lb bc, 2, 3
	call PrintNum

	ld a, "/"
	ld [hli], a

; Print max HP
	ld de, wTempMonMaxHP
	lb bc, 2, 3
	call PrintNum
	pop hl
	pop de
	ret

PrintTempMonStatsDVs:
; Print wTempMon's stats at hl, with spacing bc.
	push bc
	push hl
	push bc
	push hl
	ld de, .Line1
	hlcoord 5, 9
	call PlaceString
	ld de, .HPLine
	hlcoord 1, 10
	call PlaceString
	ld de, .AtkLine
	hlcoord 1, 11
	call PlaceString
	ld de, .DefLine
	hlcoord 1, 12
	call PlaceString
	ld de, .SpAtkLine
	hlcoord 1, 13
	call PlaceString
	ld de, .SpDefLine
	hlcoord 1, 14
	call PlaceString
	ld de, .SpeLine
	hlcoord 1, 15
	call PlaceString
	pop hl
	pop bc
	add hl, bc
	ld bc, (SCREEN_WIDTH * 2) - 11
	add hl, bc

	; HP
	call .CalcHPDVs
	ld de, wTempMonHP
	call .PrintDVsAndStat
	
	; Attack
	ld a, [wTempMonDVs]
	and $f0 
	swap a
	ld de, wTempMonAttack
	call .PrintDVsAndStat

	; Defense
	ld a, [wTempMonDVs]
	and $f 
	ld de, wTempMonAttack
	call .PrintDVsAndStat

	; Sp. Atk.
	ld a, [wTempMonDVs + 1]
	and $f
	ld de, wTempMonSpclAtk
	push af
	call .PrintDVsAndStat

	; Sp. Def. Reuses the same DV.
	pop af
	call .PrintDVsAndStat

	; Speed
	ld a, [wTempMonDVs + 1]
	and $f0
	swap a
	ld de, wTempMonSpeed
	call .PrintDVsAndStat

	pop hl
	pop bc
	add hl, bc
	; EVs
	ld bc, (SCREEN_WIDTH * 2) - 6
	add hl, bc
	ld de, wTempMonHPEV
	lb bc, 1, 3
	call .PrintStat
	ld de, wTempMonAtkEV
	call .PrintStat
	ld de, wTempMonDefEV
	call .PrintStat
	ld de, wTempMonSpclAtkEV
	call .PrintStat
	ld de, wTempMonSpclDefEV
	call .PrintStat
	ld de, wTempMonSpdEV
	; fallthrough

.PrintStat:
	push hl
	call PrintNum
	pop hl
	ld de, SCREEN_WIDTH
	add hl, de
	ret

.PrintDVsAndStat:
; Prints the DV in a and then stat pointed by de.
; Returns the next stat pointer in de.
	push de
	push hl
	ld b, a
	ld de, wTempMonAttack + 1
	ld a, [de]
	push af
	ld a, b
	ld [de], a
	lb bc, 1, 3
	call PrintNum
	pop af
	ld [wTempMonAttack + 1], a
	pop hl
	ld de, 11
	add hl, de
	pop de
	push de
	push hl
	lb bc, 2, 3
	call PrintNum
	pop hl
	ld de, 9
	add hl, de
	pop de
	ret

.CalcHPDVs
	push hl
	push bc
	ld hl, wTempMonDVs
	ld a, [hl]
	swap a
	and 1
	add a
	add a
	add a
	ld b, a
	ld a, [hli]
	and 1
	add a
	add a
	add b
	ld b, a
	ld a, [hl]
	swap a
	and 1
	add a
	add b
	ld b, a
	ld a, [hl]
	and 1
	add b
	pop bc 
	pop hl
	ret

.Line1:
	db "DVs  EVs  Stat@"
.HPLine:
	db "HP@"
.AtkLine:
	db "Atk@"
.DefLine:
	db "Def@"
.SpAtkLine:
	db "SpA@"
.SpDefLine:
	db "SpD@"
.SpeLine:
	db "Spe@"
	
PrintTempMonStats:
; Print wTempMon's stats at hl, with spacing bc.
	push bc
	push hl
	ld de, .StatNames
	call PlaceString
	pop hl
	pop bc
	add hl, bc
	ld bc, SCREEN_WIDTH
	add hl, bc
	ld de, wTempMonAttack
	lb bc, 2, 3
	call .PrintStat
	ld de, wTempMonDefense
	call .PrintStat
	ld de, wTempMonSpclAtk
	call .PrintStat
	ld de, wTempMonSpclDef
	call .PrintStat
	ld de, wTempMonSpeed
	jp PrintNum

.PrintStat:
	push hl
	call PrintNum
	pop hl
	ld de, SCREEN_WIDTH * 2
	add hl, de
	ret

.StatNames:
	db   "Atk"
	next "Def"
	next "Sp. Atk"
	next "Sp. Def"
	next "Spe"
	next "@"

GetGender:
; Return the gender of a given monster (wCurPartyMon/wCurOTMon/wCurWildMon).
; When calling this function, a should be set to an appropriate wMonType value.

; return values:
; a = 1: f = nc|nz; male
; a = 0: f = nc|z;  female
;        f = c:  genderless

; This is determined by comparing the Attack and Speed DVs
; with the species' gender ratio.

; Figure out what type of monster struct we're looking at.

; 0: PartyMon
	ld hl, wPartyMon1DVs
	ld bc, PARTYMON_STRUCT_LENGTH
	ld a, [wMonType]
	and a
	jr z, .PartyMon

; 1: OTPartyMon
	ld hl, wOTPartyMon1DVs
	dec a
	jr z, .PartyMon

; 2: sBoxMon
	ld hl, sBoxMon1DVs
	ld bc, BOXMON_STRUCT_LENGTH
	dec a
	jr z, .sBoxMon

; 3: Unknown
	ld hl, wTempMonDVs
	dec a
	jr z, .DVs

; else: WildMon
	ld hl, wEnemyMonDVs
	jr .DVs

; Get our place in the party/box.

.PartyMon:
.sBoxMon
	ld a, [wCurPartyMon]
	call AddNTimes

.DVs:
; Attack DV
    ld a, [hl]
	cpl
    and $10
    swap a
    add a     ; Atk DV << 1
    ld b, a   ; Store it in register b
; Defense DV
    ld a, [hli]
    and $1
    add a     ; Def DV << 1
    add a     ; Def DV << 2
    or b     ; Add (Atk DV << 1) + (Def DV << 2)
    ld b, a   ; Store result in b.
; Special DV
    ld a, [hl]
	cpl
    and $1
    add a     ; Spec DV << 1
    add a     ; Spec DV << 2
    add a     ; Spec DV << 3
    or b     ; Add (Spec DV << 3)
	swap a
    ld b, a   ; Again, stored in b.

; Close SRAM if we were dealing with a sBoxMon.
	ld a, [wMonType]
	cp BOXMON
	call z, CloseSRAM

; We need the gender ratio to do anything with this.
	push bc
	ld a, [wCurPartySpecies]
	dec a
	ld hl, BaseData + BASE_GENDER
	ld bc, BASE_DATA_SIZE
	call AddNTimes
	pop bc

	ld a, BANK(BaseData)
	call GetFarByte

; The higher the ratio, the more likely the monster is to be female.

	cp GENDER_UNKNOWN
	jr z, .Genderless

	and a ; GENDER_F0?
	jr z, .Male

	cp GENDER_F100
	jr z, .Female

; Values below the ratio are male, and vice versa.
	cp b
	jr c, .Male

.Female:
	xor a
	ret

.Male:
	ld a, 1
	and a
	ret

.Genderless:
	scf
	ret

ListMovePP:
	ld a, [wNumMoves]
	inc a
	ld c, a
	ld a, NUM_MOVES
	sub c
	ld b, a
	push hl
	ld a, [wListMovesLineSpacing]
	ld e, a
	ld d, 0
	ld a, $3e ; P
	call .load_loop
	ld a, b
	and a
	jr z, .skip
	ld c, a
	ld a, "-"
	call .load_loop

.skip
	pop hl
	inc hl
	inc hl
	inc hl
	ld d, h
	ld e, l
	ld hl, wTempMonMoves
	ld b, 0
.loop
	ld a, [hli]
	and a
	jr z, .done
	push bc
	push hl
	push de
	ld hl, wMenuCursorY
	ld a, [hl]
	push af
	ld [hl], b
	push hl
	callfar GetMaxPPOfMove
	pop hl
	pop af
	ld [hl], a
	pop de
	pop hl
	push hl
	ld bc, wTempMonPP - (wTempMonMoves + 1)
	add hl, bc
	ld a, [hl]
	and $3f
	ld [wStringBuffer1 + 4], a
	ld h, d
	ld l, e
	push hl
	ld de, wStringBuffer1 + 4
	lb bc, 1, 2
	call PrintNum
	ld a, "/"
	ld [hli], a
	ld de, wTempPP
	lb bc, 1, 2
	call PrintNum
	pop hl
	ld a, [wListMovesLineSpacing]
	ld e, a
	ld d, 0
	add hl, de
	ld d, h
	ld e, l
	pop hl
	pop bc
	inc b
	ld a, b
	cp NUM_MOVES
	jr nz, .loop

.done
	ret

.load_loop
	ld [hli], a
	ld [hld], a
	add hl, de
	dec c
	jr nz, .load_loop
	ret

BrokenPlacePPUnits: ; unreferenced
; Probably would have these parameters:
; hl = starting coordinate
; de = SCREEN_WIDTH or SCREEN_WIDTH * 2
; c = the number of moves (1-4)
.loop
	ld [hl], $32 ; typo for P?
	inc hl
	ld [hl], $3e ; P
	dec hl
	add hl, de
	dec c
	jr nz, .loop
	ret

Unused_PlaceEnemyHPLevel:
	ret

PlaceStatusString:
; Return nz if the status is not OK
	push de
	inc de
	inc de
	ld a, [de]
	ld b, a
	inc de
	ld a, [de]
	or b
	pop de
	jr nz, PlaceNonFaintStatus
	push de
	ld de, FntString
	call CopyStatusString
	pop de
	ld a, TRUE
	and a
	ret

FntString:
	db "<FNT1><FNT2>@"

CopyStatusString:
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [de]
	ld [hl], a
	ret

PlaceNonFaintStatus:
	push de
	ld a, [de]
	ld de, PsnString
	bit PSN, a
	jr nz, .place
	ld de, BrnString
	bit BRN, a
	jr nz, .place
	ld de, FrbString
	bit FRB, a
	jr nz, .place
	ld de, ParString
	bit PAR, a
	jr nz, .place
	ld de, SlpString
	and SLP
	jr z, .no_status

.place
	call CopyStatusString
	ld a, TRUE
	and a

.no_status
	pop de
	ret

SlpString: db "<SLP1><SLP2>@"
PsnString: db "<PSN1><PSN2>@"
BrnString: db "<BRN1><BRN2>@"
FrbString: db "<FRB1><FRB2>@"
ParString: db "<PAR1><PAR2>@"

ListMoves:
; List moves at hl, spaced every [wListMovesLineSpacing] tiles.
	ld de, wListMoves_MoveIndicesBuffer
	ld b, 0
.moves_loop
	ld a, [de]
	inc de
	and a
	jr z, .no_more_moves
	push de
	push hl
	push hl
	ld [wCurSpecies], a
	ld a, MOVE_NAME
	ld [wNamedObjectType], a
	call GetName
	ld de, wStringBuffer1
	pop hl
	push bc
	call PlaceString
	pop bc
	ld a, b
	ld [wNumMoves], a
	inc b
	pop hl
	push bc
	ld a, [wListMovesLineSpacing]
	ld c, a
	ld b, 0
	add hl, bc
	pop bc
	pop de
	ld a, b
	cp NUM_MOVES
	jr z, .done
	jr .moves_loop

.no_more_moves
	ld a, b
.nonmove_loop
	push af
	ld [hl], "-"
	ld a, [wListMovesLineSpacing]
	ld c, a
	ld b, 0
	add hl, bc
	pop af
	inc a
	cp NUM_MOVES
	jr nz, .nonmove_loop

.done
	ret
