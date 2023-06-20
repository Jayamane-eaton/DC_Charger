

#define S_FUNCTION_NAME xyinterp_f32_wrap
#define S_FUNCTION_LEVEL 2
#include "simstruc.h"

#include <math.h>
#include "mex.h"
#include "xyinterp_f32.h"


static void mdlInitializeSizes(SimStruct *S)
{
   ssSetNumSFcnParams(S,0);
   if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)){
      return;
   }
   
   
   ssSetNumContStates(S,0);
   ssSetNumDiscStates(S,0);
   
   if (!ssSetNumInputPorts(S,5)) return;
   ssSetInputPortWidth(S, 0, 1);
   ssSetInputPortWidth(S, 1, 1);
   ssSetInputPortWidth(S, 2, 1);
   ssSetInputPortWidth(S, 3, 1);
   ssSetInputPortWidth(S, 4, 1);
   
   ssSetInputPortDirectFeedThrough(S, 0, 1);
   ssSetInputPortDirectFeedThrough(S, 1, 1);
   ssSetInputPortDirectFeedThrough(S, 2, 1);
   ssSetInputPortDirectFeedThrough(S, 3, 1);
   ssSetInputPortDirectFeedThrough(S, 4, 1);
   
   ssSetInputPortDataType(S, 0, SS_SINGLE);
   ssSetInputPortDataType(S, 1, SS_SINGLE);
   ssSetInputPortDataType(S, 2, SS_SINGLE);
   ssSetInputPortDataType(S, 3, SS_SINGLE);
   ssSetInputPortDataType(S, 4, SS_SINGLE);
   
   
   if (!ssSetNumOutputPorts(S, 1)) return;
   ssSetOutputPortWidth(S, 0, 1);
   ssSetOutputPortDataType(S, 0, SS_SINGLE);
   
   ssSetNumSampleTimes(S, 1);
   
    /* Take care when specifying exception free code - see sfuntmpl_doc.c */
    ssSetOptions(S, (SS_OPTION_EXCEPTION_FREE_CODE |
                     SS_OPTION_WORKS_WITH_CODE_REUSE));
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
   ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
   
   real32_T *y = (real32_T *)ssGetOutputPortSignal(S, 0);
   InputReal32PtrsType y_1 = (InputReal32PtrsType)ssGetInputPortSignalPtrs(S, 0);
   InputReal32PtrsType y_0 = (InputReal32PtrsType)ssGetInputPortSignalPtrs(S, 1);
   InputReal32PtrsType x_1 = (InputReal32PtrsType)ssGetInputPortSignalPtrs(S, 2);
   InputReal32PtrsType x_0 = (InputReal32PtrsType)ssGetInputPortSignalPtrs(S, 3);
   InputReal32PtrsType x = (InputReal32PtrsType)ssGetInputPortSignalPtrs(S, 4);
   
   
   UNUSED_ARG(tid);
   
   y[0] = xyinterp_f32(*y_1[0], *y_0[0], *x_1[0], *x_0[0], *x[0]);
}

static void mdlTerminate(S)
{
   UNUSED_ARG(S);
}


#ifdef MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif
