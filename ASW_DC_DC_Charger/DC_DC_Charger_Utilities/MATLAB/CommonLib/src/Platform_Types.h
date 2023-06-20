/* Copyright 2018 The MathWorks, Inc. */

/*
 * File: Platform_Types.h
 *
 * Definitions for AUTOSAR platform types
 *
 * This file contains stub implementations of the AUTOSAR Platform Types.
 * The stub implementations can be used for testing the generated code in
 * Simulink, for example, in SIL/PIL simulations of the component under
 * test. Note that this file should be replaced with an appropriate RTE
 * file when deploying the generated code outside of Simulink.
 */

#ifndef PLATFORM_TYPES_H
#define PLATFORM_TYPES_H

#include "rtwtypes.h"

/* Define AUTOSAR platform types */
typedef boolean_T boolean;
typedef int16_T sint16;
typedef int32_T sint32;
typedef int8_T sint8;
typedef uint16_T uint16;
typedef uint32_T uint32;
typedef uint8_T uint8;
typedef float float32;
typedef double float64;

/* if target supports long long, rtwtypes.h will define MAX_uint64_T */
#ifdef MAX_uint64_T
    typedef int64_T sint64;
    typedef uint64_T uint64;
#endif
    
/* Define AUTOSAR standard primitive types */
typedef boolean Boolean;
typedef uint8 Char8;
typedef sint16 SInt16;
typedef sint32 SInt32;
typedef sint8 SInt4;
typedef sint8 SInt8;
typedef uint16 UInt16;
typedef uint32 UInt32;
typedef uint8 UInt4;
typedef uint8 UInt8;
typedef float64 Double;
typedef float64 Double_with_Nan;
typedef float32 Float;
typedef float32 Float_with_NaN;    
#ifdef MAX_uint64_T
    typedef int64_T SInt64;
    typedef uint64_T UInt64;
#endif


    
#endif /* PLATFORM_TYPES_H */ 
