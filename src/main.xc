#include <stdio.h>
#include <xs1.h>
#include <platform.h>
#include <timer.h>
#include <stdlib.h>
#include "pwm.h"
#include "nokia.h"
#include <print.h>


void initialized(char textBuffer[]);
extern void initialize(int sampleRate, int bitDepth);
void uiHandler(chanend uiTrigger);
void buffer(chanend c_producer, chanend c_consumer);
void trigger(chanend uiTrigger, chanend c_synth_audio);
port p_speaker = XS1_PORT_1E;
int LEN = 30;


int main() {

	initialize (22050,16); // initialize instruments
	chan c_pwm, c_synth_audio, uiTrigger;
	init();
	led(1);

	while(1) {
		par {

			uiHandler(uiTrigger);
			trigger(uiTrigger,c_synth_audio);
			pwm_server(c_pwm, p_speaker, 22050);
			buffer(c_synth_audio, c_pwm);
		}
	}
	return 0;
}
void initialized(char textBuffer[]){
	cls();
	text(textBuffer);       //text() function dumps direct to screen
}

