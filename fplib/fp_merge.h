/* Copyright (c) 2015 Etienne Pierre-Doray
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

/* $Id: fp_zero.S 1174 2015-01-14 15:13:54Z etipdoray $ */

#include "fp32def.h"
#include "asmdef.h"

/******************************************************************************
*  The __fp_mergeX() convert an X splflt40_t number to flt40_t
*
*  flt40_t __fp_mergeX(splflt40_t a);
*
*  Register pressure = 5
*
*  \Input
*  xE  : r25 Exponent<7..0>
*  xM0 : r24 1:Mantissa<29..23>
*  xM1 : r23 Mantissa<22..15>
*  xM2 : r22 Mantissa<14..7>
*  xM3 : r27 Mantissa<7..0>
*  xS  : T   Sign
*
*  \Output
*  xE  : r25 Sign:Exponent<7..1>
*  xM0 : r24 Exponent<0>:Mantissa<29..23>
*  xM1 : r23 Mantissa<22..15>
*  xM2 : r22 Mantissa<14..7>
*  xM3 : r27 Mantissa<6..0>:0
******************************************************************************/
.macro  __fp_mergeX
lsl xM0;
sbci  xE, -1
ror xE;
ror xM0;
bld xE, 7;
.endmacro

/******************************************************************************
 *  The __fp_mergeA() convert an A splflt40_t number to flt40_t
 *
 *  flt40_t __fp_mergeA(splflt40_t a);
 *
 *  Register pressure = 5
 *
 *  \Input
 *  aE  : r25 Exponent<7..0>
 *  aM0 : r24 1:Mantissa<29..23>
 *  aM1 : r23 Mantissa<22..15>
 *  aM2 : r22 Mantissa<14..7>
 *  aM3 : r27 Mantissa<7..0>
 *  aS  : T   Sign
 *
 *  \Output
 *  aE  : r25 Sign:Exponent<7..1>
 *  aM0 : r24 Exponent<0>:Mantissa<29..23>
 *  aM1 : r23 Mantissa<22..15>
 *  aM2 : r22 Mantissa<14..7>
 *  aM3 : r27 Mantissa<6..0>:0
 ******************************************************************************/
.macro  __fp_mergeA
  lsl aM0;
  sbci  aE, -1
  ror aE;
  ror aM0;
  bld aE, 7;
.endmacro


/******************************************************************************
 *  The __fp_mergeB() convert an B splflt40_t number to flt40_t
 *
 *  flt40_t __fp_mergeB(splflt40_t b);
 *
 *  Register pressure = 5
 *
 *  \Output
 *  bE  : r21 Exponent<7..0>
 *  bM0 : r20 1:Mantissa<29..23>
 *  bM1 : r19 Mantissa<22..15>
 *  bM2 : r18 Mantissa<14..7>
 *  bM3 : r26 Mantissa<7..0>
 *  bS  : T   Sign
 *
 *  \Input
 *  bE  : r21 Sign:Exponent<7..1>
 *  bM0 : r20 Exponent<0>:Mantissa<29..23>
 *  bM1 : r19 Mantissa<22..15>
 *  bM2 : r18 Mantissa<14..7>
 *  bM3 : r26 Mantissa<6..0>:0
 ******************************************************************************/
.macro  __fp_mergeB
  lsl aM0;
  sbci  bE, -1
  ror aE;
  ror aM0;
  bld aE, 7;
.endmacro

#endif /* !defined(__AVR_TINY__) */
