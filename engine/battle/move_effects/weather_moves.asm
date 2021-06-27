BattleCommand_StartRain:
; startrain
    ld b, WEATHER_RAIN
    jr BattleCommand_StartWeather

BattleCommand_StartSandstorm:
; startsandstorm
    ld b, WEATHER_SANDSTORM
    jr BattleCommand_StartWeather

BattleCommand_StartSun:
; startsun
    ld b, WEATHER_SUN
    ; fallthrough

BattleCommand_StartWeather:
;  Initialize weather
    ld a, [wBattleWeather]
    cp b
    jr z, .failed

    ld a, b
    ld hl, DownpourText
    cp WEATHER_RAIN
    jr z, .start
    cp WEATHER_SANDSTORM
    ld hl, SandstormBrewedText
    jr z, .start
    ld hl, SunGotBrightText

.start
    ld [wBattleWeather], a
    ld a, 5
    ld [wWeatherCount], a
    call AnimateCurrentMove

    jp StdBattleTextbox

.failed
    call AnimateFailedMove
    jp PrintButItFailed