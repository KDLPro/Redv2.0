AISwitchChooseMove:
	; to account for prediction
	ld hl, TrainerClassAttributes + TRNATTR_AI_MOVE_WEIGHTS
    
	; Do this for AI_SMART
	
    ld a, [wTrainerClass]
    dec a
    ld bc, NUM_TRAINER_ATTRIBUTES
    call AddNTimes
    
    ld a, BANK(TrainerClassAttributes)
    call GetFarByte
    and AI_SMART
    ret z
	
	; Don't do this if it's a wild battle.
	ld a, [wBattleMode]
	dec a
	ret z
	
	;... or a link battle.	
	ld a, [wLinkMode]
	and a
	ret nz
	
	; Don't do this if number of alive Pokémon in
	; player's party is 2 or less.
	call CheckFitMons
	ld a, d
	cp 3
	ret c
	
	ld hl, wEnemyMonMoves
	ld b, NUM_MOVES + 1
.checkmove
	dec b
	jr z, .done_checking_moves

	ld a, [hl]
	and a
	jr z, .done_checking_moves
	cp PURSUIT
	ret z

	inc hl
	jr .checkmove
	
.done_checking_moves

; Higher chance to predict if player has bad matchup or if player did switched.
	ld a, [wPlayerIsSwitching]
	and a
	jr nz, .switched

	ld a, [wEnemyAISwitchScore]
	cp BASE_AI_SWITCH_SCORE + 1
	ret c 

.switched	
	call Random
	cp 35 percent + 1
	ret nc
	
.choose_move
; No use picking a move if there's no choice.
	farcall CheckEnemyLockedIn
	ret nz

; The default score is 20. Unusable moves are given a score of 80.
	ld a, 20
	ld hl, wEnemyAIMoveScores
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a

; Don't pick disabled moves.
	ld a, [wEnemyDisabledMove]
	and a
	jr z, .CheckPP

	ld hl, wEnemyMonMoves
	ld c, 0
.CheckDisabledMove:
	cp [hl]
	jr z, .ScoreDisabledMove
	inc c
	inc hl
	jr .CheckDisabledMove
.ScoreDisabledMove:
	ld hl, wEnemyAIMoveScores
	ld b, 0
	add hl, bc
	ld [hl], 80

; Don't pick moves with 0 PP.
.CheckPP:
	ld hl, wEnemyAIMoveScores - 1
	ld de, wEnemyMonPP
	ld b, 0
.CheckMovePP:
	inc b
	ld a, b
	cp NUM_MOVES + 1
	jr z, .ApplyLayers
	inc hl
	ld a, [de]
	inc de
	and PP_MASK
	jr nz, .CheckMovePP
	ld [hl], 80
	jr .CheckMovePP

.ApplyLayers:	
	ld a, [wPlayerIsSwitching]
	and a
	jp nz, ApplyLayers
	
	call AI_Bad_Prediction
	farcall AI_Smart
	jp DecrementMoveScores

AIChooseMove:
; Score each move of wEnemyMonMoves in wEnemyAIMoveScores. Lower is better.
; Pick the move with the lowest score.

; Wildmons attack at random.
	ld a, [wBattleMode]
	dec a
	ret z

	ld a, [wLinkMode]
	and a
	ret nz
	
	ld hl, EnemyIsThinkingText
	call StdBattleTextbox

; No use picking a move if there's no choice.
	farcall CheckEnemyLockedIn
	ret nz

; The default score is 20. Unusable moves are given a score of 80.
	ld a, 20
	ld hl, wEnemyAIMoveScores
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a

; Don't pick disabled moves.
	ld a, [wEnemyDisabledMove]
	and a
	jr z, .CheckPP

	ld hl, wEnemyMonMoves
	ld c, 0
.CheckDisabledMove:
	cp [hl]
	jr z, .ScoreDisabledMove
	inc c
	inc hl
	jr .CheckDisabledMove
.ScoreDisabledMove:
	ld hl, wEnemyAIMoveScores
	ld b, 0
	add hl, bc
	ld [hl], 80

; Don't pick moves with 0 PP.
.CheckPP:
	ld hl, wEnemyAIMoveScores - 1
	ld de, wEnemyMonPP
	ld b, 0
.CheckMovePP:
	inc b
	ld a, b
	cp NUM_MOVES + 1
	jr z, ApplyLayers
	inc hl
	ld a, [de]
	inc de
	and PP_MASK
	jr nz, .CheckMovePP
	ld [hl], 80
	jr .CheckMovePP

; Apply AI scoring layers depending on the trainer class.
ApplyLayers:
	ld hl, TrainerClassAttributes + TRNATTR_AI_MOVE_WEIGHTS

	; If we have a battle in BattleTower just load the Attributes of the first trainer class in wTrainerClass (Falkner)
	; so we have always the same AI, regardless of the loaded class of trainer
	ld a, [wInBattleTowerBattle]
	bit 0, a
	jr nz, .battle_tower_skip

	ld a, [wTrainerClass]
	dec a
	ld bc, 7 ; Trainer2AI - Trainer1AI
	call AddNTimes

.battle_tower_skip
	lb bc, CHECK_FLAG, 0
	push bc
	push hl

.CheckLayer:
	pop hl
	pop bc

	ld a, c
	cp 16 ; up to 16 scoring layers
	jr z, DecrementMoveScores

	push bc
	ld d, BANK(TrainerClassAttributes)
	predef SmallFarFlagAction
	ld d, c
	pop bc

	inc c
	push bc
	push hl

	ld a, d
	and a
	jr z, .CheckLayer

	ld hl, AIScoringPointers
	dec c
	ld b, 0
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, BANK(AIScoring)
	call FarCall_hl

	jr .CheckLayer

; Decrement the scores of all moves one by one until one reaches 0.
DecrementMoveScores:
	ld hl, wEnemyAIMoveScores
	ld de, wEnemyMonMoves
	ld c, NUM_MOVES

.DecrementNextScore:
	; If the enemy has no moves, this will infinite.
	ld a, [de]
	inc de
	and a
	jr z, DecrementMoveScores

	; We are done whenever a score reaches 0
	dec [hl]
	jr z, .PickLowestScoreMoves

	; If we just decremented the fourth move's score, go back to the first move
	inc hl
	dec c
	jr z, DecrementMoveScores

	jr .DecrementNextScore

; In order to avoid bias towards the moves located first in memory, increment the scores
; that were decremented one more time than the rest (in case there was a tie).
; This means that the minimum score will be 1.
.PickLowestScoreMoves:
	ld a, c

.move_loop
	inc [hl]
	dec hl
	inc a
	cp NUM_MOVES + 1
	jr nz, .move_loop

	ld hl, wEnemyAIMoveScores
	ld de, wEnemyMonMoves
	ld c, NUM_MOVES

; Give a score of 0 to a blank move
.loop2
	ld a, [de]
	and a
	jr nz, .skip_load
	ld [hl], a

; Disregard the move if its score is not 1
.skip_load
	ld a, [hl]
	dec a
	jr z, .keep
	xor a
	ld [hli], a
	jr .after_toss

.keep
	ld a, [de]
	ld [hli], a
.after_toss
	inc de
	dec c
	jr nz, .loop2

; Randomly choose one of the moves with a score of 1
.ChooseMove:
	ld hl, wEnemyAIMoveScores
	call Random
	maskbits NUM_MOVES
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [hl]
	and a
	jr z, .ChooseMove

	ld [wCurEnemyMove], a
	ld a, c
	ld [wCurEnemyMoveNum], a
	ret

AIScoringPointers:
; entries correspond to AI_* constants
	dw AI_Basic
	dw AI_Setup
	dw AI_Types
	dw AI_Offensive
	dw AI_Smart
	dw AI_Opportunist
	dw AI_Aggressive
	dw AI_Cautious
	dw AI_Status
	dw AI_Risky
	dw AI_None
	dw AI_None
	dw AI_None
	dw AI_None
	dw AI_None
	dw AI_None
	
AI_Bad_Prediction:
; Use whatever does the least damage.

; Discourage all damaging moves that deal high damage unless they're reckless too.
	ld hl, wEnemyAIMoveScores - 1
	ld de, wEnemyMonMoves
	ld bc, 0
.checkmove
	inc b
	ld a, b
	cp NUM_MOVES + 1
	jp z, .done

	push hl
	push de
	push bc
	ld a, [de]
	call AIGetEnemyMove2
	ld a, [wEnemyMoveStruct + MOVE_POWER]
	and a
	jp z, .nodamage
	push hl
	farcall AIDamageCalc
	pop hl
	pop de
	push de
	dec hl
	ld a, [hli]
	cp PURSUIT 
	jr nz, .not_pursuit
	push hl
	farcall PursuitDamage
	pop hl
	
.not_pursuit
	pop bc
	pop de
	pop hl
	
	inc de
	inc hl
	
	push hl
	push de
	push bc
	call AIBadMatchupCheckTurnsToKOPlayer
	pop bc
	pop de
	pop hl

.check_ohko	
; Discourage moves that can OHKO and have perfect accuracy.
	cp 1
	jr nz, .check_turns_to_ko_1
	
	ld a, [wEnemyMoveStruct + MOVE_ACC]
	cp 99 percent + 1
	jr c, .check_turns_to_ko_1
	
	call AIDiscourageMove2
	
; Discourage moves that have no recoil.
	
	ld a, [wEnemyMoveStruct + MOVE_EFFECT]
	cp EFFECT_RECOIL_HIT
	jr z, .check_turns_to_ko_1
	
	call AIDiscourageMove2
	
.check_turns_to_ko_1
	push hl
	push de
	push bc
	call AIBadMatchupCheckTurnsToKOPlayer
	pop bc
	pop de
	pop hl

	cp 5
	jr c, .check_turns_to_ko_2
	
	
	call AI_Encourage_Greatly2

.check_turns_to_ko_2
	push hl
	push de
	push bc
	call AIBadMatchupCheckTurnsToKOPlayer
	pop bc
	pop de
	pop hl
	
; Discourage this move it takes 2 or less hits to KO player
	cp 3
	jp c, .checkmove
	
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

; If we made it this far, encourage this move.
	call AI_Encourage2
	jp .checkmove
	
.nodamage
	pop bc
	pop de
	pop hl
	inc de
	inc hl
	jp .checkmove
	
.done
	ld a, 0
	ld [wCurDamage], a
	ld [wCurDamage+1], a
	ret
	
AIGetEnemyMove2:
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
	
AIBadMatchupCheckTurnsToKOPlayer:
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
.just_fainted
	xor a
	ld [wEnemyMonJustFainted], a
.max_turns
	ld a, -1
.less_than_six_turns
	ret
	
AIDiscourageMove2:
	ld a, [hl]
	add 10
	ld [hl], a
	ret
	
AI_Discourage_Greatly2:
	call AI_Discourage
AI_Discourage2:
	inc [hl]
	ret

AI_Encourage_Greatly2:
	call AI_Encourage2
AI_Encourage2:
	dec [hl]
	ret
	
CheckFitMons:
; Has the player any mon in his Party that can fight?
	ld a, [wPartyCount]
	ld e, a
	xor a
	ld hl, wPartyMon1HP
	ld bc, PARTYMON_STRUCT_LENGTH - 1
.loop
	or [hl]
	inc hl ; + 1
	or [hl]
	add hl, bc
	dec e
	jr nz, .loop
	ld d, a
	ret
	
