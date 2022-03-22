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
	jp z, .unknown_moves

	ld d, NUM_MOVES
	ld e, 0
.loop
	ld a, [hli]
	and a
	jr z, .exit
	
	push hl
	push hl
	push de
	push bc
	call SwitchAIGetPlayerMove
	call PlayerDamageCalc
	pop bc
	call CheckTurnsToKOAIUsingPlayersMoves
	pop de
	pop hl
	
	push af
	call CheckEnemyHalfHP
	jr nc, .enemy_low_hp
	pop af
	
	cp 3
	jr c, .huge_damage
	cp 5
	jr c, .decent_damage
	
.small_damage
	ld a, e
	cp 1 ; 0.1
	jr nc, .next
	ld e, 1
	jr .next

.enemy_low_hp
	pop af
	
	cp 2
	jr c, .huge_damage
	cp 4
	jr c, .decent_damage
	jr .small_damage

.decent_damage
	ld e, 2
	jr .next

.huge_damage
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
	ld a, [wEnemyTurnsTaken]
	cp 3
	jr c, .done_check_stall
	ld a, [wPlayerTurnsTaken]
	cp 5
	jr c, .done_check_stall
	call CheckEnemyMoveMatchups
.done_check_stall
	ld a, d
	and a
	jr nz, .unknown_moves
.done
	pop bc
	pop de
	pop hl
	xor a
	ld [wCurDamage], a
	ld [wCurDamage + 1], a
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
	ld a, [wTypeMatchup]
	cp SUPER_EFFECTIVE + 1
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
	ld a, [wTypeMatchup]
	cp SUPER_EFFECTIVE + 1
	jr c, .done
	call DecreaseScore
	jr .done
	
	
CheckOnlyEnemyMoveMatchups:
	ld a, BASE_AI_SWITCH_SCORE
	ld [wEnemyAISwitchScore], a
	; fallthrough
CheckEnemyMoveMatchups:
	push hl
	push de
	push bc
	ld de, wEnemyMonMoves
	ld b, NUM_MOVES + 1
	ld c, 0

.loop
	dec b
	jr z, .exit

	ld a, [de]
	and a
	jr z, .exit

	push hl
	push de
	push bc
	call SwitchAIGetEnemyMove
	call SwitchAIDamageCalc
	pop bc
	pop de
	pop hl

	ld a, [de]
	inc de
	
	push bc
	push af
	ld a, [wEnemyAISwitchScore]
	push af
	push de
	cp PURSUIT 
	call z, SwitchPursuitDamage
	pop de
	pop af
	ld [wEnemyAISwitchScore], a
	pop af
	
	push de
	push hl
	call CheckTurnsToKOPlayerUsingEnemyMoves
	pop hl
	pop de
	
	push af
	call CheckPlayerHalfHP
	jr nc, .player_low_hp
	pop af
	pop bc
	
	; very low damage
	
	cp $FF
	jr nc, .loop
	
.damage_check
	; small damage
	
	inc c
	cp 4
	jr nc, .loop

	; decent damage
	
	inc c
	inc c
	inc c
	inc c
	inc c
	cp 3
	jr nc, .loop

	; huge damage
	push af
	ld a, c
	add 25
	ld c, a
	pop af
	cp 2
	jr nc, .loop
	
	; ohko
	ld c, 120
	jr .loop
	
.player_low_hp
	pop af
	pop bc
	
	; very low damage
	
	cp $FF
	jr nc, .loop
	
.damage_check_low_hp
	
	; small damage
	
	inc c
	cp 3
	jr nc, .loop

	; decent damage
	
	inc c
	inc c
	inc c
	inc c
	inc c
	cp 2
	jr nc, .loop

	; huge damage
	ld c, 120
	jr .loop

.exit
	xor a
	ld [wCurDamage], a
	ld [wCurDamage + 1], a
	
	ld a, c
	and a
	jr nz, .can_deal_decent_Damage
	call DoubleDown ; double down
	call DoubleDown ; double down
.can_deal_decent_Damage
	cp 5
	call c, DecreaseScore ; down
	ld a, [wEnemyTurnsTaken]
	cp 3
	jr c, .done_check_stall
	ld a, [wPlayerTurnsTaken]
	cp 5
	jr c, .done_check_stall
	call DoubleDown
.done_check_stall
	ld a, c
	cp 25
	jr c, .return
	
	call IncreaseScore
	
	ld a, c
	cp 120
	jr c, .return
	pop bc
	pop de
	pop hl
	jr IncreaseSharply ; up
	
.return
	pop bc
	pop de
	pop hl
	ret

DoubleDown:
	call DecreaseScore
DecreaseScore:
	ld a, [wEnemyAISwitchScore]
	dec a
	ld [wEnemyAISwitchScore], a
	ret

IncreaseSharply:
	call IncreaseScore
IncreaseScore:
	ld a, [wEnemyAISwitchScore]
	inc a
	ld [wEnemyAISwitchScore], a
	ret
	
	
PredictUsersMove:
; "Predict" user's move if player is not switching
	ld a, -1
	ld c, a
	ld d, a
	ld e, a
	 ; Use selected move for prediction only
	 ; if it's on turn 0
	ld a, [wPlayerTurnsTaken]
	and a
	jp nz, .turn_1_onwards
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
	cp $ff
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
	cp $ff
	jr z, .randomize_type_2
	call FiftyPercentRoll
	jr c, .randomize_type_2
	ld b, d
	jr FindMoveBasedOnType
.randomize_type_2
	ld a, e
	cp $ff
	jr z, .check_type_1
	ld b, e
	jr FindMoveBasedOnType
.check_type_1
	ld a, d
	cp $ff
	ret z
	ld b, d
	jr FindMoveBasedOnType
	
.turn_1_onwards
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
	 ; Randomize switch if there is status that
	 ; prevents the enemy from attacking
	ld a, [wEnemyMonStatus]
	bit FRZ, a
	jr nz, .stall_switch
	bit PAR, a
	jr nz, .stall_switch
	and SLP
	jr nz, .stall_switch
	jr .no_stall_status
.stall_switch
	call SixtyPercentRoll
	jp nc, .smartcheck_speed_matchup_check
.no_stall_status
	 ; Checks if Toxic Count is at least 3
	 ; Checks if Encore Count is at least 2
	call CheckToxicEncoreCount
	jp nc, .smartcheck
	 ; Checks if Evasion is greater than 0
	ld a, [wEnemyEvaLevel]
    cp BASE_STAT_LEVEL + 1
	jp nc, .no_switch
	 ; Checks if Accuracy is below -1
    ld a, [wEnemyAccLevel]
    cp BASE_STAT_LEVEL - 1
    jp c, .smartcheck
	call CheckStatBoosts
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
	jp nc, .checkmatchups
	 ; Checks if non-spd stat (because of Curse) is below -2
	call CheckLoweredStatsExceptSpd
	jp c, .smartcheck
	
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
	jp z, .checkmatchups

	ld a, [wEnemyPerishCount]
	cp 1
	jr z, .switch
	jp .checkmatchups

.switch ; Try to switch
	ld a, [wBattleMonStatus]
	bit FRZ, a
	jp nz, .smartcheck_speed_matchup_check
	and SLP
	jp nz, .smartcheck_speed_matchup_check
	
	ld a, [wLastPlayerCounterMove]
	cp SEISMIC_TOSS
	jp z, .constant_damage_find_immune
	cp SONICBOOM
	jp z, .constant_damage_find_immune
	cp NIGHT_SHADE
	jp z, .constant_damage_find_immune
	
.find_target_mon_to_switch
	call CheckPlayerMoveTypeMatchups
	ld a, [wEnemyAISwitchScore]
	cp BASE_AI_SWITCH_SCORE - 1
	jr c, .very_bad_matchup_find_target
	call CheckOnlyEnemyMoveMatchups
	ld a, [wEnemyAISwitchScore]
	cp BASE_AI_SWITCH_SCORE - 3
	jr nc, .randomize

.very_bad_matchup_find_target	
	call FindMonToSwitchResistSE
	ld a, [wEnemyAISwitchScore]
	cp $FF
	jr nz, .do_switch
	
	call FindEnemyMonsImmuneToOrResistsLastCounterMove
	ld a, [wEnemyAISwitchScore]
	cp $FF
	jr nz, .do_switch	
	
	; Don't switch if AI is SWITCH_SOMETIMES or SWITCH_RARELY
	call CheckSwitchOften
	jp z, .no_switch
	
	call FindEnemyMonsImmuneToOrResistsLastCounterMoveBadDamage	
	ld a, [wEnemyAISwitchScore]
	cp $FF
	jr nz, .do_switch
	jp .no_switch
	
.randomize
	call FiftyPercentRoll
	jp nc, .find_immune
.find_super_effective
	call FindAliveEnemyMons
	call FindEnemyMonsWithAtLeastQuarterMaxHP
	
.find_resist
	call FindEnemyMonsThatResistPlayer
	call FindAliveEnemyMonsWithASuperEffectiveMove	
	ld a, [wEnemyAISwitchScore]
	cp $FF
	call z, FindEnemyMonsImmuneToOrResistsLastCounterMove
	
	
.do_switch
	ld a, [wEnemyAISwitchScore]
	add $10
	ld [wEnemySwitchMonParam], a
	ret

.checkmatchups
	call CheckEnemyQuarterHP
	jp nc, .smartcheck_speed_matchup_check
	
	ld a, [wEnemyAISwitchScore]
	cp BASE_AI_SWITCH_SCORE
	jp nc, .check_move_matchups
	
	call CheckOnlyEnemyMoveMatchups
	
	ld a, [wEnemyAISwitchScore]
	cp BASE_AI_SWITCH_SCORE
	jp c, .smartcheck_speed_matchup_check

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
	jp c, .checkmatchups2
	
	
.no_need_big_brain
.switching
	 ; Switch out depending on how many times
	 ; AI switched already. Return z if stay in
	call .smartcheck_revealed_moves
	jp z, .no_switch	 
	 ; try to find a counter to the active Pokémon.
	call FindEnemyMonsImmuneToOrResistsLastCounterMove
	ld a, [wEnemyAISwitchScore]
	cp $ff
	jp nz, .do_switch
	
	call CheckSwitchOften
	jp z, .no_switch
	
	call FindMonToSwitchResistSE
	; Check if target switch Pokémon has a super effective move
	; Return if it has none
	ld a, e
	cp 2
	jp z, .do_switch
	jp .no_switch

.constant_damage_find_immune
	 ; Switch out depending on how many times
	 ; AI switched already. Return z if stay in
	call .smartcheck_revealed_moves
	jp z, .no_switch	 
	 ; try to find a counter to the active Pokémon.
	call FindEnemyMonsImmuneToOrResistsLastCounterMove
	ld a, [wEnemyAISwitchScore]
	cp $ff
	jp nz, .do_switch
	
	call CheckSwitchOften
	jp z, .no_switch
	
	call FindMonToSwitchResistSE
	; Check if target switch Pokémon has a super effective move
	; Return if it has none
	ld a, e
	cp 2
	jp z, .do_switch
	
	call FindAliveEnemyMons
	call FindEnemyMonsWithAtLeastHalfMaxHP
	jp .do_switch
	
.find_immune	 
	 ; try to find a counter to the active Pokémon.
	call FindEnemyMonsImmuneToOrResistsLastCounterMove
	ld a, [wEnemyAISwitchScore]
	cp $ff
	jp z, .find_super_effective
	
	jp .do_switch

.checkmatchups2
	ld a, [wPlayerIsSwitching]
	and a
	jp nz, .no_need_big_brain
	
	call CheckSwitchOften
	jp z, .no_need_big_brain
	
	 ; 50% chance to check target switch Pokémon to "predict"
	 ; player's prediction #BIGBRAINPLAY
	call FiftyPercentRoll
	jr c, .find_target_pokemon
	
	ld a, [wEnemyAISwitchScore]
	cp BASE_AI_SWITCH_SCORE
	jp nc, .no_switch
	jp .switch
	
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
	jp z, .no_need_big_brain
	
	inc hl
	call AIGetMoveByte
	ld hl, wBaseType
	call AICheckTypeMatchup
	ld a, [wTypeMatchup]
	cp EFFECTIVE
	jr z, .find_resist_no_big_brain
	jr c, .find_resist_big_brain
	
	pop af
	ld [wCurOTMon], a
	jp .find_immune
	
.find_resist_big_brain
	call FindMonToSwitchResistSE
	
	pop af
	ld [wCurOTMon], a
	jp .do_switch
	
.find_resist_no_big_brain
	pop af
	ld [wCurOTMon], a
	jp .find_resist

	
.find_super_effective_locked_on
	call CheckOnlyEnemyMoveMatchups
	
	ld a, [wEnemyAISwitchScore]
	cp BASE_AI_SWITCH_SCORE
	jp nc, .no_switch
	
	call FindMonToSwitchResistSE
	; Check if target switch Pokémon has a super effective move
	ld a, e
	cp 2
	jp z, .do_switch
	
	call FindEnemyMonsImmuneToOrResistsLastCounterMove
	ld a, [wEnemyAISwitchScore]
	cp $ff
	jp nz, .do_switch
	jp .no_switch
	
	
.no_last_counter_move
	call CheckPlayerMoveTypeMatchups
	ld a, [wEnemyAISwitchScore]
	cp BASE_AI_SWITCH_SCORE
	jr nc, .no_switch

	call CheckSwitchOften
	jr nz, .smartcheck_speed_matchup_check
	jr .no_switch
	
.check_move_matchups	
	call CheckOnlyEnemyMoveMatchups
	
	ld a, [wEnemyAISwitchScore]
	cp BASE_AI_SWITCH_SCORE
	jr nc, .no_switch
	
	ld a, [wEnemyConsecutiveSwitches]
	and a
	jp z, .smartcheck_speed_matchup_check
	jr .no_switch
	
.smartcheck_speed_matchup_check
	 ; If enemy is slower, higher chance to switch
	farcall AICompareSpeed
	jr nc, .smartcheck
	 ; Don't switch if enemy can counter player
	 ; thru its moves
	call CheckOnlyEnemyMoveMatchups
	
	ld a, [wEnemyAISwitchScore]
	cp BASE_AI_SWITCH_SCORE
	jr nc, .rare_switch
 ; Switch check only for SWITCH_OFTEN or SWITCH_COMPETITIVE AI
.smartcheck:
	ld a, [wEnemyConsecutiveSwitches]
	cp 3
	jr nc, .rare_switch
	call CheckEnemyMonsLessThanThree
	jr c, .less_than_three
	call SixtyFivePercentRoll
	jr nc, .no_switch
	jp .find_target_mon_to_switch
.less_than_three
	call SixtyPercentRoll
	jr c, .no_switch
	jp .find_target_mon_to_switch
	
.rare_switch
	call SeventyPercentRoll
	jr c, .no_switch
	jp .find_target_mon_to_switch
	
.no_switch
	xor a
	ld [wEnemySwitchMonParam], a
	ret

	
 ; Switch check for revealed moves
.smartcheck_revealed_moves:
	 ; If enemy is slower, higher chance to switch
	farcall AICompareSpeed
	jr nc, .smartcheck2
	 ; Don't switch if enemy can counter player
	 ; thru its moves
	call CheckOnlyEnemyMoveMatchups
	
	ld a, [wEnemyAISwitchScore]
	cp BASE_AI_SWITCH_SCORE
	jr nc, .rare_switch_revealed
.smartcheck2
	ld a, [wEnemyConsecutiveSwitches]
	cp 3
	jr nc, .rare_switch_revealed
	call CheckEnemyMonsLessThanThree
	jr c, .less_than_three_revealed
	call SixtyPercentRoll
	jr nc, .stay_in
	jr .switch_out
.less_than_three_revealed
	call FiftyPercentRoll
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
	

FindMonToSwitchResistSE:
	call FindAliveEnemyMons
	call FindEnemyMonsWithAtLeastQuarterMaxHP
	call FindEnemyMonsThatResistPlayer
	call FindAliveEnemyMonsWithASuperEffectiveMove
	ret
	
FindMonToSwitchSESwitch:
	call FindAliveEnemyMons
	call FindEnemyMonsWithAtLeastQuarterMaxHP
	call FindAliveEnemyMonsWithASuperEffectiveMoveSwitch
	ret

FindEnemyMonsThatCanHandleLastCounterMove:
	call FindEnemyMonsImmuneToOrResistsLastCounterMove
	ld a, [wEnemyAISwitchScore]
	cp $ff
	ret nz
	call FindEnemyMonsImmuneToOrResistsLastCounterMoveBadDamage
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
	
SwitchAIGetPlayerMove:
; Load attributes of move a into ram

	push hl
	push de
	push bc
	dec a
	ld hl, Moves
	ld bc, MOVE_LENGTH
	call AddNTimes

	ld de, wPlayerMoveStruct
	ld a, BANK(Moves)
	call FarCopyBytes

	pop bc
	pop de
	pop hl
	ret
	
SwitchAIGetEnemyMove:
; Load attributes of move a into ram

	push hl
	push de
	push bc
	dec a
	ld hl, Moves
	ld bc, MOVE_LENGTH
	call AddNTimes

	ld de, wEnemyMoveStruct
	ld a, BANK(Moves)
	call FarCopyBytes

	pop bc
	pop de
	pop hl
	ret

PlayerDamageCalc:
	ld a, 0
	ldh [hBattleTurn], a
	ld a, [wPlayerMoveStruct + MOVE_EFFECT]
	ld de, 1
	ld hl, ConstantDamageEffects
	call IsInArray
	jr nc, .notconstant
	farcall BattleCommand_ConstantDamage
	ret

.notconstant
	farcall PlayerAttackDamage
	farcall BattleCommand_DamageCalc
	farcall BattleCommand_Stab
	ret
	
SwitchAIDamageCalc:
	ld a, 1
	ldh [hBattleTurn], a
	ld a, [wEnemyMoveStruct + MOVE_EFFECT]
	ld de, 1
	ld hl, SwitchAIConstantDamageEffects
	call IsInArray
	jr nc, .notconstant
	farcall BattleCommand_ConstantDamage
	ret

.notconstant
	farcall EnemyAttackDamage
	farcall BattleCommand_DamageCalc
	farcall BattleCommand_Stab
	ret
	
SwitchPursuitDamage:
	push hl
	farcall AICheckPlayerQuarterHP
	pop hl
	jr nc, .calc_pursuit
	
	call CheckPlayerMoveTypeMatchups
	ld a, [wEnemyAISwitchScore]
	cp BASE_AI_SWITCH_SCORE + 1
	ret c
	
	call CheckTurnsToKOAI
	ret c

.calc_pursuit
	call Random
	cp 50 percent + 1
	ret c
	ld hl, wCurDamage + 1
	sla [hl]
	dec hl
	rl [hl]
	ret nc

	ld a, $ff
	ld [hli], a
	ld [hl], a
	ret
	
INCLUDE "data/battle/ai/switch_ai_constant_damage_effects.asm"


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
	call FiftyPercentRoll
	jp c, FindEnemyMonsImmuneToOrResistsLastCounterMoveReverse
	
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

	; If the Pokemon has at least 1/2 max HP...
	call CheckCurrentMonIfAtLeastHalfHP2
	jr nc, .next
	
	ld a, [wPlayerTurnsTaken]
	cp 4
	jr nc, .stalled
	
	; If the Pokemon is faster than the player...
	push hl
	push bc
	ld bc, MON_SPD
	add hl, bc
	
	inc hl
	ld a, [hld]
	ld b, a
	ld a, [wBattleMonSpeed + 1]
	cp b
	ld a, [hl]
	ld b, a
	ld a, [wBattleMonSpeed]
	sbc b
	pop bc
	pop hl
	jr nc, .next
	
.stalled
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
	; and the Pokemon is immune or resists it...
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
	
FindEnemyMonsImmuneToOrResistsLastCounterMoveReverse:
	ld hl, wOTPartyMon6
	ld a, [wOTPartyCount]
	ld d, a
	ld c, 1 << (PARTY_LENGTH - 1)
	ld b, 0
	ld a, $FF
	ld [wEnemyAISwitchScore], a

.loop
	ld a, [wCurOTMon]
	cp d
	push hl
	jr z, .next

	; If the Pokemon has at least 1/2 max HP...
	call CheckCurrentMonIfAtLeastHalfHP2
	jr nc, .next
	
	
	ld a, [wPlayerTurnsTaken]
	cp 4
	jr nc, .stalled
	
	; If the Pokemon is faster than the player...
	push hl
	push bc
	ld bc, MON_SPD
	add hl, bc
	
	inc hl
	ld a, [hld]
	ld b, a
	ld a, [wBattleMonSpeed + 1]
	cp b
	ld a, [hl]
	ld b, a
	ld a, [wBattleMonSpeed]
	sbc b
	pop bc
	pop hl
	jr nc, .next

.stalled
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
	; and the Pokemon is immune or resists it...
	inc hl
	call AIGetMoveByte
	ld hl, wBaseType
	call AICheckTypeMatchup
	ld a, [wTypeMatchup]
	cp EFFECTIVE
	jr nc, .next
.encourage
	; ... encourage that Pokemon.
	ld a, d
	dec a
	ld [wEnemyAISwitchScore], a
.next
	pop hl
	dec d
	ret z

	push bc
	ld bc, PARTYMON_STRUCT_LENGTH
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
	pop bc

	inc b
	srl c
	jr .loop
	
FindEnemyMonsImmuneToOrResistsLastCounterMoveBadDamage:
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
	
	; If the Pokemon has at least 1/2 max HP...
	call CheckCurrentMonIfAtLeastHalfHP2
	jr nc, .next
	
	ld a, [hl]
	ld [wCurSpecies], a
	call GetBaseData
	; the player's last move is damaging...
	; (otherwise, encourage that Pokémon randomly)
	ld a, [wLastPlayerCounterMove]
	dec a
	ld hl, Moves + MOVE_POWER
	call AIGetMoveAttr
	and a
	jr z, .encourage
	; and the Pokemon is immune to or resists it or is neutral to it...
	inc hl
	call AIGetMoveByte
	ld hl, wBaseType
	call AICheckTypeMatchup
	ld a, [wTypeMatchup]
	cp EFFECTIVE + 1
	jr nc, .next
.encourage
	; ... encourage that Pokemon randomly.
	ld a, [wEnemyAISwitchScore]
	cp $FF
	jr z, .select
	call SixtyPercentRoll
	jr nc, .next
.select
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
	; Check the Pokemon has at least 1/2 max HP...
	; Check if the Pokemon has at least 1/2 max HP...
	call CheckCurrentMonIfAtLeastHalfHP
	jr nc, .next

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
	
FindAliveEnemyMonsWithASuperEffectiveMoveSwitch:
	push bc
	ld a, [wOTPartyCount]
	ld e, a
	ld hl, wOTPartyMon1HP
	ld b, 1 << (PARTY_LENGTH - 1)
	ld c, 0
.loop
	; Check if the Pokemon has at least 1/2 max HP...
	call CheckCurrentMonIfAtLeastHalfHP
	jr nc, .next

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

	call FindEnemyMonsWithASuperEffectiveMove

	ld a, e
	cp 2
	jr nz, .no_se ; no move is super-effective
	ret
	
.no_se
	ld a, $f4
	ld [wEnemyAISwitchScore], a
	ret

FindEnemyMonsThatResistPlayer:
	push bc
	push de
	ld hl, wOTPartyMon1
	ld b, 1 << (PARTY_LENGTH - 1)
	ld c, 0
	ld a, [wEnemyMonsLeft]
	ld d, a

.loop
	ld a, d
	and a
	jp z, .done

	push hl
	
	ld a, [wBattleMonStatus]
	bit FRZ, a
	jp nz, .choose_mon
	cp 2 ; at least one more turn before waking up
	jp nc, .choose_mon
	
	ld a, [hl]
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
	cp EFFECTIVE
	jr nc, .dont_choose_mon
	cp NO_EFFECT
	jr z, .choose_mon
	ld a, [wBattleMonType2]

.check_type
	ld hl, wBaseType
	call AICheckTypeMatchup
	ld a, [wTypeMatchup]
	cp EFFECTIVE
	jr nc, .dont_choose_mon
	cp NO_EFFECT
	jr z, .choose_mon
	
	pop hl
	push hl
	; If the Pokemon is faster than the player...
	push hl
	push bc
	ld bc, MON_SPD
	add hl, bc
	
	inc hl
	ld a, [hld]
	ld b, a
	ld a, [wBattleMonSpeed + 1]
	cp b
	ld a, [hl]
	ld b, a
	ld a, [wBattleMonSpeed]
	sbc b
	pop bc
	pop hl
	jr c, .choose_mon
	
	ld a, [wEnemyMonStatus]
	bit FRZ, a
	jr nz, .stall_status
	bit PAR, a
	jr nz, .stall_status
	and SLP
	jr nz, .stall_status
	jr .dont_choose_mon

.stall_status	
	ld a, [wPlayerTurnsTaken]
	cp 4
	jr c, .dont_choose_mon

.choose_mon
	ld a, b
	or c
	ld c, a

.dont_choose_mon
	srl b
	pop hl
	
	push bc
	ld bc, PARTYMON_STRUCT_LENGTH
	add hl, bc
	pop bc
	
	dec d
	
	jp .loop

.done
	ld a, c
	pop de
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
	
FindEnemyMonsWithAtLeastHalfMaxHP:
	ld hl, wOTPartyMon1HP
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
	; If the Pokemon has at least half max HP
	ld bc, MON_HP
	add hl, bc
	pop bc
	push bc
	ld b, [hl]
	inc hl
	ld c, [hl]
	sla c
	rl b
	inc hl
	inc hl
	ld a, [hld]
	cp c
	ld a, [hl]
	sbc b
	pop bc
	pop hl
	jr c, .next

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
	
CheckPlayerHalfHP:
	push hl
	push de
	push bc
	ld hl, wBattleMonHP
	ld b, [hl]
	inc hl
	ld c, [hl]
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

CheckEnemyHalfHP:
	push hl
	push de
	push bc
	ld hl, wEnemyMonHP
	ld b, [hl]
	inc hl
	ld c, [hl]
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
	
CheckCurrentMonIfAtLeastHalfHP:
	push hl
	push bc
	ld b, [hl]
	inc hl
	ld c, [hl]
	sla c
	rl b
	inc hl
	inc hl
	ld a, [hld]
	cp c
	ld a, [hl]
	sbc b
	pop bc
	pop hl
	ret
	
CheckCurrentMonIfAtLeastHalfHP2:
	push hl
	push bc
	ld bc, MON_HP
	add hl, bc
	ld b, [hl]
	inc hl
	ld c, [hl]
	sla c
	rl b
	inc hl
	inc hl
	ld a, [hld]
	cp c
	ld a, [hl]
	sbc b
	pop bc
	pop hl
	ret
