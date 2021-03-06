#include "ivartest.h"


void task_core0(uint32_t v0, struct ivar v1)
{
  uint32_t e0;
  
  e0 = (v0 + 1);
  ivar_put(uint32_t, v1, &e0);
}

void task0(void * params)
{
  run2(task_core0, uint32_t, struct ivar);
}

void ivartest(uint32_t v0, uint32_t * out)
{
  struct ivar v1;
  uint32_t e1;
  
  ivar_init(&v1);
  spawn2(task0, uint32_t, v0, struct ivar, v1);
  ivar_get_nontask(uint32_t, &e1, v1);
  *out = (e1 << 1);
  ivar_destroy(&v1);
}
