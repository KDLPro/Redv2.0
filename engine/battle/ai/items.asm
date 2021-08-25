AI_SwitchOrTryItem:
	and a

	ld a, [wBattleMode]
	dec a
	ret z
	
	ld a, [wCurEnemyMove]
	cp $FF
	jr z, DontSwitch

	ld a, [wLinkMode]
	and a
	ret nz

	farcall CheckEnemyLockedIn
	ret nz

	ld a, [wPlayerSubStatus5]
	bit SUBSTATUS_CANT_RUN, a
	jr nz, DontSwitch

	ld a, [wEnemyWrapCount]
	and a
	jr nz, DontSwitch

	; always load the first trainer class in wTrainerClass for Battle Tower trainers
	ld hl, TrainerClassAttributes + TRNATTR_AI_ITEM_SWITCH
	ld a, [wInBattleTowerBattle]
	and a
	jr nz, .ok

	ld a, [wTrainerClass]
	dec a
	ld bc, NUM_TRAINER_ATTRIBUTES
	call AddNTimes

.ok
	bit SWITCH_COMPETITIVE_F, [hl]
	jp nz, SwitchCompetitive
	bit SWITCH_OFTEN_F, [hl]
	jp nz, SwitchOften
	bit SWITCH_RARELY_F, [hl]
	jp nz, SwitchRarely
	bit SWITCH_SOMETIMES_F, [hl]
	jp nz, SwitchSometimes
	; fallthrough

DontSwitch:
	call AI_TryItem
	ret

SwitchCompetitive:
	 ; Reroll if player is not switching
	ld a, [wPlayerIsSwitching]
	and a
	jr z, .reroll_predict
	 ; Do not reroll if player is recharging
	 ; or locked on to a move
	farcall CheckPlayerRechageOrLockedOn
	jp nz, .check_switch_param
	 ; Check if player is incentivised to switch
	ld a, [wEnemyAISwitchScore]
	cp BASE_AI_SWITCH_SCORE
	jr c, .check_switch_param
	 ; Reroll to account for prediction
	call Random
	cp 50 percent + 1
	jr c, .reroll
	jr .check_switch_param
	
.reroll_predict
	 ; Reroll target switch Pokémon
	farcall PredictUsersMove
.reroll
	farcall CheckAbleToSwitch
.check_switch_param
	ld a, [wEnemySwitchMonParam]
	and $f0
	jp z, DontSwitch
	
	jp LoadMonToSwitchTo

SwitchOften:
	 ; Reroll if player is not switching
	ld a, [wPlayerIsSwitching]
	and a
	jr z, .reroll_predict
	 ; Do not reroll if player is recharging
	 ; or locked on to a move
	farcall CheckPlayerRechageOrLockedOn
	jp nz, .check_switch_param
	 ; Check if player is incentivised to switch
	ld a, [wEnemyAISwitchScore]
	cp BASE_AI_SWITCH_SCORE
	jr c, .check_switch_param
	 ; Reroll to account for prediction
	call Random
	cp 50 percent + 1
	jr c, .reroll
	jr .check_switch_param
	
.reroll_predict
	 ; Reroll target switch Pokémon
	farcall PredictUsersMove
.reroll
	farcall CheckAbleToSwitch
.check_switch_param
	ld a, [wEnemySwitchMonParam]
	and $f0
	jp z, DontSwitch
	
	call Random
	cp 30 percent - 1
	jp c, DontSwitch
	jp LoadMonToSwitchTo
	
SwitchRarely:
	ld a, [wEnemySwitchMonParam]
	and $f0
	jp z, DontSwitch
	
	call Random
	cp 80 percent - 1
	jp c, DontSwitch
	jp LoadMonToSwitchTo

SwitchSometimes:
	 ; Check if player is incentivised to switch
	ld a, [wEnemyAISwitchScore]
	cp BASE_AI_SWITCH_SCORE
	jr c, .check_switch_param
	 ; Do not reroll if player is recharging
	 ; or locked on to a move
	farcall CheckPlayerRechageOrLockedOn
	jp nz, .check_switch_param
	 ; Reroll to account for prediction
	call Random
	cp 50 percent + 1
	jr c, .check_switch_param
	 ; Reroll target switch Pokémon
	farcall CheckAbleToSwitch
.check_switch_param
	ld a, [wEnemySwitchMonParam]
	and $f0
	jp z, DontSwitch
	
	call Random
	cp 50 percent - 1
	jp c, DontSwitch

LoadMonToSwitchTo:
	farcall CheckPlayerMoveTypeMatchups
	ld a, [wEnemySwitchMonParam]
	and $f
	inc a
	 ; In register 'a' is the number (1-6) of the mon to switch to
	ld [wEnemySwitchMonIndex], a
	 ; Remove glitched Pokémon
	and a
	ret z
	cp 7
	ret nc
	ld d, 1
	call CheckGlitchMon
	ret z
	jp VerifyTargetMonType
	
CheckGlitchMonAfterFaint:
	ld a, [wEnemyAISwitchScore]
	inc a
	ld d, 0
	; fallthrough
CheckGlitchMon:
; Prevent Glitch Pokémon
	ld b, a
	ld a, [wOTPartyCount]
	cp b
	jr c, .force_return_z
	ld a, [wCurOTMon]
	inc a
	cp b
	ret z
	; Check if the mon to switch to has 0 HP
	ld hl, wOTPartyMon1
.loop_check_mon
	ld a, b
	cp d
	jr z, .check_hp
	inc d
	push bc
	ld bc, PARTYMON_STRUCT_LENGTH
	add hl, bc
	pop bc
	jr .loop_check_mon

.check_hp
	push bc
	ld bc, MON_HP
	add hl, bc
	ld a, [hli]
	or [hl]
	pop bc
	ret
	
.force_return_z
	ld a, 0
	and a
	ret
	
VerifyTargetMonType:
	 ; Make sure the Pokémon just switched in
	 ; has a different type to the one on the field.
	ld e, 0
	
	ld a, [wCurOTMon]
	ld d, a
	
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
	
	ld a, [wBaseType1]
	ld b, a
	ld a, [wEnemyMonType1]
	cp b
	jr nz, .check_type_2
	
	inc e
	
.check_type_2
	ld a, [wBaseType2]
	ld b, a
	ld a, [wEnemyMonType2]
	cp b
	jr nz, .done_checking_types
	
	inc e
	
.done_checking_types
	ld a, d
	ld [wCurOTMon], a
	ld a, e
	cp 2
	ret z
	jp AI_TrySwitch


CheckSubstatusCantRun: ; unreferenced
	ld a, [wEnemySubStatus5]
	bit SUBSTATUS_CANT_RUN, a
	ret

AI_TryItem:
	; items are not allowed in the Battle Tower
	ld a, [wInBattleTowerBattle]
	and a
	ret nz

	ld a, [wEnemyTrainerItem1]
	ld b, a
	ld a, [wEnemyTrainerItem2]
	or b
	ret z

	call .IsHighestLevel
	ret nc

	ld a, [wTrainerClass]
	dec a
	ld hl, TrainerClassAttributes + TRNATTR_AI_ITEM_SWITCH
	ld bc, NUM_TRAINER_ATTRIBUTES
	call AddNTimes
	ld b, h
	ld c, l
	ld hl, AI_Items
	ld de, wEnemyTrainerItem1
.loop
	ld a, [hl]
	and a
	inc a
	ret z

	ld a, [de]
	cp [hl]
	jr z, .has_item
	inc de
	ld a, [de]
	cp [hl]
	jr z, .has_item

	dec de
	inc hl
	inc hl
	inc hl
	jr .loop

.has_item
	inc hl

	push hl
	push de
	ld de, .callback
	push de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl
.callback
	pop de
	pop hl

	inc hl
	inc hl
	jr c, .loop

; used item
	xor a
	ld [de], a
	inc a
	ld [wEnemyGoesFirst], a

	ld hl, wEnemySubStatus3
	res SUBSTATUS_BIDE, [hl]

	xor a
	ld [wEnemyFuryCutterCount], a
	ld [wEnemyProtectCount], a
	ld [wEnemyRageCounter], a

	ld hl, wEnemySubStatus4
	res SUBSTATUS_RAGE, [hl]

	xor a
	ld [wLastEnemyCounterMove], a

	scf
	ret

.IsHighestLevel:
	ld a, [wOTPartyCount]
	ld d, a
	ld e, 0
	ld hl, wOTPartyMon1Level
	ld bc, PARTYMON_STRUCT_LENGTH
.next
	ld a, [hl]
	cp e
	jr c, .ok
	ld e, a
.ok
	add hl, bc
	dec d
	jr nz, .next

	ld a, [wCurOTMon]
	ld hl, wOTPartyMon1Level
	call AddNTimes
	ld a, [hl]
	cp e
	jr nc, .yes

.no ; unreferenced
	and a
	ret

.yes
	scf
	ret

AI_Items:
	dbw FULL_RESTORE, .FullRestore
	dbw MAX_POTION,   .MaxPotion
	dbw HYPER_POTION, .HyperPotion
	dbw SUPER_POTION, .SuperPotion
	dbw POTION,       .Potion
	dbw X_ACCURACY,   .XAccuracy
	dbw FULL_HEAL,    .FullHeal
	dbw GUARD_SPEC,   .GuardSpec
	dbw DIRE_HIT,     .DireHit
	dbw X_ATTACK,     .XAttack
	dbw X_DEFEND,     .XDefend
	dbw X_SPEED,      .XSpeed
	dbw X_SP_ATK,     .XSpecial
	dbw X_SP_DEF,     .XSpDef
	db -1 ; end

.FullHeal:
	call .Status
	jp c, .DontUse
	call EnemyUsedFullHeal
	jp .Use

.Status:
	ld a, [wEnemyMonStatus]
	and a
	jp z, .DontUse

	ld a, [bc]
	bit CONTEXT_USE_F, a
	jr nz, .StatusCheckContext
	ld a, [bc]
	bit ALWAYS_USE_F, a
	jp nz, .Use
	call Random
	cp 20 percent - 1
	jp c, .Use
	jp .DontUse

.StatusCheckContext:
	ld a, [wEnemyMonStatus]
	bit TOX, a
	jr z, .FailToxicCheck
	ld a, [wEnemyToxicCount]
	cp 4
	jr c, .FailToxicCheck
	call Random
	cp 50 percent + 1
	jp c, .Use
.FailToxicCheck:
	ld a, [wEnemyMonStatus]
	and 1 << FRZ | SLP
	jp z, .DontUse
	jp .Use

.FullRestore:
	call .HealItem
	jp nc, .UseFullRestore
	ld a, [bc]
	bit CONTEXT_USE_F, a
	jp z, .DontUse
	call .Status
	jp c, .DontUse

.UseFullRestore:
	call EnemyUsedFullRestore
	jp .Use

.MaxPotion:
	call .HealItem
	jp c, .DontUse
	call EnemyUsedMaxPotion
	jp .Use

.HealItem:
	ld a, [bc]
	bit CONTEXT_USE_F, a
	jr nz, .CheckHalfOrQuarterHP
	callfar AICheckEnemyHalfHP
	jp c, .DontUse
	ld a, [bc]
	bit UNKNOWN_USE_F, a
	jp nz, .CheckQuarterHP
	callfar AICheckEnemyQuarterHP
	jp nc, .UseHealItem
	call Random
	cp 50 percent + 1
	jp c, .UseHealItem
	jp .DontUse

.CheckQuarterHP:
	callfar AICheckEnemyQuarterHP
	jp c, .DontUse
	call Random
	cp 20 percent - 1
	jp c, .DontUse
	jr .UseHealItem

.CheckHalfOrQuarterHP:
	callfar AICheckEnemyHalfHP
	jp c, .DontUse
	callfar AICheckEnemyQuarterHP
	jp nc, .UseHealItem
	call Random
	cp 20 percent - 1
	jp nc, .DontUse

.UseHealItem:
	jp .Use

.HyperPotion:
	call .HealItem
	jp c, .DontUse
	ld b, 200
	call EnemyUsedHyperPotion
	jp .Use

.SuperPotion:
	call .HealItem
	jp c, .DontUse
	ld b, 50
	call EnemyUsedSuperPotion
	jp .Use

.Potion:
	call .HealItem
	jp c, .DontUse
	ld b, 20
	call EnemyUsedPotion
	jp .Use

; Everything up to "End unused" is unused

.UnusedHealItem: ; unreferenced
; This has similar conditions to .HealItem
	callfar AICheckEnemyMaxHP
	jr c, .dont_use
	push bc
	ld de, wEnemyMonMaxHP + 1
	ld hl, wEnemyMonHP + 1
	ld a, [de]
	sub [hl]
	jr z, .check_40_percent
	dec hl
	dec de
	ld c, a
	sbc [hl]
	and a
	jr nz, .check_40_percent
	ld a, c
	cp b
	jp c, .check_50_percent
	callfar AICheckEnemyQuarterHP
	jr c, .check_40_percent

.check_50_percent
	pop bc
	ld a, [bc]
	bit UNKNOWN_USE_F, a
	jp z, .Use
	call Random
	cp 50 percent + 1
	jp c, .Use

.dont_use
	jp .DontUse

.check_40_percent
	pop bc
	ld a, [bc]
	bit UNKNOWN_USE_F, a
	jp z, .DontUse
	call Random
	cp 39 percent + 1
	jp c, .Use
	jp .DontUse

; End unused

.XAccuracy:
	call .XItem
	jp c, .DontUse
	call EnemyUsedXAccuracy
	jp .Use

.GuardSpec:
	call .XItem
	jp c, .DontUse
	call EnemyUsedGuardSpec
	jp .Use

.DireHit:
	call .XItem
	jp c, .DontUse
	call EnemyUsedDireHit
	jp .Use

.XAttack:
	call .XItem
	jp c, .DontUse
	call EnemyUsedXAttack
	jp .Use

.XDefend:
	call .XItem
	jp c, .DontUse
	call EnemyUsedXDefend
	jp .Use

.XSpeed:
	call .XItem
	jp c, .DontUse
	call EnemyUsedXSpeed
	jp .Use

.XSpecial:
	call .XItem
	jp c, .DontUse
	call EnemyUsedXSpecial
	jp .Use
	
.XSpDef:
	call .XItem
	jp c, .DontUse
	call EnemyUsedXSpDef
	jp .Use

.XItem:
	ld a, [wEnemyTurnsTaken]
	and a
	jr nz, .notfirstturnout
	ld a, [bc]
	bit ALWAYS_USE_F, a
	jp nz, .Use
	call Random
	cp 50 percent + 1
	jp c, .DontUse
	ld a, [bc]
	bit CONTEXT_USE_F, a
	jp nz, .Use
	call Random
	cp 50 percent + 1
	jp c, .DontUse
	jp .Use
.notfirstturnout
	ld a, [bc]
	bit ALWAYS_USE_F, a
	jp z, .DontUse
	call Random
	cp 20 percent - 1
	jp nc, .DontUse
	jp .Use

.DontUse:
	scf
	ret

.Use:
	and a
	ret

AIUpdateHUD:
	call UpdateEnemyMonInParty
	farcall UpdateEnemyHUD
	ld a, $1
	ldh [hBGMapMode], a
	ld hl, wEnemyItemState
	dec [hl]
	scf
	ret

AIUsedItemSound:
	push de
	ld de, SFX_FULL_HEAL
	call PlaySFX
	pop de
	ret

EnemyUsedFullHeal:
	call AIUsedItemSound
	call AI_HealStatus
	ld a, FULL_HEAL
	ld [wCurEnemyItem], a
	xor a
	ld [wEnemyConfuseCount], a
	jp PrintText_UsedItemOn_AND_AIUpdateHUD

EnemyUsedMaxPotion:
	ld a, MAX_POTION
	ld [wCurEnemyItem], a
	jr FullRestoreContinue

EnemyUsedFullRestore:
	call AI_HealStatus
	ld a, FULL_RESTORE
	ld [wCurEnemyItem], a

FullRestoreContinue:
	ld de, wCurHPAnimOldHP
	ld hl, wEnemyMonHP + 1
	ld a, [hld]
	ld [de], a
	inc de
	ld a, [hl]
	ld [de], a
	inc de
	ld hl, wEnemyMonMaxHP + 1
	ld a, [hld]
	ld [de], a
	inc de
	ld [wCurHPAnimMaxHP], a
	ld [wEnemyMonHP + 1], a
	ld a, [hl]
	ld [de], a
	ld [wCurHPAnimMaxHP + 1], a
	ld [wEnemyMonHP], a
	jr EnemyPotionFinish

EnemyUsedPotion:
	ld a, POTION
	ld b, 20
	jr EnemyPotionContinue

EnemyUsedSuperPotion:
	ld a, SUPER_POTION
	ld b, 50
	jr EnemyPotionContinue

EnemyUsedHyperPotion:
	ld a, HYPER_POTION
	ld b, 200

EnemyPotionContinue:
	ld [wCurEnemyItem], a
	ld hl, wEnemyMonHP + 1
	ld a, [hl]
	ld [wCurHPAnimOldHP], a
	add b
	ld [hld], a
	ld [wCurHPAnimNewHP], a
	ld a, [hl]
	ld [wCurHPAnimOldHP + 1], a
	ld [wCurHPAnimNewHP + 1], a
	jr nc, .ok
	inc a
	ld [hl], a
	ld [wCurHPAnimNewHP + 1], a
.ok
	inc hl
	ld a, [hld]
	ld b, a
	ld de, wEnemyMonMaxHP + 1
	ld a, [de]
	dec de
	ld [wCurHPAnimMaxHP], a
	sub b
	ld a, [hli]
	ld b, a
	ld a, [de]
	ld [wCurHPAnimMaxHP + 1], a
	sbc b
	jr nc, EnemyPotionFinish
	inc de
	ld a, [de]
	dec de
	ld [hld], a
	ld [wCurHPAnimNewHP], a
	ld a, [de]
	ld [hl], a
	ld [wCurHPAnimNewHP + 1], a

EnemyPotionFinish:
	call PrintText_UsedItemOn
	hlcoord 2, 2
	xor a
	ld [wWhichHPBar], a
	call AIUsedItemSound
	predef AnimateHPBar
	jp AIUpdateHUD

AI_TrySwitch:
	ld a, [wEnemySwitchMonIndex]
	ld b, a
	ld a, [wCurOTMon]
	inc a
	cp b
	ret z
; Determine whether the AI can switch based on how many Pokemon are still alive.
; If it can switch, it will.
	ld a, [wOTPartyCount]
	ld c, a
	ld hl, wOTPartyMon1HP
	ld d, 0
.SwitchLoop:
	ld a, [hli]
	ld b, a
	ld a, [hld]
	or b
	jr z, .fainted
	inc d
.fainted
	push bc
	ld bc, PARTYMON_STRUCT_LENGTH
	add hl, bc
	pop bc
	dec c
	jr nz, .SwitchLoop

	ld a, d
	cp 2
	jp nc, AI_Switch
	ret

AI_Switch:
	ld a, $1
	ld [wEnemyIsSwitching], a
	ld [wEnemyGoesFirst], a
	ld hl, wEnemySubStatus4
	res SUBSTATUS_RAGE, [hl]
	xor a
	ldh [hBattleTurn], a
	ld [wCurDamage], a
	ld [wCurDamage + 1], a
	callfar PursuitSwitch

	push af
	ld a, [wCurOTMon]
	ld hl, wOTPartyMon1Status
	ld bc, PARTYMON_STRUCT_LENGTH
	call AddNTimes
	ld d, h
	ld e, l
	ld hl, wEnemyMonStatus
	ld bc, MON_MAXHP - MON_STATUS
	call CopyBytes
	pop af

	jr c, .skiptext
	ld hl, EnemyWithdrewText
	call PrintText

.skiptext
	farcall NewEnemyMonStatus
	farcall ResetEnemyStatLevels
	ld hl, wPlayerSubStatus1
	res SUBSTATUS_IN_LOVE, [hl]
	farcall EnemySwitch
	farcall ResetBattleParticipants
	ld a, [wLinkMode]
	and a
	ret nz
	scf
	ret

EnemyWithdrewText:
	text_far _EnemyWithdrewText
	text_end

EnemyUsedFullHealRed: ; unreferenced
	call AIUsedItemSound
	call AI_HealStatus
	ld a, FULL_HEAL_RED ; X_SPEED
	jp PrintText_UsedItemOn_AND_AIUpdateHUD

AI_HealStatus:
	ld a, [wCurOTMon]
	ld hl, wOTPartyMon1Status
	ld bc, PARTYMON_STRUCT_LENGTH
	call AddNTimes
	xor a
	ld [hl], a
	ld [wEnemyMonStatus], a
	ld [wEnemyConfuseCount], a
	ld hl, wEnemySubStatus1
	res SUBSTATUS_NIGHTMARE, [hl]
	ld hl, wEnemySubStatus3
	res SUBSTATUS_CONFUSED, [hl]
	ret

EnemyUsedGuardSpec:
	call AIUsedItemSound
	ld hl, wEnemySubStatus4
	set SUBSTATUS_MIST, [hl]
	ld a, GUARD_SPEC
	jp PrintText_UsedItemOn_AND_AIUpdateHUD

EnemyUsedDireHit:
	call AIUsedItemSound
	ld hl, wEnemySubStatus4
	set SUBSTATUS_FOCUS_ENERGY, [hl]
	ld a, DIRE_HIT
	jp PrintText_UsedItemOn_AND_AIUpdateHUD

AICheckEnemyFractionMaxHP: ; unreferenced
; Input: a = divisor
; Work: bc = [wEnemyMonMaxHP] / a
; Work: de = [wEnemyMonHP]
; Output:
; -  c, nz if [wEnemyMonHP] > [wEnemyMonMaxHP] / a
; - nc,  z if [wEnemyMonHP] = [wEnemyMonMaxHP] / a
; - nc, nz if [wEnemyMonHP] < [wEnemyMonMaxHP] / a
	ldh [hDivisor], a
	ld hl, wEnemyMonMaxHP
	ld a, [hli]
	ldh [hDividend], a
	ld a, [hl]
	ldh [hDividend + 1], a
	ld b, 2
	call Divide
	ldh a, [hQuotient + 3]
	ld c, a
	ldh a, [hQuotient + 2]
	ld b, a
	ld hl, wEnemyMonHP + 1
	ld a, [hld]
	ld e, a
	ld a, [hl]
	ld d, a
	ld a, d
	sub b
	ret nz
	ld a, e
	sub c
	ret

EnemyUsedXAttack:
	ld b, ATTACK
	ld a, X_ATTACK
	jr EnemyUsedXItem

EnemyUsedXDefend:
	ld b, DEFENSE
	ld a, X_DEFEND
	jr EnemyUsedXItem

EnemyUsedXSpeed:
	ld b, SPEED
	ld a, X_SPEED
	jr EnemyUsedXItem

EnemyUsedXAccuracy:
	ld b, ACCURACY
	ld a, X_ACCURACY
	jr EnemyUsedXItem

EnemyUsedXSpDef:
	ld b, SP_DEFENSE
	ld a, X_SP_DEF
	jr EnemyUsedXItem

EnemyUsedXSpecial:
	ld b, SP_ATTACK
	ld a, X_SP_ATK

; Parameter
; a = ITEM_CONSTANT
; b = BATTLE_CONSTANT (ATTACK, DEFENSE, SPEED, SP_ATTACK, SP_DEFENSE, ACCURACY, EVASION)
EnemyUsedXItem:
	ld [wCurEnemyItem], a
	push bc
	call PrintText_UsedItemOn
	pop bc
	farcall RaiseStat
	jp AIUpdateHUD

; Parameter
; a = ITEM_CONSTANT
PrintText_UsedItemOn_AND_AIUpdateHUD:
	ld [wCurEnemyItem], a
	call PrintText_UsedItemOn
	jp AIUpdateHUD

PrintText_UsedItemOn:
	ld a, [wCurEnemyItem]
	ld [wNamedObjectIndex], a
	call GetItemName
	ld hl, wStringBuffer1
	ld de, wMonOrItemNameBuffer
	ld bc, ITEM_NAME_LENGTH
	call CopyBytes
	ld hl, EnemyUsedOnText
	jp PrintText

EnemyUsedOnText:
	text_far _EnemyUsedOnText
	text_end
