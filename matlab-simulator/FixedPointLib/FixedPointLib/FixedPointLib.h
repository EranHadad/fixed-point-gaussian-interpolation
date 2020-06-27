#ifndef FIXEDPOINTLIB_H_
#define FIXEDPOINTLIB_H_

#include <stdint.h>
#include <stdbool.h>
#include <math.h>

#define EXPORT __declspec(dllexport)

typedef uint16_t _counter;
typedef uint16_t u16;
typedef uint32_t u32;
typedef int32_t s32;
typedef int64_t s64;

EXPORT double q_to_float(s32 x, _counter n);

EXPORT s32 float_to_q(double x, _counter n);

EXPORT bool is_positive_representable(double x, _counter n);

EXPORT s32 calculateParabolicPeak(u16 index, u16 energy, u16 leftEnergy, u16 rightEnergy);

EXPORT s32 calculateGaussianPeak(u16 index, u16 energy, u16 leftEnergy, u16 rightEnergy);

EXPORT s32 fxlog(s32 x);

EXPORT s32 fxlog_mod(s32 x);

#endif // !FIXEDPOINTLIB_H_
