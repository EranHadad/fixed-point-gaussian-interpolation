#include <Windows.h>
#include <stdio.h>
#include "FixedPointLib.h"

int main()
{
	printf("Fixed Point Client!\n");
	
	compute_log_terms(15, 24);

	system("PAUSE");

	return 0;
}