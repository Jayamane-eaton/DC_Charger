/*  File:        vartable.c
 *  Author:      l j brackney, NgEK Inc.
 *  Date:        9/6/04
 *  Description: 2D Table lookup w/ variable table size at initialization
 */

#define S_FUNCTION_NAME  vartable
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"                                                 /* Required by Simulink           */
#ifdef MATLAB_MEX_FILE
#include "mex.h"                                                      /* Required by Simulink           */
#else
#include "cg_matrx.h"                                                 /* Required by Real Time Workshop */
#endif
#include <math.h>                                                     /* Math function prototypes       */
#include <float.h>                                                    /* FP math constants              */

#define U(element) (*uPtrs[element])                                  /* Pointer to Input Port          */
#define Mode       IWork[0]                                           /* Interpolation mode             */

static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumContStates(S,    0 );
    ssSetNumDiscStates(S,    0 );
    ssSetNumSampleTimes(S,   0 );
    ssSetNumNonsampledZCs(S, 0 );
    ssSetNumRWork(S,         0 );
    ssSetNumIWork(S,         1 );
    ssSetNumPWork(S,         0 );
    ssSetNumModes(S,         0 );

    ssSetNumSFcnParams(S, 1);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        ssSetErrorStatus(S,"S-Function vartable error: Number of parameters not one");
        return; }

    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(S,     0, DYNAMICALLY_SIZED);
    ssSetInputPortDataType(S,  0, DYNAMICALLY_TYPED);
    ssSetInputPortDirectFeedThrough(S, 0, 1);

    if (!ssSetNumOutputPorts(S, 1)) return;
    ssSetOutputPortWidth(S,     0, 1);
    ssSetOutputPortDataType(S,  0, DYNAMICALLY_TYPED);

    ssSetSFcnParamTunable(S, 0, 0);
    ssSetOptions(S, SS_OPTION_WORKS_WITH_CODE_REUSE);
}


# define MDL_SET_DEFAULT_PORT_DIMENSION_INFO
static void mdlSetDefaultPortDimensionInfo(SimStruct *S)
{
    int_T inpWidth = ssGetInputPortWidth(S,0);

    if (inpWidth == DYNAMICALLY_SIZED)
        if(!ssSetInputPortMatrixDimensions(S, 0, 1, 1)) return;
}


# define MDL_INITIALIZE_CONDITIONS
  static void mdlInitializeConditions(SimStruct *S)
  {
    int_T   *IWork = ssGetIWork(S);
    Mode           = mxGetPr(ssGetSFcnParam(S,0))[0];
       
  }


#if defined(MATLAB_MEX_FILE)
# define MDL_SET_INPUT_PORT_WIDTH
  static void mdlSetInputPortWidth(SimStruct *S, int_T port, int_T inputPortWidth)
  {
      if (inputPortWidth<5) {
         ssSetErrorStatus(S,"S-Function vartable error: Input must consist of a free variable, X axis, and Y axis (a minimum of 5 elements)");
         return;
      }

      if ((inputPortWidth-1) % 2 ) {
         ssSetErrorStatus(S,"S-Function vartable error: Input must consist of a free variable along with X and Y axes with equal numbers of elements");
         return;
      }
  ssSetInputPortWidth(S,port,inputPortWidth);
  }
# define MDL_SET_OUTPUT_PORT_WIDTH
  static void mdlSetOutputPortWidth(SimStruct *S, int_T port, int_T outputPortWidth)
  {}
#endif


static void mdlInitializeSampleTimes(SimStruct *S)
{}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    DTypeId         DType       = ssGetInputPortDataType(S,0);            /* Get input data type        */
    InputPtrsType   uVoidPtrs   = ssGetInputPortSignalPtrs(S,0);          /* Point to inputs            */
    void            *yVoid      = ssGetOutputPortSignal(S,0);             /* Point to output            */
    int_T           *IWork      = ssGetIWork(S);                          /* Pointer to Integer storage */
    int_T           nu          = ssGetInputPortWidth(S,0);               /* Get number of inputs       */
    int_T           nx          = (nu-1)/2;                               /* Get table size             */
    int_T           start       = 0;                                      /* Lower X bound index        */
    int_T           end         = 0;                                      /* Upper X bound index        */
    int_T           i;                                                    /* Misc. counter              */

    switch (DType)
           {
              case SS_SINGLE: {                                           /* Single precision lookup    */
                   real32_T            *y                   = yVoid;      /* Output is a single         */
                   InputReal32PtrsType  uPtrs               = uVoidPtrs;  /* Point to single inputs     */
                   real32_T             first, last, slope;               /* X0, Xn, and slope          */
                   
                   first = U(1);                                          /* Get first X value          */
                   last  = U(nx);                                         /* Get last X value           */

                   for (i = 0; i < nx; i++)                               /* Loop through table         */
                   {
                       if (( U(0) >= U(i+1) ) && ( U(0) <= U(i+2) ))      /* Get indices of X values    */
                       {                                                  /* that bound the input       */
                          start = i+1;                                    /* assuming that X table      */
                          end   = i+2;                                    /* entries are in ascending   */
                          break;                                          /* order                      */
                       }
                       if (( U(0) <= U(i+1) ) && ( U(0) >= U(i+2) ))      /* Look in both directions    */
                       {                                                  /* in case X table entries    */
                          start = i+1;                                    /* are given in descending    */
                          end   = i+2;                                    /* order                      */
                          break;
                       }
                   }

                  if ( isnan(U(0)) )                                      /* Clamp on upper end of the  */
                          y[0] = U(nx+nx);                                /* table if input is NaN      */ 
                  else if (( first < last ) && ( U(0) < U(1) ))           /* Clamp on lower end of      */
                          y[0] = U(nx+1);                                 /* the table                  */
                  else if (( first < last ) && ( U(0) > U(nx) ))          /* or the upper end of        */
                          y[0] = U(nx+nx);                                /* the table                  */
                  else if (( first > last ) && ( U(0) < U(nx) ))          /* Handle tables with         */
                          y[0] = U(nx+nx);                                /* descending X values also   */
                  else if (( first > last ) && ( U(0) > U(1) ))
                          y[0] = U(nx+1);
                  else if ( first==last )
                          y[0] = U(nx+1);
                  else
                  {
                          if      (Mode==1)                  /* Interpolate values within table bounds  */
                          {
                                  slope   = (U(start+nx)-U(end+nx))/(U(start)-U(end));
                                  y[0]    = slope*(U(0)-U(start)) + U(start+nx);
                          }
                          else if (Mode==2)                  /* Interpolate to nearest neighbor         */
                          {
                                  if ( fabs(U(0)-U(start)) < fabs(U(0)-U(end)) )
                                     y[0] = U(start+nx);
                                  else
                                     y[0] = U(end+nx);
                          }
                          else if (Mode==3)                  /* Interpolate to lower neighbor           */
                          {
                                  if (first < last)
                                     if (U(0)==U(end))
                                         y[0] = U(end+nx);
                                     else 
                                         y[0] = U(start+nx);
                                  else
                                     if (U(0)==U(start))
                                         y[0] = U(start+nx);
                                     else 
                                         y[0] = U(end+nx);
                          }
                          else if (Mode==4)                  /* Interpolate to higher neighbor          */
                          {
                                  if (first < last)
                                     if (U(0)==U(start))
                                         y[0] = U(start+nx);
                                     else 
                                         y[0] = U(end+nx);    
                                  else
                                     if (U(0)==U(end))
                                        y[0] = U(end+nx);
                                     else
                                        y[0] = U(start+nx);
                          }
                  }
              }
              break;

              case SS_DOUBLE: {                                           /* Double precision lookup    */
                   real_T            *y                   = yVoid;        /* Output is a double         */
                   InputRealPtrsType  uPtrs               = uVoidPtrs;    /* Point to double inputs     */
                   real_T             first, last, slope;                 /* X0, Xn, and slope          */
                   
                   first = U(1);                                          /* Get first X value          */
                   last  = U(nx);                                         /* Get last X value           */

                   for (i = 0; i < nx; i++)                               /* Loop through table         */
                   {
                       if (( U(0) >= U(i+1) ) && ( U(0) <= U(i+2) ))      /* Get indices of X values    */
                       {                                                  /* that bound the input       */
                          start = i+1;                                    /* assuming that X table      */
                          end   = i+2;                                    /* entries are in ascending   */
                          break;                                          /* order                      */
                       }
                       if (( U(0) <= U(i+1) ) && ( U(0) >= U(i+2) ))      /* Look in both directions    */
                       {                                                  /* in case X table entries    */
                          start = i+1;                                    /* are given in descending    */
                          end   = i+2;                                    /* order                      */
                          break;
                       }
                   }

                  if ( isnan(U(0)) )                                      /* Clamp on upper end of the  */
                          y[0] = U(nx+nx);                                /* table if input is NaN      */ 
                  else if (( first < last ) && ( U(0) < U(1) ))           /* Clamp on lower end of      */
                          y[0] = U(nx+1);                                 /* the table                  */
                  else if (( first < last ) && ( U(0) > U(nx) ))          /* or the upper end of        */
                          y[0] = U(nx+nx);                                /* the table                  */
                  else if (( first > last ) && ( U(0) < U(nx) ))          /* Handle tables with         */
                          y[0] = U(nx+nx);                                /* descending X values also   */
                  else if (( first > last ) && ( U(0) > U(1) ))
                          y[0] = U(nx+1);
                  else
                  {
                          if      (Mode==1)                  /* Interpolate values within table bounds  */
                          {
                                  slope   = (U(start+nx)-U(end+nx))/(U(start)-U(end));
                                  y[0]    = slope*(U(0)-U(start)) + U(start+nx);
                          }
                          else if (Mode==2)                  /* Interpolate to nearest neighbor         */
                          {
                                  if ( fabs(U(0)-U(start)) < fabs(U(0)-U(end)) )
                                     y[0] = U(start+nx);
                                  else
                                     y[0] = U(end+nx);
                          }
                          else if (Mode==3)                  /* Interpolate to lower neighbor           */
                          {
                                  if (first < last)
                                     if (U(0)==U(end))
                                         y[0] = U(end+nx);
                                     else 
                                         y[0] = U(start+nx);
                                  else
                                     if (U(0)==U(start))
                                         y[0] = U(start+nx);
                                     else 
                                         y[0] = U(end+nx);
                          }
                          else if (Mode==4)                  /* Interpolate to higher neighbor          */
                          {
                                  if (first < last)
                                     if (U(0)==U(start))
                                         y[0] = U(start+nx);
                                     else 
                                         y[0] = U(end+nx);
                                  else
                                     if (U(0)==U(end))
                                        y[0] = U(end+nx);
                                     else
                                        y[0] = U(start+nx);
                          }
                  }
              }
              break;
           }


/*
    mexPrintf("X = %4.1f  ",U(0));
    for (i = 0; i < nx; i++)
        mexPrintf("X%d = %3.1f  ",i,U(i+1));
    mexPrintf("Y = %4.1f  ",y[0]);
    mexPrintf("\n");
*/

}


static void mdlUpdate(SimStruct *S, int_T tid)
{}


static void mdlTerminate(SimStruct *S)
{}


#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
