#include <xs1.h>
#include <platform.h>
#include <timer.h>
#include <stdlib.h>
#include "nokia.h"
#include "pwm.h"
#include "nokia.h"
#include <safestring.h>

extern int playPattern();
extern int getPlayState();

void trigger (chanend uiTrigger, chanend c_synth_audio) {
    timer tmr;
    unsigned t;
    while(1){
           c_synth_audio <: playPattern();
    }
}
