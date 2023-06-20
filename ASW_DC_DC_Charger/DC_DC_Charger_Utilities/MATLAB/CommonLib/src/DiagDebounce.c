/*  DiagDebounce.c
*
* Implements debounce counter for Lv1 and Lv2 diagnostics blocks
* Author:  Eaton
* Version: 0.4 - 6/10/2020
*
*/

#include "DiagDebounce.h"

/* Lv1 event status type */
typedef enum {
	DEM_EVENT_STATUS_PASSED     = 0U,
    DEM_EVENT_STATUS_FAILED     = 1U,
    DEM_EVENT_STATUS_PREPASSED  = 2U,
    DEM_EVENT_STATUS_PREFAILED  = 3U,
    DEM_EVENT_STATUS_INIT       = 32U	
	
} DemEventStatusType;

/* Lv2 status type */
typedef enum {
    INITSTATE   = 0U, 
    FAULTSTATE  = 1U, 
    PASSSTATE   = 2U
    
} Lv2StatusType;

/* constants */
const boolean TEST_PASS   = false;
const boolean TEST_FAILED = true; 
const sint16 INIT_COUNTER = 0; 

/* function protype */
static DemEventStatusType diagDbncDisabled( uint8 currState, boolean prevDbEnable, 
                                            boolean diagFaultActive, boolean diagStartUpComp, 
                                            boolean diagReset, boolean diagEnable );

/* function to debounce Lv1 event status */
void DiagDebounceLv1( sint16 *diagFaultCounter, uint8 *diagCurrState, boolean *prevDbncEnable, 
                       boolean diagFaultActive, boolean diagStartUpComp, 
                       boolean diagReset, boolean diagEnable, boolean diagDbncEnable, 
                       sint16 diagFaultCntThresh, sint16 diagPassCntThresh, 
                       sint16 diagUpCnt, sint16 diagDnCnt, boolean diagHealEn )
{  
    /* comment out below for timing purpose */
    /* if( diagFaultCounter == NULL || diagCurrState == NULL || prevDbncEnable == NULL )
    {        
        return (uint8)(DEM_EVENT_STATUS_FAILED); 
    } */
    
	if( diagDbncEnable == false )
	{
        /* process fault status when debounce is disabled */
		*diagCurrState = diagDbncDisabled( *diagCurrState, *prevDbncEnable, diagFaultActive, 
                                           diagStartUpComp, diagReset, diagEnable );        
	}
	else if( diagDbncEnable != *prevDbncEnable )
    {

        /* if debounce is just enabled, set event status to init */ 
        *diagCurrState = DEM_EVENT_STATUS_INIT;   

        /* reset counter */
        *diagFaultCounter = INIT_COUNTER; 

    }
    else
    {      
        /* diagCurrState is the global state that is retained across loops */
        switch( *diagCurrState )
        {
            case DEM_EVENT_STATUS_INIT:         
                               
                if( ( diagStartUpComp == false ) || 
                    ( diagReset == true ) || ( diagEnable == false ) )
                {
                    /* reset counter */
                    *diagFaultCounter = INIT_COUNTER;                   
                }
                else if( diagFaultActive == false )
                {
                    /* decrement fault counter */
                    *diagFaultCounter = *diagFaultCounter - diagDnCnt;
                    if( *diagFaultCounter <= diagPassCntThresh ) 
                    {
                        /* update to passed */
                        *diagCurrState = DEM_EVENT_STATUS_PASSED; 
                        
                        /* set fault counter to min value in case it is smaller than 
                           diagPassCntThresh */
                        *diagFaultCounter = diagPassCntThresh;
                    }
                }
                else /* diagFaultActive == true */ 
                {
                    /* increment fault counter */
                    *diagFaultCounter = *diagFaultCounter + diagUpCnt;
                    if( *diagFaultCounter >= diagFaultCntThresh ) 
                    {
                        /* update to failed */
                        *diagCurrState = DEM_EVENT_STATUS_FAILED; 
                        
                        /* set fault counter to max value in case it is larger 
                           than diagFaultCntThresh */
                        *diagFaultCounter = diagFaultCntThresh;
                    }                    
                }
                break;

            case DEM_EVENT_STATUS_FAILED:

                if( /* ( diagStartUpComp == false ) || */ 
                    ( diagReset == true ) || ( diagEnable == false ) )
                {                     
                    /* update to init */
                    *diagCurrState = DEM_EVENT_STATUS_INIT;
                    
                    /* reset counter */
                    *diagFaultCounter = INIT_COUNTER; 
                }
                else if( diagFaultActive == false )
                {
                    /* check if healing is enabled */
                    if( diagHealEn == true )
                    {
                        /* decrement fault counter */
                        *diagFaultCounter = *diagFaultCounter - diagDnCnt;
                        if( *diagFaultCounter <= diagPassCntThresh ) 
                        {
                            /* update to passed */
                            *diagCurrState = DEM_EVENT_STATUS_PASSED; 
                            
                            /* set fault counter to min value in case it is smaller than 
                               diagPassCntThresh */
                            *diagFaultCounter = diagPassCntThresh;
                        }
                    }
                }                
                else /* diagFaultActive == true */ 
                {
                    /* only increment the counter when it is below the failed threshold 
                       due to oscillation */
                    if (*diagFaultCounter < diagFaultCntThresh)
                    {
                        /* increment the counter by diagUpCnt */
                        *diagFaultCounter = *diagFaultCounter + diagUpCnt; 
                        
                        /* check if the counter has been incremented beyond the fault threshold, 
                           if so saturate at the fault threshold */
                        if (*diagFaultCounter > diagFaultCntThresh)
                        {
                            *diagFaultCounter = diagFaultCntThresh;
                        }
                    }                    
                }
                break;

            case DEM_EVENT_STATUS_PASSED:

                if( /* ( diagStartUpComp == false ) || */
                    ( diagReset == true ) || ( diagEnable == false ) )
                {                     
                    /* update to int */
                    *diagCurrState = DEM_EVENT_STATUS_INIT;
                    
                    /* reset counter */
                    *diagFaultCounter = INIT_COUNTER; 
                }
                else if( diagFaultActive == false )
                {
                    /* only decrement the counter when it is above the pass threshold 
                       due to oscillation */
                    if (*diagFaultCounter > diagPassCntThresh)
                    {
                        /* decrement the counter by diagDnCnt */
                        *diagFaultCounter = *diagFaultCounter - diagDnCnt; 

                        /* check if the counter has been decremented beyond the passed threshold, 
                           if so saturate at the passed threshold */
                        if (*diagFaultCounter < diagPassCntThresh)
                        {
                            *diagFaultCounter = diagPassCntThresh;
                        }
                    }
                }
                else /* diagFaultActive == true */ 
                {
                    /* increment fault counter */
                    *diagFaultCounter = *diagFaultCounter + diagUpCnt;
                    if( *diagFaultCounter >= diagFaultCntThresh ) 
                    {
                        /* update to failed */
                        *diagCurrState = DEM_EVENT_STATUS_FAILED; 
                        
                        /* set fault counter to max value in case it is larger than 
                           diagFaultCntThresh */
                        *diagFaultCounter = diagFaultCntThresh;
                    }                    
                }                                   
                break;

            default:
                /* should not be possible to get here, if you get to this state a fault 
                   should be thrown */
                *diagCurrState = DEM_EVENT_STATUS_FAILED;               
                break;
        }
	}
    
    /* remember the debounce enable state */
    *prevDbncEnable = diagDbncEnable;
    
}

/* function to debounce Lv1 event status when debounce is disabled */
static DemEventStatusType diagDbncDisabled( uint8 currState, boolean prevDbEnable, 
                                            boolean diagFaultActive, boolean diagStartUpComp, 
                                            boolean diagReset, boolean diagEnable )
{
    if( ( prevDbEnable == true ) || (diagStartUpComp == false) || 
        (diagEnable == false) || (diagReset == true)  )
    {
        /* init status */
        currState = DEM_EVENT_STATUS_INIT;
    }    
    else if ( diagFaultActive == false )
    {
        /* fault inactive */
        currState = DEM_EVENT_STATUS_PREPASSED;        
    }
    else
    {
        /* fault active */
        currState = DEM_EVENT_STATUS_PREFAILED;         
    }  
    
    return currState;   
}

/* function to debounce Lv2 fault status */
boolean DiagDebounceLv2(sint16 *diagFaultCounter, uint8 *diagCurrState, boolean *diagPassCntThresh, 
                        boolean diagFaultActive, boolean diagStartUpComp, boolean diagReset, 
                        sint16 diagFaultCntThresh, sint16 diagUpCnt, sint16 diagDnCnt, 
                        boolean diagHealEn)
{    
    /* init return to TEST_FAILED */
    boolean testStatus = TEST_FAILED; 
    
    /* comment out below for timing purpose */
    /* if( diagFaultCounter == NULL || diagCurrState == NULL || diagPassCntThresh == NULL )
    {
        return TEST_FAILED; 
    } */

   /* diagCurrState is retained across loops */
    switch (*diagCurrState)
    {
        case INITSTATE:

            /* reset counter */
            *diagFaultCounter = INIT_COUNTER; 

            /* switch to pass state once startup is complete and diag reset is false */
            if ((diagStartUpComp == true) && (diagReset == false))
            {
                *diagCurrState = PASSSTATE; 
            }

            /* TEST_PASS should always be set at init */
            testStatus = TEST_PASS;
            break;

        case FAULTSTATE:

            /* init test status to failed, will only be changed once pass is confirmed */
            testStatus = TEST_FAILED; 

            /* check if reset has been triggered, if not check if counter should be adjusted */
            if (diagReset == true)
            {
                 *diagCurrState = INITSTATE; 
            }
            else /* reset is inactive, need to update the counter */
            {
                /* first check if fault is active (most likely in fault state) */
                if (diagFaultActive == true)
                {
                    /* only increment the counter when it is below the failed threshold */
                    if (*diagFaultCounter < diagFaultCntThresh)
                    {
                        *diagFaultCounter = *diagFaultCounter + diagUpCnt; 

                        /* check if the counter has been incremented beyond the fault threshold, 
                           if so saturate at the fault threshold */
                        if (*diagFaultCounter > diagFaultCntThresh)
                        {
                            *diagFaultCounter = diagFaultCntThresh;
                        }
                    }
                }
                else /* fault is not active, need to decrement the counter */
                {
                    /* only decerement counter if healing is enabled */
                    if (diagHealEn == true)
                    {
                        *diagFaultCounter = *diagFaultCounter - diagDnCnt; 
                        
                        /* check if below or equal to threshold */
                        if (*diagFaultCounter <= *diagPassCntThresh) 
                        {
                            *diagCurrState = PASSSTATE; 
                            testStatus = TEST_PASS;     
                        }
                    }
                }
            }

            break;

        case PASSSTATE:
        
            /* init test status to passed */
            testStatus = TEST_PASS; 

            /* check if reset has been triggered, if not check if counter should be adjusted */
            if (diagReset == true)
            {
                *diagCurrState = INITSTATE; 
            }
            else /* reset is inactive, need to update the counter */
            {
                /* first check if fault is inactive */
                if (diagFaultActive == false)
                {
                    /* only decrement the counter when it is above the pass threshold */
                    if (*diagFaultCounter > *diagPassCntThresh)
                    {
                        *diagFaultCounter = *diagFaultCounter - diagDnCnt; 

                        /* check if the counter has been decremented beyond the passed threshold, 
                           if so saturate at the passed threshold */
                        if (*diagFaultCounter < *diagPassCntThresh)
                        {
                            *diagFaultCounter = *diagPassCntThresh;
                        }
                    }
                }

                else /* fault is present, need to increment the counter */
                {
                    *diagFaultCounter = *diagFaultCounter + diagUpCnt; 

                    /* check if above threshold */
                    if (*diagFaultCounter >= diagFaultCntThresh) 
                    {
                        *diagCurrState = FAULTSTATE; 
                        
                        /* update the test status to failed */
                        testStatus = TEST_FAILED;    
                    }
                }
            }

          break;

        default:
            
          /* should not be possible to get here, if you get to this state 
             a fault should be thrown */
          testStatus = TEST_FAILED;
          break;
   }  
   
    /* return the test status */
    return testStatus;
}



