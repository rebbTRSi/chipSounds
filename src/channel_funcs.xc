#include <stdio.h>

void xc_channel_out(chanend c, int v)
{
     //   printf ("v: %d\n",v);
    c <: v;
}
