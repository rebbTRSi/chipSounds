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
#include <timer.h>
timer test;
int teststarttime;
int teststoptime;
extern int playPattern();
extern int getPlayState();
extern float triangleOsc (float A, int FR, int SR);
extern float sineOsc (float A, int FR, int SR);
extern float noiseOsc(float A);
extern float sawtoothOsc(float A, int FR, int SR);

int xi;
void trigger (chanend uiTrigger, chanend c_synth_audio) {
    while(1){
        if (getPlayState() == 1)

            test :> teststarttime;
            for (xi=0;xi<22049;xi++) {
            sawtoothOsc (60, 440,22050);
                   }
            test :> teststoptime;
            printf( "duration=%d ms\n", (( teststoptime - teststarttime) * 10)/1000000);
    }
}
