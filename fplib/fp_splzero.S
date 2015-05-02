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

/* $Id: fp_zero.S 1174 2007-01-14 15:13:54Z dmix $ */

#include "fp32def.h"
#include "asmdef.h"

/********************************************************************************
 *  __fp_splzero() return 0.0 in splflt40_t
 *
 *  Register pressure = 4
 *
 *  \Output
 *  xE  : r25 Exponent<7..0>
 *  xM0 : r24 1:Mantissa<29..21>
 *  xM1 : r23 Mantissa<21..15>
 *  xM2 : r22 Mantissa<14..7>
 *  xM3 : r27 Sign:Mantissa<6..0>
 ********************************************************************************/
ENTRY	__fp_splzero
	clt
/********************************************************************************
 *  __fp_splszero() return 0.0 with sign bit in splflt40_t
 *
 *  Register pressure = 4
 *
 *  \Input
 *  xS  : T sign of result
 *
 *  \Output
 *  xE  : r25 Exponent<7..0>
 *  xM0 : r24 1:Mantissa<29..21>
 *  xM1 : r23 Mantissa<21..15>
 *  xM2 : r22 Mantissa<14..7>
 *  xM3 : r27 Sign:Mantissa<6..0>
 ********************************************************************************/
ENTRY   __fp_splszero
	clr	xM3
  clr xM2
	clr	xM1
  ldi xM0,  0x80
	clr	xE
	bld	xM3, 7
	ret
ENDFUNC
