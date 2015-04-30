/* Interprocedure convensions. In separate file: for math library
   developers.	*/
#ifndef	_FP32DEF_H
#define	_FP32DEF_H

#include "sectionname.h"

#define xE  r25
#define xM0 r24 
#define xM1 r23
#define xM2 r22
#define xM3 r27

#define aE  r25
#define aM0 r24 
#define aM1 r23
#define aM2 r22
#define aM3 r27

#define bE  r21
#define bM0 r20 
#define bM1 r19
#define bM2 r18
#define bM3 r26

/* Put functions at this section.	*/
#ifdef	FUNCTION
# error	"The FUNCTION macro must be defined after FUNC_SEGNAME"
#endif
#define FUNC_SEGNAME	MLIB_SECTION

/* Put constant tables at low addresses in program memory, so they are
   reachable for "lpm" without using RAMPZ on >64K devices.  */
#define PGM_SECTION	.section  .progmem.gcc_fplib, "a", @progbits

#endif	/* !_FP32DEF_H */
