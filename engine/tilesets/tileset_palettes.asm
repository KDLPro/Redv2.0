LoadSpecialMapPalette:
	ld a, [wMapTileset]
	cp TILESET_POKECOM_CENTER
	jr z, .pokecom_2f
	cp TILESET_BATTLE_TOWER_INSIDE
	jr z, .battle_tower_inside
	cp TILESET_ICE_PATH
	jr z, .ice_path
	cp TILESET_HOUSE
	jr z, .house
	cp TILESET_RADIO_TOWER
	jr z, .radio_tower
	cp TILESET_MANSION
	jr z, .mansion_mobile
	cp TILESET_MUSEUM
	jr z, .museum
	cp TILESET_SSANNE
	jr z, .ss_anne
	cp TILESET_SS_ANNE_ROOMS_1
	jr z, .ss_anne_rooms_1
	cp TILESET_SS_ANNE_ROOMS_2
	jr z, .ss_anne_rooms_2
	cp TILESET_SS_ANNE_CAPTAIN
	jr z, .ss_anne_captain
	cp TILESET_SS_ANNE_DECK
	jr z, .ss_anne_deck
	jr .do_nothing

.pokecom_2f
	call LoadPokeComPalette
	scf
	ret

.battle_tower_inside
	call LoadBattleTowerInsidePalette
	scf
	ret

.ice_path
	ld a, [wEnvironment]
	and $7
	cp INDOOR ; Hall of Fame
	jr z, .do_nothing
	call LoadIcePathPalette
	scf
	ret

.house
	call LoadHousePalette
	scf
	ret

.radio_tower
	call LoadRadioTowerPalette
	scf
	ret

.mansion_mobile
	call LoadMansionPalette
	scf
	ret
	
.museum
	call LoadMuseumPalette
	scf
	ret
	
.ss_anne
	call LoadSSAnnePalette
	scf
	ret
	
.ss_anne_rooms_1
	call LoadSSAnneRooms1Palette
	scf
	ret
	
.ss_anne_rooms_2
	call LoadSSAnneRooms2Palette
	scf
	ret
	
.ss_anne_captain
	call LoadSSAnneCaptainPalette
	scf
	ret
	
.ss_anne_deck
	call LoadSSAnneDeckPalette
	scf
	ret

.do_nothing
	and a
	ret

LoadPokeComPalette:
	ld a, BANK(wBGPals1)
	ld de, wBGPals1
	ld hl, PokeComPalette
	ld bc, 8 palettes
	call FarCopyWRAM
	ret

PokeComPalette:
INCLUDE "gfx/tilesets/pokecom_center.pal"

LoadBattleTowerInsidePalette:
	ld a, BANK(wBGPals1)
	ld de, wBGPals1
	ld hl, BattleTowerInsidePalette
	ld bc, 8 palettes
	call FarCopyWRAM
	ret

BattleTowerInsidePalette:
INCLUDE "gfx/tilesets/battle_tower_inside.pal"

LoadIcePathPalette:
	ld a, BANK(wBGPals1)
	ld de, wBGPals1
	ld hl, IcePathPalette
	ld bc, 8 palettes
	call FarCopyWRAM
	ret

IcePathPalette:
INCLUDE "gfx/tilesets/ice_path.pal"

LoadHousePalette:
	ld a, BANK(wBGPals1)
	ld de, wBGPals1
	ld hl, HousePalette
	ld bc, 8 palettes
	call FarCopyWRAM
	ret

HousePalette:
INCLUDE "gfx/tilesets/house.pal"

LoadRadioTowerPalette:
	ld a, BANK(wBGPals1)
	ld de, wBGPals1
	ld hl, RadioTowerPalette
	ld bc, 8 palettes
	call FarCopyWRAM
	ret

RadioTowerPalette:
INCLUDE "gfx/tilesets/radio_tower.pal"

LoadMuseumPalette:
	ld a, BANK(wBGPals1)
	ld de, wBGPals1
	ld hl, MuseumPalette
	ld bc, 8 palettes
	call FarCopyWRAM
	ret

MuseumPalette:
INCLUDE "gfx/tilesets/museum.pal"

LoadSSAnnePalette:
	ld a, BANK(wBGPals1)
	ld de, wBGPals1
	ld hl, SSAnnePalette
	ld bc, 8 palettes
	call FarCopyWRAM
	ret

SSAnnePalette:
INCLUDE "gfx/tilesets/ss_anne.pal"

LoadSSAnneRooms1Palette:
	ld a, BANK(wBGPals1)
	ld de, wBGPals1
	ld hl, SSAnneRooms1Palette
	ld bc, 8 palettes
	call FarCopyWRAM
	ret

SSAnneRooms1Palette:
INCLUDE "gfx/tilesets/ss_anne_rooms_1.pal"

LoadSSAnneRooms2Palette:
	ld a, BANK(wBGPals1)
	ld de, wBGPals1
	ld hl, SSAnneRooms2Palette
	ld bc, 8 palettes
	call FarCopyWRAM
	ret

SSAnneRooms2Palette:
INCLUDE "gfx/tilesets/ss_anne_rooms_2.pal"

LoadSSAnneCaptainPalette:
	ld a, BANK(wBGPals1)
	ld de, wBGPals1
	ld hl, SSAnneCaptainPalette
	ld bc, 8 palettes
	call FarCopyWRAM
	ret

SSAnneCaptainPalette:
INCLUDE "gfx/tilesets/ssanne_captain.pal"

LoadSSAnneDeckPalette:
	ld a, BANK(wBGPals1)
	ld de, wBGPals1
	ld hl, SSAnneDeckPalette
	ld bc, 8 palettes
	call FarCopyWRAM
	ret

SSAnneDeckPalette:
INCLUDE "gfx/tilesets/ssanne_deck.pal"

MansionPalette1:
INCLUDE "gfx/tilesets/mansion_1.pal"

LoadMansionPalette:
	ld a, BANK(wBGPals1)
	ld de, wBGPals1
	ld hl, MansionPalette1
	ld bc, 8 palettes
	call FarCopyWRAM
	ld a, BANK(wBGPals1)
	ld de, wBGPals1 palette PAL_BG_YELLOW
	ld hl, MansionPalette2
	ld bc, 1 palettes
	call FarCopyWRAM
	ld a, BANK(wBGPals1)
	ld de, wBGPals1 palette PAL_BG_WATER
	ld hl, MansionPalette1 palette 6
	ld bc, 1 palettes
	call FarCopyWRAM
	ld a, BANK(wBGPals1)
	ld de, wBGPals1 palette PAL_BG_ROOF
	ld hl, MansionPalette1 palette 8
	ld bc, 1 palettes
	call FarCopyWRAM
	ret

MansionPalette2:
INCLUDE "gfx/tilesets/mansion_2.pal"
