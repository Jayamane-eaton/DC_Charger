/* DiagDebounce.h
*
* Author: Eaton
* Version: 0.4 - 6/9/2020
*
*/

#ifndef DiagDebounce_h_
#define DiagDebounce_h_

#include "rtwtypes.h"
#include "Platform_Types.h"


/* function to debounce Lv1 event status */
extern void DiagDebounceLv1( sint16 *diagFaultCounter, uint8 *diagCurrState, 
                              boolean *prevDbncEnable, boolean diagFaultActive, 
                              boolean diagStartUpComp, boolean diagReset, boolean diagEnable, 
                              boolean diagDbncEnable, sint16 diagFaultCntThresh, 
                              sint16 diagPassCntThresh, sint16 diagUpCnt, sint16 diagDnCnt, 
                              boolean diagHealEn );

/* function to debounce Lv2 fault status */
extern boolean DiagDebounceLv2( sint16 *diagFaultCounter, uint8 *diagCurrState, 
                                boolean *diagPassCntThresh, boolean diagFaultActive, 
                                boolean diagStartUpComp, boolean diagReset, 
                                sint16 diagFaultCntThresh, sint16 diagUpCnt, sint16 diagDnCnt, 
                                boolean diagHealEn );


#endif
