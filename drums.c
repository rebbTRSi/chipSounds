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

HEX ATTACK	DECAY/RELEASE
0 	20m 	6ms
1 	8ms 	24ms
2 	16ms	48ms
3 	24ms	72ms
4 	38ms 	114ms
5 	56ms 	168ms
6 	68ms 	204ms
7 	80ms 	240ms
8 	100ms	300ms
9 	250ms	750ms
A 	500ms 	1.5s
B 	800ms 	2.4s
C 	1s 		3s
D 	3s 		9s
E 	5s 		15s
F 	8s 		24s


*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include "audioHelpers.h"
#define PI 3.14159265

struct instrument {
	int wave[16];
 	int frequency[16];
	float volume;
	int attack;
	int decay;
	int sustain;
	int release;
};

int main(void)
{

struct instrument bassDrum = {
	{sine,noise,square,sawtooth,sawtooth},		// waves: triangle,noise,square,sawtooth
	{220,220,110,40,220},						// frequency
	27,										// volume
	100,											// attack
	20,											// decay
	10,											// sustain
	4 											// release
	};

struct instrument snareDrum = {
	{sine,sine,square},
	{440,220,110,40},
	117,
	30,
	30,
	2,
	1
	};

struct instrument instrumentsArray[16] = {
	snareDrum,
	bassDrum
};

int SR = 44100;
int bitDepth = 16;
int wavetype = 0;
int numberOfChannels = 2;
int stepLenght = 50 ;// 1/50th of second = 20mS
int kbps = SR * bitDepth / 8;
int stepSize =  kbps / stepLenght ;
int onemS = kbps / 100;
FILE* file;
int soundLength = 4 * stepSize;
int TABLE_LEN = 1024;
double table[TABLE_LEN];
float duration;

double j;
float kerroin = 30000;
duration = 10.0;
double phase = 0,out;
signed int sample;

//double sample_increment = frequency*TABLE_LEN/SR;
//for (j=0;j<TABLE_LEN;j++) {
//	table[j] = (double) sin(2 * PI * j/TABLE_LEN);
//}

int bpse = getBps(SR,bitDepth,2);
int fileSize =getFileSizePerSecond(SR,bitDepth,2);
file = fopen ("sample.raw" , "w" );
int q = 200;
int steps = 0;
int length = 1024;

/*
clock_t start = clock(), diff;
test1();
diff = clock() - start;
int msec = diff * 1000 / CLOCKS_PER_SEC;
printf("Time taken %d seconds %d milliseconds", msec/1000, msec%1000);
*/

int currentSample = 0;
int totalsCalculated = 0;
int currentInstrument = 1;
float currentVolume = 0;
for (j=0;j<stepSize*5;j++) {
	
	if (totalsCalculated < instrumentsArray[currentInstrument].attack*onemS)
		currentVolume += 0.1;
		if (currentVolume > instrumentsArray[currentInstrument].volume)
			currentVolume = instrumentsArray[currentInstrument].volume;

	if (currentSample > stepSize) {
		steps++;
		if (steps<16) {
			wavetype = instrumentsArray[currentInstrument].wave[steps];
		}
		currentSample = 0;
	}

	if (steps == 0 && currentSample == 0) { // handle the first step
		wavetype = instrumentsArray[currentInstrument].wave[steps];
	}

	sample = getSample (wavetype,SR,instrumentsArray[currentInstrument].frequency[steps],currentVolume);

	if (sample > 127)
		sample = 127;
	if (sample < -128)
		sample = -128;

	currentSample++;
	totalsCalculated++;
	fwrite(&sample,sizeof(char),1,file);
	
	}

	fclose(file);

}
