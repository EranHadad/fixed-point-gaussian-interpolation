#ifndef FIXEDPOINTLIB_H_
#define FIXEDPOINTLIB_H_

#include <stdint.h>
#include <stdbool.h>
#include <math.h>


#define EXPORT __declspec(dllexport)

typedef uint16_t _counter;
typedef uint32_t u32;
typedef int32_t s32;

EXPORT double q_to_float(s32 x, _counter n);

EXPORT s32 float_to_q(double x, _counter n);

EXPORT bool is_positive_representable(double x, _counter n);

EXPORT s32 fxlog(s32 x);

EXPORT s32 fxlog_mod(s32 x);

#endif // !FIXEDPOINTLIB_H_
