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
	call AIGetMoveAttr
	and a
	jr z, .next

	inc hl
	call AIGetMoveByte
	ld hl, wEnemyMonType
	call AICheckTypeMatchup
	ld a, [wTypeMatchup]
	cp EFFECTIVE
	jr z, .neutral
	jr nc, .super_effective
	
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
	call DoubleDown
	call DoubleDown
	call DoubleDown
	pop hl
	jr .done_checking_moves

.next
	pop hl
	dec d
	jr nz, .loop

.exit
	ld a, e
	cp 2
	jr z, .done_checking_moves
	call IncreaseScore
	ld a, e
	and a
	jr nz, .done_checking_moves
	call IncreaseScore

.done_checking_moves
	ld a, d
	and a
	jr nz, .unknown_moves
.done
	pop bc
	pop de
	pop hl
	ret

.unknown_moves
	ld a, [wBattleMonType1]
	ld b, a
	ld hl, wEnemyMonType1
	call AICheckTypeMatchup
	ld a, [wTypeMatchup]
	cp EFFECTIVE + 1 ; 1.0 + 0.1
	jr c, .ok
	call DecreaseScore
.ok
	ld a, [wBattleMonType2]
	cp b
	jr z, .done
	call AICheckTypeMatchup
	ld a, [wTypeMatchup]
	cp EFFECTIVE + 1 ; 1.0 + 0.1
	jr c, .done
	call DecreaseScore
	jr .done
	
CheckEnemyMoveMatchups:
	ld de, wEnemyMonMoves
	ld b, NUM_MOVES + 1
	ld c, 0

	ld a, [wTypeMatchup]
	push af
.loop2
	dec b
	jr z, .exit2

	ld a, [de]
	and a
	jr z, .exit2

	inc de
	dec a
	ld hl, Moves + MOVE_POWER
	call AIGetMoveAttr
	and a
	jr z, .loop2

	inc hl
	call AIGetMoveByte
	ld hl, wBattleMonType1
	call AICheckTypeMatchup

	ld a, [wTypeMatchup]
	; immune
	and a
	jr z, .loop2

	; not very effective
	inc c
	cp EFFECTIVE
	jr c, .loop2

	; neutral
	inc c
	inc c
	inc c
	inc c
	inc c
	cp EFFECTIVE
	jr z, .loop2

	; super effective
	ld c, 100
	jr .loop2

.exit2
	pop af
	ld [wTypeMatchup], a

	ld a, c
	and a
	jr z, DoubleDown ; double down
	cp 5
	jr c, DecreaseScore ; down
	cp 100
	ret c
	jr IncreaseScore ; up

DoubleDown:
	call DecreaseScore
DecreaseScore:
	ld a, [wEnemyAISwitchScore]
	dec a
	ld [wEnemyAISwitchScore], a
	ret

IncreaseScore:
	ld a, [wEnemyAISwitchScore]
	inc a
	ld [wEnemyAISwitchScore], a
	ret
	
	
PredictUsersMove:
; "Predict" user's move if player is not switching
	 ; Use selected move for prediction only
	 ; if it's on turn 0
	ld a, [wPlayerTurnsTaken]
	and a
	jp nz, .turn_1_onwards
	ld a, -1
	ld c, a
	ld d, a
	ld e, a
	 ; Check selected move's matchup against enemy
	ld a, [wCurPlayerMove]
	dec a
	ld hl, Moves + MOVE_POWER
	call AIGetMoveAttr
	and a
	jr z, .check_moves_revealed
	
	inc hl
	call AIGetMoveByte
	ld a, [wBaseType]
	ld c, a
.check_moves_revealed
	push de
	 ; Check if all moves are revealed
	ld hl, wPlayerUsedMoves
	ld d, NUM_MOVES
.loop
	ld a, [hli]
	and a
	jr z, .check_stab_1_matchup
	dec d
	jr nz, .loop
	ld a, -1
	ld c, a
.check_stab_1_matchup
	pop de
	ld a, [wBattleMonType1]
	ld b, a
	ld hl, wEnemyMonType1
	call AICheckTypeMatchup
	ld a, [wTypeMatchup]
	cp EFFECTIVE + 1 ; 1.0 + 0.1
	jr c, .check_stab_2_matchup
	ld a, b
	ld d, a
.check_stab_2_matchup
	ld a, [wBattleMonType2]
	cp b
	jr z, .done_checking_matchups
	call AICheckTypeMatchup
	ld a, [wTypeMatchup]
	cp EFFECTIVE + 1 ; 1.0 + 0.1
	jr c, .done_checking_matchups
	ld a, b
	ld e, a
.done_checking_matchups
	ld a, c
	cp $FF
	jr z, .randomize_type_1
	call SeventyPercentRoll
	jr c, .randomize_type_1
	
	ld a, [wPlayerTurnsTaken]
	and a
	ret nz
	 ; Use selected move for turn 0
	 ; move prediction
	ld a, [wCurPlayerMove]
	ld [wLastPlayerCounterMove], a
	ret
.randomize_type_1
	ld a, d
	cp $FF
	jr z, .randomize_type_2
	call FiftyPercentRoll
	jr c, .randomize_type_2
	ld b, d
	jr FindMoveBasedOnType
.randomize_type_2
	ld a, e
	cp $FF
	jr z, .check_type_1
	ld b, e
	jr FindMoveBasedOnType
.check_type_1
	ld a, d
	cp $FF
	ret z
	ld b, d
	jr FindMoveBasedOnType
	
.turn_1_onwards
	ld a, -1
	ld c, a
	ld d, a
	ld e, a
	 ; Check selected move's matchup against enemy
	ld a, [wLastPlayerCounterMove]
	dec a
	ld hl, Moves + MOVE_POWER
	call AIGetMoveAttr
	and a
	jr z, .check_moves_revealed
	
	inc hl
	call AIGetMoveByte
	ld hl, wBaseType
	call AICheckTypeMatchup
	ld a, [wTypeMatchup]
	cp EFFECTIVE + 1
	jp c, .check_moves_revealed
	ld a, [wBaseType]
	ld c, a
	jp .check_moves_revealed
	
FindMoveBasedOnType:
	 ; Find the best move corresponding to the 
	 ; type given in b.
	ld hl, BestMovesOfEachType
.loop
	ld a, [hl]
	cp $ff
	ret z
	cp b
	jr z, .found_move
	inc hl
	inc hl
	jr .loop
	
.found_move
	inc hl
	ld a, [hl]
	ld [wLastPlayerCounterMove], a
	ret
	
INCLUDE "data/battle/ai/best_moves.asm"
	

CheckAbleToSwitch:
    call FindAliveEnemyMons
	jp c, .no_switch

    call CheckSwitchOftenOrSometimes
    jr nz, .startsmartcheck
    jp	 .checklockedon
	
.startsmartcheck
	 ; Checks if Toxic Count is at least 3
	 ; Checks if Encore Count is at least 2
	call CheckToxicEncoreCount
	jp nc, .rollswitch
	 ; Checks if Evasion is greater than 0
	ld a, [wEnemyEvaLevel]
    cp BASE_STAT_LEVEL + 1
	jp nc, .no_switch
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
	jp nc, .no_switch
	 ; Otherwise, roll to check other clauses or not
	call SeventyPercentRoll
    jp c, .no_switch
    jr .checklockedon
.cont_check_2 
	 ; Check if player has at least 2 stat buffs
	ld a, b
	cp 2
	jr nc, .rollswitch
	 ; Checks if non-spd stat (because of Curse) is below -2
    call CheckLoweredStatsExceptSpd
    jr c, .rollswitch
    jr .checklockedon

.rollswitch
	ld a, [wEnemyConsecutiveSwitches]
	cp 2
	jp nc, .rare_switch
	
    call SixtyPercentRoll
    jr c, .switch
    
.checklockedon
	 ; AI may switch if player is recharging
	 ; or locked on to a move
	call CheckPlayerRechageOrLockedOn
	jp nz, .find_super_effective_locked_on
	
	 ; TO-DO: Add Bounce and two-turn move clauses
	 ; to switch 50% of the time when the player uses
	 ; moves like Fly and Dig

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
	call CheckConsecutiveTurnsDealLowDmg
	jp nc, .smartcheck
	jr .checkmatchups

.switch ; Try to switch
	call FiftyPercentRoll
	jp nc, .find_immune
	ld a, [wLastPlayerCounterMove]
	cp SEISMIC_TOSS
	jp z, .find_immune
	cp SONICBOOM
	jp z, .find_immune
	cp NIGHT_SHADE
	jp z, .find_immune
.find_super_effective
    call FindAliveEnemyMons
    call FindEnemyMonsWithAtLeastQuarterMaxHP
	
.find_resist
    call FindEnemyMonsThatResistPlayer
    call FindAliveEnemyMonsWithASuperEffectiveMove
	
.do_switch
    ld a, [wEnemyAISwitchScore]
	add $10
    ld [wEnemySwitchMonParam], a
	ret

.checkmatchups
	 ; Check if AI's Pokémon gets knocked out
	 ; for a maximum of 2 turns (OHKO or 2HKO)
	call CheckTurnsToKOAI
	jp c, .smartcheck_speed_matchup_check
	 ; Check if AI deals low damage for at least
	 ; 2 consecutive turns
	call CheckConsecutiveTurnsDealLowDmg
	jp nc, .smartcheck
	
	farcall CheckEnemyQuarterHP
	jp nc, .smartcheck
	
	ld a, [wEnemyAISwitchScore]
	cp 10
	jp nc, .no_switch
	
	call CheckEnemyMoveMatchups
	
	ld a, [wEnemyAISwitchScore]
	cp 11
	jp c, .smartcheck

	ld a, [wLastPlayerCounterMove]
	and a
	jp z, .no_last_counter_move
	cp SEISMIC_TOSS
	jr z, .constant_damage_find_immune
	cp SONICBOOM
	jr z, .constant_damage_find_immune
	cp NIGHT_SHADE
	jr z, .constant_damage_find_immune
	
	ld a, [wPlayerIsSwitching]
	and a
	jp nz, .switching
	
	 ; If the player's last move is damaging...
	ld a, [wLastPlayerCounterMove]
	dec a
	ld hl, Moves + MOVE_POWER
	call AIGetMoveAttr
	and a
	jp z, .find_super_effective
	inc hl
	call AIGetMoveByte
	
.super_effective_check
	 ; and the move is super-effective to the active Pokémon...
	ld hl, wEnemyMonType1
	call AICheckTypeMatchup
	ld a, [wTypeMatchup]
	cp EFFECTIVE + 1
	jr c, .checkmatchups2
	
.switching
	 ; Switch out depending on how many times
	 ; AI switched already. Return z if stay in
	call .smartcheck_revealed_moves
	jp z, .no_switch
	
.no_need_big_brain
	call FiftyPercentRoll
	jp c, .find_super_effective


.constant_damage_find_immune
	 ; Switch out depending on how many times
	 ; AI switched already. Return z if stay in
	call .smartcheck_revealed_moves
	jp z, .no_switch
.find_immune	 
	 ; try to find a counter to the active Pokémon.
	call FindEnemyMonsImmuneToOrResistsLastCounterMove
	ld a, [wEnemyAISwitchScore]
	cp $FF
	jp z, .find_super_effective
	
	jp .do_switch
	
.find_target_pokemon
	ld a, [wCurOTMon]
	push af
; Find target Pokémon to switch to
    ld hl, wOTPartySpecies
    ld a, [wEnemySwitchMonParam]
    and $f
    ld b, 0
    ld c, a
    add hl, bc
    ld [wCurOTMon], a

    ld a, [hl]
    ld [wCurSpecies], a
    call GetBaseData
	 ; If the player's last move is damaging...
	ld a, [wLastPlayerCounterMove]
	dec a
	ld hl, Moves + MOVE_POWER
	call AIGetMoveAttr
	and a
	jr z, .no_need_big_brain
	
	inc hl
	call AIGetMoveByte
	ld hl, wBaseType
	call AICheckTypeMatchup
	ld a, [wTypeMatchup]
	cp EFFECTIVE + 1
	jr c, .find_resist_big_brain
	
	pop af
	ld [wCurOTMon], a
	jp .find_immune
	
.find_resist_big_brain
	call .find_mon_to_switch_resist_se
	
	pop af
	ld [wCurOTMon], a
	jp .do_switch
	
.checkmatchups2
	ld a, [wPlayerIsSwitching]
	and a
	jr nz, .no_need_big_brain
	
	 ; 50% chance to check target switch Pokémon to "predict"
	 ; player's prediction #BIGBRAINPLAY
	call FiftyPercentRoll
	jr c, .find_target_pokemon
	
	ld a, [wEnemyAISwitchScore]
	cp 10
	jr nc, .no_switch
	jp .switch
	
.find_super_effective_locked_on
	call CheckEnemyMoveMatchups
	
	ld a, [wEnemyAISwitchScore]
	cp 11
	jr nc, .no_switch
	
    call .find_mon_to_switch_resist_se
	; Check if target switch Pokémon has a super effective move
	; Return if it has none
	ld a, e
	cp 2
	jr nz, .no_switch
	
	 ; try to find a counter to the active Pokémon.
	call FindEnemyMonsImmuneToOrResistsLastCounterMove
	ld a, [wEnemyAISwitchScore]
	cp $FF
	jr z, .no_switch
	jp .do_switch
	
.find_mon_to_switch_resist_se:
	call FindAliveEnemyMons
    call FindEnemyMonsWithAtLeastQuarterMaxHP
    call FindEnemyMonsThatResistPlayer
    call FindAliveEnemyMonsWithASuperEffectiveMove
	ret
	
.no_last_counter_move
	ld a, [wEnemyAISwitchScore]
	cp 10
	jr nc, .no_switch

	farcall CheckSwitchOften
	jr nz, .smartcheck
	jr .no_switch
	
.smartcheck_speed_matchup_check
	 ; If enemy is slower, higher chance to switch
	farcall AICompareSpeed
	jr nc, .smartcheck
	 ; Reduced switch chance if enemy can counter player
	 ; thru its moves
	call CheckEnemyMoveMatchups
	
	ld a, [wEnemyAISwitchScore]
	cp 11
	jr nc, .less_than_three
 ; Switch check only for SWITCH_OFTEN AI
.smartcheck:
	ld a, [wEnemyConsecutiveSwitches]
	cp 3
	jr nc, .rare_switch
	farcall CheckEnemyMonsLessThanThree
	jr c, .less_than_three
	call SeventyPercentRoll
	jr nc, .no_switch
	jp .switch
.less_than_three
	call SixtyPercentRoll
	jr c, .no_switch
	jp .switch
	
.rare_switch
	call SeventyPercentRoll
	jr c, .no_switch
	jp .switch
	
.no_switch
    xor a
    ld [wEnemySwitchMonParam], a
	ret
	
 ; Switch check for revealed moves
.smartcheck_revealed_moves:
	ld a, [wEnemyConsecutiveSwitches]
	cp 3
	jr nc, .rare_switch_revealed
	farcall CheckEnemyMonsLessThanThree
	jr c, .less_than_three_revealed
	call SeventyPercentRoll
	jr nc, .stay_in
	jr .switch_out
.less_than_three_revealed
	call SixtyPercentRoll
	jr c, .stay_in
	jr .switch_out
	
.rare_switch_revealed
	call SixtyFivePercentRoll
	jr c, .stay_in
	jr .switch_out
	
.stay_in
	ld a, 0
	and a
	ret
.switch_out
	ld a, 1
	and a
	ret
	
	
FiftyPercentRoll:
	call Random
	cp 50 percent + 1
	ret
	
SixtyPercentRoll:
	call Random
	cp 60 percent + 1
	ret
	
SixtyFivePercentRoll:
	call Random
	cp 65 percent + 1
	ret
	
SeventyPercentRoll:
	call Random
	cp 70 percent + 1
	ret
	
SeventyFivePercentRoll:
	call Random
	cp 75 percent + 1
	ret

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

FindEnemyMonsImmuneToOrResistsLastCounterMove:
	ld hl, wOTPartyMon1
	ld a, [wOTPartyCount]
	ld b, a
	ld c, 1 << (PARTY_LENGTH - 1)
	ld d, 0
	ld a, $FF
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
	call AIGetMoveAttr
	and a
	jr z, .next
	; and the Pokemon is immune to it...
	inc hl
	call AIGetMoveByte
	ld hl, wBaseType
	call AICheckTypeMatchup
	ld a, [wTypeMatchup]
	cp EFFECTIVE
	jr nc, .next
	; ... encourage that Pokemon.
	ld a, [wOTPartyCount]
	sub b
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
	call AIGetMoveAttr
	and a
	jr z, .nope

	; check type matchups
	inc hl
	call AIGetMoveByte
	ld hl, wBattleMonType1
	call AICheckTypeMatchup

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
	call AIGetMoveAttr
	and a
	jr z, .skip_move

	inc hl
	call AIGetMoveByte
	jr .check_type

.skip_move
	ld a, [wBattleMonType1]
	ld hl, wBaseType
	call AICheckTypeMatchup
	ld a, [wTypeMatchup]
	cp EFFECTIVE + 1
	jr nc, .dont_choose_mon
	ld a, [wBattleMonType2]

.check_type
	ld hl, wBaseType
	call AICheckTypeMatchup
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
	

AIGetMoveAttr:
; Assuming hl = Moves + x, return attribute x of move a.
	push bc
	ld bc, MOVE_LENGTH
	call AddNTimes
	call AIGetMoveByte
	pop bc
	ret

AIGetMoveData:
; Copy move struct a to de.
	ld hl, Moves
	ld bc, MOVE_LENGTH
	call AddNTimes
	ld a, BANK(Moves)
	jp FarCopyBytes

AIGetMoveByte:
	ld a, BANK(Moves)
	jp GetFarByte
	
AICheckTypeMatchup:
	push hl
	push de
	push bc
	ld d, a
	ld b, [hl]
	inc hl
	ld c, [hl]
	ld a, 10 ; 1.0
	ld [wTypeMatchup], a
	ld hl, AITypeMatchups
    ld a, [hl]
.TypesLoop:
	ld a, [hli]
	cp -1
	jr z, .End
	cp -2
	jr nz, .Next
	ld a, BATTLE_VARS_SUBSTATUS1_OPP
	call GetBattleVar
	bit SUBSTATUS_IDENTIFIED, a
	jr nz, .End
	jr .TypesLoop

.Next:
	cp d
	jr nz, .Nope
	ld a, [hli]
	; defending types
	cp b
	jr z, .Yup
	cp c
	jr z, .Yup
	jr .Nope2

.Nope:
	inc hl
.Nope2:
	inc hl
	jr .TypesLoop

.Yup:
	ld a, [hli]
	cp SUPER_EFFECTIVE
	jr z, .se
	cp NOT_VERY_EFFECTIVE
	jr z, .nve
	cp NO_EFFECT
	jr z, .immune
	jr .TypesLoop
.se
	ld a, [wTypeMatchup]
	sla a
	ld [wTypeMatchup], a
	jr .TypesLoop
.nve
	ld a, [wTypeMatchup]
	srl a
	ld [wTypeMatchup], a
	jr .TypesLoop
.immune:
	xor a
	ld [wTypeMatchup], a

.End:
	pop bc
	pop de
	pop hl
	ret

INCLUDE "data/types/ai_type_matchups.asm"

CheckEnemyQuarterHP:
	push hl
	push de
	push bc
	ld hl, wEnemyMonHP
	ld b, [hl]
	inc hl
	ld c, [hl]
	sla c
	rl b
	sla c
	rl b
	inc hl
	inc hl
	ld a, [hld]
	cp c
	ld a, [hl]
	sbc b
	pop bc
	pop de
	pop hl
	ret

