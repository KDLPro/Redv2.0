LoadMonIconPalette:
	ld a, d
	push bc
	call _GetIconPalettePointer
	pop bc
	push hl
	farcall CheckShininess
	pop hl
	jr nc, .done
rept 4
	inc hl
endr
.done
	ldh a, [hObjectStructIndex]

	ldh a, [rSVBK]
	push af
	ld a, BANK(wBGPals1)
	ldh [rSVBK], a

	push hl
	ld hl, wOBPals1
	ldh a, [hObjectStructIndex]
.get_address_loop
	cp $FF
	jr z, .start_loadpalette
	ld bc, 8
	add hl, bc
	and a
	jr z, .start_loadpalette
	dec a
	jr .get_address_loop

.start_loadpalette
	ld d, h
	ld e, l
	pop hl
	ld a, LOW(PALRGB_WHITE)
	ld [de], a
	inc de
	ld a, HIGH(PALRGB_WHITE)
	ld [de], a
	inc de

	ld c, 2 * PAL_COLOR_SIZE
.loop
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, .loop

	xor a
	ld [de], a
	inc de
	ld [de], a
	inc de

	pop af
	ldh [rSVBK], a
	ret

_GetIconPalettePointer:
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	ld bc, PokemonIconPalettes
	add hl, bc
	ret