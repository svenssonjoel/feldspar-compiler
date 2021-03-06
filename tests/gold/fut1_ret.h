#ifndef TESTS_FUT1_RET_H
#define TESTS_FUT1_RET_H

#include "feldspar_c99.h"
#include "feldspar_array.h"
#include "feldspar_future.h"
#include "ivar.h"
#include "taskpool.h"
#include <stdint.h>
#include <string.h>
#include <math.h>
#include <stdbool.h>
#include <complex.h>


void task_core0(struct ivar e0);

void task0(void * params);

void fut1__ret(struct ivar v0, struct ivar * out);

#endif // TESTS_FUT1_RET_H
