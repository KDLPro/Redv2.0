CheckPlayerMoveTypeMatchups:
; Check how well the moves you've already used
; fare against the enemy's Pokemon.  Used to
; score a potential switch.
	push hl
	push de
	push bc
	ld a, BASE_AI_SWITCH_SCORE
	ld [wEnemyAISwitchScore], a
	ld hl, wPlayerUsedMoves
	ld a, [hl]
	and a
	jr z, .unknown_moves

	ld d, NUM_MOVES
	ld e, 0
.loop
	ld a, [hli]
	and a
	jr z, .exit
	push hl
	dec a
	ld hl, Moves + MOVE_POWER
	call GetMoveAttr
	and a
	jr z, .next

	inc hl
	call GetMoveByte
	ld hl, wEnemyMonType
	call CheckTypeMatchup
	ld a, [wTypeMatchup]
	cp EFFECTIVE
	jr z, .neutral
	jr c, .super_effective
	
; not very effective
	ld a, e
	cp 1 ; 0.1
	jr nc, .next
	ld e, 1
	jr .next

.neutral
	ld e, 2
	jr .next

.super_effective
	call .doubledown
	call .doubledown
	call .doubledown
	pop hl
	jr .done

.next
	pop hl
	dec d
	jr nz, .loop

.exit
	ld a, e
	cp 2
	jr z, .done
	call .IncreaseScore
	ld a, e
	and a
	jr nz, .done
	call .IncreaseScore

.done
	pop bc
	pop de
	pop hl
	ret

.unknown_moves
	ld a, [wBattleMonType1]
	ld b, a
	ld hl, wEnemyMonType1
	call CheckTypeMatchup
	ld a, [wTypeMatchup]
	cp EFFECTIVE + 1 ; 1.0 + 0.1
	jr c, .ok
	call .DecreaseScore
.ok
	ld a, [wBattleMonType2]
	cp b
	jr z, .done
	call CheckTypeMatchup
	ld a, [wTypeMatchup]
	cp EFFECTIVE + 1 ; 1.0 + 0.1
	jr c, .done
	call .DecreaseScore
	jr .done

.doubledown
	call .DecreaseScore
.DecreaseScore:
	ld a, [wEnemyAISwitchScore]
	dec a
	ld [wEnemyAISwitchScore], a
	ret

.IncreaseScore:
	ld a, [wEnemyAISwitchScore]
	inc a
	ld [wEnemyAISwitchScore], a
	ret

CheckAbleToSwitch:
    xor a
    ld [wEnemySwitchMonParam], a
    call FindAliveEnemyMons
    ret c
	farcall CountConsecutiveTurnsDealLowDmg

    farcall CheckSwitchOftenOrSometimes
    jr nz, .startsmartcheck
    jp	 .checklockedon
.startsmartcheck
	 ; Checks if Toxic Count is at least 3
	 ; Checks if Encore Count is at least 2
	farcall CheckToxicEncoreCount
	jp nc, .rollswitch
	 ; Checks if Evasion is greater than 0
	ld a, [wEnemyEvaLevel]
    cp BASE_STAT_LEVEL + 1
    ret nc
	 ; Checks if Accuracy is below -1
    ld a, [wEnemyAccLevel]
    cp BASE_STAT_LEVEL - 1
    jr c, .rollswitch
	farcall CheckStatBoosts
.cont_check
	 ; Checks if AI has no boosts
	ld a, e
	and a
	jr z, .cont_check_2
	 ; Check if player has at least 2 stat buffs
	ld a, b
	cp 2
	ret nc
	 ; Otherwise, roll to check other clauses or not
    call Random
    cp 70 percent
    ret c
    jr .checklockedon
.cont_check_2 
	 ; Check if player has at least 2 stat buffs
	ld a, b
	cp 2
	jr nc, .rollswitch
	 ; Checks if non-spd stat (because of Curse) is below -2
    farcall CheckLoweredStatsExceptSpd
    jr c, .rollswitch
    jr .checklockedon
	
.rollswitch
	ld a, [wEnemyConsecutiveSwitches]
	cp 2
	jp nc, .rare_switch
    call Random
    cp 60 percent
    jr c, .switch
    
.checklockedon
	 ; AI may switch if player is recharging
	 ; or locked on to a move
	farcall CheckPlayerRechageOrLockedOn
	jp nz, .switch

.checkperish
    ld a, [wEnemySubStatus1]
    bit SUBSTATUS_PERISH, a
    jr z, .no_perish

    ld a, [wEnemyPerishCount]
    cp 1
    jr z, .switch
	
.no_perish
	 ; Check if AI deals low damage for at least
	 ; 2 consecutive turns
	farcall CheckConsecutiveTurnsDealLowDmg
	jp nc, .smartcheck
	jr .checkmatchups

.switch ; Try to switch
    call FindAliveEnemyMons
    call FindEnemyMonsWithAtLeastQuarterMaxHP
	
	ld a, [wLastPlayerCounterMove]
	and a
	jr z, .find_resist
	
.randomize_se_or_immune
	call Random
	cp 50 percent + 1
	jr c, .find_resist

	call FindEnemyMonsImmuneToLastCounterMove
	ld a, [wEnemyAISwitchScore]
	and a
	jr z, .find_resist
	jr .cont_find_immune
	
.find_resist
    call FindEnemyMonsThatResistPlayer
.find_se
    call FindAliveEnemyMonsWithASuperEffectiveMove
	
.do_switch_1
    ld a, [wEnemyAISwitchScore]
    add $30 ; maximum chance
    ld [wEnemySwitchMonParam], a
    ret

.checkmatchups
	 ; Check if AI's Pokémon gets knocked out
	 ; for a maximum of 2 turns (OHKO or 2HKO)
	farcall CheckTurnsToKOAI
	jr c, .smartcheck
	 ; Check if AI deals low damage for at least
	 ; 2 consecutive turns
	farcall CheckConsecutiveTurnsDealLowDmg
	jp nc, .smartcheck
	
	farcall AICheckEnemyQuarterHP
	jp nc, .smartcheck
	
	ld a, [wEnemyAISwitchScore]
	cp 10
	ret nc

	ld a, [wLastPlayerCounterMove]
	and a
	jr z, .no_last_counter_move

	call FindEnemyMonsImmuneToLastCounterMove
	ld a, [wEnemyAISwitchScore]
	and a
	ret z
	
	ld a, [wEnemyConsecutiveSwitches]
	and a
	ret nz
	
	call Random
	cp 50 percent + 1
	jr c, .do_switch_1
	
.cont_find_immune
	ld c, a
	call FindEnemyMonsWithASuperEffectiveMove
	ld a, [wEnemyAISwitchScore]
	cp $ff
	ret z

	ld b, a
	ld a, e
	cp 2
	jr z, .not_2_again
	
	ld a, [wEnemyAISwitchScore]
	cp 10
	ret c
	
	call Random
	cp 70 percent
	ret c

	ld a, b
	add $20
	ld [wEnemySwitchMonParam], a
	ret

.not_2_again
	ld c, $10
	call CheckPlayerMoveTypeMatchups
	ld a, [wEnemyAISwitchScore]
	cp 10
	jr nc, .okay
	ld c, $20

.okay
	ld a, b
	add c
	ld [wEnemySwitchMonParam], a
	ret
	
.no_last_counter_move
	ld a, [wEnemyAISwitchScore]
	cp 10
	ret nc

	farcall CheckSwitchOften
	jr nz, .smartcheck
	ret	
	
 ; Switch check only for SWITCH_OFTEN AI
.smartcheck:
	ld a, [wEnemyConsecutiveSwitches]
	cp 2
	jr nc, .rare_switch
	farcall CheckNumberOfEnemyMons
	jr c, .less_than_three
	call Random
	cp 35 percent
	ret c
	jp .switch
.less_than_three
	call Random
	cp 60 percent
	ret c
	jp .switch
	
.rare_switch
	call Random
	cp 75 percent + 1
	ret c
	jp .switch

FindAliveEnemyMons:
	ld a, [wOTPartyCount]
	cp 2
	jr c, .only_one

	ld d, a
	ld e, 0
	ld b, 1 << (PARTY_LENGTH - 1)
	ld c, 0
	ld hl, wOTPartyMon1HP

.loop
	ld a, [wCurOTMon]
	cp e
	jr z, .next

	push bc
	ld b, [hl]
	inc hl
	ld a, [hld]
	or b
	pop bc
	jr z, .next

	ld a, c
	or b
	ld c, a

.next
	srl b
	push bc
	ld bc, PARTYMON_STRUCT_LENGTH
	add hl, bc
	pop bc
	inc e
	dec d
	jr nz, .loop

	ld a, c
	and a
	jr nz, .more_than_one

.only_one
	scf
	ret

.more_than_one
	and a
	ret

FindEnemyMonsImmuneToLastCounterMove:
	ld hl, wOTPartyMon1
	ld a, [wOTPartyCount]
	ld b, a
	ld c, 1 << (PARTY_LENGTH - 1)
	ld d, 0
	xor a
	ld [wEnemyAISwitchScore], a

.loop
	ld a, [wCurOTMon]
	cp d
	push hl
	jr z, .next

	push hl
	push bc
	; If the Pokemon has at least 1 HP...
	ld bc, MON_HP
	add hl, bc
	pop bc
	ld a, [hli]
	or [hl]
	pop hl
	jr z, .next

	ld a, [hl]
	ld [wCurSpecies], a
	call GetBaseData
	; the player's last move is damaging...
	ld a, [wLastPlayerCounterMove]
	dec a
	ld hl, Moves + MOVE_POWER
	call GetMoveAttr
	and a
	jr z, .next
	; and the Pokemon is immune to it...
	inc hl
	call GetMoveByte
	ld hl, wBaseType
	call CheckTypeMatchup
	ld a, [wTypeMatchup]
	and a
	jr nz, .next
	; ... encourage that Pokemon.
	ld a, [wEnemyAISwitchScore]
	or c
	ld [wEnemyAISwitchScore], a
.next
	pop hl
	dec b
	ret z

	push bc
	ld bc, PARTYMON_STRUCT_LENGTH
	add hl, bc
	pop bc

	inc d
	srl c
	jr .loop

FindAliveEnemyMonsWithASuperEffectiveMove:
	push bc
	ld a, [wOTPartyCount]
	ld e, a
	ld hl, wOTPartyMon1HP
	ld b, 1 << (PARTY_LENGTH - 1)
	ld c, 0
.loop
	ld a, [hli]
	or [hl]
	jr z, .next

	ld a, b
	or c
	ld c, a

.next
	srl b
	push bc
	ld bc, wPartyMon2HP - (wPartyMon1HP + 1)
	add hl, bc
	pop bc
	dec e
	jr nz, .loop

	ld a, c
	pop bc

	and c
	ld c, a
	; fallthrough
FindEnemyMonsWithASuperEffectiveMove:
	ld a, -1
	ld [wEnemyAISwitchScore], a
	ld hl, wOTPartyMon1Moves
	ld b, 1 << (PARTY_LENGTH - 1)
	ld d, 0
	ld e, 0
.loop
	ld a, b
	and c
	jr z, .next

	push hl
	push bc
	; for move on mon:
	ld b, NUM_MOVES
	ld c, 0
.loop3
	; if move is None: break
	ld a, [hli]
	and a
	push hl
	jr z, .break3

	; if move has no power: continue
	dec a
	ld hl, Moves + MOVE_POWER
	call GetMoveAttr
	and a
	jr z, .nope

	; check type matchups
	inc hl
	call GetMoveByte
	ld hl, wBattleMonType1
	call CheckTypeMatchup

	; if immune or not very effective: continue
	ld a, [wTypeMatchup]
	cp 10
	jr c, .nope

	; if neutral: load 1 and continue
	ld e, 1
	cp EFFECTIVE + 1
	jr c, .nope

	; if super-effective: load 2 and break
	ld e, 2
	jr .break3

.nope
	pop hl
	dec b
	jr nz, .loop3

	jr .done

.break3
	pop hl
.done
	ld a, e
	pop bc
	pop hl
	cp 2
	jr z, .done2 ; at least one move is super-effective
	cp 1
	jr nz, .next ; no move does more than half damage

	; encourage this pokemon
	ld a, d
	or b
	ld d, a
	jr .next ; such a long jump

.next
	; next pokemon?
	push bc
	ld bc, PARTYMON_STRUCT_LENGTH
	add hl, bc
	pop bc
	srl b
	jr nc, .loop

	; if no pokemon has a super-effective move: return
	ld a, d
	ld b, a
	and a
	ret z

.done2
	; convert the bit flag to an int and return
	push bc
	sla b
	sla b
	ld c, $ff
.loop2
	inc c
	sla b
	jr nc, .loop2

	ld a, c
	ld [wEnemyAISwitchScore], a
	pop bc
	ret

FindEnemyMonsThatResistPlayer:
	push bc
	ld hl, wOTPartySpecies
	ld b, 1 << (PARTY_LENGTH - 1)
	ld c, 0

.loop
	ld a, [hli]
	cp $ff
	jr z, .done

	push hl
	ld [wCurSpecies], a
	call GetBaseData
	ld a, [wLastPlayerCounterMove]
	and a
	jr z, .skip_move

	dec a
	ld hl, Moves + MOVE_POWER
	call GetMoveAttr
	and a
	jr z, .skip_move

	inc hl
	call GetMoveByte
	jr .check_type

.skip_move
	ld a, [wBattleMonType1]
	ld hl, wBaseType
	call CheckTypeMatchup
	ld a, [wTypeMatchup]
	cp 10 + 1
	jr nc, .dont_choose_mon
	ld a, [wBattleMonType2]

.check_type
	ld hl, wBaseType
	call CheckTypeMatchup
	ld a, [wTypeMatchup]
	cp EFFECTIVE + 1
	jr nc, .dont_choose_mon

	ld a, b
	or c
	ld c, a

.dont_choose_mon
	srl b
	pop hl
	jr .loop

.done
	ld a, c
	pop bc
	and c
	ld c, a
	ret

FindEnemyMonsWithAtLeastQuarterMaxHP:
	push bc
	ld de, wOTPartySpecies
	ld b, 1 << (PARTY_LENGTH - 1)
	ld c, 0
	ld hl, wOTPartyMon1HP

.loop
	ld a, [de]
	inc de
	cp $ff
	jr z, .done

	push hl
	push bc
	ld b, [hl]
	inc hl
	ld c, [hl]
	inc hl
	inc hl
; hl = MaxHP + 1
; bc = [CurHP] * 4
	srl c
	rl b
	srl c
	rl b
; if bc >= [hl], encourage
	ld a, [hld]
	cp c
	ld a, [hl]
	sbc b
	pop bc
	jr nc, .next

	ld a, b
	or c
	ld c, a

.next
	srl b
	pop hl
	push bc
	ld bc, PARTYMON_STRUCT_LENGTH
	add hl, bc
	pop bc
	jr .loop

.done
	ld a, c
	pop bc
	and c
	ld c, a
	ret
