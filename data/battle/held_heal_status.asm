; See also data/items/heal_status.asm

HeldStatusHealingEffects:
	db HELD_HEAL_POISON,   1 << PSN | 1 << TOX
	db HELD_HEAL_FROSTBITE,   1 << FRB
	db HELD_HEAL_BURN,     1 << BRN
	db HELD_HEAL_SLEEP,    SLP
	db HELD_HEAL_PARALYZE, 1 << PAR
	db HELD_HEAL_STATUS,   ALL_STATUS
	db -1 ; end
