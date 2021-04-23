INCLUDE "constants.asm"


SECTION "Text 1", ROMX

INCLUDE "data/text/common_1.asm"


SECTION "Text 2", ROMX

INCLUDE "data/text/common_2.asm"


SECTION "Text 3", ROMX

INCLUDE "data/text/common_3.asm"

SECTION "_WarnVBAText", ROMX

_WarnVBAText::
	text "Warning!"

	para "This Game Boy"
	line "emulator has bugs"

	para "that may crash or"
	line "affect this game."

	para "Please use another"
	line "emulator, such as"
	cont "BGB or Gambatte."
	prompt