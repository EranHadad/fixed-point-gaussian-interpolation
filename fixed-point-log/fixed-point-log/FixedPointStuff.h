#pragma once
#include <stdint.h>
#include <stdbool.h>

typedef uint16_t _counter;
typedef uint32_t u32;
typedef int32_t s32;

double q_to_float(s32 x, _counter n);

s32 float_to_q(double x, _counter n);

bool is_positive_representable(double x, _counter n);

s32 fxlog(s32 x);

s32 fxlog_q7(s32 x);

