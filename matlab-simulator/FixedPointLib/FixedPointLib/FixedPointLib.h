#ifndef FIXEDPOINTLIB_H_
#define FIXEDPOINTLIB_H_

#ifdef FIXEDPOINTLIB_EXPORTS
#define FIXEDPOINTLIB_API __declspec(dllexport)
#else
#define FIXEDPOINTLIB_API __declspec(dllimport)
#endif

#include <stdint.h>
#include <stdbool.h>
#include <math.h>

typedef uint16_t _counter;
typedef uint16_t u16;
typedef uint32_t u32;
typedef int32_t s32;
typedef int64_t s64;

FIXEDPOINTLIB_API double FixedToDouble(s32 x, _counter n);

FIXEDPOINTLIB_API s32 DoubleToFixed(double x, _counter n);

FIXEDPOINTLIB_API bool is_positive_representable(double x, _counter n);

FIXEDPOINTLIB_API s32 calculateParabolicPeak(u16 index, u16 energy, u16 leftEnergy, u16 rightEnergy);

FIXEDPOINTLIB_API s32 calculateGaussianPeak(u16 index, u16 energy, u16 leftEnergy, u16 rightEnergy);

FIXEDPOINTLIB_API s32 fxlog(s32 x);

FIXEDPOINTLIB_API s32 fxlog_mod(s32 x);

#endif // !FIXEDPOINTLIB_H_
