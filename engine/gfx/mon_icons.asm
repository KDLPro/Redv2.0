LoadOverworldMonIcon:
	ld a, e
	call ReadMonMenuIcon
	ld l, a
	ld h, 0
	add hl, hl
	ld de, IconPointers
	add hl, de
	ld a, [hli]
	ld e, a
	ld d, [hl]
	ld b, BANK(Icons)
	ld c, 8
	ret

SetMenuMonIconColor:
	push hl
	push de
	push bc
	push af
	ld a, [wCurPartyMon]
	inc a
	ld hl, wVirtualOAMSprite00Attributes
	jr _ApplyMenuMonIconColor

LoadPartyMenuMonIconColors:
	push hl
	push de
	push bc
	push af

	ldh a, [hObjectStructIndex]
	ld [wCurPartyMon], a
	ld e, a
	ld d, 0

	ld hl, wPartyMon1Item
	call GetPartyLocation
	ld a, [hl]
	ld [wCurIconMonHasItemOrMail], a

	ld hl, wPartySpecies
	add hl, de
	ld a, [hl]
	ld [wCurPartySpecies], a
	ldh a, [hObjectStructIndex]
	inc a
	ld hl, wVirtualOAMSprite00Attributes
	push af
	ld a, [wCurPartyMon]
	swap a
	ld d, 0
	ld e, a
	add hl, de
	pop af

	ld de, 4
	ld [hl], a ; top left
	add hl, de
	ld [hl], a ; top right
	add hl, de
	push hl
	add hl, de
	ld [hl], a ; bottom right
	pop hl
	ld d, a
	ld a, [wCurIconMonHasItemOrMail]
	and a
	ld a, PAL_OW_RED ; item or mail color
	jr nz, .ok
	ld a, d
.ok
	ld [hl], a ; bottom left
	jr _FinishMenuMonIconColor

SetNamingMenuMonIconColor:
	push hl
	push de
	push bc
	push af
	ld a, 1
	ld hl, wVirtualOAMSprite00Attributes
	jr _ApplyMenuMonIconColor

_ApplyMenuMonIconColor:
	ld c, 4
	ld de, 4
.loop
	ld [hl], a
	add hl, de
	dec c
	jr nz, .loop
	; fallthrough
_FinishMenuMonIconColor:
	pop af
	pop bc
	pop de
	pop hl
	ret

LoadMenuMonIcon:
	push hl
	push de
	push bc
	call .LoadIcon
	pop bc
	pop de
	pop hl
	ret

.LoadIcon:
	ld d, 0
	ld hl, .Jumptable
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl

.Jumptable:
; entries correspond to MONICON_* constants
	dw PartyMenu_InitAnimatedMonIcon    ; MONICON_PARTYMENU
	dw NamingScreen_InitAnimatedMonIcon ; MONICON_NAMINGSCREEN
	dw MoveList_InitAnimatedMonIcon     ; MONICON_MOVES
	dw Trade_LoadMonIconGFX             ; MONICON_TRADE
	dw Mobile_InitAnimatedMonIcon       ; MONICON_MOBILE1
	dw Mobile_InitPartyMenuBGPal71      ; MONICON_MOBILE2
	dw Unused_GetPartyMenuMonIcon       ; MONICON_UNUSED

Unused_GetPartyMenuMonIcon:
	call InitPartyMenuIcon
	call .GetPartyMonItemGFX
	call SetPartyMonIconAnimSpeed
	ret

.GetPartyMonItemGFX:
	push bc
	ldh a, [hObjectStructIndex]
	ld hl, wPartyMon1Item
	ld bc, PARTYMON_STRUCT_LENGTH
	call AddNTimes
	pop bc
	ld a, [hl]
	and a
	jr z, .no_item
	push hl
	push bc
	ld d, a
	callfar ItemIsMail
	pop bc
	pop hl
	jr c, .not_mail
	ld a, $06
	jr .got_tile
.not_mail
	ld a, $05
	; fallthrough

.no_item
	ld a, $04
.got_tile
	ld hl, SPRITEANIMSTRUCT_FRAMESET_ID
	add hl, bc
	ld [hl], a
	ret

Mobile_InitAnimatedMonIcon:
	call PartyMenu_InitAnimatedMonIcon
	ld hl, SPRITEANIMSTRUCT_ANIM_SEQ_ID
	add hl, bc
	ld a, SPRITE_ANIM_SEQ_NULL
	ld [hl], a
	ld hl, SPRITEANIMSTRUCT_XCOORD
	add hl, bc
	ld a, 9 * 8
	ld [hl], a
	ld hl, SPRITEANIMSTRUCT_YCOORD
	add hl, bc
	ld a, 9 * 8
	ld [hl], a
	ret

Mobile_InitPartyMenuBGPal71:
	call InitPartyMenuIcon
	call SetPartyMonIconAnimSpeed
	ld hl, SPRITEANIMSTRUCT_ANIM_SEQ_ID
	add hl, bc
	ld a, SPRITE_ANIM_SEQ_NULL
	ld [hl], a
	ld hl, SPRITEANIMSTRUCT_XCOORD
	add hl, bc
	ld a, 3 * 8
	ld [hl], a
	ld hl, SPRITEANIMSTRUCT_YCOORD
	add hl, bc
	ld a, 12 * 8
	ld [hl], a
	ld a, c
	ld [wc608], a
	ld a, b
	ld [wc608 + 1], a
	ret

PartyMenu_InitAnimatedMonIcon:
	call InitPartyMenuIcon
	call .SpawnItemIcon
	call SetPartyMonIconAnimSpeed
	ret

.SpawnItemIcon:
	push bc
	ldh a, [hObjectStructIndex]
	ld hl, wPartyMon1Item
	ld bc, PARTYMON_STRUCT_LENGTH
	call AddNTimes
	pop bc
	ld a, [hl]
	and a
	ret z
	push hl
	push bc
	ld d, a
	callfar ItemIsMail
	pop bc
	pop hl
	jr c, .mail
	ld a, SPRITE_ANIM_FRAMESET_PARTY_MON_WITH_ITEM
	jr .okay

.mail
	ld a, SPRITE_ANIM_FRAMESET_PARTY_MON_WITH_MAIL
.okay
	ld hl, SPRITEANIMSTRUCT_FRAMESET_ID
	add hl, bc
	ld [hl], a
	ret

InitPartyMenuIcon:
	ld a, [wCurIconTile]
	push af
	ldh a, [hObjectStructIndex]
	ld hl, wPartySpecies
	ld e, a
	ld d, 0
	add hl, de

	push hl
	ldh a, [hObjectStructIndex]
	ld hl, wPartyMon1DVs
	call GetPartyLocation
	ld b, h
	ld c, l
	pop hl
	ld a, [hl]
	ld d, a
	push hl
	farcall LoadMonIconPalette
	pop hl
	call LoadPartyMenuMonIconColors

	ld a, [hl]
	call ReadMonMenuIcon
	ld [wCurIcon], a
	call GetMemIconGFX
	ldh a, [hObjectStructIndex]
; y coord
	add a
	add a
	add a
	add a
	add $1c
	ld d, a
; x coord
	ld e, $10
; type is partymon icon
	ld a, SPRITE_ANIM_INDEX_PARTY_MON
	call _InitSpriteAnimStruct
	pop af
	ld hl, SPRITEANIMSTRUCT_TILE_ID
	add hl, bc
	ld [hl], a
	ret

SetPartyMonIconAnimSpeed:
	push bc
	ldh a, [hObjectStructIndex]
	ld b, a
	call .getspeed
	ld a, b
	pop bc
	ld hl, SPRITEANIMSTRUCT_DURATIONOFFSET
	add hl, bc
	ld [hl], a
	rlca
	rlca
	ld hl, SPRITEANIMSTRUCT_VAR2
	add hl, bc
	ld [hl], a
	ret

.getspeed
	farcall PlacePartymonHPBar
	call GetHPPal
	ld e, d
	ld d, 0
	ld hl, .speeds
	add hl, de
	ld b, [hl]
	ret

.speeds
	db $00 ; HP_GREEN
	db $40 ; HP_YELLOW
	db $80 ; HP_RED

NamingScreen_InitAnimatedMonIcon:
	ldh a, [hObjectStructIndex]
	push af
	xor a
	ldh [hObjectStructIndex], a
	ld hl, wTempMonDVs
	ld b, h
	ld c, l
	ld a, [wTempIconSpecies]
	ld d, a
	farcall LoadMonIconPalette
	pop af
	ldh [hObjectStructIndex], a
	call SetNamingMenuMonIconColor

	ld a, [wTempIconSpecies]
	call ReadMonMenuIcon
	ld [wCurIcon], a
	xor a
	call GetIconGFX
	depixel 4, 4, 4, 0
	ld a, SPRITE_ANIM_INDEX_PARTY_MON
	call _InitSpriteAnimStruct
	ld hl, SPRITEANIMSTRUCT_ANIM_SEQ_ID
	add hl, bc
	ld [hl], SPRITE_ANIM_SEQ_NULL
	ret

MoveList_InitAnimatedMonIcon:
	call SetMenuMonIconColor
	ld a, [wTempIconSpecies]
	call ReadMonMenuIcon
	ld [wCurIcon], a
	xor a
	call GetIconGFX
	ld d, 3 * 8 + 2 ; depixel 3, 4, 2, 4
	ld e, 4 * 8 + 4
	ld a, SPRITE_ANIM_INDEX_PARTY_MON
	call _InitSpriteAnimStruct
	ld hl, SPRITEANIMSTRUCT_ANIM_SEQ_ID
	add hl, bc
	ld [hl], SPRITE_ANIM_SEQ_NULL
	ret

Trade_LoadMonIconGFX:
	ld a, [wTempIconSpecies]
	call ReadMonMenuIcon
	ld [wCurIcon], a
	ld a, $62
	ld [wCurIconTile], a
	call GetMemIconGFX
	ret

GetSpeciesIcon:
; Load species icon into VRAM at tile a
	push de
	ld a, [wTempIconSpecies]
	call ReadMonMenuIcon
	ld [wCurIcon], a
	pop de
	ld a, e
	call GetIconGFX
	call SetMenuMonIconColor
	ret

FlyFunction_GetMonIcon:
	push de
	ld a, [wTempIconSpecies]
	call ReadMonMenuIcon
	ld [wCurIcon], a
	pop de
	ld a, e
	call GetIcon_a

	ldh a, [hObjectStructIndex]
	push af
	ld a, $FF
	ldh [hObjectStructIndex], a
	ld a, [wCurPartyMon]
	ld hl, wPartyMon1DVs
	call GetPartyLocation
	ld b, h
	ld c, l
	ld a, [wTempIconSpecies]
	ld d, a
	farcall LoadMonIconPalette
	pop af
	ldh [hObjectStructIndex], a

	ld a, TRUE
 	ldh [hCGBPalUpdate], a
	farcall ApplyPals
	call SetMenuMonIconColor
	ret

GetMonIconDE: ; unreferenced
	push de
	ld a, [wTempIconSpecies]
	call ReadMonMenuIcon
	ld [wCurIcon], a
	pop de
	call GetIcon_de
	ret

GetMemIconGFX:
	ld a, [wCurIconTile]
GetIconGFX:
	call GetIcon_a
	ld de, 8 tiles
	add hl, de
	ld de, HeldItemIcons
	lb bc, BANK(HeldItemIcons), 2
	call GetGFXUnlessMobile
	ld a, [wCurIconTile]
	add 10
	ld [wCurIconTile], a
	ret

HeldItemIcons:
INCBIN "gfx/icons/mail.2bpp"
INCBIN "gfx/icons/item.2bpp"

GetIcon_de:
; Load icon graphics into VRAM starting from tile de.
	ld l, e
	ld h, d
	jr GetIcon

GetIcon_a:
; Load icon graphics into VRAM starting from tile a.
	ld l, a
	ld h, 0

GetIcon:
; Load icon graphics into VRAM starting from tile hl.

; One tile is 16 bytes long.
rept 4
	add hl, hl
endr

	ld de, vTiles0
	add hl, de
	push hl

; The icons are contiguous, in order and of the same
; size, so the pointer table is somewhat redundant.
	ld a, [wCurIcon]
	push hl
	ld l, a
	ld h, 0
	add hl, hl
	ld de, IconPointers
	add hl, de
	ld a, [hli]
	ld e, a
	ld d, [hl]
	pop hl

	lb bc, BANK(Icons), 8
	call GetGFXUnlessMobile

	pop hl
	ret

GetGFXUnlessMobile:
	ld a, [wLinkMode]
	cp LINK_MOBILE
	jp nz, Request2bpp
	jp Get2bppViaHDMA

FreezeMonIcons:
	ld hl, wSpriteAnimationStructs
	ld e, PARTY_LENGTH
	ld a, [wMenuCursorY]
	ld d, a
.loop
	ld a, [hl]
	and a
	jr z, .next
	cp d
	jr z, .loadwithtwo
	ld a, SPRITE_ANIM_SEQ_NULL
	jr .ok

.loadwithtwo
	ld a, SPRITE_ANIM_SEQ_PARTY_MON_SWITCH

.ok
	push hl
	ld c, l
	ld b, h
	ld hl, SPRITEANIMSTRUCT_ANIM_SEQ_ID
	add hl, bc
	ld [hl], a
	pop hl

.next
	ld bc, $10
	add hl, bc
	dec e
	jr nz, .loop
	ret

UnfreezeMonIcons:
	ld hl, wSpriteAnimationStructs
	ld e, PARTY_LENGTH
.loop
	ld a, [hl]
	and a
	jr z, .next
	push hl
	ld c, l
	ld b, h
	ld hl, SPRITEANIMSTRUCT_ANIM_SEQ_ID
	add hl, bc
	ld [hl], SPRITE_ANIM_SEQ_PARTY_MON
	pop hl
.next
	ld bc, $10
	add hl, bc
	dec e
	jr nz, .loop
	ret

HoldSwitchmonIcon:
	ld hl, wSpriteAnimationStructs
	ld e, PARTY_LENGTH
	ld a, [wSwitchMon]
	ld d, a
.loop
	ld a, [hl]
	and a
	jr z, .next
	cp d
	jr z, .is_switchmon
	ld a, SPRITE_ANIM_SEQ_PARTY_MON_SELECTED
	jr .join_back

.is_switchmon
	ld a, SPRITE_ANIM_SEQ_PARTY_MON_SWITCH
.join_back
	push hl
	ld c, l
	ld b, h
	ld hl, SPRITEANIMSTRUCT_ANIM_SEQ_ID
	add hl, bc
	ld [hl], a
	pop hl
.next
	ld bc, $10
	add hl, bc
	dec e
	jr nz, .loop
	ret

ReadMonMenuIcon:
	cp EGG
	jr z, .egg
	dec a
	ld hl, MonMenuIcons
	ld e, a
	ld d, 0
	add hl, de
	ld a, [hl]
	ret
.egg
	ld a, ICON_EGG
	ret

INCLUDE "data/pokemon/menu_icons.asm"

INCLUDE "data/icon_pointers.asm"

INCLUDE "gfx/icons.asm"
