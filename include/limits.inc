.pragma list(push, 0)

CHAR_BIT	equ 8		; number of bits in a char
ifdef _CHAR_UNSIGNED
CHAR_MAX	equ 255
CHAR_MIN	equ 0
else
CHAR_MAX	equ 127
CHAR_MIN	equ (-128)
endif
SCHAR_MAX	equ 127
SCHAR_MIN	equ (-128)
UCHAR_MAX	equ 255

SHRT_MAX	equ 0x7FFF
SHRT_MIN	equ 0x8000
USHRT_MAX	equ 0xFFFF

INT_MAX		equ 0x7FFFFFFF
INT_MIN		equ 0x80000000
UINT_MAX	equ 0xFFFFFFFF
LONG_MAX	equ INT_MAX
LONG_MIN	equ INT_MIN

MB_LEN_MAX	equ 2

_I64_MIN	equ (-9223372036854775807 - 1)
_I64_MAX	equ 9223372036854775807
_UI64_MAX	equ 0xffffffffffffffff

ifndef SIZE_MAX
ifdef _WIN64
SIZE_MAX	equ _UI64_MAX
else
SIZE_MAX	equ UINT_MAX
endif
endif
.pragma list(pop)
