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

/* $Id: muldf3x.S 1174 2015-01-14 15:13:54Z dmix $ */

#include "fp32def.h"
#include "asmdef.h"

FUNCTION  __mulsf3x

/********************************************************************************
 *  Answer is szero
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
__fp_ml_szero:
  rjmp  _U(__fp_splszero);

/********************************************************************************
 *  Multiplication of 2 splflt40_t
 *
 *  splflt40_t operator*(splflt40_t a, splflt40_t b) {
 *    x = a * b;
 *    return x;
 *  }
 *
 *  Register pressure = 12
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
 *  xM0 : +(aM3)  1:Mantissa<29..23>
 *  xM1 : +(aM2)  Mantissa<22..15>
 *  xM2 : +(aM1)  Mantissa<14..7>
 *  xM3 : +(aM0)  Sign:Mantissa<6..0>
 *
 *  \Clobber
 *  r0
 *  r30
 *  r31
 ********************************************************************************/
ENTRY   __mulsf3x

  /********************************************************************************
   * Register allocation
   *  Register pressure = 2
   *  stack size = 0
   *  stack
   *  aM3  : r27
   *  bM3  : r26
   ********************************************************************************/
  /********************************************************************************
   *  Put sign of x in T
   *  T = aS ^ bS
   *
   *  # cycles = 5
   *
   *  \Input
   *  aM3 : r Sign:Mantissa<6..0> of a
   *  bM3 : r Sign:Mantissa<6..0> of b
   *
   *  \Output
   *  xS  : T  Sign of x
   *
   *  \Clobber
   *  r0
   ********************************************************************************/

  lsr aM3;
  rol r0;
  lsr bM3;
  adc r0, r1;
  bst r0, 7;

  /********************************************************************************
   * Register allocation
   *  Register pressure = 2
   *  stack size = 0
   *  aE  : r25
   *  bE  : r21
   *  xE0 : r25
   *  xE1 : r21
   ********************************************************************************/
  #define xE0 r25
  #define xE1 r21
  /********************************************************************************
   *  Exponent part of result calculation for multiplication
   *  zero is detected
   *
   *  # cycles = 6
   *
   *  \Input
   *  aE  : d   Exponent<7..0> of a
   *  bE  : d   Exponent<7..0> of b
   *
   *  \Output
   *  xE1  : +r(bE)  Exponent<15..8> of x
   *  xE0  : +r(aE)  Exponent<7..0> of x
   *
   *  \Clobber
   *  r0
   *  r1
   ********************************************************************************/

  #if	defined(__AVR_ENHANCED__) && __AVR_ENHANCED__
    mul aE, bE; if (aE == 0 || bE == 0)
    breq  __fp_ml_szero;
  #else	/* to __AVR_ENHANCED__	*/
    tst aE
    breq  __fp_ml_szero;
    tst bE
    breq  __fp_ml_szero;
  #endif	/* not __AVR_ENHANCED__	*/

  add xE0,  bE; xE <- aE + bE
  clr xE1;
  adc xE1,  xE1;

  #if	defined(__AVR_ENHANCED__) && __AVR_ENHANCED__
    /********************************************************************************
     * Register allocation
     *  Register pressure = 10
     *  stack size = 0
     *  # cycles = 2
     *  aM0 : r24
     *  aM1 : r23
     *  aM2 : r22
     *  aM3 : r27
     *  bM0 : r20
     *  bM1 : r19
     *  bM2 : r18
     *  bM3 : r26
     *  xM2 : r30
     *  xM3 : r27
     *  zero  : r31
     ********************************************************************************/
    #undef  xM2
    #define xM2 r30 
    clr xM2; xM2 <- 0
    #undef  zero
    #define zero  r31
    clr zero; zero <- 0
    /********************************************************************************
     *  Mantissa multiplication of a and b
     *  xM2:xM3 = aM0*bM3 + aM3*bM0
     *
     *  # cycles = 7
     *
     *  \Input
     *  zero  : r = 0 Zero register for add
     *
     *  aM0  : r  Mantissa<31..24>
     *  aM1  : r  Mantissa<23..16>
     *  aM2  : r  Mantissa<15..8>
     *  aM3  : r  Mantissa<7..0>
     *
     *  bM0  : r  Mantissa<31..24>
     *  bM1  : r  Mantissa<23..16>
     *  bM2  : r  Mantissa<15..8>
     *  bM3  : r  Mantissa<7..0>
     *
     *  \Output
     *  xM2  : r = 0  Mantissa<15..8>
     *  xM3  : +(aM3)  Mantissa<7..0>
     *
     *  \Clobber
     *  r0
     *  r1
     ********************************************************************************/

    mul aM3,  bM0;  r1:r0 = aM0 * bM3
    mov xM3,  r1; xM3 = r1

    mul aM0,  bM3;  r1:r0 = aM3 * bM0
    add xM3,  r1; xM2:xM3 += r1
    adc xM2,  zero;

    /********************************************************************************
     * Register allocation
     *  Register pressure = 10
     *  stack size = 0
     *  # cycles = 1
     *  aM0 : r24
     *  aM1 : r23
     *  aM2 : r22
     *  bM0 : r20
     *  bM1 : r19
     *  bM2 : r18
     *  xM1 : r31
     *  xM2 : r30
     *  xM3 : r27
     *  zero  : r26
     ********************************************************************************/
    #undef  xM1
    #define xM1 r31
    #undef  zero
    #define zero  r26
    clr zero;
    /********************************************************************************
     *  Mantissa multiplication of a and b
     *  xM1:xM2:xM3 += aM1*bM2 + aM2*bM1 + aM0*bM2 + aM2*bM0
     *
     *  # cycles = 18
     *
     *  \Input
     *  zero  : r = 0 Zero register for add
     *
     *  aM0  : r  Mantissa<31..24>
     *  aM1  : r  Mantissa<23..16>
     *  aM2  : r  Mantissa<15..8>
     *
     *  bM0  : r  Mantissa<31..24>
     *  bM1  : r  Mantissa<23..16>
     *  bM2  : r  Mantissa<15..8>
     *
     *  \Input - Output
     *  xM2  : r  Mantissa<15..8>
     *  xM3  : r  Mantissa<7..0>
     *
     *  \Output
     *  xM1  : r = 0  Mantissa<23..16>
     *
     *  \Clobber
     *  r0
     *  r1
     ********************************************************************************/

    mul aM1,  bM2;  r1:r0 = aM1 * bM2
    add xM3,  r1; xM2:xM3 += r1
    adc xM2,  zero;

    mul aM2,  bM1;  r1:r0 = aM2 * bM1
    add xM3,  r1; xM2:xM3 += r1
    adc xM2,  zero;

    mul aM0,  bM2;
    add xM3,  r0;
    adc xM2,  r1;
    adc xM1,  zero;

    mul aM2,  bM0;
    add xM3,  r0;
    adc xM2,  r1;
    adc xM1,  zero;

    /********************************************************************************
     * Register allocation
     *  Register pressure = 9
     *  stack size = 0
     *  # cycles = 1
     *  aM0 : r24
     *  aM1 : r23
     *  bM0 : r20
     *  bM1 : r19
     *  xM0 : r18
     *  xM1 : r31
     *  xM2 : r30
     *  xM3 : r27
     *  zero  : r26
     **************************************************************************/
    #undef xM0
    #define xM0 r18
    clr xM0;
    /***************************************************************************
     *  Mantissa multiplication of a and b
     *  xM0:xM1:xM2:xM3 = aM0:aM1:aM2:aM3 * bM0:bM1:bM2:bM3
     *
     *  # cycles = 19
     *
     *  \Input
     *  zero  : r = 0 Zero register for add
     *
     *  aM0  : r  Mantissa<31..24>
     *  aM1  : r  Mantissa<23..16>
     *
     *  bM0  : r  Mantissa<31..24>
     *  bM1  : r  Mantissa<23..16>
     *
     *  \Input - Output
     *  xM1  : r  Mantissa<23..16>
     *  xM2  : r  Mantissa<15..8>
     *  xM3  : r  Mantissa<7..0>
     *
     *  \Output
     *  xM0  : r = 0  Mantissa<31..24>
     *
     *  \Clobber
     *  r0
     *  r1
     **************************************************************************/

    mul aM1,  bM1;
    add xM3,  r0;
    adc xM2,  r1;
    adc xM1,  zero;

    mul aM0,  bM1;
    add xM2,  r0;
    adc xM1,  r1;
    adc xM0,  zero;

    mul aM1,  bM0;
    add xM2,  r0;
    adc xM1,  r1;
    adc xM0,  zero;

    mul aM0,  bM0; r1:r0 = aM0 * bM0
    add xM1,  r0;
    adc xM0,  r1;


  #else	/* to __AVR_ENHANCED__	*/
    /********************************************************************************
     * Register allocation
     *  Register pressure = 10
     *  stack size = 0
     *  # cycles = 2
     *  aM0 : r24
     *  aM1 : r23
     *  aM2 : r22
     *  aM3 : r27
     *  bM0 : r20
     *  tmpbM0 : r0
     *  bM1 : r19
     *  bM2 : r18
     *  bM3 : r26
     *  xM2 : r30
     *  xM3 : r31
     ********************************************************************************/
    #define tmpbM0  r0
    mov  tmpbM0, bM0
    #undef  xM2
    #define xM2 r30
    clr  xM2
    #undef  xM3
    #define xM3 r31
    clr  xM3
    /********************************************************************************
     *  Mantissa multiplication of a and b
     *  xM2:xM3 = aM3*bM0
     *
     *  # cycles = 11
     *
     *  \Input
     *  aM0  : r  Mantissa<31..24>
     *  aM1  : r  Mantissa<23..16>
     *  aM2  : r  Mantissa<15..8>
     *  aM3  : r  Mantissa<7..0>
     *
     *  bM0  : r  Mantissa<31..24>
     *  bM1  : r  Mantissa<23..16>
     *  bM2  : r  Mantissa<15..8>
     *  bM3  : r  Mantissa<7..0>
     *
     *  \Output
     *  xM2  : r = 0  Mantissa<15..8>
     *  xM3  : r = 0  Mantissa<7..0>
     *
     *  \Clobber
     *  bM0  : r  Mantissa<31..24>
     ********************************************************************************/
    /*
    for (int i = 0; i < 8; i++) {
      xM += aM3<i> * (bM << i) >> 24;
    }
    */
    sec			; to count loops
	  ror aM3
 01:brcc	02f
	  adc	xM3,  bM0 
	  adc xM2,  r1
 02:rol	bM0
	  lsr	aM3
	  brne	01b

    /********************************************************************************
     * Register allocation
     *  Register pressure = 11
     *  stack size = 0
     *  # cycles = 3
     *  aM0 : r24
     *  aM1 : r23
     *  aM2 : r22
     *  bM0 : r20
     *  tmpbM0  : r0
     *  bM1 : r19
     *  bM2 : r18
     *  bM3 : r26
     *  xM1 : r31
     *  xM2 : r30
     *  xM3 : r27
     ********************************************************************************/
    mov  r27,  xM3
    #undef xM3
    #define  xM3 r27
    mov  bM0,  tmpbM0
    #undef xM1
    #define  xM1  r23
    clr  xM1
    /********************************************************************************
     *  Mantissa multiplication of a and b
     *  xM1:xM2:xM3 += aM2*bM0:bM1
     *
     *  \Input
     *  aM0  : r  Mantissa<31..24>
     *  aM1  : r  Mantissa<23..16>
     *  aM2  : r  Mantissa<15..8>
     *
     *  bM0  : r  Mantissa<31..24>
     *  bM1  : r  Mantissa<23..16>
     *  bM2  : r  Mantissa<15..8>
     *  bM3  : r  Mantissa<7..0>
     *
     *  \Output
     *  xM1  : r = 0  Mantissa<23..16>
     *  xM2  : r  Mantissa<15..8>
     *  xM3  : r  Mantissa<7..0>
     *
     *  \Clobber
     *  bM0  : r Mantissa<23..16>
     ********************************************************************************/
    /*
    for (int i = 0; i < 8; i++) {
      xM += aM2<i> * (bM << i) >> 16;
    }
    */
	  ror aM2
  11:brcc	12f
    adc	xM3,  bM1 
	  adc	xM2,  bM0 
	  adc xM1,  r1
  12:rol	bM1
	  rol	bM0
	  lsr	aM2
	  brne	11b

    /********************************************************************************
     * Register allocation
     *  Register pressure = 11
     *  stack size = 0
     *  # cycles = 2
     *  aM0 : r24
     *  aM1 : r23
     *  bM0 : r19
     *  tmpbM0  : r0
     *  bM1 : r20
     *  bM2 : r18
     *  bM3 : r26
     *  xM0 : r22
     *  xM1 : r31
     *  xM2 : r30
     *  xM3 : r27
     ********************************************************************************/
    #undef  bM0
    #define bM0 r19
    #undef  bM1
    #define bM1 r20
    mov  bM0,  tmpbM0
    #undef  xM0
    #define xM0 r22
    clr  xM0
    /********************************************************************************
     *  Mantissa multiplication of a and b
     *  xM0:xM1:xM2:xM3 += aM1*bM0:bM1:bM2
     *
     *  \Input
     *  aM0  : r  Mantissa<31..24>
     *  aM1  : r  Mantissa<23..16>
     *
     *  bM0  : r  Mantissa<31..24>
     *  bM1  : r Mantissa<23..16>
     *  bM2  : r  Mantissa<15..8>
     *  bM3  : r  Mantissa<7..0>
     *
     *  \Output
     *  xM0  : r = 0  Mantissa<31..24>
     *  xM1  : r  Mantissa<23..16>
     *  xM2  : r  Mantissa<15..8>
     *  xM3  : r  Mantissa<7..0>
     *
     *  \Clobber
     *  bM0  : r  Mantissa<15..8>
     ********************************************************************************/
    /*
    for (int i = 0; i < 8; i++) {
      xM += aM1<i> * (bM << i) >> 8;
    }
    */
    ror aM1
  21:brcc	22f
    adc	xM3,  bM2 
    adc	xM2,  bM1 
	  adc	xM1,  bM0 
	  adc xM0,  r1
  22:rol	bM2
    rol	bM1
	  rol	bM0
	  lsr	aM1
	  brne	21b


    /********************************************************************************
     * Register allocation
     *  Register pressure = 9
     *  aM0 : r24
     *  bM0 : r18
     *  bM1 : r19
     *  bM2 : r20
     *  bM3 : r26
     *  xM0 : r22
     *  xM1 : r31
     *  xM2 : r30
     *  xM3 : r27
     ********************************************************************************/
    #undef  bM0
    #define bM0 r18
    #undef  bM1
    #define bM1 r19
    #undef  bM2
    #define bM2 r20
    #undef  xM0
    #define xM0 r22
    /********************************************************************************
     *  Mantissa multiplication of a and b
     *  xM0:xM1:xM2:xM3 += aM0*bM0:bM1:bM2:bM3
     *
     *  \Input
     *  aM0  : r  Mantissa<31..24>
     *
     *  bM0  : r  Mantissa<31..24>
     *  bM1  : r Mantissa<23..16>
     *  bM2  : r  Mantissa<15..8>
     *  bM3  : r  Mantissa<7..0>
     *
     *  \Output
     *  xM0  : r  Mantissa<31..24>
     *  xM1  : r  Mantissa<23..16>
     *  xM2  : r  Mantissa<15..8>
     *  xM3  : r  Mantissa<7..0>
     *
     *  \Clobber
     *  bM3  : r  Mantissa<7..0>
     ********************************************************************************/
    /*
    for (int i = 0; i < 8; i++) {
      xM += aM0<i> * (bM << i);
    }
    */
    ror aM0
 31:brcc	32f
    adc	xM3,  bM3 
    adc	xM2,  bM2 
	  adc	xM1,  bM1 
	  adc xM0,  bM0
 32:rol	bM3
    rol	bM2
    rol	bM1
	  rol	bM0
	  lsr	aM0
    brne	31b

  #endif	/* not __AVR_ENHANCED__	*/
  /********************************************************************************
   * Register allocation
   *  Register pressure = 6
   *  # cycles = 3
   *  xE1 : r21
   *  xE0 : r25
   *  xM0 : r24
   *  xM1 : r23
   *  xM2 : r22
   *  xM3 : r27
   ********************************************************************************/
  X_movw  r22,  xM2
  #undef  xM2
  #define xM2 r22
  #undef  xM1
  #define xM1 r23
  mov   r24,  xM0
  #undef  xM0
  #define xM0 r24
  /********************************************************************************
   *  Renormalization or denormalization of Mantissa
   *
   *  # cycles = 10-17 typical
   *
   *  \Input - Output
   *  xE1 : d  Exponent<15..8>
   *  xE0 : d  Exponent<7..0>
   *  xM0 : d  Mantissa<31..24>
   *  xM1 : r  Mantissa<23..16>
   *  xM2 : r  Mantissa<15..8>
   *  xM3 : r  Mantissa<7..0>
   ********************************************************************************/

  subi	xE0, lo8(127); xE -= 126 (but we use 127 for compare conviniency)
	sbci	xE1, hi8(127)
  ; if (xE == 1)
  //breq  14; normalisation is not possible : but can be handled anyway in 81
  ; if (xE >= 1)
  brcc	81f
    ; denormalization is needed
    cpi xM0,  lo8(-24); if (xE < -24)
    brge  __fp_ml_szero;  return s0.0
    /*
    while (xE < 1) {
      xM <<= 1;
      xE--;
    }
    */
80:
    lsr xM0;
    ror xM1;
    ror xM2;
    ror xM3;
    inc xE0;
    brne  80b;
    inc xE0;
    rjmp  85f;

81:
  ; if (xE >= 255)
  cpi xE0,  254;
  cpc xE1,  r1;
  brsh  __fp_ml_inf;

  /*
  while (xM <= 1.0 && xE > 1) {
    xM <<= 1;
    xE--;
  }
  */
  tst xM0
  brmi  84f
83:
    subi  xE0, 1;
    brlo  84f;
    lsl xM3;
    rol xM2;
    rol xM1;
    rol xM0;
    brpl  83b;
84:
  subi  xE0,  -2;
85:

  ret;
ENDFUNC

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
__fp_ml_inf:
  rjmp  _U(__fp_splinf);


