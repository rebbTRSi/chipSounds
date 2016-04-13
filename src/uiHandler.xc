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

/* ********************** */
/* Used startKit Ports    */
/* For actual pins refer  */
/* Hšdr portmap.txt       */
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
    int patternData[32];
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
extern void getCurrentPatternStep (int step);
extern void setBpm(int bpm);
extern int getBpm();
extern struct epattern getCurrentPattern();
extern struct instrument getInstrument(int instrumentNr);
extern int setInstrument (int instrumentNr, struct instrument instrumentData );

/* ********************** */
/* XC function prototypes */
/* ********************** */

void drawUI(int uiState,int buttonNr);
void updatePatternData();
void fonttest(void);
void printText(char textBuffer[]);
void printCurrent(int currentInstrumentNr,int inversedChar);

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
		unsigned button =  peek(butt1) & 1;
		unsigned button1 = peek(butt2) & 1;
		unsigned button2 = peek(butt3) & 1;
		unsigned button3 = peek(butt4) & 1;
		unsigned button4 = peek(butt5) & 1;


		if (button1 == 1 && button1 != buttonOld1) {
		    t1:> lastDebounce1;
		}
		t1:> time1;
		if (time1 - lastDebounce1 > 50000) {
			if (button1 != buttonOld1) {
				drawUI(currentUIState,1);
			}
		}

		if (button4 == 1 && button4 != buttonOld4) {
		    t4:> lastDebounce4;
		}
		t4:> time4;
		if (time4 - lastDebounce4 > 50000) {
			if (button4 != buttonOld4) {
				if (currentUIState == pattern) {
					currentUIState = sound;
					drawUI(currentUIState,4);
					text ("sound");
				}
				else if (currentUIState == sound) {
					currentUIState = pattern;
					drawUI(currentUIState,4);
					text ("pattern");
				}
			}
		}

		if (button3 == 1 && button3 != buttonOld3) {
		    t3:> lastDebounce3;
		}
		t3:> time3;
		if (time3 - lastDebounce3 > 50000) {
			if (button3 != buttonOld3) {
				drawUI(currentUIState,3);

			}
		}

		if (button2 == 1 && button != buttonOld2) {
		    t2:> lastDebounce2;
		}
		t2:> time2;
		if (time2 - lastDebounce2 > 50000) {
			if (button2 != buttonOld2) {
				drawUI(currentUIState,2);

			}
		}
		if (button == 1 && button != buttonOld) {
		    t:> lastDebounce;
		}
		t:> time;
		if (time - lastDebounce > 50000) {
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
	sprintf(str,"instr nr: %d   ",currentInstrumentNr);
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
	updatePatternData();

	switch (uiState) {
	case pattern:
		switch (buttonNr) {
		case 1:
			int bpm = getBpm();
			setBpm(bpm+1);
			updatePatternData();
			break;
		case 2:
			int bpm = getBpm();
			setBpm(bpm-1);
			updatePatternData();
			break;
		default:
			break;
		}
		break;
	case sound:
		switch (buttonNr) {
		case 0:
			int currentState = getPlayState();
			if (currentState == 1) {
				text("stop");
				setPlayState(0);
			}
			else {
				text("start");
				setPlayState(1);
			}
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
	default: break;
	}
}

void updatePatternData() {
	cls();
	currentPattern = getCurrentPattern();
	int bpm = currentPattern.bpm;
	safememset(str,0,200);
	sprintf(str,"bpm: %d\n ",bpm);
	text (str);
	int i;
	for (i=0; i<15; i++) {
		sprintf(str,"%d ",currentPattern.patternData[i]);
		text (str);
	}
}


