#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "FixedPointStuff.h"

#define N_ROWS 100
#define N_COLS 3

// number of fraction bits
const _counter N_intermediate = 31;
const _counter N_REF = 16; // referrence implementation design for Q16
const _counter N_VZ = 7;

const double na_value = -30.0; // value assign when log(x) can not be computed for the current fixed-point format

void log_space(double arr[N_ROWS], double start, double end);
void matrix_print(double arr[N_ROWS][N_COLS]);
void matrix_to_csv(double arr[N_ROWS][N_COLS]);

int main()
{
	/*
	double matrix[N_ROWS][N_COLS]; // store x and various log(x) results as columns
	double xvec[N_ROWS]; // values of x for log(x) comparison test between different log() implementations
	s32 fxpTemp;

	log_space(xvec, -5, 6); // generate values from 10^(-5) to 10^(6) and store them in xvec

	for (int i = 0; i < N_ROWS; i++)
	{
		matrix[i][0] = xvec[i];
		matrix[i][1] = matrix[i][2] = na_value;
		if (is_positive_representable(xvec[i], N_REF)) {
			fxpTemp = float_to_q(xvec[i], N_REF);
			matrix[i][1] = q_to_float(fxlog(fxpTemp), N_REF);
		}
		if (is_positive_representable(xvec[i], N_VZ)){
			fxpTemp = float_to_q(xvec[i], N_VZ);
			matrix[i][2] = q_to_float(fxlog_q7(fxpTemp), N_VZ);
		}
	}

	matrix_print(matrix);
	//matrix_to_csv(matrix);
	*/

	//compute_log2_terms(N_VZ);

	s32 realIndex = calculateParabolicPeak(20, 32082, 6598, 25038);
	printf("real index = %.5f\n", q_to_float(realIndex, N_VZ));

	char ch;
	puts("\nPlease type any key to continue...");
	scanf_s("%c", &ch, 1);

	return 0;
}

void log_space(double arr[N_ROWS], double start, double end)
{
	double step = (end - start) / (double)N_ROWS;
	for (int i = 0; i < N_ROWS; i++) { 
		arr[i] = pow(10, start + i * step);
	}
}

void matrix_print(double arr[N_ROWS][N_COLS])
{
	for (int i = 0; i < N_ROWS; i++)
	{
		for (int j = 0; j < N_COLS; j++)
		{
			if (arr[i][j] == na_value) {
				printf(",");
			}
			else {
				printf("%f,", arr[i][j]);
			}
		}
		printf("\n");
	}
}

void matrix_to_csv(double arr[N_ROWS][N_COLS])
{
	FILE *fptr;
	errno_t err;

	err = fopen_s(&fptr, "log-results.csv", "w");

	if (err != 0)
	{
		printf("Error: can not open file\n");
		exit(1);
	}

	for (int i = 0; i < N_ROWS; i++)
	{
		for (int j = 0; j < N_COLS; j++)
		{
			if (arr[i][j] == na_value) {
				fprintf(fptr, ",");
			}
			else {
				fprintf(fptr, "%f,", arr[i][j]);
			}
		}
		fprintf(fptr, "\n");
	}

	fclose(fptr);
}