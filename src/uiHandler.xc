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
port butt3 = XS1_PORT_1C;
extern void calculate(chanend c_synth_audio);  // This function is defined in C
extern int setPlayState(int state);  // This function is defined in C
extern int getPlayState();  // This function is defined in C


void fonttest(void);
void printText(char textBuffer[]);
void printCurrent(int currentInstrumentNr,int inversedChar);
typedef enum { triangle, noise, square, sawtooth, sine } waves; // sine = !, triangle = ", square = #, noise = $, sawtooth = %
char str[200];
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
struct instrument copyInstrumentTest;

int buttonOld = 1;
int buttonOld1 = 1;
int buttonOld2 = 1;
  timer t;
  timer t1;
  timer t2;
  int starttime;
  int stoptime;
  unsigned int time;
  unsigned int time1;
  unsigned int time2;
  int lastDebounce;
  int lastDebounce1;
  int lastDebounce2;
  int x1=1;
  char teksti[33];
  int uiState;
  int currentInstrumentNr = 0;
  int currentInverseWaveNr=0;
  void uiHandler(chanend uiTrigger) {
    current = getInstrument(currentInstrumentNr); // get instrumentdata
    struct instrument copyInstrumentTest = {
        {sine,sine,sine,sine,sine,square,square,square,square,square},
        {400,400,400,400,200,100,400,400,400,400},
        {40,110},
        70,
        10,
        20,
        20,
        6
        };

    while (1) {

            unsigned button =  peek(butt1)  & 1;
            unsigned button1 = peek(butt2) & 1;
            unsigned button2 = peek(butt3) & 1;

            if (button1 == 1 && button1 != buttonOld1) {
                t1 :> lastDebounce1;
            }

            t1 :> time1;

            if (time1 - lastDebounce1 > 50000) {
                if (button1 != buttonOld1) {
                    currentInstrumentNr++;

                    if (currentInstrumentNr > 3 || currentInstrumentNr < 0) {
                        currentInstrumentNr = 0;
                    }
                    printCurrent(currentInstrumentNr,currentInverseWaveNr);
                }
            }

            if (button2 == 1 && button != buttonOld2) {
                t2 :> lastDebounce2;
            }
            t2 :> time2;
            if (time2 - lastDebounce2 > 50000) {
                if (button2 != buttonOld2) {
                   cls();
                    safememset(str,0,200);
                    current = getInstrument(currentInstrumentNr); // get instrumentdata
                    int length = current.length;
                    currentInverseWaveNr++;

                    if (currentInverseWaveNr > current.length-1) {
                        currentInverseWaveNr = 0;
                    }

                   // sprintf(str,"inv nr: %d  ",currentInverseWaveNr);
                   // text (str);

                      printCurrent(currentInstrumentNr,currentInverseWaveNr);
                   // setInstrument(currentInstrumentNr,copyInstrumentTest);
                   // printCurrent(currentInstrumentNr);
                }
            }
            if (button == 1 && button != buttonOld) {
                t :> lastDebounce;
            }
            t :> time;
            if (time - lastDebounce > 50000) {
                if (button != buttonOld) {
                    int currentState = getPlayState();
                    if (currentState == 1) {
                        setPlayState(0);
                    }
                    else {
                        setPlayState(1);
                    }
                }
            }
            buttonOld = button;
            buttonOld1 = button1;
            buttonOld2 = button2;
    }
}

void fonttest(void){
    cls();
    text("Button pressed\n");           //text() function dumps direct to screen
}
void printCurrent(int currentInstrumentNr,int inversedChar) {
    cls();
    safememset(str,0,200);

    if (currentInstrumentNr < 0 || currentInstrumentNr > 3) {
        text("ime nullii");
    }

    current = getInstrument(currentInstrumentNr); // get instrumentdata
    int length = current.length;
    x1 = 0;
    sprintf(str,"instr nr: %d   ",currentInstrumentNr);
        for (x1=0;x1<length;x1++) {
            if (x1==inversedChar) {             // sine = !, triangle = ", square = #, noise = $, sawtooth = %
                switch (current.wave[x1]) {
                    case triangle : safestrcat(str,"("); break;
                    case noise : safestrcat(str,"*"); break;
                    case square : safestrcat(str,")"); break;
                    case sawtooth : safestrcat(str,"+"); break;
                    case sine : safestrcat(str,"'"); break;
                    default : safestrcat(str,"null"); break;
                }
            }
            else {
                switch (current.wave[x1]) {
                    case triangle : safestrcat(str,"\""); break;
                    case noise : safestrcat(str,"$"); break;
                    case square : safestrcat(str,"#"); break;
                    case sawtooth : safestrcat(str,"%"); break;
                    case sine : safestrcat(str,"!"); break;
                    default : safestrcat(str,"null"); break;
                }
            }
        }
        char freqBuf[20];

        sprintf(freqBuf,"-- %d -- ",current.frequency[inversedChar]);
        safestrcat(str,freqBuf);
        text (str);
}

void printText(char textBuffer[]){
    cls();
    text(textBuffer);           //text() function dumps direct to screen
}


