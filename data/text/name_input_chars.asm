; see engine/menus/naming_screen.asm

NameInputLower:
	db "a b c d e f g h i"
	db "j k l m n o p q r"
	db "s t u v w x y z é"
	db "'d 'l 'm 'r 's 't 'v    "
	db "Other  DEL   END "

BoxNameInputLower:
	db "a b c d e f g h i"
	db "j k l m n o p q r"
	db "s t u v w x y z  "
	db "é 'd 'l 'm 'r 's 't 'v 0"
	db "1 2 3 4 5 6 7 8 9"
	db "UPPER  DEL   END "

NameInputUpper:
	db "A B C D E F G H I"
	db "J K L M N O P Q R"
	db "S T U V W X Y Z  "
	db "<PO> <KE> <PERCENT> <PK> <MN>        "
	db "lower  DEL   END "

BoxNameInputUpper:
	db "A B C D E F G H I"
	db "J K L M N O P Q R"
	db "S T U V W X Y Z  "
	db "× ( ) : ; [ ] <PK> <MN>"
	db "- ? ! ♂ ♀ / . , &"
	db "lower  DEL   END "
	
NameInputOther:
	db "1 2 3 4 5 6 7 8 9"
	db "0 . ? ! & , ′ ″ …"
	db "× ( ) : ; [ ] ♂ ♀"
	db "- : “ ” ¥        "
	db "UPPER  DEL   END "
