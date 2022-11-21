; RestartClock_GetWraparoundTime.WrapAroundTimes indexes
	const_def 1
	const RESTART_CLOCK_DAY
	const RESTART_CLOCK_HOUR
	const RESTART_CLOCK_MIN
NUM_RESTART_CLOCK_DIVISIONS EQU const_value - 1

RestartClock_GetWraparoundTime:
	push hl
	dec a
	ld e, a
	ld d, 0
	ld hl, .WrapAroundTimes
rept 4
	add hl, de
endr
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
	ld b, [hl]
	inc hl
	ld c, [hl]
	pop hl
	ret

.WrapAroundTimes:
; entries correspond to RESTART_CLOCK_* constants
wraparound_time: MACRO
	dw \1 ; value pointer
	db \2 ; maximum value
	db \3 ; up/down arrow x coord (pairs with wRestartClockUpArrowYCoord)
ENDM
	wraparound_time wRestartClockDay,   7,  4
	wraparound_time wRestartClockHour, 24, 12
	wraparound_time wRestartClockMin,  60, 15

SetAlarm:
	call ClearSprites
	ld a, 12
	ld [wItemQuantity], a
	ld hl, .SetAlarmText
	call PrintText
	ld hl, SleepHours_MenuHeader
	call LoadMenuHeader
	call SleepHours_Loop
	jr c, .finish_2
	ld hl, .ClockIsThisOKText
	call PrintText
	call YesNoBox
	push af
	call ExitMenu
	pop af
	jr c, .finish

	ld hl, .AlarmDoneSetText
	call PrintText
	ld a, [wItemQuantityChange]
	ld b, a
	ldh a, [hHours]
	add b
	cp 24
	jr c, .continue_reset
	sub 24
	push af
	call GetWeekday
	inc a
	ld [wStringBuffer2], a
	pop af
.continue_reset
	ld [wStringBuffer2 + 1], a
	call InitTime
	ld hl, .SleepWakeUpText
	call PrintText
.finish
	ret

.finish_2
	push af
	call ExitMenu
	pop af
	ret

.SetAlarmText:
	text_far _SetAlarmText
	text_end

.SleepWakeUpText:
	text_far _SleepWakeUpText
	text_end

.AlarmDoneSetText:
	text_far _AlarmDoneSetText
	text_end

.ClockIsThisOKText:
	text_far _ClockIsThisOKText
	text_end

SleepHours_Loop:
	ld a, 1
	ld [wItemQuantityChange], a
.loop
	call SleepHours_UpdateTime 						; update display
	call SleepHours_InterpretJoypad       ; joy action
	jr nc, .loop
	cp -1
	jr nz, .nope ; pressed B
	scf
	ret

.nope
	and a
	ret

SleepHours_UpdateTime:
	call MenuBox
	call MenuBoxCoord2Tile
	ld de, SCREEN_WIDTH + 1
	add hl, de
	ld de, wItemQuantityChange
	lb bc, 1, 2
	call PrintNum
	ld a, [wMenuDataPointer]
	ld e, a
	ld a, [wMenuDataPointer + 1]
	ld d, a
	ld a, [wMenuDataBank]
	call FarCall_de
	ret

SleepHours_InterpretJoypad:
	call JoyTextDelay_ForcehJoyDown ; get joypad
	bit B_BUTTON_F, c
	jr nz, .b
	bit A_BUTTON_F, c
	jr nz, .a
	bit D_DOWN_F, c
	jr nz, .down
	bit D_UP_F, c
	jr nz, .up
	and a
	ret

.b
	ld a, -1
	scf
	ret

.a
	ld a, 0
	scf
	ret

.down
	ld hl, wItemQuantityChange
	dec [hl]
	jr nz, .finish_down
	ld a, [wItemQuantity]
	ld [hl], a

.finish_down
	and a
	ret

.up
	ld hl, wItemQuantityChange
	inc [hl]
	ld a, [wItemQuantity]
	cp [hl]
	jr nc, .finish_up
	ld [hl], 1

.finish_up
	and a
	ret

SleepHours_MenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 10, 9, SCREEN_WIDTH - 1, TEXTBOX_Y - 1
	dw PrintHours
	db 1 ; default option

PrintHours:
	hlcoord 14, 10
	ld de, .hours
	jp PlaceString

.hours:
	db "hours@"

RestartClock:
; If we're here, we had an RTC overflow.
	ld hl, .ClockTimeMayBeWrongText
	call PrintText

	ld hl, wOptions
	ld a, [hl]
	push af
	set NO_TEXT_SCROLL, [hl]
	call LoadStandardMenuHeader
	call ClearTilemap
	ld b, SCGB_DIPLOMA
	call GetSGBLayout
	call SetPalettes
	ld hl, .ClockSetWithControlPadText
	call PrintText
	call .SetClock
	call ExitMenu
	pop bc
	ld hl, wOptions
	ld [hl], b
	ld c, a
	ret

.ClockTimeMayBeWrongText:
	text_far _ClockTimeMayBeWrongText
	text_end

.ClockSetWithControlPadText:
	text_far _ClockSetWithControlPadText
	text_end

.SetClock:
	ld a, RESTART_CLOCK_DAY
	ld [wRestartClockCurDivision], a
	ld [wRestartClockPrevDivision], a
	ld a, 8
	ld [wRestartClockUpArrowYCoord], a
	call UpdateTime
	call GetWeekday
	ld [wRestartClockDay], a
	ldh a, [hHours]
	ld [wRestartClockHour], a
	ldh a, [hMinutes]
	ld [wRestartClockMin], a

.loop
	call .joy_loop
	jr nc, .loop
	and a
	ret nz
	call .PrintTime
	ld hl, .ClockIsThisOKText
	call PrintText
	call YesNoBox
	jr c, .cancel
	ld a, [wRestartClockDay]
	ld [wStringBuffer2], a
	ld a, [wRestartClockHour]
	ld [wStringBuffer2 + 1], a
	ld a, [wRestartClockMin]
	ld [wStringBuffer2 + 2], a
	xor a
	ld [wStringBuffer2 + 3], a
	call InitTime
	call .PrintTime
	ld hl, .ClockHasResetText
	call PrintText
	call WaitPressAorB_BlinkCursor
	xor a ; FALSE
	ret

.cancel
	ld a, TRUE
	ret

.ClockIsThisOKText:
	text_far _ClockIsThisOKText
	text_end

.ClockHasResetText:
	text_far _ClockHasResetText
	text_end

.joy_loop
	call JoyTextDelay_ForcehJoyDown
	ld c, a
	push af
	call .PrintTime
	pop af
	bit 0, a
	jr nz, .press_A
	bit 1, a
	jr nz, .press_B
	bit 6, a
	jr nz, .pressed_up
	bit 7, a
	jr nz, .pressed_down
	bit 5, a
	jr nz, .pressed_left
	bit 4, a
	jr nz, .pressed_right
	jr .joy_loop

.press_A
	ld a, FALSE
	scf
	ret

.press_B
	ld a, TRUE
	scf
	ret

.pressed_up
	ld a, [wRestartClockCurDivision]
	call RestartClock_GetWraparoundTime
	ld a, [de]
	inc a
	ld [de], a
	cp b
	jr c, .done_scroll
	ld a, 0
	ld [de], a
	jr .done_scroll

.pressed_down
	ld a, [wRestartClockCurDivision]
	call RestartClock_GetWraparoundTime
	ld a, [de]
	dec a
	ld [de], a
	cp -1
	jr nz, .done_scroll
	ld a, b
	dec a
	ld [de], a
	jr .done_scroll

.pressed_left
	ld hl, wRestartClockCurDivision
	dec [hl]
	jr nz, .done_scroll
	ld [hl], RESTART_CLOCK_MIN
	jr .done_scroll

.pressed_right
	ld hl, wRestartClockCurDivision
	inc [hl]
	ld a, [hl]
	cp NUM_RESTART_CLOCK_DIVISIONS + 1
	jr c, .done_scroll
	ld [hl], RESTART_CLOCK_DAY

.done_scroll
	xor a ; FALSE
	ret

.PrintTime:
	hlcoord 0, 5
	ld b, 5
	ld c, 18
	call Textbox
	decoord 1, 8
	ld a, [wRestartClockDay]
	ld b, a
	farcall PrintDayOfWeek
	ld a, [wRestartClockHour]
	ld b, a
	ld a, [wRestartClockMin]
	ld c, a
	decoord 11, 8
	farcall PrintHoursMins
	ld a, [wRestartClockPrevDivision]
	lb de, " ", " "
	call .PlaceChars
	ld a, [wRestartClockCurDivision]
	lb de, "▲", "▼"
	call .PlaceChars
	ld a, [wRestartClockCurDivision]
	ld [wRestartClockPrevDivision], a
	ret


.PlaceChars:
	push de
	call RestartClock_GetWraparoundTime
	ld a, [wRestartClockUpArrowYCoord]
	dec a
	ld b, a
	call Coord2Tile
	pop de
	ld [hl], d
	ld bc, 2 * SCREEN_WIDTH
	add hl, bc
	ld [hl], e
	ret

JPHourString: ; unreferenced
	db "じ@" ; HR

JPMinuteString: ; unreferenced
	db "ふん@" ; MIN
