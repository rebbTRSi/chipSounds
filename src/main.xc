#include <stdio.h>
#include <xs1.h>
#include <xscope.h>
#include <platform.h>
#include <timer.h>
#include <stdlib.h>
#include "pwm.h"
#include "trigger.h"

void buffer(chanend c_producer, chanend c_consumer);

port p_speaker = XS1_PORT_1A;

/* xscope initialisation section
 * ( called before main() )
 * * * */


int main() {
    chan c_pwm, c_synth_audio;

    xscope_register(1, XSCOPE_CONTINUOUS , " Continuous Value 1", XSCOPE_INT , " Value ");

      while(1){
                par {
                         trigger(c_synth_audio);
                         pwm_server(c_pwm, p_speaker, 22050);
                         buffer(c_synth_audio, c_pwm);
                   }
    }
           return 0;
}


