_AnimateHPBar:
; Code in here treat the HP bar for update frequency as
; if it had 96 pixels. This makes the HP bar animate
; in 30fps (60fps makes it too fast), while numbers update
; at 60fps frequency.
	call .ComputePixels
	call .CheckDamage
	jr c, .LongAnimLoop
.ShortAnimLoop:
	push bc
	push hl
	call HPBarAnim_UpdateVariables
	pop hl
	pop bc
	push af
	push bc
	push hl
	call HPBarAnim_UpdateTiles
	call HPBarAnim_BGMapUpdate
	pop hl
	pop bc
	pop af
	jr nc, .ShortAnimLoop
	ret
	
.LongAnimLoop:
	; faster animation for huge damage
	push bc
	push hl
	call LongAnim_UpdateVariables
	pop hl
	pop bc
	ret c
	push af
	push bc
	push hl
	call LongHPBarAnim_UpdateTiles
	call HPBarAnim_BGMapUpdate
	pop hl
	pop bc
	pop af
	jr nc, .LongAnimLoop
	ret
	
.CheckDamage:
	push hl
	push de
	push bc
	ld a, [wWhichHPBar]
	and a
	jr nz, .player
	ld a, [wEnemyMonLevel]
	cp 21
	jr c, .no_carry_return
	ld hl, wCurDamage
	ld b, [hl]
	inc hl
	ld c, [hl]
	sla c
	rl b
	sla c
	rl b
	ld hl, wEnemyMonMaxHP + 1
	ld a, [hld]
	cp c
	ld a, [hl]
	sbc b
.return
	pop bc
	pop de
	pop hl
	ret
	
.no_carry_return
	pop bc
	pop de
	pop hl
	and a
	ret

.player
	ld a, [wBattleMonLevel]
	cp 21
	jr c, .no_carry_return
	ld hl, wCurDamage
	ld b, [hl]
	inc hl
	ld c, [hl]
	sla c
	rl b
	sla c
	rl b
	ld hl, wBattleMonMaxHP + 1
	ld a, [hld]
	cp c
	ld a, [hl]
	sbc b
	jr .return

.ComputePixels
	push hl
	ld hl, wCurHPAnimMaxHP
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	pop hl
	sla c
	rl b
	call ComputeHPBarPixels
	ld a, e
	; because HP bar calculations are doubled for 60 to 30fps conversion,
	; the last pixel is set to 2px/2, not 1px/2
	cp 1
	jr nz, .ok
	inc a
.ok
	ld [wCurHPBarPixels], a

	ld a, [wCurHPAnimNewHP]
	ld c, a
	ld a, [wCurHPAnimNewHP + 1]
	ld b, a
	ld a, [wCurHPAnimMaxHP]
	ld e, a
	ld a, [wCurHPAnimMaxHP + 1]
	ld d, a
	sla c
	rl b
	call ComputeHPBarPixels
	ld a, e
	cp 1
	jr nz, .ok2
	inc a
.ok2
	ld [wNewHPBarPixels], a

	push hl
	ld hl, wCurHPAnimOldHP
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	pop hl
	ld a, e
	sub c
	ld e, a
	ld a, d
	sbc b
	ld d, a
	jr c, .Damage
	ld a, [wCurHPAnimOldHP]
	ld [wCurHPAnimLowHP], a
	ld a, [wCurHPAnimNewHP]
	ld [wCurHPAnimHighHP], a
	ld c, 1
	jr .Okay

.Damage
	ld a, [wCurHPAnimOldHP]
	ld [wCurHPAnimHighHP], a
	ld a, [wCurHPAnimNewHP]
	ld [wCurHPAnimLowHP], a
	ld a, e
	cpl
	inc a
	ld e, a
	ld a, d
	cpl
	ld d, a
	ld c, 0
.Okay
	ld a, d
	ld [wCurHPAnimDeltaHP], a
	ld a, e
	ld [wCurHPAnimDeltaHP + 1], a
	ret

HPBarAnim_UpdateVariables:
	ld hl, wCurHPBarPixels
	ld a, c
	and a
	jr nz, .inc
	ld a, [hli]
	dec a
	cp [hl]
	jr c, .animdone
	jr z, .animdone
	jr .incdecdone

.inc
	ld a, [hli]
	inc a
	cp [hl]
	jr nc, .animdone
.incdecdone
	dec hl
	ld [hl], a
; wCurHPAnimOldHP = a * wCurHPAnimMaxHP / (HP_BAR_LENGTH_PX * 2)
	ldh [hMultiplier], a
	xor a
	ldh [hMultiplicand], a
	ld a, [wCurHPAnimMaxHP + 1]
	ldh [hMultiplicand + 1], a
	ld a, [wCurHPAnimMaxHP]
	ldh [hMultiplicand + 2], a
	call Multiply
	ld a, HP_BAR_LENGTH_PX * 2
	ldh [hDivisor], a
	ld b, 4
	call Divide
	ldh a, [hQuotient + 2]
	ld [wCurHPAnimOldHP + 1], a
	ldh a, [hQuotient + 3]
	ld [wCurHPAnimOldHP], a
	xor a ; clear carry flag
	ret

.animdone
	ld a, [hld]
	ld [hl], a
	ld hl, wCurHPAnimNewHP
	ld a, [hli]
	ld [wCurHPAnimOldHP], a
	ld a, [hl]
	ld [wCurHPAnimOldHP + 1], a
	scf
	ret
	
LongAnim_UpdateVariables:
.loop
	ld hl, wCurHPAnimOldHP
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, e
	cp [hl]
	jr nz, .next
	inc hl
	ld a, d
	cp [hl]
	jr nz, .next
	scf
	ret

.next
	push bc
	ld a, c
	and a
	jr nz, .heal
	dec a
.heal
	pop bc
	ld c, a
	cp 1
	jr z, .heal_2
	ld b, a
.heal_2
	ld l, e
	ld h, d
	add hl, bc
	ld a, l
	ld [wCurHPAnimOldHP], a
	ld a, h
	ld [wCurHPAnimOldHP + 1], a
	push hl
	push de
	push bc
	ld hl, wCurHPAnimMaxHP
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	call ComputeHPBarPixels
	ld a, e
	pop bc
	pop de
	pop hl
	ld hl, wCurHPBarPixels
	cp [hl]
	jr z, .loop
	ld [hl], a
	and a
	ret

HPBarAnim_UpdateTiles:
	call HPBarAnim_UpdateHPRemaining
.show_hp_bar
	ld a, [wCurHPBarPixels]
	srl a
	ld c, a
	ld e, a
	jr DrawHPBar
	
LongHPBarAnim_UpdateTiles:
	call HPBarAnim_UpdateHPRemaining
	ld a, [wCurHPAnimOldHP]
	ld c, a
	ld a, [wCurHPAnimOldHP + 1]
	ld b, a
	ld a, [wCurHPAnimMaxHP]
	ld e, a
	ld a, [wCurHPAnimMaxHP + 1]
	ld d, a
	call ComputeHPBarPixels
	ld c, e
	; fallthrough
	
DrawHPBar:
	ld d, HP_BAR_LENGTH
	ld a, [wWhichHPBar]
	and 1
	ld b, a
	ld a, [wWhichHPBar]
	cp 2
	jr nz, .skip
	push de
	ld de, SCREEN_WIDTH * 2
	add hl, de
	pop de
.skip
	call DrawBattleHPBar
	ld hl, wCurHPAnimPal
	call SetHPPal
	ld c, d
	farcall ApplyHPBarPals
	ret
	
HPBarAnim_UpdateHPRemaining:
	ld a, [wWhichHPBar]
	and a
	ret z

	ld de, SCREEN_WIDTH + 2
	dec a
	jr nz, .update_hp_number
	dec de
.update_hp_number
	push hl
	add hl, de
	ld a, " "
	ld [hli], a
	ld [hli], a
	ld [hld], a
	dec hl
	ld a, [wCurHPAnimOldHP]
	ld [wStringBuffer2 + 1], a
	ld a, [wCurHPAnimOldHP + 1]
	ld [wStringBuffer2], a
	ld de, wStringBuffer2
	lb bc, 2, 3
	call PrintNum
	pop hl
	ret

HPBarAnim_BGMapUpdate:
	ldh a, [hCGB]
	and a
	jr nz, .cgb
	jr .delay

.cgb
	ld a, [wWhichHPBar]
	and a
	jr z, .load_0
	cp $1
	jr z, .load_1
	ld a, [wCurPartyMon]
	cp $3
	jr nc, .bottom_half_of_screen
	ld c, $0
	jr .got_third

.bottom_half_of_screen
	ld c, $1
.got_third
	push af
	cp $2
	jr z, .skip_delay
	cp $5
	jr z, .skip_delay
	ld a, $2
	ldh [hBGMapMode], a
	ld a, c
	ldh [hBGMapThird], a
.skip_delay
	call DelayFrame
	ld a, $1
	ldh [hBGMapMode], a
	ld a, c
	ldh [hBGMapThird], a
	pop af
	cp $2
	jr z, .two_frames
	cp $5
	jr z, .two_frames
	jr .delay

.two_frames
	inc c
	ld a, $2
	ldh [hBGMapMode], a
	ld a, c
	ldh [hBGMapThird], a
	ld a, $1
	ldh [hBGMapMode], a
	ld a, c
	ldh [hBGMapThird], a
	jr .delay

.load_0
	ld c, $0
	jr .finish

.load_1
	ld c, $1
.finish
	call DelayFrame
	ld a, c
	ldh [hBGMapThird], a
.delay
	call DelayFrame
	ret
