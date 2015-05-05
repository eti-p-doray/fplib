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

/* $Id: fp_inf.S 1173 2007-01-14 15:04:40Z dmix $ */

#include <stdint.h>


#define special_output_port (*((volatile char *)0x20))
#define special_input_port (*((volatile char *)0x22))

extern "C" {
  uint32_t __mulsf3(uint32_t, uint32_t);
  uint32_t __addsf3(uint32_t, uint32_t);
}

int main()
{
  uint16_t n = special_input_port << 16;
  n += special_input_port;

  for (uint16_t i = 0; i < n; ++i)
  {
    uint32_t a = 0;
    for (uint8_t j = 0; j < 4; ++j)
    {
      a += special_input_port << (j*8);
    }
    for (int j = 0; j < n; ++j)
    {
      uint32_t b = 0;
      for (uint8_t k = 0; k < 4; ++k)
      {
        b += special_input_port << (k*8);
      }
      uint32_t r = __mulsf3(a, b);
      for (uint8_t k = 0; k < 4; ++k)
      {
        special_output_port = (r >> (k*8)) & 0xff;
      }
    }
  }
  return 0;
}
