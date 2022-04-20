BattleCommand_Acid:
; Deals double damage to Steel-types
	ld hl, wEnemyMonType1
    ldh a, [hBattleTurn]
    and a
    jr z, .checksteeltype
    ld hl, wBattleMonType1
	
.checksteeltype
	ld a, [hli]
    cp STEEL
    jp z, .DoubleDamage
    ld a, [hl]
    cp STEEL
    ret nz
	; fallthrough
.DoubleDamage
	jp DoubleDamage
	
BattleCommand_AcidSuperEffectiveText:
	ld hl, wEnemyMonType1
    ldh a, [hBattleTurn]
    and a
    jr z, .checksteeltype
    ld hl, wBattleMonType1
	
.checksteeltype
	ld a, [hli]
    cp STEEL
    jp z, .SEText
    ld a, [hl]
    cp STEEL
    ret nz
	; fallthrough
.SEText
	ld hl, AcidSuperEffectiveText
	jp StdBattleTextbox
	