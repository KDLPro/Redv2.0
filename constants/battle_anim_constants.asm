; battle_anim_struct members (see macros/wram.asm)
	const_def
	const BATTLEANIMSTRUCT_INDEX
	const BATTLEANIMSTRUCT_OAMFLAGS
	const BATTLEANIMSTRUCT_FIX_Y
	const BATTLEANIMSTRUCT_FRAMESET_ID
	const BATTLEANIMSTRUCT_FUNCTION
	const BATTLEANIMSTRUCT_PALETTE
	const BATTLEANIMSTRUCT_TILEID
	const BATTLEANIMSTRUCT_XCOORD
	const BATTLEANIMSTRUCT_YCOORD
	const BATTLEANIMSTRUCT_XOFFSET
	const BATTLEANIMSTRUCT_YOFFSET
	const BATTLEANIMSTRUCT_PARAM
	const BATTLEANIMSTRUCT_DURATION
	const BATTLEANIMSTRUCT_FRAME
	const BATTLEANIMSTRUCT_JUMPTABLE_INDEX
	const BATTLEANIMSTRUCT_VAR1
	const BATTLEANIMSTRUCT_VAR2
	const_skip 7
BATTLEANIMSTRUCT_LENGTH EQU const_value
NUM_ANIM_OBJECTS EQU 10 ; see wActiveAnimObjects

; wBattleAnimTileDict size (see wram.asm)
NUM_BATTLEANIMTILEDICT_ENTRIES EQU 5

; Start tile for battle animation graphics
BATTLEANIM_BASE_TILE EQU 7 * 7  ; Maximum size of a pokemon picture

; BattleAnimObjects indexes (see data/battle_anims/objects.asm)
	const_def
	const ANIM_OBJ_HIT_BIG_YFIX
	const ANIM_OBJ_HIT_YFIX
	const ANIM_OBJ_HIT_SMALL_YFIX
	const ANIM_OBJ_HIT_BIG
	const ANIM_OBJ_HIT
	const ANIM_OBJ_HIT_SMALL
	const ANIM_OBJ_POISON_STING
	const ANIM_OBJ_PUNCH
	const ANIM_OBJ_KICK
	const ANIM_OBJ_PALM
	const ANIM_OBJ_FANG
	const ANIM_OBJ_PUNCH_SHAKE
	const ANIM_OBJ_EMBER
	const ANIM_OBJ_DRAGON_RAGE
	const ANIM_OBJ_FLAMETHROWER
	const ANIM_OBJ_FIRE_SPIN
	const ANIM_OBJ_FIRE_BLAST
	const ANIM_OBJ_BURNED
	const ANIM_OBJ_BLIZZARD
	const ANIM_OBJ_ICE
	const ANIM_OBJ_ICE_BEAM
	const ANIM_OBJ_RAZOR_LEAF
	const ANIM_OBJ_POKE_BALL
	const ANIM_OBJ_POKE_BALL_BG
	const ANIM_OBJ_POKE_BALL_BLOCKED
	const ANIM_OBJ_EXPLOSION1
	const ANIM_OBJ_EXPLOSION2
	const ANIM_OBJ_ACID
	const ANIM_OBJ_SLUDGE
	const ANIM_OBJ_SLUDGE_2
	const ANIM_OBJ_SHADOW_BALL_POOF
	const ANIM_OBJ_BALL_POOF
	const ANIM_OBJ_BIG_ROCK
	const ANIM_OBJ_SMALL_ROCK
	const ANIM_OBJ_ROCK_TOMB
	const ANIM_OBJ_STRENGTH
	const ANIM_OBJ_SEISMIC_TOSS
	const ANIM_OBJ_BUBBLE
	const ANIM_OBJ_SURF
	const ANIM_OBJ_SING_1
	const ANIM_OBJ_SING_2
	const ANIM_OBJ_SING_3
	const ANIM_OBJ_WATER_GUN
	const ANIM_OBJ_HYDRO_PUMP
	const ANIM_OBJ_POWDER
	const ANIM_OBJ_POWDER_S
	const ANIM_OBJ_POWDER_V
	const ANIM_OBJ_BEAM
	const ANIM_OBJ_BEAM_TIP
	const ANIM_OBJ_ICE_BUILDUP
	const ANIM_OBJ_FROZEN
	const ANIM_OBJ_MASTER_BALL_SPARKLE
	const ANIM_OBJ_RECOVER
	const ANIM_OBJ_THUNDER1
	const ANIM_OBJ_THUNDER2
	const ANIM_OBJ_THUNDER3
	const ANIM_OBJ_THUNDER_WAVE
	const ANIM_OBJ_SPARKS_CIRCLE_BIG
	const ANIM_OBJ_THUNDERBOLT_BALL
	const ANIM_OBJ_SPARKS_CIRCLE
	const ANIM_OBJ_THUNDERSHOCK_BALL
	const ANIM_OBJ_BITE
	const ANIM_OBJ_CUT_DOWN_LEFT
	const ANIM_OBJ_CUT_DOWN_RIGHT
	const ANIM_OBJ_CUT_UP_RIGHT
	const ANIM_OBJ_CUT_LONG_DOWN_LEFT
	const ANIM_OBJ_CUT_LONG_DOWN_RIGHT
	const ANIM_OBJ_SOLAR_BEAM_CHARGE
	const ANIM_OBJ_ABSORB_CENTER
	const ANIM_OBJ_GUST
	const ANIM_OBJ_VINE_WHIP1
	const ANIM_OBJ_VINE_WHIP2
	const ANIM_OBJ_FURY_CUTTER_LEFT
	const ANIM_OBJ_FURY_CUTTER_RIGHT
	const ANIM_OBJ_WARP
	const ANIM_OBJ_ABSORB
	const ANIM_OBJ_EGG
	const ANIM_OBJ_FOCUS
	const ANIM_OBJ_BIND1
	const ANIM_OBJ_BIND2
	const ANIM_OBJ_LEECH_SEED
	const ANIM_OBJ_SOUND
	const ANIM_OBJ_WAVE
	const ANIM_OBJ_CONFUSE_RAY
	const ANIM_OBJ_LEER
	const ANIM_OBJ_LEER_TIP
	const ANIM_OBJ_SCREEN
	const ANIM_OBJ_SCREEN_WALL
	const ANIM_OBJ_HARDEN
	const ANIM_OBJ_CHICK
	const ANIM_OBJ_AMNESIA
	const ANIM_OBJ_ASLEEP
	const ANIM_OBJ_SKULL
	const ANIM_OBJ_DIG_SAND
	const ANIM_OBJ_DIG_PILE
	const ANIM_OBJ_SAND
	const ANIM_OBJ_PARALYZED
	const ANIM_OBJ_STRING_SHOT
	const ANIM_OBJ_HAZE
	const ANIM_OBJ_MIST
	const ANIM_OBJ_SMOG
	const ANIM_OBJ_POISON_GAS
	const ANIM_OBJ_HORN
	const ANIM_OBJ_NEEDLE
	const ANIM_OBJ_NEEDLE_2
	const ANIM_OBJ_PETAL_DANCE
	const ANIM_OBJ_SLUDGE_BOMB
	const ANIM_OBJ_PAY_DAY
	const ANIM_OBJ_SONICBOOM_JP_UNUSED
	const ANIM_OBJ_MIMIC
	const ANIM_OBJ_ATTRACT
	const ANIM_OBJ_BONEMERANG
	const ANIM_OBJ_BONE_CLUB
	const ANIM_OBJ_BONE_RUSH
	const ANIM_OBJ_SWIFT
	const ANIM_OBJ_KINESIS
	const ANIM_OBJ_FLASH
	const ANIM_OBJ_SHINY
	const ANIM_OBJ_SKY_ATTACK
	const ANIM_OBJ_LICK
	const ANIM_OBJ_WITHDRAW
	const ANIM_OBJ_DRAIN
	const ANIM_OBJ_GROWTH
	const ANIM_OBJ_CONVERSION2
	const ANIM_OBJ_SMOKE
	const ANIM_OBJ_SMOKESCREEN
	const ANIM_OBJ_SWORDS_DANCE
	const ANIM_OBJ_SPEED_LINE
	const ANIM_OBJ_SHARPEN
	const ANIM_OBJ_DEFENSE_CURL
	const ANIM_OBJ_METRONOME_HAND
	const ANIM_OBJ_METRONOME_SPARKLE
	const ANIM_OBJ_DISABLE
	const ANIM_OBJ_AGILITY
	const ANIM_OBJ_HEART
	const ANIM_OBJ_SACRED_FIRE
	const ANIM_OBJ_COTTON_SPORE
	const ANIM_OBJ_MILK_DRINK
	const ANIM_OBJ_ANGER
	const ANIM_OBJ_HEAL_BELL
	const ANIM_OBJ_HEAL_BELL_NOTE
	const ANIM_OBJ_BATON_PASS
	const ANIM_OBJ_LOCK_ON
	const ANIM_OBJ_MIND_READER
	const ANIM_OBJ_SAFEGUARD
	const ANIM_OBJ_PROTECT
	const ANIM_OBJ_THIEF
	const ANIM_OBJ_OCTAZOOKA
	const ANIM_OBJ_PRESENT
	const ANIM_OBJ_SPIKES
	const ANIM_OBJ_POWDER_SNOW
	const ANIM_OBJ_DRAGONBREATH
	const ANIM_OBJ_DRAGONBREATH_FIRE
	const ANIM_OBJ_CONVERSION
	const ANIM_OBJ_SPIDER_WEB
	const ANIM_OBJ_LEER_SHINE
	const ANIM_OBJ_NIGHTMARE
	const ANIM_OBJ_IN_NIGHTMARE
	const ANIM_OBJ_LOVELY_KISS
	const ANIM_OBJ_SWEET_KISS
	const ANIM_OBJ_SKETCH
	const ANIM_OBJ_ENCORE_HAND
	const ANIM_OBJ_ENCORE_STAR
	const ANIM_OBJ_DESTINY_BOND
	const ANIM_OBJ_MORNING_SUN
	const ANIM_OBJ_GLIMMER
	const ANIM_OBJ_MOONLIGHT
	const ANIM_OBJ_HIDDEN_POWER
	const ANIM_OBJ_CROSS_CHOP1
	const ANIM_OBJ_CROSS_CHOP2
	const ANIM_OBJ_SANDSTORM
	const ANIM_OBJ_ZAP_CANNON
	const ANIM_OBJ_SPITE
	const ANIM_OBJ_CURSE
	const ANIM_OBJ_PERISH_SONG
	const ANIM_OBJ_FORESIGHT
	const ANIM_OBJ_RAPID_SPIN
	const ANIM_OBJ_SWAGGER
	const ANIM_OBJ_BELLY_DRUM_HAND
	const ANIM_OBJ_BELLY_DRUM_NOTE
	const ANIM_OBJ_MEAN_LOOK
	const ANIM_OBJ_BETA_PURSUIT
	const ANIM_OBJ_SHOOTING_SPARKLE
	const ANIM_OBJ_RAIN
	const ANIM_OBJ_ROLLOUT
	const ANIM_OBJ_PSYCH_UP
	const ANIM_OBJ_ANCIENTPOWER
	const ANIM_OBJ_AEROBLAST
	const ANIM_OBJ_SHADOW_BALL
	const ANIM_OBJ_ROCK_SMASH
	const ANIM_OBJ_FLOWER
	const ANIM_OBJ_COTTON
	const ANIM_OBJ_ENEMYFEET_1ROW
	const ANIM_OBJ_PLAYERHEAD_1ROW
	const ANIM_OBJ_ENEMYFEET_2ROW
	const ANIM_OBJ_PLAYERHEAD_2ROW
	const ANIM_OBJ_WATERFALL
	const ANIM_OBJ_WATERFALL_YFIX
	const ANIM_OBJ_WHIRLPOOL
	const ANIM_OBJ_SUNNY_DAY
	const ANIM_OBJ_WATER_PULSE
	const ANIM_OBJ_VOICE_HIT
	const ANIM_OBJ_PSYCHIC

; DoBattleAnimFrame arguments (see engine/battle_anims/functions.asm)
	const_def
	const BATTLEANIMFUNC_NULL
	const BATTLEANIMFUNC_USER_TO_TARGET
	const BATTLEANIMFUNC_USER_TO_TARGET_DISAPPEAR
	const BATTLEANIMFUNC_MOVE_IN_CIRCLE
	const BATTLEANIMFUNC_WAVE_TO_TARGET
	const BATTLEANIMFUNC_THROW_TO_TARGET
	const BATTLEANIMFUNC_THROW_TO_TARGET_DISAPPEAR
	const BATTLEANIMFUNC_DROP
	const BATTLEANIMFUNC_DROPNOBOUNCE
	const BATTLEANIMFUNC_USER_TO_TARGET_SPIN
	const BATTLEANIMFUNC_SHAKE
	const BATTLEANIMFUNC_FIRE_BLAST
	const BATTLEANIMFUNC_RAZOR_LEAF
	const BATTLEANIMFUNC_BUBBLE
	const BATTLEANIMFUNC_SURF
	const BATTLEANIMFUNC_SING
	const BATTLEANIMFUNC_WATER_GUN
	const BATTLEANIMFUNC_EMBER
	const BATTLEANIMFUNC_POWDER
	const BATTLEANIMFUNC_POKEBALL
	const BATTLEANIMFUNC_POKEBALL_BG
	const BATTLEANIMFUNC_POKEBALL_BLOCKED
	const BATTLEANIMFUNC_RECOVER
	const BATTLEANIMFUNC_THUNDER_WAVE
	const BATTLEANIMFUNC_CLAMP_ENCORE
	const BATTLEANIMFUNC_BITE
	const BATTLEANIMFUNC_SOLAR_BEAM
	const BATTLEANIMFUNC_GUST
	const BATTLEANIMFUNC_RAZOR_WIND
	const BATTLEANIMFUNC_KICK
	const BATTLEANIMFUNC_ABSORB
	const BATTLEANIMFUNC_EGG
	const BATTLEANIMFUNC_MOVE_UP
	const BATTLEANIMFUNC_WRAP
	const BATTLEANIMFUNC_LEECH_SEED
	const BATTLEANIMFUNC_SOUND
	const BATTLEANIMFUNC_CONFUSE_RAY
	const BATTLEANIMFUNC_DIZZY
	const BATTLEANIMFUNC_AMNESIA
	const BATTLEANIMFUNC_FLOAT_UP
	const BATTLEANIMFUNC_DIG
	const BATTLEANIMFUNC_STRING
	const BATTLEANIMFUNC_PARALYZED
	const BATTLEANIMFUNC_SPIRAL_DESCENT
	const BATTLEANIMFUNC_POISON_GAS
	const BATTLEANIMFUNC_HORN
	const BATTLEANIMFUNC_NEEDLE
	const BATTLEANIMFUNC_PETAL_DANCE
	const BATTLEANIMFUNC_THIEF_PAYDAY
	const BATTLEANIMFUNC_ABSORB_CIRCLE
	const BATTLEANIMFUNC_BONEMERANG
	const BATTLEANIMFUNC_SHINY
	const BATTLEANIMFUNC_SKY_ATTACK
	const BATTLEANIMFUNC_GROWTH_SWORDS_DANCE
	const BATTLEANIMFUNC_SMOKE_FLAME_WHEEL
	const BATTLEANIMFUNC_PRESENT_SMOKESCREEN
	const BATTLEANIMFUNC_STRENGTH_SEISMIC_TOSS
	const BATTLEANIMFUNC_SPEED_LINE
	const BATTLEANIMFUNC_SLUDGE
	const BATTLEANIMFUNC_METRONOME_HAND
	const BATTLEANIMFUNC_METRONOME_SPARKLE_SKETCH
	const BATTLEANIMFUNC_AGILITY
	const BATTLEANIMFUNC_SACRED_FIRE
	const BATTLEANIMFUNC_SAFEGUARD_PROTECT
	const BATTLEANIMFUNC_LOCK_ON_MIND_READER
	const BATTLEANIMFUNC_SPIKES
	const BATTLEANIMFUNC_HEAL_BELL_NOTES
	const BATTLEANIMFUNC_BATON_PASS
	const BATTLEANIMFUNC_CONVERSION
	const BATTLEANIMFUNC_ENCORE_BELLY_DRUM
	const BATTLEANIMFUNC_SWAGGER_MORNING_SUN
	const BATTLEANIMFUNC_HIDDEN_POWER
	const BATTLEANIMFUNC_CURSE
	const BATTLEANIMFUNC_PERISH_SONG
	const BATTLEANIMFUNC_RAPID_SPIN
	const BATTLEANIMFUNC_BETA_PURSUIT
	const BATTLEANIMFUNC_RAIN_SANDSTORM
	const BATTLEANIMFUNC_ROLLOUT
	const BATTLEANIMFUNC_PSYCH_UP
	const BATTLEANIMFUNC_ANCIENT_POWER
	const BATTLEANIMFUNC_ROCK_SMASH
	const BATTLEANIMFUNC_COTTON
	const BATTLEANIMFUNC_USER_TO_TARGET_NO_STOP

; BattleAnimFrameData indexes (see data/battle_anims/framesets.asm)
	const_def
	const BATTLEANIMFRAMESET_00
	const BATTLEANIMFRAMESET_01
	const BATTLEANIMFRAMESET_02
	const BATTLEANIMFRAMESET_03
	const BATTLEANIMFRAMESET_04
	const BATTLEANIMFRAMESET_05
	const BATTLEANIMFRAMESET_06
	const BATTLEANIMFRAMESET_07
	const BATTLEANIMFRAMESET_08
	const BATTLEANIMFRAMESET_09
	const BATTLEANIMFRAMESET_0A
	const BATTLEANIMFRAMESET_0B
	const BATTLEANIMFRAMESET_0C
	const BATTLEANIMFRAMESET_0D
	const BATTLEANIMFRAMESET_0E
	const BATTLEANIMFRAMESET_0F
	const BATTLEANIMFRAMESET_10
	const BATTLEANIMFRAMESET_11
	const BATTLEANIMFRAMESET_12
	const BATTLEANIMFRAMESET_13
	const BATTLEANIMFRAMESET_14
	const BATTLEANIMFRAMESET_15
	const BATTLEANIMFRAMESET_16
	const BATTLEANIMFRAMESET_17
	const BATTLEANIMFRAMESET_18
	const BATTLEANIMFRAMESET_19
	const BATTLEANIMFRAMESET_1A
	const BATTLEANIMFRAMESET_1B
	const BATTLEANIMFRAMESET_1C
	const BATTLEANIMFRAMESET_1D
	const BATTLEANIMFRAMESET_1E
	const BATTLEANIMFRAMESET_1F
	const BATTLEANIMFRAMESET_20
	const BATTLEANIMFRAMESET_21
	const BATTLEANIMFRAMESET_22
	const BATTLEANIMFRAMESET_23
	const BATTLEANIMFRAMESET_24
	const BATTLEANIMFRAMESET_25
	const BATTLEANIMFRAMESET_26
	const BATTLEANIMFRAMESET_27
	const BATTLEANIMFRAMESET_28
	const BATTLEANIMFRAMESET_29
	const BATTLEANIMFRAMESET_2A
	const BATTLEANIMFRAMESET_2B
	const BATTLEANIMFRAMESET_2C
	const BATTLEANIMFRAMESET_2D
	const BATTLEANIMFRAMESET_2E
	const BATTLEANIMFRAMESET_2F
	const BATTLEANIMFRAMESET_30
	const BATTLEANIMFRAMESET_31
	const BATTLEANIMFRAMESET_32
	const BATTLEANIMFRAMESET_33
	const BATTLEANIMFRAMESET_34
	const BATTLEANIMFRAMESET_35
	const BATTLEANIMFRAMESET_36
	const BATTLEANIMFRAMESET_37
	const BATTLEANIMFRAMESET_38
	const BATTLEANIMFRAMESET_39
	const BATTLEANIMFRAMESET_3A
	const BATTLEANIMFRAMESET_3B
	const BATTLEANIMFRAMESET_3C
	const BATTLEANIMFRAMESET_3D
	const BATTLEANIMFRAMESET_3E
	const BATTLEANIMFRAMESET_3F
	const BATTLEANIMFRAMESET_40
	const BATTLEANIMFRAMESET_41
	const BATTLEANIMFRAMESET_42
	const BATTLEANIMFRAMESET_43
	const BATTLEANIMFRAMESET_44
	const BATTLEANIMFRAMESET_45
	const BATTLEANIMFRAMESET_46
	const BATTLEANIMFRAMESET_47
	const BATTLEANIMFRAMESET_48
	const BATTLEANIMFRAMESET_49
	const BATTLEANIMFRAMESET_4A
	const BATTLEANIMFRAMESET_4B
	const BATTLEANIMFRAMESET_4C
	const BATTLEANIMFRAMESET_4D
	const BATTLEANIMFRAMESET_4E
	const BATTLEANIMFRAMESET_4F
	const BATTLEANIMFRAMESET_50
	const BATTLEANIMFRAMESET_51
	const BATTLEANIMFRAMESET_52
	const BATTLEANIMFRAMESET_53
	const BATTLEANIMFRAMESET_54
	const BATTLEANIMFRAMESET_55
	const BATTLEANIMFRAMESET_56
	const BATTLEANIMFRAMESET_57
	const BATTLEANIMFRAMESET_58
	const BATTLEANIMFRAMESET_59
	const BATTLEANIMFRAMESET_5A
	const BATTLEANIMFRAMESET_5B
	const BATTLEANIMFRAMESET_5C
	const BATTLEANIMFRAMESET_5D
	const BATTLEANIMFRAMESET_5E
	const BATTLEANIMFRAMESET_5F
	const BATTLEANIMFRAMESET_60
	const BATTLEANIMFRAMESET_61
	const BATTLEANIMFRAMESET_62
	const BATTLEANIMFRAMESET_63
	const BATTLEANIMFRAMESET_64
	const BATTLEANIMFRAMESET_65
	const BATTLEANIMFRAMESET_66
	const BATTLEANIMFRAMESET_67
	const BATTLEANIMFRAMESET_68
	const BATTLEANIMFRAMESET_69
	const BATTLEANIMFRAMESET_6A
	const BATTLEANIMFRAMESET_6B
	const BATTLEANIMFRAMESET_6C
	const BATTLEANIMFRAMESET_6D
	const BATTLEANIMFRAMESET_6E
	const BATTLEANIMFRAMESET_6F
	const BATTLEANIMFRAMESET_70
	const BATTLEANIMFRAMESET_71
	const BATTLEANIMFRAMESET_72
	const BATTLEANIMFRAMESET_73
	const BATTLEANIMFRAMESET_74
	const BATTLEANIMFRAMESET_75
	const BATTLEANIMFRAMESET_76
	const BATTLEANIMFRAMESET_77
	const BATTLEANIMFRAMESET_78
	const BATTLEANIMFRAMESET_79
	const BATTLEANIMFRAMESET_7A
	const BATTLEANIMFRAMESET_7B
	const BATTLEANIMFRAMESET_7C
	const BATTLEANIMFRAMESET_7D
	const BATTLEANIMFRAMESET_7E
	const BATTLEANIMFRAMESET_7F
	const BATTLEANIMFRAMESET_80
	const BATTLEANIMFRAMESET_81
	const BATTLEANIMFRAMESET_82
	const BATTLEANIMFRAMESET_83
	const BATTLEANIMFRAMESET_84
	const BATTLEANIMFRAMESET_85
	const BATTLEANIMFRAMESET_86
	const BATTLEANIMFRAMESET_87
	const BATTLEANIMFRAMESET_88
	const BATTLEANIMFRAMESET_89
	const BATTLEANIMFRAMESET_8A
	const BATTLEANIMFRAMESET_8B
	const BATTLEANIMFRAMESET_8C
	const BATTLEANIMFRAMESET_8D
	const BATTLEANIMFRAMESET_8E
	const BATTLEANIMFRAMESET_8F
	const BATTLEANIMFRAMESET_90
	const BATTLEANIMFRAMESET_91
	const BATTLEANIMFRAMESET_92
	const BATTLEANIMFRAMESET_93
	const BATTLEANIMFRAMESET_94
	const BATTLEANIMFRAMESET_95
	const BATTLEANIMFRAMESET_96
	const BATTLEANIMFRAMESET_97
	const BATTLEANIMFRAMESET_98
	const BATTLEANIMFRAMESET_99
	const BATTLEANIMFRAMESET_9A
	const BATTLEANIMFRAMESET_9B
	const BATTLEANIMFRAMESET_9C
	const BATTLEANIMFRAMESET_9D
	const BATTLEANIMFRAMESET_9E
	const BATTLEANIMFRAMESET_9F
	const BATTLEANIMFRAMESET_A0
	const BATTLEANIMFRAMESET_A1
	const BATTLEANIMFRAMESET_A2
	const BATTLEANIMFRAMESET_A3
	const BATTLEANIMFRAMESET_A4
	const BATTLEANIMFRAMESET_A5
	const BATTLEANIMFRAMESET_A6
	const BATTLEANIMFRAMESET_A7
	const BATTLEANIMFRAMESET_A8
	const BATTLEANIMFRAMESET_A9
	const BATTLEANIMFRAMESET_AA
	const BATTLEANIMFRAMESET_AB
	const BATTLEANIMFRAMESET_AC
	const BATTLEANIMFRAMESET_AD
	const BATTLEANIMFRAMESET_AE
	const BATTLEANIMFRAMESET_AF
	const BATTLEANIMFRAMESET_B0
	const BATTLEANIMFRAMESET_B1
	const BATTLEANIMFRAMESET_B2
	const BATTLEANIMFRAMESET_B3
	const BATTLEANIMFRAMESET_B4
	const BATTLEANIMFRAMESET_B5
	const BATTLEANIMFRAMESET_B6
	const BATTLEANIMFRAMESET_B7
	const BATTLEANIMFRAMESET_B8
	const BATTLEANIMFRAMESET_B9
	const BATTLEANIMFRAMESET_BA
	const BATTLEANIMFRAMESET_BB
	const BATTLEANIMFRAMESET_BC
	const BATTLEANIMFRAMESET_BD
	const BATTLEANIMFRAMESET_BE
	const BATTLEANIMFRAMESET_BF
	const BATTLEANIMFRAMESET_C0
	const BATTLEANIMFRAMESET_C1

; BattleAnimOAMData indexes (see data/battle_anims/oam.asm)
	const_def
	const BATTLEANIMOAMSET_00
	const BATTLEANIMOAMSET_01
	const BATTLEANIMOAMSET_02
	const BATTLEANIMOAMSET_03
	const BATTLEANIMOAMSET_04
	const BATTLEANIMOAMSET_05
	const BATTLEANIMOAMSET_06
	const BATTLEANIMOAMSET_07
	const BATTLEANIMOAMSET_08
	const BATTLEANIMOAMSET_09
	const BATTLEANIMOAMSET_0A
	const BATTLEANIMOAMSET_0B
	const BATTLEANIMOAMSET_0C
	const BATTLEANIMOAMSET_0D
	const BATTLEANIMOAMSET_0E
	const BATTLEANIMOAMSET_0F
	const BATTLEANIMOAMSET_10
	const BATTLEANIMOAMSET_11
	const BATTLEANIMOAMSET_12
	const BATTLEANIMOAMSET_13
	const BATTLEANIMOAMSET_14
	const BATTLEANIMOAMSET_15
	const BATTLEANIMOAMSET_16
	const BATTLEANIMOAMSET_17
	const BATTLEANIMOAMSET_18
	const BATTLEANIMOAMSET_19
	const BATTLEANIMOAMSET_1A
	const BATTLEANIMOAMSET_1B
	const BATTLEANIMOAMSET_1C
	const BATTLEANIMOAMSET_1D
	const BATTLEANIMOAMSET_1E
	const BATTLEANIMOAMSET_1F
	const BATTLEANIMOAMSET_20
	const BATTLEANIMOAMSET_21
	const BATTLEANIMOAMSET_22
	const BATTLEANIMOAMSET_23
	const BATTLEANIMOAMSET_24
	const BATTLEANIMOAMSET_25
	const BATTLEANIMOAMSET_26
	const BATTLEANIMOAMSET_27
	const BATTLEANIMOAMSET_28
	const BATTLEANIMOAMSET_29
	const BATTLEANIMOAMSET_2A
	const BATTLEANIMOAMSET_2B
	const BATTLEANIMOAMSET_2C
	const BATTLEANIMOAMSET_2D
	const BATTLEANIMOAMSET_2E
	const BATTLEANIMOAMSET_2F
	const BATTLEANIMOAMSET_30
	const BATTLEANIMOAMSET_31
	const BATTLEANIMOAMSET_32
	const BATTLEANIMOAMSET_33
	const BATTLEANIMOAMSET_34
	const BATTLEANIMOAMSET_35
	const BATTLEANIMOAMSET_36
	const BATTLEANIMOAMSET_37
	const BATTLEANIMOAMSET_38
	const BATTLEANIMOAMSET_39
	const BATTLEANIMOAMSET_3A
	const BATTLEANIMOAMSET_3B
	const BATTLEANIMOAMSET_3C
	const BATTLEANIMOAMSET_3D
	const BATTLEANIMOAMSET_3E
	const BATTLEANIMOAMSET_3F
	const BATTLEANIMOAMSET_40
	const BATTLEANIMOAMSET_41
	const BATTLEANIMOAMSET_42
	const BATTLEANIMOAMSET_43
	const BATTLEANIMOAMSET_44
	const BATTLEANIMOAMSET_45
	const BATTLEANIMOAMSET_46
	const BATTLEANIMOAMSET_47
	const BATTLEANIMOAMSET_48
	const BATTLEANIMOAMSET_49
	const BATTLEANIMOAMSET_4A
	const BATTLEANIMOAMSET_4B
	const BATTLEANIMOAMSET_4C
	const BATTLEANIMOAMSET_4D
	const BATTLEANIMOAMSET_4E
	const BATTLEANIMOAMSET_4F
	const BATTLEANIMOAMSET_50
	const BATTLEANIMOAMSET_51
	const BATTLEANIMOAMSET_52
	const BATTLEANIMOAMSET_53
	const BATTLEANIMOAMSET_54
	const BATTLEANIMOAMSET_55
	const BATTLEANIMOAMSET_56
	const BATTLEANIMOAMSET_57
	const BATTLEANIMOAMSET_58
	const BATTLEANIMOAMSET_59
	const BATTLEANIMOAMSET_5A
	const BATTLEANIMOAMSET_5B
	const BATTLEANIMOAMSET_5C
	const BATTLEANIMOAMSET_5D
	const BATTLEANIMOAMSET_5E
	const BATTLEANIMOAMSET_5F
	const BATTLEANIMOAMSET_60
	const BATTLEANIMOAMSET_61
	const BATTLEANIMOAMSET_62
	const BATTLEANIMOAMSET_63
	const BATTLEANIMOAMSET_64
	const BATTLEANIMOAMSET_65
	const BATTLEANIMOAMSET_66
	const BATTLEANIMOAMSET_67
	const BATTLEANIMOAMSET_68
	const BATTLEANIMOAMSET_69
	const BATTLEANIMOAMSET_6A
	const BATTLEANIMOAMSET_6B
	const BATTLEANIMOAMSET_6C
	const BATTLEANIMOAMSET_6D
	const BATTLEANIMOAMSET_6E
	const BATTLEANIMOAMSET_6F
	const BATTLEANIMOAMSET_70
	const BATTLEANIMOAMSET_71
	const BATTLEANIMOAMSET_72
	const BATTLEANIMOAMSET_73
	const BATTLEANIMOAMSET_74
	const BATTLEANIMOAMSET_75
	const BATTLEANIMOAMSET_76
	const BATTLEANIMOAMSET_77
	const BATTLEANIMOAMSET_78
	const BATTLEANIMOAMSET_79
	const BATTLEANIMOAMSET_7A
	const BATTLEANIMOAMSET_7B
	const BATTLEANIMOAMSET_7C
	const BATTLEANIMOAMSET_7D
	const BATTLEANIMOAMSET_7E
	const BATTLEANIMOAMSET_7F
	const BATTLEANIMOAMSET_80
	const BATTLEANIMOAMSET_81
	const BATTLEANIMOAMSET_82
	const BATTLEANIMOAMSET_83
	const BATTLEANIMOAMSET_84
	const BATTLEANIMOAMSET_85
	const BATTLEANIMOAMSET_86
	const BATTLEANIMOAMSET_87
	const BATTLEANIMOAMSET_88
	const BATTLEANIMOAMSET_89
	const BATTLEANIMOAMSET_8A
	const BATTLEANIMOAMSET_8B
	const BATTLEANIMOAMSET_8C
	const BATTLEANIMOAMSET_8D
	const BATTLEANIMOAMSET_8E
	const BATTLEANIMOAMSET_8F
	const BATTLEANIMOAMSET_90
	const BATTLEANIMOAMSET_91
	const BATTLEANIMOAMSET_92
	const BATTLEANIMOAMSET_93
	const BATTLEANIMOAMSET_94
	const BATTLEANIMOAMSET_95
	const BATTLEANIMOAMSET_96
	const BATTLEANIMOAMSET_97
	const BATTLEANIMOAMSET_98
	const BATTLEANIMOAMSET_99
	const BATTLEANIMOAMSET_9A
	const BATTLEANIMOAMSET_9B
	const BATTLEANIMOAMSET_9C
	const BATTLEANIMOAMSET_9D
	const BATTLEANIMOAMSET_9E
	const BATTLEANIMOAMSET_9F
	const BATTLEANIMOAMSET_A0
	const BATTLEANIMOAMSET_A1
	const BATTLEANIMOAMSET_A2
	const BATTLEANIMOAMSET_A3
	const BATTLEANIMOAMSET_A4
	const BATTLEANIMOAMSET_A5
	const BATTLEANIMOAMSET_A6
	const BATTLEANIMOAMSET_A7
	const BATTLEANIMOAMSET_A8
	const BATTLEANIMOAMSET_A9
	const BATTLEANIMOAMSET_AA
	const BATTLEANIMOAMSET_AB
	const BATTLEANIMOAMSET_AC
	const BATTLEANIMOAMSET_AD
	const BATTLEANIMOAMSET_AE
	const BATTLEANIMOAMSET_AF
	const BATTLEANIMOAMSET_B0
	const BATTLEANIMOAMSET_B1
	const BATTLEANIMOAMSET_B2
	const BATTLEANIMOAMSET_B3
	const BATTLEANIMOAMSET_B4
	const BATTLEANIMOAMSET_B5
	const BATTLEANIMOAMSET_B6
	const BATTLEANIMOAMSET_B7
	const BATTLEANIMOAMSET_B8
	const BATTLEANIMOAMSET_B9
	const BATTLEANIMOAMSET_BA
	const BATTLEANIMOAMSET_BB
	const BATTLEANIMOAMSET_BC
	const BATTLEANIMOAMSET_BD
	const BATTLEANIMOAMSET_BE
	const BATTLEANIMOAMSET_BF
	const BATTLEANIMOAMSET_C0
	const BATTLEANIMOAMSET_C1
	const BATTLEANIMOAMSET_C2
	const BATTLEANIMOAMSET_C3
	const BATTLEANIMOAMSET_C4
	const BATTLEANIMOAMSET_C5
	const BATTLEANIMOAMSET_C6
	const BATTLEANIMOAMSET_C7
	const BATTLEANIMOAMSET_C8
	const BATTLEANIMOAMSET_C9
	const BATTLEANIMOAMSET_CA
	const BATTLEANIMOAMSET_CB
	const BATTLEANIMOAMSET_CC
	const BATTLEANIMOAMSET_CD
	const BATTLEANIMOAMSET_CE
	const BATTLEANIMOAMSET_CF
	const BATTLEANIMOAMSET_D0
	const BATTLEANIMOAMSET_D1
	const BATTLEANIMOAMSET_D2
	const BATTLEANIMOAMSET_D3
	const BATTLEANIMOAMSET_D4
	const BATTLEANIMOAMSET_D5
	const BATTLEANIMOAMSET_D6
	const BATTLEANIMOAMSET_D7
	const BATTLEANIMOAMSET_D8
	const BATTLEANIMOAMSET_D9

; BattleBGEffects indexes (see engine/battle_anims/bg_effects.asm)
	const_def 1
	const ANIM_BG_FLASH_INVERTED
	const ANIM_BG_FLASH_WHITE
	const ANIM_BG_WHITE_HUES
	const ANIM_BG_BLACK_HUES
	const ANIM_BG_ALTERNATE_HUES
	const ANIM_BG_CYCLE_OBPALS_GRAY_AND_YELLOW
	const ANIM_BG_CYCLE_MID_OBPALS_GRAY_AND_YELLOW
	const ANIM_BG_CYCLE_BGPALS_INVERTED
	const ANIM_BG_HIDE_MON
	const ANIM_BG_SHOW_MON
	const ANIM_BG_ENTER_MON
	const ANIM_BG_RETURN_MON
	const ANIM_BG_SURF
	const ANIM_BG_WHIRLPOOL
	const ANIM_BG_TELEPORT
	const ANIM_BG_NIGHT_SHADE
	const ANIM_BG_BATTLEROBJ_1ROW
	const ANIM_BG_BATTLEROBJ_2ROW
	const ANIM_BG_DOUBLE_TEAM
	const ANIM_BG_ACID_ARMOR
	const ANIM_BG_RAPID_FLASH
	const ANIM_BG_FADE_MON_TO_LIGHT
	const ANIM_BG_FADE_MON_TO_BLACK
	const ANIM_BG_FADE_MON_TO_LIGHT_REPEATING
	const ANIM_BG_FADE_MON_TO_BLACK_REPEATING
	const ANIM_BG_CYCLE_MON_LIGHT_DARK_REPEATING
	const ANIM_BG_FLASH_MON_REPEATING
	const ANIM_BG_FADE_MONS_TO_BLACK_REPEATING
	const ANIM_BG_FADE_MON_TO_WHITE_WAIT_FADE_BACK
	const ANIM_BG_FADE_MON_FROM_WHITE
	const ANIM_BG_SHAKE_SCREEN_X
	const ANIM_BG_SHAKE_SCREEN_Y
	const ANIM_BG_WITHDRAW
	const ANIM_BG_BOUNCE_DOWN
	const ANIM_BG_DIG
	const ANIM_BG_TACKLE
	const ANIM_BG_BODY_SLAM
	const ANIM_BG_WOBBLE_MON
	const ANIM_BG_REMOVE_MON
	const ANIM_BG_WAVE_DEFORM_MON
	const ANIM_BG_PSYCHIC
	const ANIM_BG_BETA_SEND_OUT_MON1
	const ANIM_BG_BETA_SEND_OUT_MON2
	const ANIM_BG_FLAIL
	const ANIM_BG_BETA_PURSUIT
	const ANIM_BG_ROLLOUT
	const ANIM_BG_VITAL_THROW
	const ANIM_BG_START_WATER
	const ANIM_BG_WATER
	const ANIM_BG_END_WATER
	const ANIM_BG_VIBRATE_MON
	const ANIM_BG_WOBBLE_PLAYER
	const ANIM_BG_WOBBLE_SCREEN

; wBattleAnimTileDict keys (see wram.asm)
; AnimObjGFX indexes (see data/battle_anims/object_gfx.asm)
	const_def 1
	const ANIM_GFX_HIT
	const ANIM_GFX_CUT
	const ANIM_GFX_FIRE
	const ANIM_GFX_WATER
	const ANIM_GFX_LIGHTNING
	const ANIM_GFX_PLANT
	const ANIM_GFX_SMOKE
	const ANIM_GFX_EXPLOSION
	const ANIM_GFX_ROCKS
	const ANIM_GFX_ICE
	const ANIM_GFX_POKE_BALL
	const ANIM_GFX_POKE_BALL_BG
	const ANIM_GFX_POISON
	const ANIM_GFX_BUBBLE
	const ANIM_GFX_NOISE
	const ANIM_GFX_POWDER
	const ANIM_GFX_BEAM
	const ANIM_GFX_SPEED
	const ANIM_GFX_CHARGE
	const ANIM_GFX_WIND
	const ANIM_GFX_WHIP
	const ANIM_GFX_EGG
	const ANIM_GFX_ROPE
	const ANIM_GFX_PSYCHIC
	const ANIM_GFX_REFLECT
	const ANIM_GFX_STATUS
	const ANIM_GFX_SAND
	const ANIM_GFX_WEB
	const ANIM_GFX_HAZE
	const ANIM_GFX_HORN
	const ANIM_GFX_FLOWER
	const ANIM_GFX_MISC
	const ANIM_GFX_SKY_ATTACK
	const ANIM_GFX_GLOBE
	const ANIM_GFX_SHAPES
	const ANIM_GFX_OBJECTS
	const ANIM_GFX_SHINE
	const ANIM_GFX_ANGELS
	const ANIM_GFX_WAVE
	const ANIM_GFX_AEROBLAST
	const ANIM_GFX_PLAYERHEAD
	const ANIM_GFX_ENEMYFEET

; battle_bg_effect struct members (see macros/wram.asm)
	const_def
	const BG_EFFECT_STRUCT_FUNCTION
	const BG_EFFECT_STRUCT_JT_INDEX
	const BG_EFFECT_STRUCT_BATTLE_TURN
	const BG_EFFECT_STRUCT_PARAM
BG_EFFECT_STRUCT_LENGTH EQU const_value
NUM_BG_EFFECTS EQU 5 ; see wActiveBGEffects

; anim_bgeffect battle turn values for some effects
	const_def
	const BG_EFFECT_TARGET ; 0
	const BG_EFFECT_USER   ; 1

; battle palettes
	const_def
	const PAL_BATTLE_BG_PLAYER    ; 0
	const PAL_BATTLE_BG_ENEMY     ; 1
	const PAL_BATTLE_BG_ENEMY_HP  ; 2
	const PAL_BATTLE_BG_PLAYER_HP ; 3
	const PAL_BATTLE_BG_EXP       ; 4
	const PAL_BATTLE_BG_5         ; 5
	const PAL_BATTLE_BG_6         ; 6
	const PAL_BATTLE_BG_TEXT      ; 7

; animation object palettes
	const_def
	const PAL_BATTLE_OB_ENEMY      		; 0
	const PAL_BATTLE_OB_PLAYER    		; 1
	const PAL_BATTLE_OB_GRAY      		; 2
	const PAL_BATTLE_OB_YELLOW     		; 3
	const PAL_BATTLE_OB_RED        		; 4
	const PAL_BATTLE_OB_GREEN      		; 5
	const PAL_BATTLE_OB_BLUE       		; 6
	const PAL_BATTLE_OB_BROWN      		; 7
	const PAL_BATTLE_OB_POISON     		; 8
	const PAL_BATTLE_OB_RED_VIOLET 		; 9
	const PAL_BATTLE_OB_YELLOW_GREEN 	; A
	const PAL_BATTLE_OB_GHOST    		; B
	const PAL_BATTLE_OB_SKY_BLUE   		; C
	const PAL_BATTLE_OB_GRAY_2    		; D
	const PAL_BATTLE_OB_DRAGON    		; E
	const PAL_BATTLE_OB_PINK			; F	
	const PAL_BATTLE_OB_OTHERS_1		; 10
	const PAL_BATTLE_OB_OTHERS_2		; 11
	const PAL_BATTLE_OB_OTHERS_3		; 12
	const PAL_BATTLE_OB_GRAY_3    		; 13
