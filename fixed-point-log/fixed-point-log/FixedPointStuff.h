#pragma once
#include <stdint.h>
#include <stdio.h>
#include <stdbool.h>
#include <math.h>

typedef uint16_t _counter;
typedef uint16_t u16;
typedef uint32_t u32;
typedef int32_t s32;
typedef int64_t s64;

double q_to_float(s32 x, _counter n);

s32 float_to_q(double x, _counter n);

bool is_positive_representable(double x, _counter n);

s32 fxlog(s32 x);

s32 fxlog_q7(s32 x);

s32 fxlog2_q7(s32 x);

void compute_log_terms(_counter n); // for use in fxlog_Qn

void compute_log2_terms(_counter n); // for use in fxlog2_Qn

s32 calculateParabolicPeak(u16 index, u16 energy, u16 leftEnergy, u16 rightEnergy);

s32 calculateGaussianPeak(u16 index, u16 energy, u16 leftEnergy, u16 rightEnergy);

