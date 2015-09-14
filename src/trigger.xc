#include <stdio.h>
#include <xs1.h>
#include <xscope.h>
#include <platform.h>
#include <timer.h>
#include <stdlib.h>
#include "pwm.h"
#include "trigger.h"

port butt1 = XS1_PORT_32A;
extern void calculate(chanend c_synth_audio);  // This function is defined in C
int buttonOld = 1;
  timer t;
  int starttime;
  int stoptime;
  int time;
  int lastDebounce;
  int x=1;

void trigger(chanend snd) {
    while (1) {
    unsigned int time;
           int current_val = 0;
           int is_stable = 1;
           const unsigned debounce_delay_ms = 50;
           unsigned debounce_timeout;

           unsigned button = peek(butt1) & 1;
           if (button == 0 && button != buttonOld) {
               t :> lastDebounce;
           }
           t :> time;

          if (time - lastDebounce > 50000) {
               if (button != buttonOld) {
                   t :> starttime;
                   calculate( snd);
                   t :> stoptime;
                                 printf("starttime: %d",starttime);
                                 printf("stoptime: %d",stoptime);

                                 printf( "duration=%ld ms\n", (( stoptime - starttime) * 10)/1000000);
                                 x++;
                                 buttonOld = button;

                             }
                         }
                         buttonOld = button;

    }
return 0;
}
