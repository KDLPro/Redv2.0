AIScoring: ; used only for BANK(AIScoring)


AI_Basic:
; Don't do anything redundant:
;  -Using status-only moves if the player can't be statused
;  -Using moves that fail if they've already been used

	ld hl, wEnemyAIMoveScores - 1
	ld de, wEnemyMonMoves
	ld b, NUM_MOVES + 1
.checkmove
	dec b
	ret z

	inc hl
	ld a, [de]
	and a
	ret z

	inc de
	call AIGetEnemyMove

	ld a, [wEnemyMoveStruct + MOVE_EFFECT]
	ld c, a

; Dismiss moves with special effects if they are
; useless or not a good choice right now.
; For example, healing moves, weather moves, Dream Eater...
	push hl
	push de
	push bc
	farcall AI_Redundant
	pop bc
	pop de
	pop hl
	jr nz, .discourage

; Dismiss status-only moves if the player can't be statused.
	ld a, [wEnemyMoveStruct + MOVE_EFFECT]
	push hl
	push de
	push bc
	ld hl, StatusOnlyEffects
	call IsInByteArray

	pop bc
	pop de
	pop hl
	jr nc, .checkmove

	ld a, [wBattleMonStatus]
	and a
	jr nz, .discourage

; Dismiss Safeguard if it's already active.
	ld a, [wPlayerScreens]
	bit SCREENS_SAFEGUARD, a
	jr z, .checkmove

.discourage
	call AIDiscourageMove
	jr .checkmove

INCLUDE "data/battle/ai/status_only_effects.asm"


AI_Setup:
; Use stat-modifying moves on turn 1.

; 50% chance to greatly encourage stat-up moves during the first turn of enemy's Pokemon.
; 50% chance to greatly encourage stat-down moves during the first turn of player's Pokemon.
; Almost 90% chance to greatly discourage stat-modifying moves otherwise.

	ld hl, wEnemyAIMoveScores - 1
	ld de, wEnemyMonMoves
	ld b, NUM_MOVES + 1
.checkmove
	dec b
	ret z

	inc hl
	ld a, [de]
	and a
	ret z

	inc de
	call AIGetEnemyMove

	ld a, [wEnemyMoveStruct + MOVE_EFFECT]

	cp EFFECT_ATTACK_UP
	jr c, .checkmove
	cp EFFECT_EVASION_UP + 1
	jr c, .statup

	cp EFFECT_ATTACK_DOWN - 1
	jr z, .checkmove
	cp EFFECT_EVASION_DOWN + 1
	jr c, .statdown

	cp EFFECT_ATTACK_UP_2
	jr c, .checkmove
	cp EFFECT_EVASION_UP_2 + 1
	jr c, .statup

	cp EFFECT_ATTACK_DOWN_2 - 1
	jr z, .checkmove
	cp EFFECT_EVASION_DOWN_2 + 1
	jr c, .statdown

	jr .checkmove

.statup
	ld a, [wEnemyTurnsTaken]
	and a
	jr nz, .discourage

	jr .encourage

.statdown
	ld a, [wPlayerTurnsTaken]
	and a
	jr nz, .discourage

.encourage
	call AI_50_50
	jr c, .checkmove

	dec [hl]
	dec [hl]
	jr .checkmove

.discourage
	call Random
	cp 12 percent
	jr c, .checkmove
	inc [hl]
	inc [hl]
	jr .checkmove


AI_Types:
; Don't do this if player is switching.
	ld a, [wPlayerIsSwitching]
	and a
	ret nz
; Dismiss any move that the player is immune to.
; Encourage super-effective moves.
; Discourage not very effective moves unless
; all damaging moves are of the same type.

	ld hl, wEnemyAIMoveScores - 1
	ld de, wEnemyMonMoves
	ld b, NUM_MOVES + 1
.checkmove
	dec b
	ret z

	inc hl
	ld a, [de]
	and a
	ret z

	inc de
	call AIGetEnemyMove

	push hl
	push bc
	push de
	ld a, 1
	ldh [hBattleTurn], a
	farcall BattleCheckTypeMatchup
	pop de
	pop bc
	pop hl

	ld a, [wTypeMatchup]
	and a
	jr z, .immune
	cp EFFECTIVE
	jr z, .checkmove
	jr c, .noteffective

; effective
	ld a, [wEnemyMoveStruct + MOVE_POWER]
	and a
	jr z, .checkmove
	dec [hl]
	jr .checkmove

.noteffective
; Discourage this move if there are any moves
; that do damage of a different type.
	push hl
	push de
	push bc
	ld a, [wEnemyMoveStruct + MOVE_TYPE]
	and TYPE_MASK
	ld d, a
	ld hl, wEnemyMonMoves
	ld b, NUM_MOVES + 1
	ld c, 0
.checkmove2
	dec b
	jr z, .movesdone

	ld a, [hli]
	and a
	jr z, .movesdone

	call AIGetEnemyMove
	ld a, [wEnemyMoveStruct + MOVE_TYPE]
	and TYPE_MASK
	cp d
	jr z, .checkmove2
	ld a, [wEnemyMoveStruct + MOVE_POWER]
	and a
	jr nz, .damaging
	jr .checkmove2

.damaging
	ld c, a
.movesdone
	ld a, c
	pop bc
	pop de
	pop hl
	and a
	jr z, .checkmove
	inc [hl]
	jr .checkmove

.immune
	call AIDiscourageMove
	jr .checkmove
	

AI_Offensive:
; Don't do this if player is switching.
	ld a, [wPlayerIsSwitching]
	and a
	ret nz
; Greatly discourage non-damaging moves.

	ld hl, wEnemyAIMoveScores - 1
	ld de, wEnemyMonMoves
	ld b, NUM_MOVES + 1
.checkmove
	dec b
	ret z

	inc hl
	ld a, [de]
	and a
	ret z

	inc de
	call AIGetEnemyMove

	ld a, [wEnemyMoveStruct + MOVE_POWER]
	and a
	jr nz, .checkmove

	inc [hl]
	inc [hl]
	jr .checkmove


AI_Smart:
; Context-specific scoring.

	ld hl, wEnemyAIMoveScores
	ld de, wEnemyMonMoves
	ld b, NUM_MOVES + 1
.checkmove
	dec b
	ret z

	ld a, [de]
	inc de
	and a
	ret z

	push de
	push bc
	push hl
	call AIGetEnemyMove

	ld a, [wEnemyMoveStruct + MOVE_EFFECT]
	ld hl, AI_Smart_EffectHandlers
	ld de, 3
	call IsInArray

	inc hl
	jr nc, .nextmove

	ld a, [hli]
	ld e, a
	ld d, [hl]

	pop hl
	push hl

	ld bc, .nextmove
	push bc

	push de
	ret

.nextmove
	pop hl
	pop bc
	pop de
	inc hl
	jr .checkmove

AI_Smart_EffectHandlers:
	dbw EFFECT_SLEEP,            AI_Smart_Sleep
	dbw EFFECT_LEECH_HIT,        AI_Smart_LeechHit
	dbw EFFECT_SELFDESTRUCT,     AI_Smart_Selfdestruct
	dbw EFFECT_DREAM_EATER,      AI_Smart_DreamEater
	dbw EFFECT_MIRROR_MOVE,      AI_Smart_MirrorMove
	dbw EFFECT_EVASION_UP,       AI_Smart_EvasionUp
	dbw EFFECT_ALWAYS_HIT,       AI_Smart_AlwaysHit
	dbw EFFECT_ACCURACY_DOWN,    AI_Smart_AccuracyDown
	dbw EFFECT_RESET_STATS,      AI_Smart_ResetStats
	dbw EFFECT_FORCE_SWITCH,     AI_Smart_ForceSwitch
	dbw EFFECT_HEAL,             AI_Smart_Heal
	dbw EFFECT_TOXIC,            AI_Smart_Toxic
	dbw EFFECT_LIGHT_SCREEN,     AI_Smart_LightScreen
	dbw EFFECT_OHKO,             AI_Smart_Ohko
	dbw EFFECT_SUPER_FANG,       AI_Smart_SuperFang
	dbw EFFECT_TRAP_TARGET,      AI_Smart_TrapTarget
	dbw EFFECT_PRIORITY_HIT,     AI_Smart_PriorityHit
	dbw EFFECT_CONFUSE,          AI_Smart_Confuse
	dbw EFFECT_SP_DEF_UP_2,      AI_Smart_SpDefenseUp2
	dbw EFFECT_REFLECT,          AI_Smart_Reflect
	dbw EFFECT_PARALYZE,         AI_Smart_Paralyze
	dbw EFFECT_SPEED_DOWN_HIT,   AI_Smart_SpeedDownHit
	dbw EFFECT_SUBSTITUTE,       AI_Smart_Substitute
	dbw EFFECT_HYPER_BEAM,       AI_Smart_HyperBeam
	dbw EFFECT_MIMIC,            AI_Smart_Mimic
	dbw EFFECT_LEECH_SEED,       AI_Smart_LeechSeed
	dbw EFFECT_DISABLE,          AI_Smart_Disable
	dbw EFFECT_COUNTER,          AI_Smart_Counter
	dbw EFFECT_ENCORE,           AI_Smart_Encore
	dbw EFFECT_PAIN_SPLIT,       AI_Smart_PainSplit
	dbw EFFECT_SNORE,            AI_Smart_Snore
	dbw EFFECT_CONVERSION2,      AI_Smart_Conversion2
	dbw EFFECT_LOCK_ON,          AI_Smart_LockOn
	dbw EFFECT_SLEEP_TALK,       AI_Smart_SleepTalk
	dbw EFFECT_DESTINY_BOND,     AI_Smart_DestinyBond
	dbw EFFECT_REVERSAL,         AI_Smart_Reversal
	dbw EFFECT_HEAL_BELL,        AI_Smart_HealBell
	dbw EFFECT_THIEF,            AI_Smart_Thief
	dbw EFFECT_MEAN_LOOK,        AI_Smart_MeanLook
	dbw EFFECT_NIGHTMARE,        AI_Smart_Nightmare
	dbw EFFECT_FLAME_WHEEL,      AI_Smart_FlameWheel
	dbw EFFECT_CURSE,            AI_Smart_Curse
	dbw EFFECT_PROTECT,          AI_Smart_Protect
	dbw EFFECT_FORESIGHT,        AI_Smart_Foresight
	dbw EFFECT_PERISH_SONG,      AI_Smart_PerishSong
	dbw EFFECT_SANDSTORM,        AI_Smart_Sandstorm
	dbw EFFECT_ENDURE,           AI_Smart_Endure
	dbw EFFECT_ROLLOUT,          AI_Smart_Rollout
	dbw EFFECT_SWAGGER,          AI_Smart_Swagger
	dbw EFFECT_FURY_CUTTER,      AI_Smart_FuryCutter
	dbw EFFECT_ATTRACT,          AI_Smart_Attract
	dbw EFFECT_SAFEGUARD,        AI_Smart_Safeguard
	dbw EFFECT_MAGNITUDE,        AI_Smart_Magnitude
	dbw EFFECT_BATON_PASS,       AI_Smart_BatonPass
	dbw EFFECT_PURSUIT,          AI_Smart_Pursuit
	dbw EFFECT_RAPID_SPIN,       AI_Smart_RapidSpin
	dbw EFFECT_MORNING_SUN,      AI_Smart_MorningSun
	dbw EFFECT_SYNTHESIS,        AI_Smart_Synthesis
	dbw EFFECT_MOONLIGHT,        AI_Smart_Moonlight
	dbw EFFECT_RAIN_DANCE,       AI_Smart_RainDance
	dbw EFFECT_SUNNY_DAY,        AI_Smart_SunnyDay
	dbw EFFECT_BELLY_DRUM,       AI_Smart_BellyDrum
	dbw EFFECT_MIRROR_COAT,      AI_Smart_MirrorCoat
	dbw EFFECT_SKULL_BASH,       AI_Smart_SkullBash
	dbw EFFECT_TWISTER,          AI_Smart_Twister
	dbw EFFECT_EARTHQUAKE,       AI_Smart_Earthquake
	dbw EFFECT_FUTURE_SIGHT,     AI_Smart_FutureSight
	dbw EFFECT_GUST,             AI_Smart_Gust
	dbw EFFECT_STOMP,            AI_Smart_Stomp
	dbw EFFECT_SOLARBEAM,        AI_Smart_Solarbeam
	dbw EFFECT_THUNDER,          AI_Smart_Thunder
	dbw EFFECT_FLY,              AI_Smart_Fly
	dbw EFFECT_FLINCH_HIT,       AI_Smart_Flinch
	dbw EFFECT_RETURN,           AI_Smart_Return
	dbw EFFECT_FRUSTRATION,      AI_Smart_Frustration
	dbw EFFECT_ACID,             AI_Smart_Acid
	db -1 ; end

AI_Smart_Sleep:
; Greatly encourage sleep inducing moves if the enemy has either Dream Eater or Nightmare,
; or if the enemy has bad matchup.
; Greatly discourage sleep inducing moves if player has low HP or if the enemy doesn't have Nightmare.
; 50% chance to greatly encourage sleep inducing moves otherwise.

	ld b, EFFECT_DREAM_EATER
	call AIHasMoveEffect
	jr c, .encourage
	
	push hl
	farcall CheckPlayerMoveTypeMatchups
	pop hl
	ld a, [wEnemyAISwitchScore]
	cp BASE_AI_SWITCH_SCORE
	jr nc, .lowhp_check
	
	push hl
	farcall CheckOnlyEnemyMoveMatchups
	pop hl
	ld a, [wEnemyAISwitchScore]
	cp BASE_AI_SWITCH_SCORE - 1
	jr c, .encourage
	
	call AI_80_20
	jr nc, .encourage
	
.lowhp_check
	call AICheckPlayerQuarterHP
	jr nc, .discourage
	
	ld b, EFFECT_NIGHTMARE
	call AIHasMoveEffect
	jr nc, .discourage
	jr .encourage

.encourage
	call AI_50_50
	ret c
	jp AI_Encourage_Greatly
	
.discourage
	jp AI_Discourage_Greatly

AI_Smart_LeechHit:
    push hl
    ld a, 1
    ldh [hBattleTurn], a
    farcall BattleCheckTypeMatchup
    pop hl

; 60% chance to discourage this move if not very effective.
    ld a, [wTypeMatchup]
    cp EFFECTIVE
    jr c, .discourage

; Check for STAB if neutral
    jr z, .neutral

.checkhp
; Do nothing if enemy's HP is full and if the enemy is faster than player.
    call AICheckEnemyMaxHP
    jr nc, .encourage
	call AICompareSpeed
	ret c

.encourage
; 60% chance to encourage this move otherwise.
    call AI_60_40
    ret c

    jp AI_Encourage

.discourage
    call AI_60_40
    ret nc

    jp AI_Discourage
	
.neutral
; Encourage this move if it deals STAB damage.
	ld a, [wEnemyMoveStruct + MOVE_TYPE]
    and TYPE_MASK       
	ld b, a
	ld a, [wEnemyMonType1]
	cp b
	jr z, .encourage

	ld a, [wEnemyMonType2]
	cp b
	jr z, .encourage
	jr .checkhp

AI_Smart_LockOn:
	ld a, [wPlayerSubStatus5]
	bit SUBSTATUS_LOCK_ON, a
	jr nz, .player_locked_on

	push hl
	call AICheckEnemyQuarterHP
	jr nc, .discourage

	call AICheckEnemyHalfHP
	jr c, .skip_speed_check

	call AICompareSpeed
	jr nc, .discourage

.skip_speed_check
	ld a, [wPlayerEvaLevel]
	cp BASE_STAT_LEVEL + 3
	jr nc, .maybe_encourage
	cp BASE_STAT_LEVEL + 1
	jr nc, .do_nothing

	ld a, [wEnemyAccLevel]
	cp BASE_STAT_LEVEL - 2
	jr c, .maybe_encourage
	cp BASE_STAT_LEVEL
	jr c, .do_nothing

	ld hl, wEnemyMonMoves
	ld c, NUM_MOVES + 1
.checkmove
	dec c
	jr z, .discourage

	ld a, [hli]
	and a
	jr z, .discourage

	call AIGetEnemyMove

	ld a, [wEnemyMoveStruct + MOVE_ACC]
	cp 71 percent - 1
	jr nc, .checkmove

	ld a, 1
	ldh [hBattleTurn], a

	push hl
	push bc
	farcall BattleCheckTypeMatchup
	ld a, [wTypeMatchup]
	cp EFFECTIVE
	pop bc
	pop hl
	jr c, .checkmove

.do_nothing
	pop hl
	ret

.discourage
	pop hl
	jp AI_Discourage

.maybe_encourage
	pop hl
	call AI_50_50
	ret c

	jp AI_Encourage_Greatly

.player_locked_on
	push hl
	ld hl, wEnemyAIMoveScores - 1
	ld de, wEnemyMonMoves
	ld c, NUM_MOVES + 1

.checkmove2
	inc hl
	dec c
	jr z, .dismiss

	ld a, [de]
	and a
	jr z, .dismiss

	inc de
	call AIGetEnemyMove

	ld a, [wEnemyMoveStruct + MOVE_ACC]
	cp 71 percent - 1
	jr nc, .checkmove2

	call AI_Encourage_Greatly
	jr .checkmove2

.dismiss
	pop hl
	jp AIDiscourageMove

AI_Smart_Selfdestruct:
; Unless this is the enemy's last Pokemon...
	push hl
	farcall FindAliveEnemyMons
	pop hl
	jr nc, .notlastmon

; ...greatly discourage this move unless this is the player's last Pokemon too.
	push hl
	call AICheckLastPlayerMon
	pop hl
	jr nz, .discourage

.notlastmon
; Greatly discourage this move if there's another move that can kill.
	ld a, [wMovesThatOHKOPlayer]
	and a
	jr nz, .discourage
	
; 90% chance to greatly discourage this move if enemy's HP is full.
	call AICheckEnemyMaxHP
	jr nc, .check_type
	
	call Random
	cp 90 percent + 1
	jr c, .greatly_discourage
	jr .may_encourage
	
.check_type
; 75% chance to greatly discourage this move if enemy's HP is above 50% but is not full.
	call AICheckEnemyHalfHP
	ret nc
	
	call Random
	cp 75 percent + 1
	jr c, .greatly_discourage

.may_encourage
; May greatly discourage if enemy is a Ghost-type.

	ld a, [wBattleMonType1]
	cp GHOST
	jr z, .random_greatly_discourage
	ld a, [wBattleMonType2]
	cp GHOST
	jr z, .random_greatly_discourage
	
; May discourage if enemy is Rock- or Steel-type.
	ld a, [wBattleMonType1]
	cp ROCK
	jr z, .random_discourage
	ld a, [wBattleMonType2]
	cp ROCK
	jr z, .random_discourage
	ld a, [wBattleMonType1]
	cp STEEL
	jr z, .random_discourage
	ld a, [wBattleMonType2]
	cp STEEL
	jr z, .random_discourage

.greatly_encourage
; Greatly encourage otherwise.
	jp AI_Encourage_Greatly

.greatly_discourage
	call AI_Discourage_Greatly
.discourage
	jp AI_Discourage
	
.random_greatly_discourage
	call AI_50_50
	ret c
	call AI_50_50
	jr c, .greatly_encourage
	jr .greatly_discourage

.random_discourage
	call AI_50_50
	ret c
	call AI_50_50
	jr c, .greatly_encourage
	jr .discourage

AI_Smart_DreamEater:
; 90% chance to greatly encourage this move.
; The AI_Basic layer will make sure that
; Dream Eater is only used against sleeping targets.
	call Random
	cp 10 percent
	ret c
	call AI_Encourage_Greatly
	jp AI_Encourage

AI_Smart_EvasionUp:
; Dismiss this move if enemy's evasion can't raise anymore.
	ld a, [wEnemyEvaLevel]
	cp MAX_STAT_LEVEL
	jp nc, AIDiscourageMove

; If enemy's HP is full...
	call AICheckEnemyMaxHP
	jr nc, .hp_mismatch_1

; ...greatly encourage this move if player is badly poisoned.
	ld a, [wBattleMonStatus]
	bit TOX, a
	jr nz, .greatly_encourage

; ...70% chance to greatly encourage this move if player is not badly poisoned.
	call Random
	cp 70 percent
	jr nc, .not_encouraged

.greatly_encourage
	jp AI_Encourage_Greatly

.hp_mismatch_1

; Greatly discourage this move if enemy's HP is below 25%.
	call AICheckEnemyQuarterHP
	jr nc, .hp_mismatch_2

; If enemy's HP is above 25% but not full, 4% chance to greatly encourage this move.
	call Random
	cp 4 percent
	jr c, .greatly_encourage

; If enemy's HP is between 25% and 50%,...
	call AICheckEnemyHalfHP
	jr nc, .hp_mismatch_3

; If enemy's HP is above 50% but not full, 20% chance to greatly encourage this move.
	call AI_80_20
	jr c, .greatly_encourage
	jr .not_encouraged

.hp_mismatch_3
; ...50% chance to greatly discourage this move.
	call AI_50_50
	jr c, .not_encouraged

.hp_mismatch_2
	inc [hl]
	inc [hl]

; 30% chance to end up here if enemy's HP is full and player is not badly poisoned.
; 77% chance to end up here if enemy's HP is above 50% but not full.
; 96% chance to end up here if enemy's HP is between 25% and 50%.
; 100% chance to end up here if enemy's HP is below 25%.
; In other words, we only end up here if the move has not been encouraged or dismissed.
.not_encouraged
	ld a, [wBattleMonStatus]
	bit TOX, a
	jr nz, .maybe_greatly_encourage

	ld a, [wPlayerSubStatus4]
	bit SUBSTATUS_LEECH_SEED, a
	jr nz, .maybe_encourage

; Discourage this move if enemy's evasion level is higher than player's accuracy level.
	ld a, [wEnemyEvaLevel]
	ld b, a
	ld a, [wPlayerAccLevel]
	cp b
	jr c, .discourage

; Greatly encourage this move if the player is in the middle of Fury Cutter or Rollout.
	ld a, [wPlayerFuryCutterCount]
	and a
	jr nz, .greatly_encourage

	ld a, [wPlayerSubStatus1]
	bit SUBSTATUS_ROLLOUT, a
	jr nz, .greatly_encourage

.discourage
	jp AI_Discourage

; Player is badly poisoned.
; 70% chance to greatly encourage this move.
; This would counter any previous discouragement.
.maybe_greatly_encourage
	call Random
	cp 31 percent + 1
	ret c

	jp AI_Encourage_Greatly

; Player is seeded.
; 50% chance to encourage this move.
; This would partly counter any previous discouragement.
.maybe_encourage
	call AI_50_50
	ret c

	jp AI_Encourage

AI_Smart_AlwaysHit:
; 80% chance to greatly encourage this move if either...

; ...enemy's accuracy level has been lowered three or more stages
	ld a, [wEnemyAccLevel]
	cp BASE_STAT_LEVEL - 2
	jr c, .encourage

; ...or player's evasion level has been raised three or more stages.
	ld a, [wPlayerEvaLevel]
	cp BASE_STAT_LEVEL + 3
	ret c

.encourage
	call AI_80_20
	ret c

	jp AI_Encourage_Greatly

AI_Smart_MirrorMove:
; If the player did not use any move last turn...
	ld a, [wLastPlayerCounterMove]
	and a
	jr nz, .usedmove

; ...do nothing if enemy is slower than player
	call AICompareSpeed
	ret nc

; ...or dismiss this move if enemy is faster than player.
	jp AIDiscourageMove

; If the player did use a move last turn...
.usedmove
	push hl
	ld hl, UsefulMoves
	ld de, 1
	call IsInArray
	pop hl

; ...do nothing if he didn't use a useful move.
	ret nc

; If he did, 50% chance to encourage this move...
	call AI_50_50
	ret c

	dec [hl]

; ...and 90% chance to encourage this move again if the enemy is faster.
	call AICompareSpeed
	ret nc

	call Random
	cp 10 percent
	ret c

	dec [hl]
	ret

AI_Smart_AccuracyDown:
; If player's HP is full...
	call AICheckPlayerMaxHP
	jr nc, .hp_mismatch_1

; ...and enemy's HP is above 50%...
	call AICheckEnemyHalfHP
	jr nc, .hp_mismatch_1

; ...greatly encourage this move if player is badly poisoned.
	ld a, [wBattleMonStatus]
	bit TOX, a
	jr nz, .greatly_encourage

; ...70% chance to greatly encourage this move if player is not badly poisoned.
	call Random
	cp 70 percent
	jr nc, .not_encouraged

.greatly_encourage
	dec [hl]
	dec [hl]
	ret

.hp_mismatch_1

; Greatly discourage this move if player's HP is below 25%.
	call AICheckPlayerQuarterHP
	jr nc, .hp_mismatch_2

; If player's HP is above 25% but not full, 4% chance to greatly encourage this move.
	call Random
	cp 4 percent
	jr c, .greatly_encourage

; If player's HP is between 25% and 50%,...
	call AICheckPlayerHalfHP
	jr nc, .hp_mismatch_3

; If player's HP is above 50% but not full, 20% chance to greatly encourage this move.
	call AI_80_20
	jr c, .greatly_encourage
	jr .not_encouraged

; ...50% chance to greatly discourage this move.
.hp_mismatch_3
	call AI_50_50
	jr c, .not_encouraged

.hp_mismatch_2
	inc [hl]
	inc [hl]

; We only end up here if the move has not been already encouraged.
.not_encouraged
	ld a, [wBattleMonStatus]
	bit TOX, a
	jr nz, .maybe_greatly_encourage

	ld a, [wPlayerSubStatus4]
	bit SUBSTATUS_LEECH_SEED, a
	jr nz, .encourage

; Discourage this move if enemy's evasion level is higher than player's accuracy level.
	ld a, [wEnemyEvaLevel]
	ld b, a
	ld a, [wPlayerAccLevel]
	cp b
	jr c, .discourage

; Greatly encourage this move if the player is in the middle of Fury Cutter or Rollout.
	ld a, [wPlayerFuryCutterCount]
	and a
	jr nz, .greatly_encourage

	ld a, [wPlayerSubStatus1]
	bit SUBSTATUS_ROLLOUT, a
	jr nz, .greatly_encourage

.discourage
	jp AI_Discourage

; Player is badly poisoned.
; 70% chance to greatly encourage this move.
; This would counter any previous discouragement.
.maybe_greatly_encourage
	call Random
	cp 31 percent + 1
	ret c

	jp AI_Encourage_Greatly

; Player is seeded.
; 50% chance to encourage this move.
; This would partly counter any previous discouragement.
.encourage
	call AI_50_50
	ret c

	jp AI_Encourage

AI_Smart_ResetStats:
; 85% chance to encourage this move if any of enemy's stat levels is lower than -2.
	push hl
	ld hl, wEnemyAtkLevel
	ld c, NUM_LEVEL_STATS
.enemystatsloop
	dec c
	jr z, .enemystatsdone
	ld a, [hli]
	cp BASE_STAT_LEVEL - 2
	jr c, .encourage
	jr .enemystatsloop

; 85% chance to encourage this move if any of player's stat levels is higher than +2.
.enemystatsdone
	ld hl, wPlayerAtkLevel
	ld c, NUM_LEVEL_STATS
.playerstatsloop
	dec c
	jr z, .discourage
	ld a, [hli]
	cp BASE_STAT_LEVEL + 3
	jr c, .playerstatsloop

.encourage
	pop hl
	call Random
	cp 16 percent
	ret c
	jp AI_Encourage

; Discourage this move if neither:
; Any of enemy's stat levels is	lower than -2.
; Any of player's stat levels is higher than +2.
.discourage
	pop hl
	jp AI_Discourage

AI_Smart_ForceSwitch:
; Whirlwind, Roar.

; 80% chance to greatly encourage this move if player has 
; more than 2 stat boosts.

	push hl
	farcall CheckPlayerStatBoosts
	pop hl
	ld a, b
	cp 2
	jr nc, .encourage

; Discourage this move if the player has not shown
; a super-effective move against the enemy.
; Consider player's type(s) if its moves are unknown.

	push hl
	farcall CheckPlayerMoveTypeMatchups
	ld a, [wEnemyAISwitchScore]
	cp BASE_AI_SWITCH_SCORE
	pop hl
	ret c
	inc [hl]
	ret
	
; TO-DO: Encourage this move if there are spikes/rocks
; and you have bad matchup against opponent and discourage
; otherwise.

.encourage
    call AI_80_20
    ret c

    jp AI_Encourage_Greatly

AI_Smart_MorningSun:
AI_Smart_Synthesis:
AI_Smart_Moonlight:
; 80% to greatly discourage this move if weather is raining, sandstorm, (and hail, to be added).
	ld a, [wBattleWeather]
	cp WEATHER_RAIN
	jp z, AI_Discourage_Greatly
	cp WEATHER_SANDSTORM
	jp z, AI_Discourage_Greatly
	cp WEATHER_SUN
	jr nz, AI_Smart_Heal
	
	call AI_Encourage_Greatly

; Discourage this move if damage taken in the last turn was greater
; than the amount of HP healed.
	
	ld a, 1
	ldh [hBattleTurn], a
	
	push bc
	ld a, [wHPBuffer1]
	ld b, a
	ld a, [wHPBuffer1 + 1]
	ld c, a
	push bc
	push de
	push hl
	farcall GetHalfMaxHP
	ld d, b
	ld e, c
	ld b, c
	ld a, [wEnemyDamageTakenThisTurn + 1]
	cp b
	ld b, d
	ld a, [wEnemyDamageTakenThisTurn]
	sbc b
	pop hl
	pop de
	pop bc
	ld a, c
	ld [wHPBuffer1 + 1], a
	ld a, b
	ld [wHPBuffer1], a
	pop bc
	jp nc, AI_Discourage
	
AI_Smart_Heal:
; 80% chance to greatly encourage this move if enemy's HP is below 25%.
; 50% chance to encourage this move if enemy's HP is between 25% and 50%.
; Discourage this move if damage taken in the last turn was greater
; than the amount of HP healed.
; Discourage otherwise.

	ld a, [wEnemyMoveStruct]
	cp REST
	jr z, .rest

	ld a, 1
	ldh [hBattleTurn], a
	
	push bc
	ld a, [wHPBuffer1]
	ld b, a
	ld a, [wHPBuffer1 + 1]
	ld c, a
	push bc
	push de
	push hl
	farcall GetHalfMaxHP
	ld d, b
	ld e, c
	ld b, c
	ld a, [wEnemyDamageTakenThisTurn + 1]
	cp b
	ld b, d
	ld a, [wEnemyDamageTakenThisTurn]
	sbc b
	pop hl
	pop de
	pop bc
	ld a, c
	ld [wHPBuffer1 + 1], a
	ld a, b
	ld [wHPBuffer1], a
	pop bc
	jp nc, AI_Discourage

.check_hp
	call AICheckEnemyQuarterHP
	jr nc, .encourage
	call AICheckEnemyHalfHP
	jr nc, .low_hp
	call AI_Discourage
	call AI_60_40
	ret nc
	jp AI_Discourage_Greatly
	
.rest
	push hl
	farcall CheckPlayerMoveTypeMatchups
	pop hl
	ld a, [wEnemyAISwitchScore]
	cp BASE_AI_SWITCH_SCORE - 1
	jr nc, .check_hp
	jp AI_Discourage_Greatly

.low_hp
	call AI_50_50
	ret c
	jp AI_Encourage
	
.very_low_hp
	call AI_60_40
	ret c
.encourage
	jp AI_Encourage_Greatly

AI_Smart_Toxic:
AI_Smart_LeechSeed:
; Encourage this move if enemy can't kill player easily with its moves.

	push hl
	farcall CheckOnlyEnemyMoveMatchups
	pop hl 
	ld a, [wEnemyAISwitchScore]
	cp BASE_AI_SWITCH_SCORE
	jp c, AI_Encourage_Greatly

; Discourage this move if player's HP is below 50%.

	call AICheckPlayerHalfHP
	ret c
	jp AI_Discourage

AI_Smart_LightScreen:
; Check if enemy is slower than player.
	call AICompareSpeed
	jr nc, .slower

; Greatly encourage this move if enemy's HP is greater than 50%,
; enemy's Sp. Def < Def, and enemy is faster than player.

    call AICheckEnemyHalfHP
    ret nc
    ld a, [wEnemyDefense]
    ld b, a
    ld a, [wEnemySpDef]
    cp b
    jr nc, .spdef_is_greater_or_equal
	jp AI_Encourage_Greatly
	
.spdef_is_greater_or_equal
; Otherwise, encourage if enemy's HP is greater than 50%, 
; enemy's Sp. Def >= Def, and enemy is faster than player.
	jp AI_Encourage
	
.slower
; Over 50% chance to encourage this move if enemy's HP is greater than 50%.

	call AICheckEnemyHalfHP
	ret c
	call AI_50_50
	ret c
	jp AI_Encourage

AI_Smart_Reflect:
; Check if enemy is slower than player.
	call AICompareSpeed
	jr nc, .slower

; Greatly encourage this move if enemy's HP is greater than 50%, 
; enemy's Def < Sp. Def, and enemy is faster than player.

    call AICheckEnemyHalfHP
    ret nc
    ld a, [wEnemySpDef]
    ld b, a
    ld a, [wEnemyDefense]
    cp b
    jr nc, .def_is_greater_or_equal
	jp AI_Encourage_Greatly
	
.def_is_greater_or_equal
; Otherwise, encourage if enemy's HP is greater than 50%,
; enemy's Def >= Sp. Def, and enemy is faster than player.
	jp AI_Encourage
	
.slower
; Over 50% chance to encourage this move if enemy's HP is greater than 50%.

	call AICheckEnemyHalfHP
	ret c
	call AI_50_50
	ret c
	jp AI_Encourage

AI_Smart_Ohko:
; Greatly encourage this move if enemy has 1 Pokémon left. 
	push hl
	farcall FindAliveEnemyMons
	pop hl
    jr nc, .level_check
	jp AI_Encourage_Greatly

.level_check
; Dismiss this move if player's level is higher than enemy's level.
; Else, discourage this move is player's HP is below 50%.

	ld a, [wBattleMonLevel]
	ld b, a
	ld a, [wEnemyMonLevel]
	cp b
	jp c, AIDiscourageMove
	call AICheckPlayerHalfHP
	ret c
	jp AI_Discourage

AI_Smart_TrapTarget:
; Bind, Wrap, Fire Spin, Clamp

; 50% chance to discourage this move if the player is already trapped.
	ld a, [wPlayerWrapCount]
	and a
	jr nz, .discourage

; 50% chance to greatly encourage this move if player is either
; badly poisoned, in love, identified, stuck in Rollout, or has a Nightmare.
	ld a, [wBattleMonStatus]
	bit TOX, a
	jr nz, .encourage

	ld a, [wPlayerSubStatus1]
	and 1 << SUBSTATUS_IN_LOVE | 1 << SUBSTATUS_ROLLOUT | 1 << SUBSTATUS_IDENTIFIED | 1 << SUBSTATUS_NIGHTMARE
	jr nz, .encourage

; Else, 50% chance to greatly encourage this move if it's the player's Pokemon first turn.
	ld a, [wPlayerTurnsTaken]
	and a
	jr z, .encourage

; 50% chance to discourage this move otherwise.
.discourage
	call AI_50_50
	ret c
	jp AI_Discourage

.encourage
	call AICheckEnemyQuarterHP
	ret nc
	call AI_50_50
	ret c
	jp AI_Encourage_Greatly

AI_Smart_Confuse:
; 90% chance to discourage this move if player's HP is between 25% and 50%.
	call AICheckPlayerHalfHP
	ret c
	call Random
	cp 10 percent
	jr c, .skipdiscourage
	inc [hl]

.skipdiscourage
; Discourage again if player's HP is below 25%.
	call AICheckPlayerQuarterHP
	ret c
	jp AI_Discourage

AI_Smart_SpDefenseUp2:
; Discourage this move if enemy's HP is lower than 50%.
	call AICheckEnemyHalfHP
	jr nc, .discourage

; Discourage this move if enemy's special defense level is higher than +3.
	ld a, [wEnemySDefLevel]
	cp BASE_STAT_LEVEL + 4
	jr nc, .discourage

; 80% chance to greatly encourage this move if
; enemy's Special Defense level is lower than +2,
; and the player's Pokémon is Special-oriented.
	push hl
; Get the pointer for the player's Pokémon's base Attack
	ld a, [wBattleMonSpecies]
	ld hl, BaseData + BASE_ATK
	ld bc, BASE_DATA_SIZE
	call AddNTimes
; Get the Pokémon's base Attack
	ld a, BANK(BaseData)
	call GetFarByte
	ld d, a
; Get the pointer for the player's Pokémon's base Special Attack
	ld bc, BASE_SAT - BASE_ATK
	add hl, bc
; Get the Pokémon's base Special Attack
	ld a, BANK(BaseData)
	call GetFarByte
	pop hl
; If its base Attack is greater than its base Special Attack,
; don't encourage this move.
	cp d
	ret c

.encourage
	call AI_80_20
	ret c
	jp AI_Encourage_Greatly

.discourage
	jp AI_Discourage

AI_Smart_Fly:
; Fly, Dig

; Greatly encourage this move if the player is
; flying or underground, and slower than the enemy.

	ld a, [wPlayerSubStatus3]
	and 1 << SUBSTATUS_FLYING | 1 << SUBSTATUS_UNDERGROUND
	ret z

	call AICompareSpeed
	ret nc

	call AI_Encourage_Greatly
	jp AI_Encourage

AI_Smart_SuperFang:
; Discourage this move if player's HP is below 25%.

	call AICheckPlayerQuarterHP
	ret c
	jp AI_Discourage

AI_Smart_Paralyze:
; 50% chance to discourage this move if player's HP is below 25%.
	call AICheckPlayerQuarterHP
	jr nc, .discourage
	
; Check if player has good matchup.
	push hl
	farcall CheckPlayerMoveTypeMatchups
	pop hl
	ld a, [wEnemyAISwitchScore]
	cp BASE_AI_SWITCH_SCORE
	jr c, .encourage

; 80% chance to greatly encourage this move
; if enemy is slower than player and its HP is above 25%.
	call AICompareSpeed
	jr c, .encourage
	call AICheckEnemyQuarterHP
	ret nc
	call AI_80_20
	ret c
	jp AI_Encourage_Greatly
	
.encourage
; 60% chance to encourage this move if its HP is above 25%
; and if enemy is faster or speed ties with player
; or if enemy has bad matchup against player
	call AI_60_40
	ret c
	jp AI_Encourage

.discourage
	call AI_50_50
	ret c
	jp AI_Discourage

AI_Smart_SpeedDownHit:
; Icy Wind

; Almost 90% chance to greatly encourage this move if the following conditions all meet:
; Enemy's HP is higher than 25%.
; It's the first turn of player's Pokemon.
; Player is faster than enemy.

	ld a, [wEnemyMoveStruct + MOVE_ANIM]
	cp ICY_WIND
	ret nz
	call AICheckEnemyQuarterHP
	ret nc
	ld a, [wPlayerTurnsTaken]
	and a
	ret nz
	call AICompareSpeed
	ret c
	call Random
	cp 12 percent
	ret c
	jp AI_Encourage_Greatly

AI_Smart_Substitute:
; Dismiss this move if enemy's HP is below 50%.

	call AICheckEnemyHalfHP
	ret c
	jp AIDiscourageMove

AI_Smart_HyperBeam:
	call AICheckEnemyHalfHP
	jr c, .discourage

; 50% chance to encourage this move if enemy's HP is below 25%.
	call AICheckEnemyQuarterHP
	ret c
	call AI_50_50
	ret c
	jp AI_Encourage

.discourage
; If enemy's HP is above 50%, discourage this move at random
	call Random
	cp 16 percent
	ret c
	inc [hl]
	call AI_50_50
	ret c
	jp AI_Discourage

AI_Smart_Mimic:
; Discourage this move if the player did not use any move last turn.
	ld a, [wLastPlayerCounterMove]
	and a
	jr z, .dismiss

	call AICheckEnemyHalfHP
	jr nc, .discourage

	push hl
	ld a, [wLastPlayerCounterMove]
	call AIGetEnemyMove

	ld a, 1
	ldh [hBattleTurn], a
	farcall BattleCheckTypeMatchup

	ld a, [wTypeMatchup]
	cp EFFECTIVE
	pop hl
	jr c, .discourage
	jr z, .skip_encourage

	call AI_50_50
	jr c, .skip_encourage

	dec [hl]

.skip_encourage
	ld a, [wLastPlayerCounterMove]
	push hl
	ld hl, UsefulMoves
	ld de, 1
	call IsInArray

	pop hl
	ret nc
	call AI_50_50
	ret c
	jp AI_Encourage

.dismiss
; Dismiss this move if the enemy is faster than the player.
	call AICompareSpeed
	jp c, AIDiscourageMove

.discourage
	jp AI_Discourage

AI_Smart_Counter:
	push hl
	ld hl, wPlayerUsedMoves
	ld c, NUM_MOVES
	ld b, 0

.playermoveloop
	ld a, [hli]
	and a
	jr z, .skipmove

	call AIGetEnemyMove

	ld a, [wEnemyMoveStruct + MOVE_POWER]
	and a
	jr z, .skipmove

	ld a, [wEnemyMoveStruct + MOVE_TYPE]
	cp SPECIAL
	jr nc, .skipmove

	inc b

.skipmove
	dec c
	jr nz, .playermoveloop

	pop hl
	ld a, b
	and a
	jr z, .discourage

	cp 3
	jr nc, .encourage

	ld a, [wLastPlayerCounterMove]
	and a
	jr z, .done

	call AIGetEnemyMove

	ld a, [wEnemyMoveStruct + MOVE_POWER]
	and a
	jr z, .done

	ld a, [wEnemyMoveStruct + MOVE_TYPE]
	cp SPECIAL
	jr nc, .done

.encourage
	call Random
	cp 39 percent + 1
	jr c, .done

	dec [hl]

.done
	ret

.discourage
	jp AI_Discourage

AI_Smart_Encore:
	call AICompareSpeed
	jr nc, .discourage

	ld a, [wLastPlayerMove]
	and a
	jp z, AIDiscourageMove

	call AIGetEnemyMove

	ld a, [wEnemyMoveStruct + MOVE_POWER]
	and a
	jr z, .weakmove

	push hl
	ld a, [wEnemyMoveStruct + MOVE_TYPE]
	and TYPE_MASK
	ld hl, wEnemyMonType1
	predef CheckTypeMatchup

	pop hl
	ld a, [wTypeMatchup]
	cp EFFECTIVE
	jr nc, .weakmove

	and a
	ret nz
	jr .encourage

.weakmove
	push hl
	ld a, [wLastPlayerCounterMove]
	ld hl, EncoreMoves
	ld de, 1
	call IsInArray
	pop hl
	jr nc, .discourage

.encourage
	call Random
	cp 28 percent - 1
	ret c
	jp AI_Encourage_Greatly

.discourage
	call AI_Discourage_Greatly
	jp AI_Discourage

INCLUDE "data/battle/ai/encore_moves.asm"

AI_Smart_PainSplit:
; Discourage this move if [enemy's current HP * 2 > player's current HP].

	push hl
	ld hl, wEnemyMonHP
	ld b, [hl]
	inc hl
	ld c, [hl]
	sla c
	rl b
	ld hl, wBattleMonHP + 1
	ld a, [hld]
	cp c
	ld a, [hl]
	sbc b
	pop hl
	ret nc
	inc [hl]
	ret

AI_Smart_Snore:
AI_Smart_SleepTalk:
; Greatly encourage this move if enemy is fast asleep.
; Greatly discourage this move otherwise.

	ld a, [wEnemyMonStatus]
	and SLP
	cp 1
	jr z, .discourage

	call AI_Encourage_Greatly
	jp AI_Encourage

.discourage
	call AI_Discourage_Greatly
	jp AI_Discourage

AI_Smart_DefrostOpponent:
; No move has EFFECT_DEFROST_OPPONENT, so this layer is unused.
	ret

AI_Smart_DestinyBond:
; 33% chance to encourage this move.
	call Random
	cp 33 percent + 1
	ret nc
	
	call AI_Encourage_Greatly
	ret
	
AI_Smart_Reversal:
AI_Smart_SkullBash:
; Discourage this move if enemy's HP is above 25%.

	call AICheckEnemyQuarterHP
	ret nc
	jp AI_Discourage

AI_Smart_HealBell:
; Dismiss this move if none of the opponent's Pokemon is statused.
; Encourage this move if the enemy is statused.
; 50% chance to greatly encourage this move if the enemy is fast asleep or has a frostbite.

	push hl
	ld a, [wOTPartyCount]
	ld b, a
	ld c, 0
	ld hl, wOTPartyMon1HP
	ld de, PARTYMON_STRUCT_LENGTH

.loop
	push hl
	ld a, [hli]
	or [hl]
	jr z, .next

	; status
	dec hl
	dec hl
	dec hl
	ld a, [hl]
	or c
	ld c, a

.next
	pop hl
	add hl, de
	dec b
	jr nz, .loop

	pop hl
	ld a, c
	and a
	jr z, .no_status

	ld a, [wEnemyMonStatus]
	and a
	jr z, .ok
	dec [hl]
.ok
	and 1 << FRB | SLP
	ret z
	call AI_50_50
	ret c
	jp AI_Encourage_Greatly

.no_status
	ld a, [wEnemyMonStatus]
	and a
	ret nz
	jp AIDiscourageMove

AI_Smart_Return:
	ld a, [wEnemyMonHappiness]
	cp 225
	jp nc, AI_Encourage_Greatly
	
	cp 175
	jp nc, AI_Encourage
	
	jp AIDiscourageMove
	
AI_Smart_Frustration:
	ld a, [wEnemyMonHappiness]
	cp 30
	jp c, AI_Encourage_Greatly
	
	cp 80
	jp c, AI_Encourage
	
	jp AIDiscourageMove

AI_Smart_PriorityHit:
; Dismiss this move if the player is flying or underground.
	ld a, [wPlayerSubStatus3]
	and 1 << SUBSTATUS_FLYING | 1 << SUBSTATUS_UNDERGROUND
	jp nz, AIDiscourageMove

; Greatly encourage this move when enemy has very low HP.
	call AICheckEnemyQuarterHP
	jp nc, AI_Encourage_Greatly
	
	call AICompareSpeed
	jr nc, .check_ko
	
	call AI_50_50
	ret c

.check_ko
; Greatly encourage this move if it will KO the player.
	ld a, 1
	ldh [hBattleTurn], a
	push hl
	farcall EnemyAttackDamage
	farcall BattleCommand_DamageCalc
	farcall BattleCommand_Stab
	pop hl
	ld a, [wCurDamage + 1]
	ld c, a
	ld a, [wCurDamage]
	ld b, a
	ld a, [wBattleMonHP + 1]
	cp c
	ld a, [wBattleMonHP]
	sbc b
	jr nc, .not_ko
	call AI_Encourage_Greatly
	jp AI_Encourage
	
.not_ko
; Dismiss this move if the enemy won't be fainted immediately.

	push hl
	farcall CheckOnlyEnemyMoveMatchups
	pop hl
	ld a, [wEnemyAISwitchScore]
	cp BASE_AI_SWITCH_SCORE - 2
	jp nc, AIDiscourageMove
	ret

AI_Smart_Thief:
; Don't use Thief unless it's the only move available.

	ld a, [hl]
	add $1e
	ld [hl], a
	ret
	
AI_Smart_Acid:
; Greatly encourage this move if the player's Pokémon
; is a Steel-type.

	ld a, [wBattleMonType1]
	cp STEEL
	jr z, .encourage_greatly
	ld a, [wBattleMonType2]
	cp STEEL
	ret nz
	; fallthrough
.encourage_greatly
	jp AI_Encourage_Greatly

AI_Smart_Conversion2:
	ld a, [wLastPlayerMove]
	and a
	jr z, .discourage

	push hl
	dec a
	ld hl, Moves + MOVE_TYPE
	ld bc, MOVE_LENGTH
	call AddNTimes

	ld a, BANK(Moves)
	call GetFarByte
	ld [wPlayerMoveStruct + MOVE_TYPE], a

	xor a
	ldh [hBattleTurn], a

	farcall BattleCheckTypeMatchup

	ld a, [wTypeMatchup]
	cp EFFECTIVE
	pop hl
	jr c, .discourage
	ret z

	call AI_50_50
	ret c

	jp AI_Encourage

.discourage
	call Random
	cp 10 percent
	ret c
	jp AI_Discourage

AI_Smart_Disable:
	call AICompareSpeed
	jr nc, .discourage

	push hl
	ld a, [wLastPlayerCounterMove]
	ld hl, UsefulMoves
	ld de, 1
	call IsInArray

	pop hl
	jr nc, .notencourage

	call Random
	cp 39 percent + 1
	ret c
	jp AI_Encourage

.notencourage
	ld a, [wEnemyMoveStruct + MOVE_POWER]
	and a
	ret nz

.discourage
	call Random
	cp 8 percent
	ret c
	jp AI_Discourage

AI_Smart_MeanLook:
	call AICheckEnemyHalfHP
	jr nc, .discourage

	push hl
	call AICheckLastPlayerMon
	pop hl
	jp z, AIDiscourageMove

; 80% chance to greatly encourage this move if the player is badly poisoned
	ld a, [wBattleMonStatus]
	bit TOX, a
	jr nz, .encourage

; 80% chance to greatly encourage this move if the player is either
; in love, identified, stuck in Rollout, or has a Nightmare.
	ld a, [wPlayerSubStatus1]
	and 1 << SUBSTATUS_IN_LOVE | 1 << SUBSTATUS_ROLLOUT | 1 << SUBSTATUS_IDENTIFIED | 1 << SUBSTATUS_NIGHTMARE
	jr nz, .encourage

; Otherwise, discourage this move unless the player only has not very effective moves against the enemy.
	push hl
	farcall CheckPlayerMoveTypeMatchups
	ld a, [wEnemyAISwitchScore]
	cp BASE_AI_SWITCH_SCORE + 1 ; not very effective
	pop hl
	ret nc

.discourage
	jp AI_Discourage

.encourage
	call AI_80_20
	ret c
	call AI_Encourage_Greatly
	jp AI_Encourage

AICheckLastPlayerMon:
	ld a, [wPartyCount]
	ld b, a
	ld c, 0
	ld hl, wPartyMon1HP
	ld de, PARTYMON_STRUCT_LENGTH

.loop
	ld a, [wCurBattleMon]
	cp c
	jr z, .skip

	ld a, [hli]
	or [hl]
	ret nz
	dec hl

.skip
	add hl, de
	inc c
	dec b
	jr nz, .loop

	ret

AI_Smart_Nightmare:
; 50% chance to encourage this move.
; The AI_Basic layer will make sure that
; Dream Eater is only used against sleeping targets.

	call AI_50_50
	ret c
	jp AI_Encourage

AI_Smart_FlameWheel:
; Use this move if the enemy has a frostbite.

	ld a, [wEnemyMonStatus]
	bit FRB, a
	ret z
rept 5
	dec [hl]
endr
	ret

AI_Smart_Curse:
	ld a, [wEnemyMonType1]
	cp GHOST
	jr z, .ghost_curse
	ld a, [wEnemyMonType2]
	cp GHOST
	jr z, .ghost_curse

	call AICheckEnemyHalfHP
	jr nc, .encourage

	ld a, [wEnemyAtkLevel]
	cp BASE_STAT_LEVEL + 4
	jr nc, .encourage
	cp BASE_STAT_LEVEL + 2
	ret nc

	ld a, [wBattleMonType1]
	cp GHOST
	jr z, .greatly_encourage
	call AI_80_20
	ret c
	jp AI_Encourage

.approve
	call AI_Encourage_Greatly
.greatly_encourage
	call AI_Encourage
.encourage
	call AI_Encourage
	ret

.ghost_curse
	ld a, [wPlayerSubStatus1]
	bit SUBSTATUS_CURSE, a
	jp nz, AIDiscourageMove

	push hl
	farcall FindAliveEnemyMons
	pop hl
	jr nc, .notlastmon

	push hl
	call AICheckLastPlayerMon
	pop hl
	jr nz, .approve

	jr .ghost_continue

.notlastmon
	push hl
	call AICheckLastPlayerMon
	pop hl
	jr z, .maybe_greatly_encourage

.ghost_continue
	call AICheckEnemyQuarterHP
	jp nc, .rarely_greatly_encourage
	
	push hl
	farcall CheckPlayerMoveTypeMatchups
	pop hl
	
	ld a, [wEnemyAISwitchScore]
	cp BASE_AI_SWITCH_SCORE + 1
	jp nc, AI_Discourage_Greatly
	
	push hl
	farcall CheckOnlyEnemyMoveMatchups
	pop hl
	
	ld a, [wEnemyAISwitchScore]
	cp BASE_AI_SWITCH_SCORE
	jr c, .maybe_greatly_encourage
	
	call AI_Discourage_Greatly
	jp AI_Discourage_Greatly
	
.rarely_greatly_encourage
	call AI_80_20
	ret nc
	
	jp AI_Encourage_Greatly

.maybe_greatly_encourage
	call AI_50_50
	ret c

	jp AI_Encourage_Greatly

AI_Smart_Protect:
; Greatly discourage this move if the enemy already used Protect.
	ld a, [wEnemyProtectCount]
	and a
	jr nz, .greatly_discourage

; Discourage this move if the player is locked on.
	ld a, [wPlayerSubStatus5]
	bit SUBSTATUS_LOCK_ON, a
	jr nz, .discourage

; Encourage this move if the player's Fury Cutter is boosted enough.
	ld a, [wPlayerFuryCutterCount]
	cp 3
	jr nc, .encourage

; Encourage this move if the player has charged a two-turn move.
	ld a, [wPlayerSubStatus3]
	bit SUBSTATUS_CHARGED, a
	jr nz, .encourage

; Encourage this move if the player is affected by Toxic, Leech Seed, or Curse.
	ld a, [wBattleMonStatus]
	bit TOX, a
	jr nz, .encourage
	ld a, [wPlayerSubStatus4]
	bit SUBSTATUS_LEECH_SEED, a
	jr nz, .encourage
	ld a, [wPlayerSubStatus1]
	bit SUBSTATUS_CURSE, a
	jr nz, .encourage

; Discourage this move if the player's Rollout count is not boosted enough.
	bit SUBSTATUS_ROLLOUT, a
	jr z, .discourage
	ld a, [wPlayerRolloutCount]
	cp 3
	jr c, .discourage

; 80% chance to encourage this move otherwise.
.encourage
	call AI_80_20
	ret c

	jp AI_Encourage

.greatly_discourage
	inc [hl]

.discourage
	call Random
	cp 8 percent
	ret c

	jp AI_Discourage_Greatly

AI_Smart_Foresight:
; 60% chance to encourage this move if the enemy's accuracy is sharply lowered.
	ld a, [wEnemyAccLevel]
	cp BASE_STAT_LEVEL - 2
	jr c, .encourage

; 60% chance to encourage this move if the player's evasion is sharply raised.
	ld a, [wPlayerEvaLevel]
	cp BASE_STAT_LEVEL + 3
	jr nc, .encourage

; 60% chance to encourage this move if the player is a Ghost type.
	ld a, [wBattleMonType1]
	cp GHOST
	jr z, .encourage
	ld a, [wBattleMonType2]
	cp GHOST
	jr z, .encourage

; 92% chance to discourage this move otherwise.
	call Random
	cp 8 percent
	ret c

	call AI_Discourage
	ret

.encourage
	call Random
	cp 39 percent + 1
	ret c

	jp AI_Encourage_Greatly

AI_Smart_PerishSong:
	push hl
	farcall FindAliveEnemyMons
	pop hl
	jr c, .no

	ld a, [wPlayerSubStatus5]
	bit SUBSTATUS_CANT_RUN, a
	jr nz, .yes

	push hl
	farcall CheckPlayerMoveTypeMatchups
	ld a, [wEnemyAISwitchScore]
	cp BASE_AI_SWITCH_SCORE
	pop hl
	ret c

	call AI_50_50
	ret c

	jp AI_Discourage

.yes
	call AI_50_50
	ret c

	jp AI_Encourage

.no
	ld a, [hl]
	add 5
	ld [hl], a
	ret

AI_Smart_Sandstorm:
; Greatly discourage this move if the player is immune to Sandstorm damage.
	ld a, [wBattleMonType1]
	push hl
	ld hl, .SandstormImmuneTypes
	ld de, 1
	call IsInArray
	pop hl
	jr c, .greatly_discourage

	ld a, [wBattleMonType2]
	push hl
	ld hl, .SandstormImmuneTypes
	ld de, 1
	call IsInArray
	pop hl
	jr c, .greatly_discourage

; Discourage this move if player's HP is below 50%.
	call AICheckPlayerHalfHP
	jr nc, .discourage

; 50% chance to encourage this move otherwise.
	call AI_50_50
	ret c

	call AI_Encourage
	ret

.greatly_discourage
	call AI_Discourage
.discourage
	jp AI_Discourage

.SandstormImmuneTypes:
	db ROCK
	db GROUND
	db STEEL
	db -1 ; end

AI_Smart_Endure:
; Greatly discourage this move if the enemy already used Protect.
	ld a, [wEnemyProtectCount]
	and a
	jr nz, .greatly_discourage

; Greatly discourage this move if the enemy's HP is full.
	call AICheckEnemyMaxHP
	jr c, .greatly_discourage

; Discourage this move if the enemy's HP is at least 25%.
	call AICheckEnemyQuarterHP
	jr c, .discourage

; If the enemy has Reversal...
	ld b, EFFECT_REVERSAL
	call AIHasMoveEffect
	jr nc, .no_reversal

; ...80% chance to greatly encourage this move.
	call AI_80_20
	ret c

	call AI_Encourage_Greatly
	jp AI_Encourage

.no_reversal
; If the enemy is not locked on, do nothing.
	ld a, [wEnemySubStatus5]
	bit SUBSTATUS_LOCK_ON, a
	ret z

; 50% chance to greatly encourage this move.
	call AI_50_50
	ret c

	jp AI_Encourage_Greatly

.greatly_discourage
	inc [hl]
.discourage
	jp AI_Discourage

AI_Smart_FuryCutter:
; Encourage this move based on Fury Cutter's count.

	ld a, [wEnemyFuryCutterCount]
	and a
	jr z, AI_Smart_Rollout
	call AI_Encourage

	cp 2
	jr c, AI_Smart_Rollout
	call AI_Encourage_Greatly

	cp 3
	jr c, AI_Smart_Rollout
	call AI_Encourage
	call AI_Encourage_Greatly

	; fallthrough

AI_Smart_Rollout:
; Rollout, Fury Cutter

; 80% chance to discourage this move if the enemy is in love, confused, or paralyzed.
	ld a, [wEnemySubStatus1]
	bit SUBSTATUS_IN_LOVE, a
	jr nz, .maybe_discourage

	ld a, [wEnemySubStatus3]
	bit SUBSTATUS_CONFUSED, a
	jr nz, .maybe_discourage

	ld a, [wEnemyMonStatus]
	bit PAR, a
	jr nz, .maybe_discourage

; 80% chance to discourage this move if the enemy's HP is below 25%.
	call AICheckEnemyQuarterHP
	jr nc, .maybe_discourage

; 80% chance to greatly discourage this move otherwise.
	call Random
	cp 79 percent - 1
	ret nc
	jp AI_Discourage_Greatly

.maybe_discourage
	call AI_80_20
	ret c
	jp AI_Discourage

AI_Smart_Swagger:
AI_Smart_Attract:
; 80% chance to encourage this move during the first turn of player's Pokemon.
; 80% chance to discourage this move otherwise.

	ld a, [wPlayerTurnsTaken]
	and a
	jr z, .first_turn

	call AI_80_20
	ret c
	jp AI_Discourage

.first_turn
	call Random
	cp 79 percent - 1
	ret nc
	jp AI_Encourage

AI_Smart_Safeguard:
; 80% chance to discourage this move if player's HP is below 50%.

	call AICheckPlayerHalfHP
	ret c
	call AI_80_20
	ret c
	jp AI_Discourage

AI_Smart_Magnitude:
AI_Smart_Earthquake:
; Greatly encourage this move if the player is underground and the enemy is faster.
	ld a, [wLastPlayerCounterMove]
	cp DIG
	ret nz

	ld a, [wPlayerSubStatus3]
	bit SUBSTATUS_UNDERGROUND, a
	jr z, .could_dig

	call AICompareSpeed
	ret nc
	jp AI_Encourage_Greatly

.could_dig
	; Try to predict if the player will use Dig this turn.

	; 50% chance to encourage this move if the enemy is slower than the player.
	call AICompareSpeed
	ret c

	call AI_50_50
	ret c

	jp AI_Encourage

AI_Smart_BatonPass:
; Discourage this move if the player hasn't shown super-effective moves against the enemy.
; Also discourage this move if the enemy's stat buffs are zero or lower.
; Also discourage this move if the enemy has only one Pokémon left.
; Consider player's type(s) if its moves are unknown.

	push hl
	farcall CheckPlayerMoveTypeMatchups
	ld a, [wEnemyAISwitchScore]
	cp BASE_AI_SWITCH_SCORE
	pop hl
	ret c
	
	push hl
	farcall FindAliveEnemyMons
	pop hl
  jr c, .discourage
	
	push hl
	farcall CheckEnemyStatBoosts
	pop hl
	; Checks if AI has no boosts
	ld a, e
	and a
  jp nz, AI_Encourage
  ; fallthrough
	
.discourage
	jp AI_Discourage_Greatly

AI_Smart_Pursuit:
; 60% chance to greatly encourage this move if player's HP is below 25%
; or if player may switch.
; 80% chance to discourage this move otherwise.
	call AICheckPlayerQuarterHP
	jr nc, .encourage
	
	push hl
	farcall CheckPlayerMoveTypeMatchups
	pop hl 
	ld a, [wEnemyAISwitchScore]
	cp BASE_AI_SWITCH_SCORE + 1
	jr nc, .encourage
	
	push hl
	farcall CheckOnlyEnemyMoveMatchups
	pop hl 
	ld a, [wEnemyAISwitchScore]
	cp BASE_AI_SWITCH_SCORE + 2
	jr nc, .encourage
	
	jp AI_Discourage
	
.discourage_greatly
	call AI_60_40
	ret c
	jp AI_Discourage_Greatly

.encourage
	call AI_60_40
	ret c
	call AI_Encourage
	jp AI_Encourage_Greatly

AI_Smart_RapidSpin:
; 80% chance to greatly encourage this move if the enemy is
; trapped (Bind effect), seeded, or scattered with spikes.

	ld a, [wEnemyWrapCount]
	and a
	jr nz, .encourage

	ld a, [wEnemySubStatus4]
	bit SUBSTATUS_LEECH_SEED, a
	jr nz, .encourage

	ld a, [wEnemyScreens]
	bit SCREENS_SPIKES, a
	ret z

.encourage
	call AI_80_20
	ret c

	jp AI_Encourage_Greatly

AI_Smart_RainDance:
; Greatly discourage this move if it would favour the player type-wise.
; Particularly, if the player is a Water-type.
	ld a, [wBattleMonType1]
	cp WATER
	jr z, AIBadWeatherType
	cp FIRE
	jr z, AIGoodWeatherType

	ld a, [wBattleMonType2]
	cp WATER
	jr z, AIBadWeatherType
	cp FIRE
	jr z, AIGoodWeatherType

	push hl
	ld hl, RainDanceMoves
	jr AI_Smart_WeatherMove

INCLUDE "data/battle/ai/rain_dance_moves.asm"

AI_Smart_SunnyDay:
; Greatly discourage this move if it would favour the player type-wise.
; Particularly, if the player is a Fire-type.
	ld a, [wBattleMonType1]
	cp FIRE
	jr z, AIBadWeatherType
	cp WATER
	jr z, AIGoodWeatherType

	ld a, [wBattleMonType2]
	cp FIRE
	jr z, AIBadWeatherType
	cp WATER
	jr z, AIGoodWeatherType

	push hl
	ld hl, SunnyDayMoves

	; fallthrough

AI_Smart_WeatherMove:
; Rain Dance, Sunny Day

; Greatly discourage this move if the enemy doesn't have
; one of the useful Rain Dance or Sunny Day moves.
	call AIHasMoveInArray
	pop hl
	jr nc, AIBadWeatherType

; Greatly discourage this move if player's HP is below 50%.
	call AICheckPlayerHalfHP
	jr nc, AIBadWeatherType

; 50% chance to encourage this move otherwise.
	call AI_50_50
	ret c

	jp AI_Encourage

AIBadWeatherType:
	call AI_Discourage_Greatly
	jp AI_Discourage

AIGoodWeatherType:
; Rain Dance, Sunny Day

; Greatly encourage this move if it would disfavour the player type-wise and player's HP is above 50%...
	call AICheckPlayerHalfHP
	ret nc

; ...as long as one of the following conditions meet:
; It's the first turn of the player's Pokemon.
	ld a, [wPlayerTurnsTaken]
	and a
	jr z, .good

; Or it's the first turn of the enemy's Pokemon.
	ld a, [wEnemyTurnsTaken]
	and a
	ret nz

.good
	jp AI_Encourage_Greatly

INCLUDE "data/battle/ai/sunny_day_moves.asm"

AI_Smart_BellyDrum:
; Dismiss this move if enemy's attack is higher than +2 or if enemy's HP is below 50%.
; Else, discourage this move if enemy's HP is not full.

	ld a, [wEnemyAtkLevel]
	cp BASE_STAT_LEVEL + 3
	jr nc, .discourage

	call AICheckEnemyMaxHP
	ret c

	inc [hl]

	call AICheckEnemyHalfHP
	ret c

.discourage
	ld a, [hl]
	add 5
	ld [hl], a
	ret

AI_Smart_MirrorCoat:
	push hl
	ld hl, wPlayerUsedMoves
	ld c, NUM_MOVES
	ld b, 0

.playermoveloop
	ld a, [hli]
	and a
	jr z, .skipmove

	call AIGetEnemyMove

	ld a, [wEnemyMoveStruct + MOVE_POWER]
	and a
	jr z, .skipmove

	ld a, [wEnemyMoveStruct + MOVE_TYPE]
	cp SPECIAL
	jr c, .skipmove

	inc b

.skipmove
	dec c
	jr nz, .playermoveloop

	pop hl
	ld a, b
	and a
	jr z, .discourage

	cp 3
	jr nc, .encourage

	ld a, [wLastPlayerCounterMove]
	and a
	jr z, .done

	call AIGetEnemyMove

	ld a, [wEnemyMoveStruct + MOVE_POWER]
	and a
	jr z, .done

	ld a, [wEnemyMoveStruct + MOVE_TYPE]
	cp SPECIAL
	jr c, .done

.encourage
	call Random
	cp 39 percent + 1
	jr c, .done
	dec [hl]

.done
	ret

.discourage
	jp AI_Discourage

AI_Smart_Twister:
AI_Smart_Gust:
; Greatly encourage this move if the player is flying and the enemy is faster.
	ld a, [wLastPlayerCounterMove]
	cp FLY
	ret nz

	ld a, [wPlayerSubStatus3]
	bit SUBSTATUS_FLYING, a
	jr z, .couldFly

	call AICompareSpeed
	ret nc

	jp AI_Encourage_Greatly

; Try to predict if the player will use Fly this turn.
.couldFly

; 50% chance to encourage this move if the enemy is slower than the player.
	call AICompareSpeed
	ret c
	call AI_50_50
	ret c
	jp AI_Encourage

AI_Smart_FutureSight:
; Greatly encourage this move if the player is
; flying or underground, and slower than the enemy.

	call AICompareSpeed
	ret nc

	ld a, [wPlayerSubStatus3]
	and 1 << SUBSTATUS_FLYING | 1 << SUBSTATUS_UNDERGROUND
	ret z

	jp AI_Encourage_Greatly

AI_Smart_Stomp:
; 80% chance to encourage this move if the player has used Minimize.

	ld a, [wPlayerMinimized]
	and a
	ret z

	call AI_80_20
	call nc, AI_Encourage
	
	; fallthrough
	
AI_Smart_Flinch:
; 40% chance to encourage this move if the enemy is faster than player.
; 60% chance to encourage this move if enemy has low hp.
; Greatly discourage this move if enemy is asleep or frozen.
	ld a, [wBattleMonStatus]
	bit FRB, a
	jp nz, AI_Discourage_Greatly
	and SLP
	jp nz, AI_Discourage_Greatly
	
	call AICompareSpeed
	ret nc
	
	call AICheckEnemyQuarterHP
	jr nc, .lowhp
	
	call AI_60_40
	ret nc
.encourage
	jp AI_Encourage
	
.lowhp
	call AI_60_40
	ret c
	jr .encourage

AI_Smart_Solarbeam:
; Discourage this move when the weather is clear and player has more than one Pokémon.
; Greatly discourage when weather is not clear or sunny.

	ld a, [wBattleWeather]
	and a
	jr z, .clear

	cp WEATHER_SUN
	ret z

	call AI_Discourage
	jp AI_Discourage_Greatly

.clear
	push hl
	farcall FindAliveEnemyMons
	pop hl
	ret c

	jp AI_Discourage

AI_Smart_Thunder:
; 90% chance to discourage this move when it's sunny.

	ld a, [wBattleWeather]
	cp WEATHER_RAIN
	ret z

	call Random
	cp 10 percent
	ret c

	jp AI_Discourage

AICompareSpeed:
; Return carry if enemy is faster than player.

	push bc
	ld a, [wEnemyMonSpeed + 1]
	ld b, a
	ld a, [wBattleMonSpeed + 1]
	cp b
	ld a, [wEnemyMonSpeed]
	ld b, a
	ld a, [wBattleMonSpeed]
	sbc b
	pop bc
	ret

AICheckPlayerMaxHP:
	push hl
	push de
	push bc
	ld de, wBattleMonHP
	ld hl, wBattleMonMaxHP
	jr AICheckMaxHP

AICheckEnemyMaxHP:
	push hl
	push de
	push bc
	ld de, wEnemyMonHP
	ld hl, wEnemyMonMaxHP
	; fallthrough

AICheckMaxHP:
; Return carry if hp at de matches max hp at hl.

	ld a, [de]
	inc de
	cp [hl]
	jr nz, .not_max

	inc hl
	ld a, [de]
	cp [hl]
	jr nz, .not_max

	pop bc
	pop de
	pop hl
	scf
	ret

.not_max
	pop bc
	pop de
	pop hl
	and a
	ret

AICheckPlayerHalfHP:
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

AICheckEnemyHalfHP:
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

AICheckEnemyQuarterHP:
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

AICheckPlayerQuarterHP:
	push hl
	push de
	push bc
	ld hl, wBattleMonHP
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


AIHasMoveEffect:
; Return carry if the enemy has move b.

	push hl
	ld hl, wEnemyMonMoves
	ld c, NUM_MOVES

.checkmove
	ld a, [hli]
	and a
	jr z, .no

	call AIGetEnemyMove

	ld a, [wEnemyMoveStruct + MOVE_EFFECT]
	cp b
	jr z, .yes

	dec c
	jr nz, .checkmove

.no
	pop hl
	and a
	ret

.yes
	pop hl
	scf
	ret

AIHasMoveInArray:
; Return carry if the enemy has a move in array hl.

	push hl
	push de
	push bc

.next
	ld a, [hli]
	cp -1
	jr z, .done

	ld b, a
	ld c, NUM_MOVES + 1
	ld de, wEnemyMonMoves

.check
	dec c
	jr z, .next

	ld a, [de]
	inc de
	cp b
	jr nz, .check

	scf

.done
	pop bc
	pop de
	pop hl
	ret

INCLUDE "data/battle/ai/useful_moves.asm"

AI_Opportunist:
; Discourage status moves when the player's HP is low.

; Discourage status moves if enemy's HP is below 25%.
	call AICheckPlayerQuarterHP
	ret c
	
; Discourage status moves if enemy has very good matchup
; against player.

	push hl
	farcall CheckPlayerMoveTypeMatchups
	pop hl
	ld a, [wEnemyAISwitchScore]
	cp BASE_AI_SWITCH_SCORE
	jr nc, .checkmove

	call AI_50_50
	ret c

	ld hl, wEnemyAIMoveScores - 1
	ld de, wEnemyMonMoves
	ld c, NUM_MOVES + 1
.checkmove
	inc hl
	dec c
	jr z, .done

	ld a, [de]
	inc de
	and a
	jr z, .done

	dec de
	ld a, [de]
	call AIGetEnemyMove
	inc de
	ld a, [wEnemyMoveStruct + MOVE_POWER]
	and a
	jr nz, .checkmove

	call AI_Discourage_Greatly
	jr .checkmove

.done
	ret

INCLUDE "data/battle/ai/stall_moves.asm"


AI_Aggressive:
; Be aggressive when the player has a status condition.
	ld a, [wBattleMonStatus]
	bit FRB, a
	jr nz, .start
	and SLP
	jr nz, .start
	
; Be aggressive when either player or enemy has low hp
; or has a bad matchup.
	call AICheckEnemyHalfHP
	jr nc, .start
	call AICheckPlayerHalfHP
	jr nc, .start
	farcall CheckPlayerMoveTypeMatchups
	jr c, .start
	
; 50% chance to be aggressive otherwise.
	call AI_50_50
	ret c
.start
; Use whatever does the most damage.

; Discourage all damaging moves that deal low damage unless they're reckless too.
	ld hl, wEnemyAIMoveScores - 1
	ld de, wEnemyMonMoves
	ld bc, 0
	xor a
	ld [wMovesThatOHKOPlayer], a
.checkmove
	inc b
	ld a, b
	cp NUM_MOVES + 1
	jp z, .done

	push hl
	push de
	push bc
	ld a, [de]
	call AIGetEnemyMove
	cp SELFDESTRUCT
	jp z, .nodamage
	cp EXPLOSION
	jp z, .nodamage
	ld a, [wEnemyMoveStruct + MOVE_POWER]
	and a
	jr z, .nodamage
	call AIDamageCalc
	pop de
	push de
	ld a, [de]
	cp PURSUIT 
	call z, PursuitDamage
	pop bc
	pop de
	pop hl
	
	inc de
	inc hl
	
	call AICheckEnemyHalfHP
	jr nc, .low_hp
	
	push hl
	push de
	push bc
	call AIAggessiveCheckTurnsToKOPlayer
	pop bc
	pop de
	pop hl
	
; Encourage moves that can OHKO and have good accuracy.
	cp 1
	jr nz, .check_turns_to_ko

	ld a, [wMovesThatOHKOPlayer]
	inc a
	ld [wMovesThatOHKOPlayer], a
	
	ld a, [wEnemyMoveStruct + MOVE_ACC]
	cp 89 percent
	jr c, .check_turns_to_ko
	
	call AI_Encourage
	
; Encourage moves that can OHKO and have perfect accuracy.

	ld a, [wEnemyMoveStruct + MOVE_ACC]
	cp 99 percent + 1
	jr c, .check_turns_to_ko
	
	call AI_Encourage
	
; Encourage moves that have no recoil.
	
	ld a, [wEnemyMoveStruct + MOVE_EFFECT]
	cp EFFECT_RECOIL_HIT
	jr z, .check_turns_to_ko
	
	call AI_Encourage
	
	
.check_turns_to_ko
	push hl
	push de
	push bc
	call AIAggessiveCheckTurnsToKOPlayer
	pop bc
	pop de
	pop hl

; Discourage this move it takes 4 or more hits to KO player
	cp 4
	jr c, .checkmove
	
.check_reckless
; Ignore this move if it is reckless.
	push hl
	push de
	push bc
	ld a, [wEnemyMoveStruct + MOVE_EFFECT]
	ld hl, RecklessMoves
	ld de, 1
	call IsInArray
	pop bc
	pop de
	pop hl
	jp c, .checkmove

; If we made it this far, discourage this move.
	call AI_Discourage
	jp .checkmove
	
.nodamage
	pop bc
	pop de
	pop hl
	inc de
	inc hl
	jp .checkmove
	
.low_hp
	push hl
	push de
	push bc
	call AIAggessiveCheckTurnsToKOPlayer
	pop bc
	pop de
	pop hl

; Encourage moves that can OHKO and have perfect accuracy.
	cp 1
	jr nz, .check_turns_to_ko_lowhp
	
	ld a, [wEnemyMoveStruct + MOVE_ACC]
	cp 99 percent + 1
	jr c, .check_turns_to_ko_lowhp
	
	call AI_Encourage
	
	ld a, [wEnemyMoveStruct + MOVE_EFFECT]
	cp EFFECT_RECOIL_HIT
	jr z, .check_turns_to_ko_lowhp
	
	call AI_Encourage
	
.check_turns_to_ko_lowhp
	
; Discourage this move it takes 3 or more hits to KO player
	cp 3
	jp c, .checkmove
	
	jr .check_reckless
	
.done
	ld a, 0
	ld [wCurDamage], a
	ld [wCurDamage+1], a
	ret

INCLUDE "data/battle/ai/reckless_moves.asm"

AIDamageCalc:
; TO-DO: Account for two-turn moves. Halve BP during AI Damage Calculation.
	ld a, 1
	ldh [hBattleTurn], a
	ld a, [wEnemyMoveStruct + MOVE_EFFECT]
	cp EFFECT_MULTI_HIT
	jr z, .multihit
	cp EFFECT_DOUBLE_HIT
	jr z, .doublehit
	cp EFFECT_MAGNITUDE
	jr z, .magnitude
	cp EFFECT_HIDDEN_POWER
	jr z, .hidden_power
	cp EFFECT_RETURN
	jr z, .return
	cp EFFECT_REVERSAL
	jr z, .reversal

	ld de, 1
	ld hl, TwoTurnEffects
	call IsInArray
	jr c, .two_turn_effects
	
	ld de, 1
	ld hl, ConstantDamageEffects
	call IsInArray
	jr nc, .regular_damage
	farcall BattleCommand_ConstantDamage
	ret

.multihit
	ld b, 3
	jr .multihit_boost
.doublehit
	; Multiply base power by 2
	ld b, 2
.multihit_boost
	ld a, [wEnemyMoveStruct + MOVE_POWER]
	ld c, a
.multihit_loop
	dec b
	jr z, .regular_damage ; With proper BP, we can use regular calc now
	add c
	ld [wEnemyMoveStruct + MOVE_POWER], a
	jr .multihit_loop
	
.hidden_power
	farcall HiddenPowerDamage
	jr .damagecalc
	
.return ; the move
	farcall EnemyAttackDamage
	farcall BattleCommand_HappinessPower
	jr .damagecalc

.reversal
	farcall BattleCommand_ConstantDamage
	jr .stab

.two_turn_effects
	ld a, [wEnemyMoveStruct + MOVE_POWER]
	rrca
	ld [wEnemyMoveStruct + MOVE_POWER], a
	jr .regular_damage

.magnitude
	; Pretend that the base power is 70
	ld a, 70
	ld [wEnemyMoveStruct + MOVE_POWER], a
	; fallthrough
.regular_damage
	farcall EnemyAttackDamage
.damagecalc
	farcall BattleCommand_DamageCalc
.stab
	farcall BattleCommand_Stab
	jr MinDamageRoll
	
PursuitDamage:
	call AICheckPlayerQuarterHP
	jr nc, .calc_pursuit
	
	ld a, [wCurDamage]
	ld d, a
	ld a, [wCurDamage + 1]
	ld e, a
	
	push hl
	farcall CheckPlayerMoveTypeMatchups
	pop hl 
	ld a, [wEnemyAISwitchScore]
	cp BASE_AI_SWITCH_SCORE + 1
	jr c, .return

	ld a, d
	ld [wCurDamage], a
	ld a, e
	ld [wCurDamage + 1], a
	
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
	
.return
	ld a, d
	ld [wCurDamage], a
	ld a, e
	ld [wCurDamage + 1], a
	ret

MinDamageRoll:
; Set damage spread to a minimum of 85%.

; Because of the method of division the probability distribution
; is not consistent. This makes the highest damage multipliers
; rarer than normal.

; No point in reducing 1 or 0 damage.
	ld hl, wCurDamage
	ld a, [hli]
	and a
	jr nz, .go
	ld a, [hl]
	cp 2
	ret c

.go
; Start with the maximum damage.
	xor a
	ldh [hMultiplicand + 0], a
	dec hl
	ld a, [hli]
	ldh [hMultiplicand + 1], a
	ld a, [hl]
	ldh [hMultiplicand + 2], a

; Multiply by 85%...
	ld a, 85 percent 

	ldh [hMultiplier], a
	call Multiply

; ...divide by 100%...
	ld a, 100 percent
	ldh [hDivisor], a
	ld b, $4
	call Divide

; ...to get .85-1.00x damage.
	ldh a, [hQuotient + 2]
	ld hl, wCurDamage
	ld [hli], a
	ldh a, [hQuotient + 3]
	ld [hl], a
	ret

INCLUDE "data/battle/ai/constant_damage_effects.asm"
INCLUDE "data/battle/ai/two_turn_move_effects.asm"

AIAggessiveCheckTurnsToKOPlayer:
	ld hl, wCurDamage
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
	jr nc, .less_than_six_turns
	cp 6
	jr c, .loop
	jr .max_turns
.max_turns
	ld a, -1
.less_than_six_turns
	ret
	

AI_Cautious:
; Don't do this if player is switching.
	ld a, [wPlayerIsSwitching]
	and a
	ret nz
; 90% chance to discourage moves with residual effects after the first turn.

	ld a, [wEnemyTurnsTaken]
	and a
	ret z

	ld hl, wEnemyAIMoveScores - 1
	ld de, wEnemyMonMoves
	ld c, NUM_MOVES + 1
.loop
	inc hl
	dec c
	ret z

	ld a, [de]
	inc de
	and a
	ret z

	push hl
	push de
	push bc
	ld hl, ResidualMoves
	ld de, 1
	call IsInArray

	pop bc
	pop de
	pop hl
	jr nc, .loop

	call Random
	cp 90 percent + 1
	ret nc

	inc [hl]
	jr .loop

INCLUDE "data/battle/ai/residual_moves.asm"


AI_Status:
; Don't do this if player is switching.
	ld a, [wPlayerIsSwitching]
	and a
	ret nz
; Dismiss status moves that don't affect the player.

	ld hl, wEnemyAIMoveScores - 1
	ld de, wEnemyMonMoves
	ld b, NUM_MOVES + 1
.checkmove
	dec b
	ret z
	
	ld c, 0 ; Cleaning register c.
	inc hl
	ld a, [de]
	and a
	ret z

	inc de
	call AIGetEnemyMove
	
; Check if move is Leech Seed.
	ld a, [wEnemyMoveStruct + MOVE_EFFECT]
	cp EFFECT_LEECH_SEED
	jr z, .grassimmunity

; Check if the opponent is immune to powder/spore moves.      
	ld a, [wEnemyMoveStruct + MOVE_ANIM]
	push bc
	push de
	push hl
	ld hl, PowderMoves
	call IsInByteArray
	pop hl
	pop de
	pop bc
	jr nc, .normal_status_check

.grassimmunity
	ld a, [wBattleMonType1]
	cp GRASS
	jp z, .immune
	ld a, [wBattleMonType2]
	cp GRASS
	jr z, .immune

.normal_status_check
	ld a, [wEnemyMoveStruct + MOVE_EFFECT]
	cp EFFECT_TOXIC
	jr z, .poisonimmunity
	cp EFFECT_POISON
	jr z, .poisonimmunity
	cp EFFECT_SLEEP
	jr z, .typeimmunity
	cp EFFECT_PARALYZE
	jr z, .paralysisimmunity

; Discourage moves that inflict status ailments, confuse or lower stats 
; against a subtitute.
; This check also applies for Leech Seed and Swagger.
	cp EFFECT_LEECH_SEED
	jr z, .subs_check 
	cp EFFECT_CONFUSE
	jr z, .subs_check 

; Stat-lowering moves
	cp EFFECT_ATTACK_DOWN
	jr c, .powercheck
	cp EFFECT_EVASION_DOWN + 1
	jr c, .subs_check

	cp EFFECT_ATTACK_DOWN_2
	jr c, .powercheck
	cp EFFECT_EVASION_DOWN_2 + 1
	jr c, .subs_check

.powercheck
	ld a, [wEnemyMoveStruct + MOVE_POWER]
	ld c, a ; Store Move's Power in c.
	and a
	jr z, .checkmove

	jr .typeimmunity

.paralysisimmunity
	ld a, [wBattleMonType1]
	cp ELECTRIC
	jr z, .immune
	ld a, [wBattleMonType2]
	cp ELECTRIC
	jr z, .immune
	jr .typeimmunity
	
.poisonimmunity
	ld a, [wBattleMonType1]
	cp POISON
	jr z, .immune
	ld a, [wBattleMonType2]
	cp POISON
	jr z, .immune
	; fallthrough

.typeimmunity
	push hl
	push bc
	push de
	ld a, 1
	ldh [hBattleTurn], a
	farcall BattleCheckTypeMatchup
	pop de
	pop bc
	pop hl

	ld a, [wTypeMatchup]
	and a
	jr z, .immune
	; fallthrough

; ** Substitute check starts here **
.subs_check
	ld a, BATTLE_VARS_SUBSTATUS4_OPP
	call GetBattleVar
	bit SUBSTATUS_SUBSTITUTE, a
	jp z, .checkmove

	ld a, c ; Load Move's Power back into a.
	and a
	jp nz, .checkmove

.immune
	call AIDiscourageMove
	jp .checkmove


AI_Risky:
; Use any move that will KO the target.
; Risky moves will often be an exception (see below).

	ld hl, wEnemyAIMoveScores - 1
	ld de, wEnemyMonMoves
	ld c, NUM_MOVES + 1
.checkmove
	inc hl
	dec c
	ret z

	ld a, [de]
	inc de
	and a
	ret z

	push de
	push bc
	push hl
	call AIGetEnemyMove

	ld a, [wEnemyMoveStruct + MOVE_POWER]
	and a
	jr z, .nextmove

; Don't use risky moves at max hp.
	ld a, [wEnemyMoveStruct + MOVE_EFFECT]
	ld de, 1
	ld hl, RiskyEffects
	call IsInArray
	jr nc, .checkko

	call AICheckEnemyMaxHP
	jr c, .nextmove

; Else, 80% chance to exclude them.
	call Random
	cp 79 percent - 1
	jr c, .nextmove

.checkko
	call AIDamageCalc

	ld a, [wCurDamage + 1]
	ld e, a
	ld a, [wCurDamage]
	ld d, a
	ld a, [wBattleMonHP + 1]
	cp e
	ld a, [wBattleMonHP]
	sbc d
	jr nc, .nextmove

	pop hl
rept 5
	dec [hl]
endr
	push hl

.nextmove
	pop hl
	pop bc
	pop de
	jr .checkmove

INCLUDE "data/battle/ai/risky_effects.asm"

AI_None:
	ret

AIGetEnemyMove:
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

AI_80_20:
	call Random
	cp 20 percent - 1
	ret

AI_50_50:
	call Random
	cp 50 percent + 1
	ret
	
AI_60_40:
	call Random
	cp 40 percent - 1
	ret

AIDiscourageMove:
	ld a, [hl]
	add 10
	ld [hl], a
	ret
	
AI_Discourage_Greatly:
	call AI_Discourage
AI_Discourage:
	inc [hl]
	ret

AI_Encourage_Greatly:
	call AI_Encourage
AI_Encourage:
	dec [hl]
	ret
	