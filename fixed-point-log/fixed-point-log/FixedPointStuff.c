#include "FixedPointStuff.h"

/*
x is the input fixed number which is of integer datatype
n is the number of fractional bits for example in Q1.15 n = 15
*/
double q_to_float(s32 x, _counter n) {
	return (double)x / (u32)(1 << n);
}

s32 float_to_q(double x, _counter n) {
	return (s32)(x * (1 << n));
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
	if (x<0x00008000) x <<= 16, y -= 0x58b;
	if (x<0x00800000) x <<= 8, y -= 0x2c5;
	if (x<0x08000000) x <<= 4, y -= 0x162;
	if (x<0x20000000) x <<= 2, y -= 0xb1;
	if (x<0x40000000) x <<= 1, y -= 0x58;
	t = x + (x >> 1); if ((t & 0x80000000) == 0) x = t, y -= 0x33;
	t = x + (x >> 2); if ((t & 0x80000000) == 0) x = t, y -= 0x1c;
	t = x + (x >> 3); if ((t & 0x80000000) == 0) x = t, y -= 0xf;
	t = x + (x >> 4); if ((t & 0x80000000) == 0) x = t, y -= 0x7;
	t = x + (x >> 5); if ((t & 0x80000000) == 0) x = t, y -= 0x3;
	t = x + (x >> 6); if ((t & 0x80000000) == 0) x = t, y -= 0x1;
	x = 0x80000000 - x;
	y -= x >> 24;
	return y;
}