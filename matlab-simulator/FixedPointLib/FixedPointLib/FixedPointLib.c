#include "FixedPointLib.h"

/*
x is the input fixed number which is of integer datatype
n is the number of fractional bits for example in Q1.15 n = 15
*/
EXPORT double q_to_float(s32 x, _counter n) {
	return (double)x / (u32)(1 << n);
}

EXPORT s32 float_to_q(double x, _counter n) {
	return (s32)round(x * (1 << n));
}

/*
is_positive_representable: returns true if x is positive and can be represent by a signed 32 bit fixed-point Qm.n
positive because the log argument must be positive so we only interested in that range.
*/
EXPORT bool is_positive_representable(double x, _counter n) {
	_counter m = 32 - n;
	double resolution = (double)1 / (1 << n);
	double max_positive = (double)(1 << (m - 1)) - resolution;
	if (x >= resolution && x <= max_positive) {
		return true;
	}
	return false;
}

s32 calculateParabolicPeak(u16 index, u16 energy, u16 leftEnergy, u16 rightEnergy)
{
	s32 energySum = (s32)leftEnergy + (s32)rightEnergy;
	s32 doubleEnergy = 2 * (s32)energy;
	s32 dxQ7 = 0;
	const _counter p = 7;

	if (energySum < doubleEnergy)
	{
		s32 energyDiff = (s32)leftEnergy - (s32)rightEnergy;
		s32 denom = (s32)(energySum - doubleEnergy);

		// the following two lines replace the equation dxQ7 = 0.5 * logEnergyDiff / logDenom;
		dxQ7 = (energyDiff << (p - 1)); // shift p is due to fix point. -1 is because we need to multiple by 0.5				
		dxQ7 = denom != 0 ? dxQ7 / denom : 0;
	}

	return ((s32)index << p) + dxQ7;
}

/*
Here is a sample C function to compute log() using the above algorithm.
The code assumes integers are at least 32 bits long.
The(positive) argument and the result of the function are both expressed as fixed - point values with 16 fractional bits,
although intermediates are kept with 31 bits of precision to avoid loss of accuracy during shifts.
After 12 steps of the algorithm the correction described above is applied.
*/
EXPORT s32 fxlog(s32 x) {
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
EXPORT s32 fxlog_q7(s32 x) {
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
EXPORT s32 fxlog2_q7(s32 x) {
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