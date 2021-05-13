CheckSwitchOftenOrSometimes:
	ld hl, TrainerClassAttributes + TRNATTR_AI_ITEM_SWITCH
    
    ld a, [wTrainerClass]
    dec a
    ld bc, NUM_TRAINER_ATTRIBUTES
    call AddNTimes
    
    ld a, BANK(TrainerClassAttributes)
    call GetFarByte
    bit SWITCH_OFTEN_F, a
    ret nz
    bit SWITCH_SOMETIMES_F, a
    ret
	
CheckSwitchOften:
	ld hl, TrainerClassAttributes + TRNATTR_AI_ITEM_SWITCH
    
    ld a, [wTrainerClass]
    dec a
    ld bc, NUM_TRAINER_ATTRIBUTES
    call AddNTimes
    
    ld a, BANK(TrainerClassAttributes)
    call GetFarByte
    bit SWITCH_OFTEN_F, a
    ret 
	
CheckLoweredStatsExceptSpd:
	 ; Checks if non-spd stat (because of Curse) is below -2
    ld a, [wEnemyAtkLevel]
    cp BASE_STAT_LEVEL - 2
    ret c
    ld a, [wEnemyDefLevel]
    cp BASE_STAT_LEVEL - 2
    ret c
    ld a, [wEnemySAtkLevel]
    cp BASE_STAT_LEVEL - 2
    ret c
    ld a, [wEnemySDefLevel]
    cp BASE_STAT_LEVEL - 2
	ret
	
CheckPlayerHasSEMove:
	 ; Check if Player has super-effective move
	ld a, [wPlayerHasSEMove]
	and 1 ; 1 = Player has SE move
	ret z
	ld a, [wEnemyAISwitchScore]
	sub 5
	ld [wEnemyAISwitchScore], a
	ret
	
CheckToxicEncoreCount:
	 ; Checks if Toxic Count is at least 3
	ld a, [wEnemyToxicCount]
	cp 3
	ret nc
	 ; Checks if Encore Count is at least 2
	ld a, [wEnemyToxicCount]
	cp 3
	ret
	
CountConsecutiveTurnsDealLowDmg:
	ld a, [wEnemyTurnsTaken]
	and a
	jr z, .dealt_dmg
	call CheckTurnsToKOPlayer
	jr c, .dealt_dmg
	jr z, .dealt_dmg
	ld a, [wEnemyCantDealDmgTurnsCnsctvly]
	inc a
	ld [wEnemyCantDealDmgTurnsCnsctvly], a
	ret
.dealt_dmg
	xor a
	ld [wEnemyCantDealDmgTurnsCnsctvly], a
	ret

CheckConsecutiveTurnsDealLowDmg:
	ld a, [wEnemyCantDealDmgTurnsCnsctvly]
	cp 2
	ret
	
CheckStatBoosts:
    ld hl, wPlayerStatLevels
    ld c, NUM_LEVEL_STATS - 1
    ld b, 0
	ld e, 0
.checkplayerbuff  ; Check player's stat buffs
	dec c
	jr z, .checkpt2
	ld a, [hli]
	cp BASE_STAT_LEVEL
	jr nc, .checkplayerbuff2
	jr .checkplayerbuff
.checkplayerbuff2
	sub a, BASE_STAT_LEVEL
	add b	 ; b holds the stat buffs
	ld b, a
	jr .checkplayerbuff

.checkpt2
	ld hl, wEnemyStatLevels
	ld c, 7
.checkenemybuff	 ; Check AI's stat buffs
	dec c
	ret z
	ld a, [hli]
	cp BASE_STAT_LEVEL
	jr nc, .checkenemybuff2
	jr .checkenemybuff
.checkenemybuff2
	sub a, BASE_STAT_LEVEL
	add e	 ; e holds the stat buffs
	ld e, a
	jr .checkenemybuff
	ret
	
CheckTurnsToKOAI:
	ld a, [wEnemyMonJustFainted]
	and a
	jr nz, .just_fainted
	ld a, [wPlayerTurnsTaken]
	and a
	jr z, .max_turns
	ld hl, wEnemyDamageTakenThisTurn
	ld a, [hli]
	cpl
	ld e, a
	ld a, [hl]
	cpl
	ld d, a
	and e
	cp -1
	jr z, .max_turns
	inc de
	ld hl, wEnemyMonHP
	ld a, [hli]
	ld h, [hl]
	ld l, a
	xor a
.loop
	inc a
	add hl, de
	jr nc, .less_than_four_turns
	cp 4
	jr c, .loop
	jr .max_turns
.just_fainted
	xor a
	ld [wEnemyMonJustFainted], a
.max_turns
	ld a, -1
.less_than_four_turns
	cp a, 3
	ret
	
CheckTurnsToKOPlayer:
	ld hl, wPlayerDamageTakenThisTurn
	ld a, [hli]
	cpl
	ld e, a
	ld a, [hl]
	cpl
	ld d, a
	and e
	cp -1
	jr z, .max_turns
	inc de
	ld hl, wBattleMonHP
	ld a, [hli]
	ld h, [hl]
	ld l, a
	xor a
.loop
	inc a
	add hl, de
	jr nc, .less_than_four_turns
	cp 4
	jr c, .loop
	jr .max_turns
.max_turns
	ld a, -1
.less_than_four_turns
	cp a, 4
	ret
	
CheckPlayerRechageOrLockedOn:
	ld hl, wPlayerSubStatus3
	bit SUBSTATUS_RAMPAGE, [hl]
	jr nz, .switch
	ld hl, wPlayerSubStatus4
	bit SUBSTATUS_RECHARGE, [hl]
	jr nz, .switch
	ld hl, wPlayerSubStatus1
	bit SUBSTATUS_ROLLOUT, [hl]
	jr z, .stay_in
	ld a, [wPlayerRolloutCount]
	cp 3
	jr c, .switch
.stay_in
	ld a, 0
	and a
	ret
.switch
	ld a, [wEnemyTurnsTaken]
	and a
	jr z, .stay_in
	call Random
	cp 50 percent + 1
	jr c, .stay_in
	ld a, 1
	and a
	ret

	
CalcPlayerDamageTakenThisTurn:
	ld a, [wCurDamage]
	ld [wPlayerDamageTakenThisTurn], a
	ld a, [wCurDamage + 1]
	ld [wPlayerDamageTakenThisTurn + 1], a
	ret
	
CalcEnemyDamageTakenThisTurn:
	ld a, [wCurDamage]
	ld [wEnemyDamageTakenThisTurn], a
	ld a, [wCurDamage + 1]
	ld [wEnemyDamageTakenThisTurn + 1], a
	ret
	
ResetPlayerDamageTakenThisTurn:
	xor a
	ld [wPlayerDamageTakenThisTurn], a
	ld [wPlayerDamageTakenThisTurn + 1], a
	ret
	
ResetEnemyDamageTakenThisTurn:
	xor a
	ld [wEnemyDamageTakenThisTurn], a
	ld [wEnemyDamageTakenThisTurn + 1], a
	ret
	
SetEnemyMonJustFainted:
	ld a, [wEnemyMonJustFainted]
	inc a
	ld [wEnemyMonJustFainted], a
	ld a, [wEnemyMonsLeft]
	dec a
	ld [wEnemyMonsLeft], a
	ret
	
DidEnemySwitch:
	ld a, [wEnemyIsSwitching]
	and a
	jr z, .enemy_didnt_switch
	xor a
	ld [wEnemyCantDealDmgTurnsCnsctvly], a
	ld a, [wEnemyConsecutiveSwitches]
	inc a
	ld [wEnemyConsecutiveSwitches], a
	ret
.enemy_didnt_switch
	xor a
	ld [wEnemyConsecutiveSwitches], a
	ret
	
CheckNumberOfEnemyMons:
	 ; returns c if enemy mons alive is less than 3
	ld a, [wEnemyMonsLeft]
	cp 3
	ret
	