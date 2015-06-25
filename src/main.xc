#include <stdio.h>
#include <platform.h>
#include <xs1.h>
#include <timer.h>

port led = XS1_PORT_1A;
port butt1 = XS1_PORT_32A;

  extern int calculate();  // This function is defined in C

int main() {
    int buttonOld = 1;
    timer t;
    int starttime;
    int stoptime;
    int time;
    int lastDebounce;
    int x=1;

    while(1){
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
                calculate();
                t :> stoptime;
                printf( "duration=%d ms\n", (( stoptime - starttime) * 10)/1000000);
                x++;
                buttonOld = button;
            }
        }
        buttonOld = button;

    }
           return 0;
}


