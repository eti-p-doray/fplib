/* Copyright (c) 2002  Michael Stumpf  <mistumpf@de.pepperl-fuchs.com>
   Copyright (c) 2006  Dmitry Xmelkov
   Copyright (c) 2015  Etienne Pierre-Doray
   All rights reserved.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are met:

   * Redistributions of source code must retain the above copyright
     notice, this list of conditions and the following disclaimer.
   * Redistributions in binary form must reproduce the above copyright
     notice, this list of conditions and the following disclaimer in
     the documentation and/or other materials provided with the
     distribution.
   * Neither the name of the copyright holders nor the names of
     contributors may be used to endorse or promote products derived
     from this software without specific prior written permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
   ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
   POSSIBILITY OF SUCH DAMAGE. */

/* $Id: addsf3x.S 2191 2010-11-05 13:45:57Z arcanum $ */


#if !defined(__AVR_TINY__)

#include "fp32def.h"
#include "asmdef.h"

FUNCTION addsf3x

/********************************************************************************
 *  Addition of 2 splflt40_t
 *
 *  splflt40_t operator+(splflt40_t a, splflt40_t b) {
 *    x = a + b;
 *    return x;
 *  }
 *
 *  Register pressure = 13
 *  # cycles = 70 typical
 *
 *  \Input
 *  aE  : r25 Exponent<7..0>
 *  aM0 : r24 1:Mantissa<29..23>
 *  aM1 : r23 Mantissa<22..15>
 *  aM2 : r22 Mantissa<14..7>
 *  aM3 : r27 Sign:Mantissa<6..0>
 *
 *  bE  : r21 Exponent<7..0>
 *  bM0 : r20 1:Mantissa<29..23>
 *  bM1 : r19 Mantissa<22..15>
 *  bM2 : r18 Mantissa<14..7>
 *  bM3 : r26 Sign:Mantissa<6..0>
 *
 *  \Output
 *  xE  : +(aE)   Exponent<7..0>
 *  xM0 : +(aM3)  1:Mantissa<30..24>
 *  xM1 : +(aM2)  Mantissa<23..16>
 *  xM2 : +(aM1)  Mantissa<15..8>
 *  xM3 : +(aM0)  Mantissa<7..0>
 *
 *  \Clobber
 *  r0
 *  r30
 *  r31
 ********************************************************************************/
ENTRY	__addsf3x

  /********************************************************************************
   * Register allocation
   *  Register pressure = 2
   *  aM3  : r27
   *  bM3  : r26
   ********************************************************************************/
  /********************************************************************************
   *  Put aS ^ bS in T
   *  T <- aS ^ bS
   *
   *  # cycles = 3
   *
   *  \Input
   *  aM3  : r   Sign:Mantissa<6..0> of a
   *  bM3  : r   Sign:Mantissa<6..0> of b
   *
   *  \Output
   *  xS  : T  aS ^ bS
   *
   *  \Clobber
   *  r0
   ********************************************************************************/

  mov r0, aM3;
  eor r0, bM3;
  bst r0, 7;

  /********************************************************************************
   * Register allocation
   *  Register pressure = 12
   *  stack size = 0
   *  stack
   *  aE  : r25
   *  aM0 : r24
   *  aM1 : r23
   *  aM2 : r22
   *  aM3 : r27
   *  bE  : r21
   *  bM0 : r20
   *  bM1 : r19
   *  bM2 : r18
   *  bM3 : r26
   *  Ed  : r25
   *  tmp1  : r31
   *  tmp0  : r30
   ********************************************************************************/
  #define Ed  r25
  #define tmp1  r31
  #define tmp0  r30
  /********************************************************************************
   *  Compare exp for exponent difference
   *  Ed = abs(aE - bE)
   *  Put biggest operand in A
   *
   *  # cycles = 5-14
   *
   *  \Input
   *  aE  : r Exponent<7..0>
   *  bE  : r Exponent<7..0>
   *
   *  \Input - Output
   *  aM0 : r 1:Mantissa<29..23>
   *  aM1 : r Mantissa<22..15>
   *  aM2 : r Mantissa<14..7>
   *  aM3 : r Sign:Mantissa<6..0>
   *
   *  bM0 : r Mantissa<31..24>
   *  bM1 : r Mantissa<23..16>
   *  bM2 : r Mantissa<15..8>
   *  bM3 : r Mantissa<7..0> <- We're removing the sign here
   *
   *  \Output
   *  Ed  : +(aE) Exponents difference
   *
   *  \Clobber
   *  tmp0  : temporary register to swap
   *  tmp1  : temporary register to swap
   ********************************************************************************/

  sub  aE, bE;
  breq  L10; if (Ed == 0) // Denormalization not needed
    rjmp  L32
L10:
  brsh  L11;  if (Ed > 0)
    ; if (Ed < 0)
    neg Ed; Ed <- -Ed
    ; swap A and B
    mov   tmp0, aM3;
    mov   aM3,  bM3
    mov   bM3,  tmp0
    X_movw  tmp0  aM2
    X_movw  aM2,  bM2
    X_movw  bM2,  tmp0
    mov   tmp0, aM0;
    mov   aM0,  bM0
    mov   bM0,  tmp0
L11:
   lsr  bM3;  bM3 <<= 1 // We don't need its sign anymore

  /********************************************************************************
   * Register allocation
   *  Register pressure = 6
   *  bM0 : r20
   *  bM1 : r19
   *  bM2 : r18
   *  bM3 : r26
   *  bM4 : r30
   *  Ed  : r25
   ********************************************************************************/
  #define bM4 r30
  /********************************************************************************
   *  Denormalize B to align with A
   *  First step : Binary decision tree to shift B by swapping bytes
   *
   *  # cycles = 6-15
   *
   *  \Input
   *  dE  : r Sign of x
   *  aM3 : r Sign:Mantissa<6..0> conditional to 22
   *
   *  \Input - Output
   *  bM0 : r Mantissa<39..32>
   *  bM1 : r Mantissa<31..24>
   *  bM2 : r Mantissa<23..16>
   *  bM3 : r Mantissa<15..8>
   *  bM4 : r Mantissa<7..0>
   *
   *  \Output
   *  aS  : r Sign of A conditional to 22
   ********************************************************************************/
__fp_pl_Bdenorm:
  cpi Ed, 13
  brlo  L23; if (Ed < 13)
    cpi Ed, 29
    brsh  L21; if (Ed >= 21)
      cpi Ed, 21
      brlo  L20; if (Ed < 32)
          ; 21 <= Ed < 29
          mov bM4,  bM1;  bM >>= 24
          mov bM3,  bM0
          clr bM2
          clr bM1
          clr bM0
          subi  Ed, 24;  Ed -= 24
          rjmp  L24
  L20:
          ; 13 <= Ed < 21
          mov bM4,  bM2;  bM >>= 16
          mov bM3,  bM1
          mov bM2,  bM0
          clr bM1
          clr bM0
          subi  Ed, 16;  Ed -= 16
          rjmp  L24
  L21:
      cpi Ed, 32
      brsh  L22
          ; 29 <= Ed < 32
          mov bM4,  bM0;  bM >>= 32
          clr bM3
          clr bM2
          clr bM1
          clr bM0
          subi  Ed, 32;  Ed -= 32
          rjmp  L24
  L22:
          ; Ed >= 32
          ; Difference is too big, return biggest number: A
          bst aM3,  7;  Put sign of A in T
          ret;
  L23:
    cpi Ed, 5
    brlo  L24
          ; 5 <= Ed < 13
          mov bM4,  bM3;  bM >>= 8
          mov bM3,  bM2
          mov bM2,  bM1
          mov bM1,  bM0
          clr bM0
          subi  Ed, 8;  Ed -= 8
L24:
  ; -3 <= Ed < 5


  /********************************************************************************
   * Register allocation
   *  Register pressure = 6
   *  bM0 : r20
   *  bM1 : r19
   *  bM2 : r18
   *  bM3 : r26
   *  bM4 : r30
   *  Ed  : r25
   ********************************************************************************/
  /********************************************************************************
   *  Denormalize B to align with A
   *  Second step : Shift loop
   *
   *  # cycles = 4-28
   *
   *  \Input
   *  dE  : r Sign of x
   *
   *  \Input - Output
   *  bM0 : r Mantissa<39..32>
   *  bM1 : r Mantissa<31..24>
   *  bM2 : r Mantissa<23..16>
   *  bM3 : r Mantissa<15..8>
   *  bM4 : r Mantissa<7..0>
   ********************************************************************************/

  tst Ed
  breq  L32
  brmi  L31; if (Ed < 0)
L30: ; while (Ed != 0) {bM >>= 1;  Ed--}
    lsr bM0;
    ror bM1;
    ror bM2;
    ror bM3;
    dec Ed;
    brne  L30
    rjmp  L32

L31: ; while (Ed != 0) {bM <<= 1;  Ed++}
    lsl bM4;
    rol bM3;
    rol bM2;
    rol bM1;
    rol bM0;
    inc Ed;
    brne  L31

L32:
  brts  __fp_pl_sub

  /********************************************************************************
   * Register allocation
   *  Register pressure = 8
   *  aM0 : r24
   *  aM1 : r23
   *  aM2 : r22
   *  aM3 : r27
   *  bM0 : r20
   *  bM1 : r19
   *  bM2 : r18
   *  bM3 : r26
   *  xE  : r25
   *  xM0 : r24
   *  xM1 : r23
   *  xM2 : r22
   *  xM3 : r27
   ********************************************************************************/
  /********************************************************************************
   *  Both A and B are the same sign : Add A and B
   *
   *  # cycles = 8-14
   *
   *  \Input
   *  aM0 : r 1:Mantissa<30..24>
   *  aM1 : r Mantissa<23..16>
   *  aM2 : r Mantissa<15..8>
   *  aM3 : r Mantissa<7..0> <- We're removing the sign here
   *
   *  bM0 : r Mantissa<31..24>
   *  bM1 : r Mantissa<23..16>
   *  bM2 : r Mantissa<15..8>
   *  bM3 : r Mantissa<7..0>
   *
   *  \Input - Output
   *  xE  : r   Exponent<7..0>
   *
   *  \Output
   *  xM0 : +(aM3)  1:Mantissa<30..24>
   *  xM1 : +(aM2)  Mantissa<23..16>
   *  xM2 : +(aM1)  Mantissa<15..8>
   *  xM3 : +(aM0)  Mantissa<7..0>
   ********************************************************************************/

__fp_pl_add:
  bld aM3,  7;  T <- a.sign
  lsr aM3

  add aM3,  bM3;  xM = aM + bM;
  adc aM2,  bM2
  adc aM1,  bM1
  adc aM0,  bM0

  brcc  L40;
    ; if (xM >= 2.0)
    ror xM0;  xM >>= 1;
    ror xM1
    ror xM2
    ror xM3
    inc xE
    cpi xE,  0xff; if (xE >= 255)
    breq  __fp_pl_inf; return inf
L40:
  ret

    /********************************************************************************
   *  Answer is inf
   *
   *  \Input
   *  xS  : T sign of result
   *
   *  \Output
   *  xE  : r25 Exponent<7..0>
   *  xM0 : r24 1:Mantissa<29..22>
   *  xM1 : r23 Mantissa<21..15>
   *  xM2 : r22 Mantissa<14..7>
   *  xM3 : r22 Sign:Mantissa<6..0>
   ********************************************************************************/
  __fp_pl_inf:
    rjmp  _U(__fp_splinf);

  /********************************************************************************
   * Register allocation
   *  Register pressure = 8
   *  aM0 : r24
   *  aM1 : r23
   *  aM2 : r22
   *  aM3 : r27
   *  bM0 : r20
   *  bM1 : r19
   *  bM2 : r18
   *  bM3 : r26
   *  xE  : r25
   *  xM0 : r24
   *  xM1 : r23
   *  xM2 : r22
   *  xM3 : r27
   ********************************************************************************/
  /********************************************************************************
   *  A and B are not the same sign : substract B from A
   *
   *  # cycles = 8-15
   *
   *  \Input
   *  aM0 : r 1:Mantissa<30..24>
   *  aM1 : r Mantissa<23..16>
   *  aM2 : r Mantissa<15..8>
   *  aM3 : r Mantissa<7..0> <- We're removing the sign here
   *
   *  bM0 : r Mantissa<31..24>
   *  bM1 : r Mantissa<23..16>
   *  bM2 : r Mantissa<15..8>
   *  bM3 : r Mantissa<7..0>
   *
   *  \Output
   *  xM0 : +(aM3)  1:Mantissa<30..24>
   *  xM1 : +(aM2)  Mantissa<23..16>
   *  xM2 : +(aM1)  Mantissa<15..8>
   *  xM3 : +(aM0)  Mantissa<7..0>
   ********************************************************************************/

__fp_pl_sub:
  bld aM3,  7
  lsr aM3

  sub aM3,  bM3;  xM = aM - bM;
  sbc aM2,  bM2
  sbc aM1,  bM1
  sbc aM0,  bM0
  brcc  L50
    com xM3;  if (xM < 0)
    com xM2;  {
    com xM1;    xM = -xM;
    com xM0;  }
    subi  xM3,  -1
    sbci  xM2,  -1
    sbci  xM1,  -1
    sbci  xM0,  -1
L50:

  /********************************************************************************
   * Register allocation
   *  Register pressure = 2
   *  stack size = 0
   *  xM0 : r20
   *  xM1 : r19
   *  xM2 : r18
   *  xM3 : r26
   *  xE  : r25
   ********************************************************************************/
  /********************************************************************************
   *  Renormalisation of result
   *  First step :  Binary decision tree
   *
   *  # cycles = 3-12
   *
   *  \Input - Output
   *  xE  : d Exponent<7..0>
   *  xM0 : r Mantissa<31..24>
   *  xM1 : r Mantissa<23..16>
   *  xM2 : r Mantissa<15..8>
   *  xM3 : r Mantissa<7..0>
   ********************************************************************************/

ENTRY __fp_pl_Xrenorm
  brne  L63
    tst xM1
    brne  L62
      tst xM2
      brne  L61
        tst xM3
        brne  L60
          ; if (xM == 0)
          rjmp  _U(__fp_splszero); return szero
      L60:
          ; if (xM<31..8> == 0)
          cpi xE, 25
          brlo  L61
          mov xM0,  xM3
          clr xM1
          clr xM2
          clr xM3
          subi  xE, 24
      L61:
          cpi xE, 17
          brlo  L62
          mov xM0,  xM2
          mov xM1,  xM3
          clr xM2
          clr xM3
          subi  xE, 16
      L62:
          cpi xE, 9
          brlo  L63
          mov xM0,  xM1
          mov xM1,  xM2
          mov xM2,  xM3
          clr xM3
          subi  xE, 8
      L63:

  /********************************************************************************
   * Register allocation
   *  Register pressure = 2
   *  stack size = 0
   *  xM0 : r20
   *  xM1 : r19
   *  xM2 : r18
   *  xM3 : r26
   *  xE  : r25
   ********************************************************************************/
  /********************************************************************************
   *  Renormalisation of result
   *  Second step :
   *
   *  # cycles = 3-12
   *
   *  \Input - Output
   *  xE  : r Exponent<7..0>
   *  xM0 : d Mantissa<31..24>
   *  xM1 : r Mantissa<23..16>
   *  xM2 : r Mantissa<15..8>
   *  xM3 : r Mantissa<7..0>
   ********************************************************************************/

__fp_pl_Xrenorml:

  tst xM0
  brmi  L72
  cpi xM0,  0b00001000
  brsh  L70
  cpi xE, 8
  brsh  __fp_pl_Xrenormr
L70:
    dec xE
    breq  L71
    lsl xM3
    rol xM2
    rol xM1
    rol xM0
    brpl  L70
    ret

L71:
  inc xE
L72:
  ret

__fp_pl_Xrenormr:

  /********************************************************************************
   * Register allocation
   *  Register pressure = 2
   *  # cycles  5
   *  xE  : r25
   *  xM0 : r30
   *  xM1 : r24
   *  xM2 : r23
   *  xM3 : r22
   *  xM4 : r27
   ********************************************************************************/
  mov r30,  xM0
  #undef  xM0
  #define xM0 r30
  mov r24,  xM1
  #undef  xM1
  #define xM1 r24
  mov r23,  xM2
  #undef  xM2
  #define xM2 r23
  mov r22,  xM3
  #undef  xM3
  #define xM3 r22
  clr r21
  #define xM4 r27
  /********************************************************************************
   *  Renormalisation of result
   *  Second step :
   *
   *  # cycles = 8-28
   *
   *  \Input - Output
   *  xE  : r Exponent<7..0>
   *  xM0 : r Mantissa<39..32>
   *  xM1 : r Mantissa<31..24>
   *  xM2 : r Mantissa<23..16>
   *  xM3 : r Mantissa<15..8>
   *  xM4 : r = 0 Mantissa<7..0>
   ********************************************************************************/

  subi  xE, 7
  lsr xM0
  ror xM1
  brmi  L83
L82:
  ror xM2
  ror xM3
  ror xM4
  inc xE
  lsr xM0
  ror xM1
  brpl  L82
L83:
  ror xM2
  ror xM3
  ror xM4

L84:
  ret

ENDFUNC

#endif /* !defined(__AVR_TINY__) */
