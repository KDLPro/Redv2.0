TrainerClassAttributes:
; entries correspond to trainer classes (see constants/trainer_constants.asm)

; Falkner
	db POTION, NO_ITEM ; items
	db 25 ; base reward
	dw AI_SETUP | AI_SMART | AI_AGGRESSIVE | AI_STATUS
	dw CONTEXT_USE | SWITCH_COMPETITIVE

; Whitney
	db POTION, SUPER_POTION ; items
	db 25 ; base reward
	dw AI_SETUP | AI_SMART | AI_AGGRESSIVE | AI_STATUS
	dw CONTEXT_USE | SWITCH_COMPETITIVE

; Bugsy
	db POTION, NO_ITEM ; items
	db 25 ; base reward
	dw AI_SETUP | AI_SMART | AI_AGGRESSIVE | AI_STATUS
	dw CONTEXT_USE | SWITCH_COMPETITIVE

; Morty
	db LEMONADE, NO_ITEM ; items
	db 25 ; base reward
	dw AI_SETUP | AI_SMART | AI_AGGRESSIVE | AI_STATUS
	dw CONTEXT_USE | SWITCH_COMPETITIVE

; Pryce
	db HYPER_POTION, NO_ITEM ; items
	db 25 ; base reward
	dw AI_BASIC | AI_SMART | AI_STATUS | AI_AGGRESSIVE | AI_OPPORTUNIST | AI_TYPES
	dw CONTEXT_USE | SWITCH_COMPETITIVE

; Jasmine
	db HYPER_POTION, NO_ITEM ; items
	db 25 ; base reward
	dw AI_BASIC | AI_SMART | AI_STATUS | AI_AGGRESSIVE | AI_OPPORTUNIST | AI_TYPES
	dw CONTEXT_USE | SWITCH_COMPETITIVE

; Chuck
	db FULL_HEAL, NO_ITEM ; items
	db 25 ; base reward
	dw AI_BASIC | AI_SMART | AI_STATUS | AI_AGGRESSIVE | AI_OPPORTUNIST | AI_TYPES
	dw CONTEXT_USE | SWITCH_COMPETITIVE

; Clair
	db FULL_HEAL, HYPER_POTION ; items
	db 25 ; base reward
	dw AI_BASIC | AI_SMART | AI_STATUS | AI_AGGRESSIVE | AI_OPPORTUNIST | AI_TYPES
	dw CONTEXT_USE | SWITCH_COMPETITIVE
	
; Rival1
	db NO_ITEM, NO_ITEM ; items
	db 15 ; base reward
	dw AI_SETUP | AI_SMART | AI_AGGRESSIVE | AI_CAUTIOUS | AI_STATUS | AI_RISKY
	dw CONTEXT_USE | SWITCH_COMPETITIVE

; Pokemon Prof
	db NO_ITEM, NO_ITEM ; items
	db 25 ; base reward
	dw AI_BASIC | AI_AGGRESSIVE | AI_STATUS
	dw CONTEXT_USE | SWITCH_SOMETIMES

; Will
	db MAX_POTION, NO_ITEM ; items
	db 25 ; base reward
	dw AI_BASIC | AI_SETUP | AI_SMART | AI_AGGRESSIVE | AI_CAUTIOUS | AI_STATUS | AI_RISKY
	dw CONTEXT_USE | SWITCH_SOMETIMES

; Cal
	db NO_ITEM, NO_ITEM ; items
	db 25 ; base reward
	dw AI_SETUP | AI_SMART | AI_AGGRESSIVE | AI_STATUS
	dw CONTEXT_USE | SWITCH_COMPETITIVE

; Bruno
	db MAX_POTION, NO_ITEM ; items
	db 25 ; base reward
	dw AI_SETUP | AI_SMART | AI_AGGRESSIVE | AI_STATUS
	dw CONTEXT_USE | SWITCH_COMPETITIVE

; Karen
	db FULL_HEAL, MAX_POTION ; items
	db 25 ; base reward
	dw AI_SETUP | AI_SMART | AI_AGGRESSIVE | AI_STATUS
	dw CONTEXT_USE | SWITCH_COMPETITIVE

; Koga
	db FULL_HEAL, FULL_RESTORE ; items
	db 25 ; base reward
	dw AI_SETUP | AI_SMART | AI_AGGRESSIVE | AI_STATUS
	dw CONTEXT_USE | SWITCH_COMPETITIVE

; Champion
	db FULL_HEAL, FULL_RESTORE ; items
	db 25 ; base reward
	dw AI_SETUP | AI_SMART | AI_AGGRESSIVE | AI_STATUS
	dw CONTEXT_USE | SWITCH_COMPETITIVE

; Brock
	db HYPER_POTION, NO_ITEM ; items
	db 25 ; base reward
	dw AI_SETUP | AI_SMART | AI_AGGRESSIVE | AI_STATUS
	dw CONTEXT_USE | SWITCH_COMPETITIVE

; Misty
	db FULL_HEAL, NO_ITEM ; items
	db 25 ; base reward
	dw AI_SETUP | AI_SMART | AI_AGGRESSIVE | AI_STATUS
	dw CONTEXT_USE | SWITCH_COMPETITIVE

; Lt Surge
	db HYPER_POTION, NO_ITEM ; items
	db 25 ; base reward
	dw AI_SETUP | AI_SMART | AI_AGGRESSIVE | AI_STATUS
	dw CONTEXT_USE | SWITCH_COMPETITIVE

; Scientist
	db NO_ITEM, NO_ITEM ; items
	db 25 ; base reward
	dw AI_BASIC | AI_SETUP | AI_TYPES | AI_STATUS | AI_RISKY
	dw CONTEXT_USE | SWITCH_SOMETIMES

; Erika
	db HYPER_POTION, NO_ITEM ; items
	db 25 ; base reward
	dw AI_SETUP | AI_SMART | AI_AGGRESSIVE | AI_STATUS
	dw CONTEXT_USE | SWITCH_COMPETITIVE

; Youngster
	db NO_ITEM, NO_ITEM ; items
	db 4 ; base reward
	dw AI_BASIC | AI_STATUS
	dw CONTEXT_USE | SWITCH_SOMETIMES

; Schoolboy
	db NO_ITEM, NO_ITEM ; items
	db 8 ; base reward
	dw AI_BASIC | AI_SETUP | AI_TYPES | AI_OPPORTUNIST | AI_CAUTIOUS | AI_STATUS
	dw CONTEXT_USE | SWITCH_OFTEN

; Bird Keeper
	db NO_ITEM, NO_ITEM ; items
	db 6 ; base reward
	dw AI_BASIC | AI_TYPES | AI_OFFENSIVE | AI_OPPORTUNIST | AI_STATUS
	dw CONTEXT_USE | SWITCH_SOMETIMES

; Lass
	db NO_ITEM, NO_ITEM ; items
	db 6 ; base reward
	dw AI_BASIC | AI_CAUTIOUS | AI_STATUS
	dw CONTEXT_USE | SWITCH_OFTEN

; Janine
	db DIRE_HIT, NO_ITEM ; items
	db 25 ; base reward
	dw AI_BASIC | AI_SETUP | AI_SMART | AI_AGGRESSIVE | AI_CAUTIOUS | AI_STATUS | AI_RISKY
	dw CONTEXT_USE | SWITCH_COMPETITIVE

; Cooltrainerm
	db NO_ITEM, NO_ITEM ; items
	db 12 ; base reward
	dw AI_BASIC | AI_SMART | AI_STATUS | AI_AGGRESSIVE | AI_OPPORTUNIST | AI_TYPES
	dw CONTEXT_USE | SWITCH_OFTEN

; Cooltrainerf
	db NO_ITEM, NO_ITEM ; items
	db 12 ; base reward
	dw AI_BASIC | AI_SMART | AI_STATUS | AI_AGGRESSIVE | AI_OPPORTUNIST | AI_TYPES
	dw CONTEXT_USE | SWITCH_OFTEN

; Beauty
	db NO_ITEM, NO_ITEM ; items
	db 22 ; base reward
	dw AI_BASIC | AI_TYPES | AI_SMART | AI_STATUS
	dw CONTEXT_USE | SWITCH_SOMETIMES

; Pokemaniac
	db NO_ITEM, NO_ITEM ; items
	db 15 ; base reward
	dw AI_BASIC | AI_SETUP | AI_OFFENSIVE | AI_AGGRESSIVE | AI_STATUS
	dw CONTEXT_USE | SWITCH_SOMETIMES

; Gruntm
	db NO_ITEM, NO_ITEM ; items
	db 10 ; base reward
	dw AI_BASIC | AI_SETUP | AI_TYPES | AI_OPPORTUNIST | AI_CAUTIOUS | AI_STATUS | AI_RISKY
	dw CONTEXT_USE | SWITCH_SOMETIMES

; Gentleman
	db NO_ITEM, NO_ITEM ; items
	db 18 ; base reward
	dw AI_BASIC | AI_SETUP | AI_AGGRESSIVE | AI_STATUS
	dw CONTEXT_USE | SWITCH_SOMETIMES

; Skier
	db NO_ITEM, NO_ITEM ; items
	db 18 ; base reward
	dw AI_BASIC | AI_SETUP | AI_TYPES | AI_STATUS | AI_RISKY
	dw CONTEXT_USE | SWITCH_SOMETIMES

; Teacher
	db NO_ITEM, NO_ITEM ; items
	db 18 ; base reward
	dw AI_BASIC | AI_OPPORTUNIST | AI_AGGRESSIVE | AI_STATUS
	dw CONTEXT_USE | SWITCH_SOMETIMES

; Sabrina
	db HYPER_POTION, NO_ITEM ; items
	db 25 ; base reward
	dw AI_BASIC | AI_SETUP | AI_SMART | AI_AGGRESSIVE | AI_CAUTIOUS | AI_STATUS | AI_RISKY
	dw CONTEXT_USE | SWITCH_COMPETITIVE

; Bug Catcher
	db NO_ITEM, NO_ITEM ; items
	db 4 ; base reward
	dw AI_BASIC | AI_SETUP | AI_STATUS
	dw CONTEXT_USE | SWITCH_SOMETIMES

; Fisher
	db NO_ITEM, NO_ITEM ; items
	db 10 ; base reward
	dw AI_BASIC | AI_TYPES | AI_OPPORTUNIST | AI_CAUTIOUS | AI_STATUS
	dw CONTEXT_USE | SWITCH_OFTEN

; Swimmerm
	db NO_ITEM, NO_ITEM ; items
	db 2 ; base reward
	dw AI_BASIC | AI_SETUP | AI_TYPES | AI_OFFENSIVE | AI_STATUS
	dw CONTEXT_USE | SWITCH_SOMETIMES

; Swimmerf
	db NO_ITEM, NO_ITEM ; items
	db 5 ; base reward
	dw AI_BASIC | AI_SETUP | AI_TYPES | AI_CAUTIOUS | AI_STATUS
	dw CONTEXT_USE | SWITCH_SOMETIMES

; Sailor
	db NO_ITEM, NO_ITEM ; items
	db 10 ; base reward
	dw AI_BASIC | AI_OFFENSIVE | AI_OPPORTUNIST | AI_STATUS
	dw CONTEXT_USE | SWITCH_SOMETIMES

; Super Nerd
	db NO_ITEM, NO_ITEM ; items
	db 8 ; base reward
	dw AI_BASIC | AI_TYPES | AI_SMART | AI_STATUS
	dw CONTEXT_USE | SWITCH_SOMETIMES

; Rival2
	db NO_ITEM, NO_ITEM ; items
	db 25 ; base reward
	dw AI_BASIC | AI_SETUP | AI_SMART | AI_AGGRESSIVE | AI_CAUTIOUS | AI_STATUS | AI_RISKY
	dw CONTEXT_USE | SWITCH_OFTEN

; Guitarist
	db NO_ITEM, NO_ITEM ; items
	db 8 ; base reward
	dw AI_BASIC | AI_SETUP | AI_TYPES | AI_CAUTIOUS | AI_STATUS
	dw CONTEXT_USE | SWITCH_SOMETIMES

; Hiker
	db NO_ITEM, NO_ITEM ; items
	db 8 ; base reward
	dw AI_BASIC | AI_OFFENSIVE | AI_STATUS
	dw CONTEXT_USE | SWITCH_SOMETIMES

; Biker
	db NO_ITEM, NO_ITEM ; items
	db 8 ; base reward
	dw AI_BASIC | AI_TYPES | AI_STATUS | AI_RISKY
	dw CONTEXT_USE | SWITCH_SOMETIMES

; Blaine
	db MAX_POTION, FULL_HEAL ; items
	db 25 ; base reward
	dw AI_BASIC | AI_SETUP | AI_SMART | AI_AGGRESSIVE | AI_CAUTIOUS | AI_STATUS | AI_RISKY
	dw CONTEXT_USE | SWITCH_SOMETIMES

; Burglar
	db NO_ITEM, NO_ITEM ; items
	db 22 ; base reward
	dw AI_BASIC | AI_OFFENSIVE | AI_CAUTIOUS | AI_STATUS
	dw CONTEXT_USE | SWITCH_SOMETIMES

; Firebreather
	db NO_ITEM, NO_ITEM ; items
	db 12 ; base reward
	dw AI_BASIC | AI_SETUP | AI_OFFENSIVE | AI_OPPORTUNIST | AI_STATUS
	dw CONTEXT_USE | SWITCH_RARELY

; Juggler
	db NO_ITEM, NO_ITEM ; items
	db 10 ; base reward
	dw AI_BASIC | AI_TYPES | AI_SMART | AI_STATUS
	dw CONTEXT_USE | SWITCH_RARELY

; Blackbelt T
	db NO_ITEM, NO_ITEM ; items
	db 6 ; base reward
	dw AI_BASIC | AI_OFFENSIVE | AI_STATUS | AI_RISKY
	dw CONTEXT_USE | SWITCH_RARELY

; Executivem
	db NO_ITEM, NO_ITEM ; items
	db 18 ; base reward
	dw AI_BASIC | AI_SETUP | AI_TYPES | AI_SMART | AI_OPPORTUNIST | AI_CAUTIOUS | AI_STATUS | AI_RISKY
	dw CONTEXT_USE | SWITCH_RARELY

; Psychic T
	db NO_ITEM, NO_ITEM ; items
	db 8 ; base reward
	dw AI_BASIC | AI_TYPES | AI_OPPORTUNIST | AI_CAUTIOUS | AI_STATUS
	dw CONTEXT_USE | SWITCH_RARELY

; Picnicker
	db NO_ITEM, NO_ITEM ; items
	db 5 ; base reward
	dw AI_BASIC | AI_CAUTIOUS | AI_STATUS
	dw CONTEXT_USE | SWITCH_RARELY

; Camper
	db NO_ITEM, NO_ITEM ; items
	db 5 ; base reward
	dw AI_BASIC | AI_CAUTIOUS | AI_STATUS
	dw CONTEXT_USE | SWITCH_RARELY

; Executivef
	db NO_ITEM, NO_ITEM ; items
	db 18 ; base reward
	dw AI_BASIC | AI_SETUP | AI_TYPES | AI_SMART | AI_OPPORTUNIST | AI_CAUTIOUS | AI_STATUS | AI_RISKY
	dw CONTEXT_USE | SWITCH_SOMETIMES

; Sage
	db NO_ITEM, NO_ITEM ; items
	db 8 ; base reward
	dw AI_BASIC | AI_SETUP | AI_TYPES | AI_CAUTIOUS | AI_STATUS | AI_RISKY
	dw CONTEXT_USE | SWITCH_RARELY

; Medium
	db NO_ITEM, NO_ITEM ; items
	db 10 ; base reward
	dw AI_BASIC | AI_SETUP | AI_TYPES | AI_CAUTIOUS | AI_STATUS | AI_RISKY
	dw CONTEXT_USE | SWITCH_RARELY

; Boarder
	db NO_ITEM, NO_ITEM ; items
	db 18 ; base reward
	dw AI_BASIC | AI_TYPES | AI_OPPORTUNIST | AI_STATUS
	dw CONTEXT_USE | SWITCH_RARELY

; Pokefanm
	db NO_ITEM, NO_ITEM ; items
	db 20 ; base reward
	dw AI_BASIC | AI_TYPES | AI_SMART | AI_STATUS
	dw CONTEXT_USE | SWITCH_RARELY

; Kimono Girl
	db NO_ITEM, NO_ITEM ; items
	db 18 ; base reward
	dw AI_BASIC | AI_TYPES | AI_SMART
	dw CONTEXT_USE | SWITCH_SOMETIMES

; Twins
	db NO_ITEM, NO_ITEM ; items
	db 5 ; base reward
	dw NO_AI
	dw CONTEXT_USE | SWITCH_OFTEN

; Pokefanf
	db NO_ITEM, NO_ITEM ; items
	db 20 ; base reward
	dw AI_BASIC | AI_TYPES | AI_SMART | AI_STATUS
	dw CONTEXT_USE | SWITCH_SOMETIMES

; Red
	db FULL_RESTORE, FULL_RESTORE ; items
	db 25 ; base reward
	dw AI_BASIC | AI_SETUP | AI_SMART | AI_AGGRESSIVE | AI_CAUTIOUS | AI_STATUS | AI_RISKY
	dw CONTEXT_USE | SWITCH_SOMETIMES

; Blue
	db FULL_RESTORE, FULL_RESTORE ; items
	db 25 ; base reward
	dw AI_BASIC | AI_SETUP | AI_SMART | AI_AGGRESSIVE | AI_CAUTIOUS | AI_STATUS | AI_RISKY
	dw CONTEXT_USE | SWITCH_SOMETIMES

; Officer
	db NO_ITEM, NO_ITEM ; items
	db 10 ; base reward
	dw AI_BASIC | AI_TYPES | AI_OPPORTUNIST | AI_STATUS
	dw CONTEXT_USE | SWITCH_SOMETIMES

; Gruntf
	db NO_ITEM, NO_ITEM ; items
	db 10 ; base reward
	dw AI_BASIC | AI_TYPES | AI_OPPORTUNIST | AI_CAUTIOUS | AI_STATUS | AI_RISKY
	dw CONTEXT_USE | SWITCH_SOMETIMES

; Mysticalman
	db NO_ITEM, NO_ITEM ; items
	db 25 ; base reward
	dw AI_BASIC | AI_SMART | AI_STATUS | AI_AGGRESSIVE | AI_OPPORTUNIST | AI_TYPES
	dw CONTEXT_USE | SWITCH_COMPETITIVE
