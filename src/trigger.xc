#include <stdio.h>
#include <xs1.h>
#include <xscope.h>
#include <platform.h>
#include <timer.h>
#include <stdlib.h>
#include "nokia.h"
#include "pwm.h"
#include "nokia.h"
#include <safestring.h>

extern void calculate(chanend c_synth_audio,int playInstr);  // This function is defined in C
int x;
int isPlaying = 0;
int xi;
void trigger (chanend uiTrigger, chanend c_synth_audio) {
    while(1){
    select
      {
      case uiTrigger :> x :
        switch (x)
          {
        case 0:
            calculate(c_synth_audio,x);
            break;
        case 1:
            calculate(c_synth_audio,x);
            break;
        case 2:
            calculate(c_synth_audio,x);
            break;
        case 3:
            calculate(c_synth_audio,x);
            break;
        default:
            break;
          }
      break;
      }
    }
}
