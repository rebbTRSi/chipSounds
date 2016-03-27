/*
wavetable drummachine

20ms per step
44100khz 16-bit mono -> bitrate 705600 -> 88.2kb/s -> 1.764 kb of data per step

STEP CMD    #1  #2  #3
00   Play   01  40 +00   # Plays triangle, transposed by +0 (40 is the middle)
01   Play   08 +00 +00   # Plays noise, transpose value untouched
02   Play   04 +00 +00   # Plays a pulse, transpose value untouched
03   Play   14 -07 +00   # release gate bit, transpose value decremented by -7
03   Play  +00 -07 +00   # transpose value decremented by -7
03   Play  +00 -07 +00   # transpose value decremented by -7
06   End   +00 +00 +00   # stop wavetable

Is stepOn? == have we calculated 1764 samples. -> out % 1764 = 0
    if in step
    check waveform from table -> link to waveform table
    copy to output at rate of transpose
    if not in step
    increase step counter
    check waveform from table -> link to waveform table
    copy to output at rate of transpose

ADSR lenghts:

HEX ATTACK  DECAY/RELEASE
0   20m     6ms
1   8ms     24ms
2   16ms    48ms
3   24ms    72ms
4   38ms    114ms
5   56ms    168ms
6   68ms    204ms
7   80ms    240ms
8   100ms   300ms
9   250ms   750ms
A   500ms   1.5s
B   800ms   2.4s
C   1s      3s
D   3s      9s
E   5s      15s
F   8s      24s


*/
#include <timer.h>

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include "audioHelpers.h"
#include "channel_funcs.h"
int i=0;
#define PI 3.14159265
int bufferSize = 32;
int kulli = 0;
int q = 200;
int playState = 1;
int steps = 0;
int toOutput = 0;
int length = 1024;
int z = 0;
int currentSample = 0;
int currentCalculated = 0;
int trailing = 0;
int currentInstrument = 0;
int totalsCalculated = 0;
float currentVolume = 0;
int patternPosition = 0;
FILE *fp;
signed int sample;
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

struct pattern {
    int bpm;
    int patternData[32];
};

struct pattern pattern = {
    120,
    //{0,3,3,3,0,3,3,3,0,3,3,3,0,3,3,3,0,3,3,3}
    {1,4,2,2,1,4,2,2,1,4,2,0,1,4,2,2,1,4,2,2,1,4,2,2,1,4,2,0,1,3,1,1}
//  {0,3,0,3,0,3,0,3,0,3,0,3,0,3,0,3}
};
int samplesInterval2 = 0;
float beatsPerSecond = 0.0f;
float quarterNoteLengths = 0.0f;
float sixteenthNoteLength = 0.0f;
float barLenghtInMs = 0.0f;
float quarternNotesPerSecond = 0.0f;
int bufferIndex = 0;
int SR = 0;
int wavetype = 0;
int numberOfChannels = 0;
int stepLenght = 20;// 1/50th of second = 20mS
int kbps =  0;
int stepSize =  0;
int onemS = 0;
int bitDepth = 16;
float speedInSamples = 0.0f;
int TABLE_LEN = 0;
float duration = 0.0f;
double j;
double out;
signed int output;

//double sample_increment = frequency*TABLE_LEN/SR;
//for (j=0;j<TABLE_LEN;j++) {
//  table[j] = (double) sin(2 * PI * j/TABLE_LEN);
//}
int bpse = 0;
int totalLength = 0;
int noteLimit = 0;

struct instrument bassDrum = {
    {noise,sine,square,sawtooth,sine},      // waves: triangle,noise,square,sawtooth
    {360,294,146,136,100},                      // frequency
    {100,100},                                      // volume
    10,                                         // attack
    10,                                         // decay
    20,                                         // sustain
    10,                                             // release
    5
    };

struct instrument snareDrum = {
    {noise,sine,sine,sine,sine,sine,sine},
    {80,120,80,40,80,80,80},
    {100,70},
    30,
    60,
    2,
    100,
    7
    };

struct instrument blank = {
    {sine,sine,square},
    {0,0,0,0},
    {0,0},
    0,
    0,
    0,
    0,
    1
    };

struct instrument bass = {
    {sawtooth,sawtooth,sawtooth,square,square,square,square,square,square,square},
    {40,40,40,40,20,10,40,40,40,40},
    {40,110},
    70,
    10,
    20,
    20,
    6
    };

struct instrument arpeg = {
    {triangle,triangle,triangle,triangle,triangle,triangle,triangle,triangle,triangle,triangle},
    {523,659,783,659,523,659,783,659,523,659},
    {20,110},
    70,
    10,
    20,
    20,
    10
    };

struct instrument instrumentsArray[16] = { };

struct waveDefaults wave1;
struct waveDefaults wave2;
struct waveDefaults wave3;
struct waveDefaults wave4;

void initialize(int sampleRate, int bitDepth)
{
    instrumentsArray[0] = bassDrum;
    instrumentsArray[1] = snareDrum;
    instrumentsArray[2] = bass;
    instrumentsArray[3] = arpeg;
    instrumentsArray[4] = blank;
beatsPerSecond = (float)pattern.bpm/60.0f;
quarterNoteLengths = (1000.0f/beatsPerSecond);
sixteenthNoteLength = quarterNoteLengths / 4.0f; // ms
barLenghtInMs = quarterNoteLengths * 4.0f;
quarternNotesPerSecond = 1000.0f*quarterNoteLengths;
bufferIndex = 0;
SR = sampleRate;
wavetype = 0;
numberOfChannels = 1;
stepLenght = 50;// 1/50th of second = 20mS
kbps = (SR * bitDepth)/8;
stepSize =  kbps / stepLenght ;
onemS = (int)SR/1000.0;
duration = 10.0;
int currentCalculated = 0;
float samplesPerMinute = SR*60.0;
float sampleIntervalQuarter= samplesPerMinute/(float)pattern.bpm;
samplesInterval2 = (int) (sampleIntervalQuarter/4+0.5);
//double sample_increment = frequency*TABLE_LEN/SR;
//for (j=0;j<TABLE_LEN;j++) {
//  table[j] = (double) sin(2 * PI * j/TABLE_LEN);
//}
bpse = getBps(SR,bitDepth,1);
totalLength = (speedInSamples*4.0f);
noteLimit = (int) (sixteenthNoteLength * (kbps/1000.0f));
// print sane defaults
kulli = 1;
}

int setInstrument (int instrumentNr, struct instrument instrumentData ) {
   instrumentsArray[instrumentNr] = instrumentData;
   return 1;
}

int getPlayState() {
    return playState;
}

int setPlayState(int state) {
    playState = state;
    return state;
}

struct instrument getInstrument (int instrumentNr) {
    if (instrumentNr <= 16 && instrumentNr >= 0) {
        return instrumentsArray[instrumentNr];
    }
    else {
         struct instrument fail =
        {
            /* data */
        };;
    return fail;
    }
}

int playPattern() {

    //printf ("instrumentLengt:%d samples\n",instrumentsArray[currentInstrument].length*stepSize);
    //printf ("max instrument length:%d in samples in seconds: %f\n",samplesInterval2,sixteenthNoteLength);
    //printf ("stepsize: %d",stepSize);
    if (kulli == 1) {
if ( patternPosition <= 31 ) {

    if (currentSample < (instrumentsArray[currentInstrument].attack)*onemS) {
        if (currentVolume < instrumentsArray[currentInstrument].volume[0]) {
        currentVolume += 0.1;
    }
        else {
            currentVolume = instrumentsArray[currentInstrument].volume[0]   ;
                }
    }
    else if (currentSample < (instrumentsArray[currentInstrument].attack+instrumentsArray[currentInstrument].decay)*onemS && currentVolume > instrumentsArray[currentInstrument].volume[1]) {
        currentVolume -= 0.1;
    }
    else if (currentSample < (instrumentsArray[currentInstrument].attack+instrumentsArray[currentInstrument].decay+instrumentsArray[currentInstrument].sustain)*onemS ) {
        currentVolume = currentVolume;
    }
    else {
        if (currentVolume > 0.0) {
        currentVolume -=0.1;
    }
    else {
        currentVolume =0.0;
    }
}
    if (currentSample > stepSize) {
        steps++;
        if (steps>15) {
            steps = 15;
        }
        if (steps<=15) {
            wavetype = instrumentsArray[currentInstrument].wave[steps];
        //  fprintf(stderr, "-1234 reading wave:%d\n",wavetype);
        }
        currentSample = 0;
    }
    if (steps == 0 && currentCalculated == 0) { // handle the first step
        wavetype = instrumentsArray[currentInstrument].wave[steps];
    }
    output = getSample (wavetype,SR,instrumentsArray[currentInstrument].frequency[steps],currentVolume,wave1);
    if (output > 127)
        output = 127;
    if (output < -128)
        output = -128;
    currentSample++;
    currentCalculated++;
    totalsCalculated++;
    // if current calculated sample is under 16th note, but over current instrument lenght then pad to zeroes
    if (currentCalculated < samplesInterval2 && currentCalculated > stepSize*instrumentsArray[currentInstrument].length) {
        //printf("trailing from: %d to: %d and we are over: %d \n",currentCalculated,samplesInterval2,stepSize*instrumentsArray[currentInstrument].length);
        output = 0.0;
        totalsCalculated++;
    //  currentSample++;
    //  currentCalculated++;
        trailing++;
    }
    // if current calculated sample is over 16th note, change to next instrument in current pattern
    if (currentCalculated >= samplesInterval2 ) {
        currentCalculated = 0;
        currentSample = 0;
        currentVolume = 0.0;
        steps = 0;
        trailing=0;
        patternPosition++;
        if (patternPosition > 31)
        patternPosition = 0;

        currentInstrument = pattern.patternData[patternPosition];
        noteLimit = totalsCalculated + sixteenthNoteLength*onemS;
    }
    return output;
    }
//fprintf(stderr, "* sample: %f\n",output);
}
else {
    //fprintf(stderr, "Instruments not inited yet!!!\n");
}
        return 0;
}
float playInstrument(playInstr,i) {
    if (currentSample < (instrumentsArray[playInstr].attack)*onemS) {
           if (currentVolume < instrumentsArray[playInstr].volume[0]) {
           currentVolume += 0.1;
       }
           else {
               currentVolume = instrumentsArray[playInstr].volume[0]   ;
                   }
       }
       else if (currentSample < (instrumentsArray[playInstr].attack+instrumentsArray[playInstr].decay)*onemS && currentVolume > instrumentsArray[playInstr].volume[1]) {
           currentVolume -= 0.1;
       }
       else if (currentSample < (instrumentsArray[playInstr].attack+instrumentsArray[playInstr].decay+instrumentsArray[playInstr].sustain)*onemS ) {
           currentVolume = currentVolume;
       }
       else {
           if (currentVolume > 0.0) {
           currentVolume -=0.1;
       }
       else {
           currentVolume =0.0;
       }
   }
       if (currentSample > stepSize) {
           steps++;
           if (steps>15) {
               steps = 15;
           }
           if (steps<=15) {
               wavetype = instrumentsArray[playInstr].wave[steps];
           //  fprintf(stderr, "-1234 reading wave:%d\n",wavetype);
           }
           currentSample = 0;
       }
       if (steps == 0 && currentCalculated == 0) { // handle the first step
           wavetype = instrumentsArray[playInstr].wave[steps];
       }
       output = getSample (wavetype,SR,instrumentsArray[playInstr].frequency[steps],currentVolume,wave1);
       if (output > 127)
           output = 127;
       if (output < -128)
           output = -128;
       currentSample++;
       currentCalculated++;
       totalsCalculated++;
       // if current calculated sample is under 16th note, but over current instrument lenght then pad to zeroes
       if (currentCalculated < samplesInterval2 && currentCalculated > stepSize*instrumentsArray[playInstr].length) {
           //printf("trailing from: %d to: %d and we are over: %d \n",currentCalculated,samplesInterval2,stepSize*instrumentsArray[currentInstrument].length);
           output = 0.0;
           totalsCalculated++;
       //  currentSample++;
       //  currentCalculated++;
           trailing++;
       }

       return output;
       }



