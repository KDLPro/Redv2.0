GetMoveCategoryName:
	call GetMoveType

	ld hl, CategoryNames
	ld e, a
	ld d, 0
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld de, wStringBuffer1
	ld bc, MOVE_NAME_LENGTH
	jp CopyBytes

INCLUDE "data/types/category_names.asm"

GetMoveType:
; Copy the category name of move b to wStringBuffer1.

	ld a, b
	dec a
	ld bc, MOVE_LENGTH
	ld hl, Moves + MOVE_TYPE
	call AddNTimes
	ld a, BANK(Moves)
	call GetFarByte

; Mask out the type
	and $ff ^ TYPE_MASK
; Shift the category bits into the range 0-2
	rlc a
	rlc a
	dec a
	ret

GetMoveCategoryIcon:
	call GetMoveType

	ld de, PhysicalIconGFX
	lb bc, PAL_BATTLE_OB_RED, 2
	and a
	jr z, .done
	ld de, SpecialIconGFX
	ld b, PAL_BATTLE_OB_GREEN
	cp 1
	jr z, .done
	ld de, StatusIconGFX
	ld b, PAL_BATTLE_OB_BLUE
	
.done
	push bc
	ld b, BANK(CategoryImages) ; c = 4
	ld hl, vTiles0
	call Request2bpp
	pop bc
	ld hl, wVirtualOAMSprite00
	ld de, .CategoryImagesOAMData
.loop
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [de]
	inc de
	ld [hli], a
	dec c
	ld a, c
	ld [hli], a
	ld a, b
	ld [hli], a
	jr nz, .loop
	ret

.CategoryImagesOAMData
; positions are backwards since
; we load them in reverse order
	db $58, $44 ; y/x - bottom right
	db $58, $3c ; y/x - bottom left
	