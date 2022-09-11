SpeedCheckWhoGoesFirst:
	ld de, wBattleMonSpeed
	ld hl, wEnemyMonSpeed
	ld c, 2
	call CompareBytes
	jr z, .speed_tie
	jr nc, .player_first
	jr .enemy_first
	
.speed_tie
	ldh a, [hSerialConnectionStatus]
	cp USING_INTERNAL_CLOCK
	jr z, .player_2c
	call BattleRandom
	cp 50 percent + 1
	jp c, .player_first
	jp .enemy_first

.player_2c
	call BattleRandom
	cp 50 percent + 1
	jp c, .enemy_first

.player_first
	ld a, 0
	ld [wEnemyShouldGoFirst], a
	ret

.enemy_first
	ld a, 1
	ld [wEnemyShouldGoFirst], a
	ret

    GetWeatherImage:
	ld a, [wBattleWeather]
	dec a
	jr z, .rain
	dec a
	jr z, .sun
	dec a
	jr z, .sand
	; dec a
	; jr z, .hail
	ld a, [wTimeOfDay]
	cp 2
	jr z, .clear_night
	jr .clear_day
	
.rain
	farcall SetPalettes_Rain
	ld de, RainWeatherImage
	lb bc, PAL_BATTLE_OB_BROWN, 6
	jr z, .done	
	
.sun
	farcall SetPalettes_Sun
	ld de, SunWeatherImage
	lb bc, PAL_BATTLE_OB_BROWN, 6
	jr z, .done	
	
.hail
	farcall SetPalettes_Hail
	ld de, HailWeatherImage
	lb bc, PAL_BATTLE_OB_BROWN, 6
	jr z, .done	
	
.sand
	farcall SetPalettes_Sand
	ld de, SandstormWeatherImage
	lb bc, PAL_BATTLE_OB_BROWN, 6
	jr z, .done
	
.clear_day
	farcall SetPalettes_ClearDay
	ld de, ClearDayWeatherImage
	lb bc, PAL_BATTLE_OB_BROWN, 6
	jr z, .done

.clear_night
	farcall SetPalettes_ClearNight
	ld de, ClearNightWeatherImage
	lb bc, PAL_BATTLE_OB_BROWN, 6
	
.done
	push bc
	ld b, BANK(WeatherImages) ; c = 6
	ld hl, vTiles0 tile $02
	call Request2bpp
	pop bc
	ld hl, wVirtualOAMSprite02
	ld de, .WeatherImageOAMData
.loop
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [de]
	inc de
	ld [hli], a
	dec c
	ld a, c
	ld [hli], a
	ld a, b
	ld [hli], a
	jr nz, .loop
	ret

.WeatherImageOAMData
; positions are backwards since
; we load them in reverse order
	db $88, $1c ; y/x - bottom right
	db $88, $14 ; y/x - bottom left
	db $80, $1c ; y/x - top right
	db $80, $14 ; y/x - top left
	