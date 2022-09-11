_ReturnToBattle_UseBall:
	call ClearBGPalettes
	call ClearTilemap
	ld a, [wBattleType]
	cp BATTLETYPE_TUTORIAL
	jr z, .gettutorialbackpic
	farcall GetBattleMonBackpic
	jr .continue

.gettutorialbackpic
	farcall GetTrainerBackpic
.continue
	farcall GetEnemyMonFrontpic
	ld a, PAL_BATTLE_OB_RED
	ld [wBattleAnimTempPalette], a
	farcall _LoadBattleFontsHPBar
	call GetMemSGBLayout
	call CloseWindow
	call LoadStandardMenuHeader
	call WaitBGMap
	jp SetPalettes
