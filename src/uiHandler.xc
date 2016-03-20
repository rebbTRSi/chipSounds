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

port butt1 = XS1_PORT_32A;
port butt2 = XS1_PORT_1D;
extern void calculate(chanend c_synth_audio);  // This function is defined in C
void fonttest(void);
void printText(char textBuffer[]);
typedef enum { triangle, noise, square, sawtooth, sine } waves;
char str[300];
int www = 0;
struct instrument {
    int wave[16];
    int frequency[16];
    float volume[2];
    int attack;
    int decay;
    int sustain;
    int release;
    int length;
};
extern struct instrument getInstrument(int instrumentNr);  // This function is defined in C
extern int setInstrument (int instrumentNr, struct instrument instrumentData ); // This function is defined in C
struct instrument current;

int buttonOld = 1;
int buttonOld1 = 1;

  timer t;
  timer t1;
  int starttime;
  int stoptime;
  int time;
  int time1;
  int lastDebounce;
  int lastDebounce1;
  int x1=1;
  char teksti[33];
  int uiState;
  int isPlaying = 0;
  int currentInstrumentNr = 0;

  void uiHandler(chanend uiTrigger) {
    current = getInstrument(currentInstrumentNr); // get instrumentdata

    while (1) {
    unsigned int time;
    int uiState = 0;

            unsigned button = peek(butt1) & 1;
            unsigned button1 = peek(butt2) & 1;

            if (button1 == 1 && button1 != buttonOld1) {
                t1 :> lastDebounce1;
            }
            t1 :> time1;
            if (time1 - lastDebounce1 > 50000) {
                       if (button1 != buttonOld1) {
                       safememset(str,0,300);
                       currentInstrumentNr++;
                       if (currentInstrumentNr > 3 || currentInstrumentNr < 0) {
                           currentInstrumentNr = 0;
                       }
                       current = getInstrument(currentInstrumentNr); // get instrumentdata
                       int length = current.length;
                           x1 = 0;
                           sprintf(str,"instr nr: %d   ",currentInstrumentNr);
                           for (x1=0;x1<length;x1++) {
                               switch (current.wave[x1]) {
                                   case triangle : safestrcat(str,"triangle "); break;
                                   case noise : safestrcat(str,"noise "); break;
                                   case square : safestrcat(str,"square "); break;
                                   case sawtooth : safestrcat(str,"sawtooth "); break;
                                   case sine : safestrcat(str,"sine "); break;
                                   default : safestrcat(str,"null "); break;
                                     }
                           }

                           printText(str);
                   }
                       buttonOld1 = button1;

                   }
                   if (button == 0 && button != buttonOld) {
                       t :> lastDebounce;
                   }
                   t :> time;

                  if (time - lastDebounce > 50000) {

                       if (button != buttonOld) {
                           cls();
                           text("Playing Pattern");
                           isPlaying = 1;
                           uiTrigger <: 1;
                           buttonOld = button;
                  }
                                 }
                           buttonOld = button;
                           buttonOld1 = button1;

            }
    }

void fonttest(void){
    cls();
    text("Button pressed\n");           //text() function dumps direct to screen
}

void printText(char textBuffer[]){
    cls();
    text(textBuffer);           //text() function dumps direct to screen
}


