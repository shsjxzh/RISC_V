	.org 0x0
.global _start
_start:
   lui  x1,0x101           #x1 = 0x00101000
   ori  x1,x1,0x101        #x1 = 0x00101101
   auipc x5, 0xff012       #x5 = 0xff012008
   or   x2,x1,x5           #x2 = 0xff113109
   andi x3,x1,-0x3fe       #x3 = 0x00101000
   and  x1,x3,x1           #x1 = 0x00101000
   xori x4,x1,0x032        #x4 = 0x00101032
   xor  x1,x4,x1           #x1 = 0x00000032
