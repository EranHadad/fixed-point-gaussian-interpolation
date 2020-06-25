#include "FixedPointStuff.h"

/*
x is the input fixed number which is of integer datatype
n is the number of fractional bits for example in Q1.15 n = 15
*/
double q_to_float(s32 x, _counter n) {
	return (double)x / (u32)(1 << n);
}

s32 float_to_q(double x, _counter n) {
	return (s32)round(x * (1 << n));
}

/*
is_positive_representable: returns true if x is positive and can be represent by a signed 32 bit fixed-point Qm.n
positive because the log argument must be positive so we only interested in that range.
*/
bool is_positive_representable(double x, _counter n) {
	_counter m = 32 - n;
	double resolution = (double)1 / (1 << n);
	double max_positive = (double)(1 << (m - 1)) - resolution;
	if (x >= resolution && x <= max_positive){
		return true;
	}
	return false;
}

void compute_log_terms(_counter n)
{
	_counter m = 32 - n;
	double x = 1 << (m - 1);
	s32 logVal = float_to_q(log(x), n);
	printf("initial value = %05x\n", logVal);
	printf("log(2^16) = %05x\n", float_to_q(log(1 << 16), n));
	printf("log(2^8) = %05x\n", float_to_q(log(1 << 8), n));
	printf("log(2^4) = %05x\n", float_to_q(log(1 << 4), n));
	printf("log(2^2) = %05x\n", float_to_q(log(1 << 2), n));
	printf("log(2^1) = %05x\n", float_to_q(log(1 << 1), n));
	printf("log(3/2) = %05x\n", float_to_q(log((double)3 / 2), n));
	printf("log(5/4) = %05x\n", float_to_q(log((double)5 / 4), n));
	printf("log(9/8) = %05x\n", float_to_q(log((double)9 / 8), n));
	printf("log(17/16) = %05x\n", float_to_q(log((double)17 / 16), n));
	printf("log(33/32) = %05x\n", float_to_q(log((double)33 / 32), n));
	printf("log(65/64) = %05x\n", float_to_q(log((double)65 / 64), n));
	printf("log(129/128) = %05x\n", float_to_q(log((double)129 / 128), n));
}

void compute_log2_terms(_counter n)
{
	_counter m = 32 - n;
	double x = 1 << (m - 1);
	s32 logVal = float_to_q(log2(x), n);
	printf("initial value = %05x\n", logVal);
	printf("log(2^16) = %05x\n", float_to_q(log2(1 << 16), n));
	printf("log(2^8) = %05x\n", float_to_q(log2(1 << 8), n));
	printf("log(2^4) = %05x\n", float_to_q(log2(1 << 4), n));
	printf("log(2^2) = %05x\n", float_to_q(log2(1 << 2), n));
	printf("log(2^1) = %05x\n", float_to_q(log2(1 << 1), n));
	printf("log(3/2) = %05x\n", float_to_q(log2((double)3 / 2), n));
	printf("log(5/4) = %05x\n", float_to_q(log2((double)5 / 4), n));
	printf("log(9/8) = %05x\n", float_to_q(log2((double)9 / 8), n));
	printf("log(17/16) = %05x\n", float_to_q(log2((double)17 / 16), n));
	printf("log(33/32) = %05x\n", float_to_q(log2((double)33 / 32), n));
	printf("log(65/64) = %05x\n", float_to_q(log2((double)65 / 64), n));
	printf("log(129/128) = %05x\n", float_to_q(log2((double)129 / 128), n));
}

/*
Here is a sample C function to compute log() using the above algorithm.
The code assumes integers are at least 32 bits long.
The(positive) argument and the result of the function are both expressed as fixed - point values with 16 fractional bits,
although intermediates are kept with 31 bits of precision to avoid loss of accuracy during shifts.
After 12 steps of the algorithm the correction described above is applied.
*/
s32 fxlog(s32 x) {
	s32 t, y;

	y = 0xa65af;
	if (x<0x00008000) x <<= 16, y -= 0xb1721;
	if (x<0x00800000) x <<= 8, y -= 0x58b91;
	if (x<0x08000000) x <<= 4, y -= 0x2c5c8;
	if (x<0x20000000) x <<= 2, y -= 0x162e4;
	if (x<0x40000000) x <<= 1, y -= 0x0b172;
	t = x + (x >> 1); if ((t & 0x80000000) == 0) x = t, y -= 0x067cd;
	t = x + (x >> 2); if ((t & 0x80000000) == 0) x = t, y -= 0x03920;
	t = x + (x >> 3); if ((t & 0x80000000) == 0) x = t, y -= 0x01e27;
	t = x + (x >> 4); if ((t & 0x80000000) == 0) x = t, y -= 0x00f85;
	t = x + (x >> 5); if ((t & 0x80000000) == 0) x = t, y -= 0x007e1;
	t = x + (x >> 6); if ((t & 0x80000000) == 0) x = t, y -= 0x003f8;
	t = x + (x >> 7); if ((t & 0x80000000) == 0) x = t, y -= 0x001fe;
	x = 0x80000000 - x;
	y -= x >> 15;
	return y;
}

/*
fxlog_q7: implementation for Q7
*/
s32 fxlog_q7(s32 x) {
	s32 t, y;
	y = 0x851;
	if (x<0x00008000) x <<= 16, y -= 0x58c;
	if (x<0x00800000) x <<= 8, y -= 0x2c6;
	if (x<0x08000000) x <<= 4, y -= 0x163;
	if (x<0x20000000) x <<= 2, y -= 0xb1;
	if (x<0x40000000) x <<= 1, y -= 0x59;
	t = x + (x >> 1); if ((t & 0x80000000) == 0) x = t, y -= 0x34;
	t = x + (x >> 2); if ((t & 0x80000000) == 0) x = t, y -= 0x1d;
	t = x + (x >> 3); if ((t & 0x80000000) == 0) x = t, y -= 0xf;
	t = x + (x >> 4); if ((t & 0x80000000) == 0) x = t, y -= 0x8;
	t = x + (x >> 5); if ((t & 0x80000000) == 0) x = t, y -= 0x4;
	t = x + (x >> 6); if ((t & 0x80000000) == 0) x = t, y -= 0x2;
	t = x + (x >> 7); if ((t & 0x80000000) == 0) x = t, y -= 0x1;
	x = 0x80000000 - x;
	y -= x >> 24;
	return y;
}

/*
fxlog2_q7: implementation of log2 for Q7
*/
s32 fxlog2_q7(s32 x) {
	s32 t, y;
	y = 0xc00;
	if (x<0x00008000) x <<= 16, y -= 0x800;
	if (x<0x00800000) x <<= 8, y -= 0x400;
	if (x<0x08000000) x <<= 4, y -= 0x200;
	if (x<0x20000000) x <<= 2, y -= 0x100;
	if (x<0x40000000) x <<= 1, y -= 0x80;
	t = x + (x >> 1); if ((t & 0x80000000) == 0) x = t, y -= 0x4b;
	t = x + (x >> 2); if ((t & 0x80000000) == 0) x = t, y -= 0x29;
	t = x + (x >> 3); if ((t & 0x80000000) == 0) x = t, y -= 0x16;
	t = x + (x >> 4); if ((t & 0x80000000) == 0) x = t, y -= 0xb;
	t = x + (x >> 5); if ((t & 0x80000000) == 0) x = t, y -= 0x6;
	t = x + (x >> 6); if ((t & 0x80000000) == 0) x = t, y -= 0x3;
	t = x + (x >> 7); if ((t & 0x80000000) == 0) x = t, y -= 0x1;
	x = 0x80000000 - x;
	y -= x >> 24;
	return y;
}