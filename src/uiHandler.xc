#include <stdio.h>
#include <xs1.h>
#include <platform.h>
#include <timer.h>
#include "nokia.h"
#include "pwm.h"
#include "nokia.h"
#include <safestring.h>

#define PERIOD 100000

/* This the port where the leds reside */
port quad = XS1_PORT_4E;


/* ********************** */
/* Used startKit Ports    */
/* For actual pins refer  */
/* H�dr portmap.txt       */
/* ********************** */
port butt1 = XS1_PORT_1A;
port butt2 = XS1_PORT_1D;
port butt3 = XS1_PORT_1C;
port butt4 = XS1_PORT_1F;
port butt5 = XS1_PORT_1M;


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

struct epattern {
    int bpm;
    int patternData[16];
};

typedef enum { triangle, noise, square, sawtooth, sine } waves; // sine = !, triangle = ", square = #, noise = $, sawtooth = %
typedef enum { sound, pattern } uiState;

/* ********************** */
/* C function definitions */
/* ********************** */

extern void calculate(chanend c_synth_audio);
extern int setPlayState(int state);
extern int getPlayState();
extern void changeCurrentParameter(int currentIntrument, int parameterNr, int parameterTo);
extern void setCurrentPatternStep (int step,int value);
extern int getCurrentPatternStep (int step);
extern void setBpm(int bpm);
extern int getBpm();
extern struct epattern getCurrentPattern();
extern struct instrument getInstrument(int instrumentNr);
extern int setInstrument (int instrumentNr, struct instrument instrumentData );
extern void increaseFreq(int changInstr,int waveNr, int value) ;
/* ********************** */
/* XC function prototypes */
/* ********************** */
void drawUI(int uiState,int buttonNr);
void updatePatternData(int iversedPatternPosition);
void fonttest(void);
void printText(char textBuffer[]);
void printCurrent(int currentInstrumentNr,int inversedChar);
int quadTicks = 0;
int oldQuadPulse = 0;
int newQuadPulse = 0;
int debounceTime = 10000;
char str[200];
int www = 0;
int newWave = 0;
struct instrument current;
struct instrument copyInstrumentTest;
struct epattern currentPattern;
int buttonOld = 1;
int buttonOld1 = 1;
int buttonOld2 = 1;
int buttonOld3 =1;
int buttonOld4 =1;
int currentUIState = sound;
timer t;
timer t1;
timer t2;
timer t3;
timer t4;
timer tmr;
unsigned tmr1;
int ticks=0;
out port x = XS1_PORT_1P;
int starttime;
int stoptime;
unsigned int time;
unsigned int time1;
unsigned int time2;
unsigned int time3;
unsigned int time4;

int lastDebounce;
int lastDebounce1;
int lastDebounce2;
int lastDebounce3;
int lastDebounce4;

int x1=1;
char teksti[33];
int currentInstrumentNr = 0;
int currentInverseWaveNr=0;
int currentInversePatternPosition = -1;
int currentPatternPosition = 0;

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
        x <: 1;

		unsigned button =  peek(butt1) & 1;
		unsigned button1 = peek(butt2) & 1;
		unsigned button2 = peek(butt3) & 1;
		unsigned button3 = peek(butt4) & 1;
		unsigned button4 = peek(butt5) & 1;

		if (button1 == 1 && button1 != buttonOld1) {
		    t1:> lastDebounce1;
		}
		t1:> time1;
		if (time1 - lastDebounce1 > debounceTime) {
			if (button1 != buttonOld1) {
				drawUI(currentUIState,1);
			}
		}

		if (button4 == 1 && button4 != buttonOld4) {
		    t4:> lastDebounce4;
		}
		t4:> time4;
		if (time4 - lastDebounce4 > debounceTime) {
			if (button4 != buttonOld4) {
				if (currentUIState == pattern) {
					currentUIState = sound;
					drawUI(currentUIState,4);
				}
				else if (currentUIState == sound) {
					currentUIState = pattern;
					drawUI(currentUIState,4);
				}
			}
		}

		if (button3 == 1 && button3 != buttonOld3) {
		    t3:> lastDebounce3;
		}
		t3:> time3;
		if (time3 - lastDebounce3 > debounceTime) {
			if (button3 != buttonOld3) {
				drawUI(currentUIState,3);
			}

		}

		if (button2 == 1 && button != buttonOld2) {
		    t2:> lastDebounce2;
		}
		t2:> time2;
		if (time2 - lastDebounce2 > debounceTime) {
			if (button2 != buttonOld2) {
				drawUI(currentUIState,2);
			}
		}
		if (button == 1 && button != buttonOld) {
		    t:> lastDebounce;
		}
		t:> time;
		if (time - lastDebounce > debounceTime) {
			if (button != buttonOld) {
				int currentState = getPlayState();
				drawUI(currentUIState,0);

			}
		}
		buttonOld = button;
		buttonOld1 = button1;
		buttonOld2 = button2;
		buttonOld3 = button3;
		buttonOld4 = button4;
	}
}

void sendLSDjTick() {
    for(ticks=0;ticks<8;ticks++) {
        tmr :> tmr1;
        // add delay to t, wait until timer reaches that value
        tmr when timerafter (tmr1 + PERIOD) :> void;
        x <: 0;
        tmr :> tmr1;
        // add delay to t, wait until timer reaches that value
        tmr when timerafter (tmr1 + PERIOD) :> void;
        x <: 1;
    }
}
void fonttest(void){
	cls();
	text("Button pressed\n");       //text() function dumps direct to screen
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
	sprintf(str,"INSTR NR: %d   ",currentInstrumentNr);
	for (x1=0; x1<length; x1++) {
		if (x1==inversedChar) {         // sine = !, triangle = ", square = #, noise = $, sawtooth = %
			switch (current.wave[x1]) {
			case triangle: safestrcat(str,"("); break;
			case noise: safestrcat(str,"*"); break;
			case square: safestrcat(str,")"); break;
			case sawtooth: safestrcat(str,"+"); break;
			case sine: safestrcat(str,"'"); break;
			default: safestrcat(str,"null"); break;
			}
		}
		else {
			switch (current.wave[x1]) {
			case triangle: safestrcat(str,"\""); break;
			case noise: safestrcat(str,"$"); break;
			case square: safestrcat(str,"#"); break;
			case sawtooth: safestrcat(str,"%"); break;
			case sine: safestrcat(str,"!"); break;
			default: safestrcat(str,"null"); break;
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
	text(textBuffer);       //text() function dumps direct to screen
}

void drawUI(int uiState,int buttonNr) {
//	updatePatternData(currentInversePatternPosition);

	switch (uiState) {
	case pattern:
		switch (buttonNr) {
	/*	case 1:
			int bpm = getBpm();
			setBpm(bpm+1);
			updatePatternData(currentInversePatternPosition);
			break;
		case 2:
			int bpm = getBpm();
			setBpm(bpm-1);
			updatePatternData(currentInversePatternPosition);
			break;*/
		case 1:
		    int currentPatternInstrument = getCurrentPatternStep(currentInversePatternPosition);
		    currentPatternInstrument++;
		    if (currentPatternInstrument < 0)
		        currentPatternInstrument = 4;
		    if (currentPatternInstrument > 4)
		        currentPatternInstrument = 0;
           // printf ("NEW:%d at position: %d\n",currentPatternInstrument,currentInversePatternPosition);

		    setCurrentPatternStep(currentInversePatternPosition,currentPatternInstrument);
            updatePatternData(currentInversePatternPosition);
		    break;
		case 2:
		    currentInversePatternPosition++;
		    if (currentInversePatternPosition > 15) {
		        currentInversePatternPosition = 0;
		    }
		    if (currentInversePatternPosition < 0) {
		        currentInversePatternPosition = 15;
		    }
		    updatePatternData(currentInversePatternPosition);
		    break;
		case 3:
		    int perse = 0;
		   for (perse=0;perse<1000;perse++) {

		    for(ticks=0;ticks<8;ticks++) {
		        tmr :> tmr1;
		        // add delay to t, wait until timer reaches that value
		        tmr when timerafter (tmr1 + PERIOD) :> void;
		        x <: 0;
		        tmr :> tmr1;
		        // add delay to t, wait until timer reaches that value
		        tmr when timerafter (tmr1 + PERIOD) :> void;
		        x <: 1;
		    }
		   }
            break;
		default:
            updatePatternData(currentInversePatternPosition);
			break;
		}
		break;
	case sound:
		switch (buttonNr) {
		case 0:
			/*int currentState = getPlayState();
			if (currentState == 1) {
				text("STOP");
				setPlayState(0);
			}
			else {
				text("START");
				setPlayState(1);
			}*/
            int newFreq=0;
            newFreq = current.frequency[currentInverseWaveNr];
            newFreq +=10;
		    increaseFreq(currentInstrumentNr,currentInverseWaveNr,newFreq);
            current = getInstrument(currentInstrumentNr); // get instrumentdata
            printCurrent(currentInstrumentNr,currentInverseWaveNr);

			break;
		case 1:
			currentInstrumentNr++;
			if (currentInstrumentNr > 3 || currentInstrumentNr < 0) {
				currentInstrumentNr = 0;
			}
			printCurrent(currentInstrumentNr,currentInverseWaveNr);
			break;
		case 2:
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
			break;
		case 3:
			current = getInstrument(currentInstrumentNr); // update instrumentdata
			int parameterTo = current.wave[currentInverseWaveNr];
			parameterTo--;
			if (parameterTo < 0)
				parameterTo=4;
			if (parameterTo >4)
				parameterTo=0;
			int parameterNr = currentInverseWaveNr;
			changeCurrentParameter (currentInstrumentNr,parameterNr,parameterTo);
			printCurrent(currentInstrumentNr,currentInverseWaveNr);
			break;
		case 4:
			printCurrent(currentInstrumentNr,currentInverseWaveNr);
			break;
		}
		break;
	default: break;
	}
}

void updatePatternData(int iversedPatternPosition) {
	cls();
	currentPattern = getCurrentPattern();
	int bpm = currentPattern.bpm;
	safememset(str,0,200);
	//sprintf(str,"BPM: %d\n ",bpm);
	//text (str);

	x1 = 0;
	for (x1=0; x1<16; x1++) {
	    if (x1==iversedPatternPosition) {         // inversed numbers mapped to lowcase alphabets
	        switch (currentPattern.patternData[x1]) {
	            case 0 : safestrcat(str,"a "); break;
	            case 1 : safestrcat(str,"b "); break;
	            case 2 : safestrcat(str,"c "); break;
	            case 3 : safestrcat(str,"d "); break;
	            case 4 : safestrcat(str,"e "); break;
	            case 5 : safestrcat(str,"f "); break;
	            case 6 : safestrcat(str,"g "); break;
	            case 7 : safestrcat(str,"h "); break;
	            case 8 : safestrcat(str,"i "); break;
	            case 9 : safestrcat(str,"j "); break;
	            default: break;
	        }
	    }
	    else {
	        char instBuf[20];
	        sprintf(instBuf,"%d ",currentPattern.patternData[x1]);
	        safestrcat(str,instBuf);
	    }
	}
    text (str);

}
