BattleCommand_Spite:
; spite

	ld a, [wAttackMissed]
	and a
	jp nz, .failed
	ld hl, wBattleMonPP
	ld a, [hl]
	ld b, NUM_MOVES + 1
.loop_moves
	dec b
	jr z, .done
	
	cp 5
	jr nc, .subtract_pp
	ld a, 5
.subtract_pp
	sub 5
	ld [hl], a
	inc hl
	jr .loop_moves

.done
	ld hl, SpiteEffectText
	jp StdBattleTextbox

.failed
	jp PrintDidntAffect2
