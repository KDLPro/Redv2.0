INCLUDE "gfx/font.asm"

EnableHDMAForGraphics:
	db FALSE

Get1bppOptionalHDMA: ; unreferenced
	ld a, [EnableHDMAForGraphics]
	and a
	jp nz, Get1bppViaHDMA
	jp Get1bpp

Get2bppOptionalHDMA: ; unreferenced
	ld a, [EnableHDMAForGraphics]
	and a
	jp nz, Get2bppViaHDMA
	jp Get2bpp

_LoadBattleCoreFont::
_LoadStandardFont::
	ld de, Font
	ld hl, vTiles1
	lb bc, BANK(Font), 32 ; "A" to "]"
	call Get2bppViaHDMA
	ld de, Font + 32 * LEN_2BPP_TILE
	ld hl, vTiles1 tile $20
	lb bc, BANK(Font), 26 ; "a" to "z" (skip "┌" to "┘")
	call Get2bppViaHDMA
	ld de, Font + 64 * LEN_2BPP_TILE
	ld hl, vTiles1 tile $40
	lb bc, BANK(Font), 32 ; "SLP" to "←"
	call Get2bppViaHDMA
	ld de, Font + 96 * LEN_2BPP_TILE
	ld hl, vTiles1 tile $60
	lb bc, BANK(Font), 32 ; "'" to "9"
	jp Get2bppViaHDMA
	
_LoadInversedFont::
	ld de, FontInversed
	ld hl, vTiles1
	lb bc, BANK(FontInversed), 32 ; "A" to "]"
	call Get2bppViaHDMA
	ld de, FontInversed + 32 * LEN_2BPP_TILE
	ld hl, vTiles1 tile $20
	lb bc, BANK(FontInversed), 26 ; "a" to "z" (skip "┌" to "┘")
	call Get2bppViaHDMA
	ld de, FontInversed + 64 * LEN_2BPP_TILE
	ld hl, vTiles1 tile $40
	lb bc, BANK(FontInversed), 32 ; "SLP" to "←"
	call Get2bppViaHDMA
	ld de, FontInversed + 96 * LEN_2BPP_TILE
	ld hl, vTiles1 tile $60
	lb bc, BANK(FontInversed), 32 ; "'" to "9"
	jp Get2bppViaHDMA

_LoadFontsExtra1::
	jr LoadFrame

_LoadFontsExtra2::
	ret

_LoadFontsBattleExtra::
	ld de, FontBattleExtra
	ld hl, vTiles2 tile $60
	lb bc, BANK(FontBattleExtra), 25
	call Get2bppViaHDMA
	jr LoadFrame

LoadFrame:
	ld a, [wTextboxFrame]
	maskbits NUM_FRAMES
	ld bc, 6 * LEN_1BPP_TILE
	ld hl, Frames
	call AddNTimes
	ld d, h
	ld e, l
	ld hl, vTiles0 tile "┌" ; $ba
	lb bc, BANK(Frames), 6 ; "┌" to "┘"
	call Get1bppViaHDMA
	ld hl, vTiles2 tile " " ; $7f
	ld de, TextboxSpaceGFX
	lb bc, BANK(TextboxSpaceGFX), 1
	call Get1bppViaHDMA
	ret

LoadBattleFontsHPBar:
	ld de, FontBattleExtra
	ld hl, vTiles2 tile $60
	lb bc, BANK(FontBattleExtra), 12
	call Get2bppViaHDMA
	ld hl, vTiles2 tile $70
	ld de, FontBattleExtra + 16 tiles ; "<DO>"
	lb bc, BANK(FontBattleExtra), 3 ; "<DO>" to "『"
	call Get2bppViaHDMA
	call LoadFrame

LoadHPBar:
	ld de, EnemyHPBarBorderGFX
	ld hl, vTiles2 tile $6c
	lb bc, BANK(EnemyHPBarBorderGFX), 4
	call Get1bppViaHDMA
	ld de, HPExpBarBorderGFX
	ld hl, vTiles2 tile $73
	lb bc, BANK(HPExpBarBorderGFX), 8
	call Get2bppViaHDMA
	ld de, ExpBarGFX
	ld hl, vTiles2 tile $55
	lb bc, BANK(ExpBarGFX), 11
	jp Get2bppViaHDMA

StatsScreen_LoadFont:
	call _LoadBattleCoreFont
	ld de, GenderGFX
	ld hl, vTiles2 tile $7b
	lb bc, BANK(GenderGFX), 2 
	call Get1bppViaHDMA
	ld de, EnemyHPBarBorderGFX
	ld hl, vTiles2 tile $6c
	lb bc, BANK(EnemyHPBarBorderGFX), 4
	call Get1bppViaHDMA
	ld de, HPExpBarBorderGFX
	ld hl, vTiles2 tile $78
	lb bc, BANK(HPExpBarBorderGFX), 1
	call Get2bppViaHDMA
	ld de, HPExpBarBorderGFX + 3 * LEN_2BPP_TILE
	ld hl, vTiles2 tile $76
	lb bc, BANK(HPExpBarBorderGFX), 2
	call Get2bppViaHDMA
	ld de, ExpBarGFX
	ld hl, vTiles2 tile $55
	lb bc, BANK(ExpBarGFX), 10
	call Get2bppViaHDMA
LoadStatsScreenPageTilesGFX:
	ld de, StatsScreenPageTilesGFX
	ld hl, vTiles2 tile $31
	lb bc, BANK(StatsScreenPageTilesGFX), 17
	jp Get2bppViaHDMA