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
*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include "audioHelpers.h"
#define PI 3.14159265

int wave[16]=
{
	0,1,2,3,4,0,0,1,1,1,1,1,1,1,1,1
};

int frequency[16]=
{
	120,440,440,220,110,0,0,0,0,0,0,0,0,0
};

int volume[16]=
{
	127,127,127,80,20
};

int main(void)
{

int SR = 44100;
int bitDepth = 16;
int wavetype = 0;
int numberOfChannels = 2;
int stepLenght = 5 ;// 1/5th of second = 20mS
int kbps = SR * bitDepth / 8;
int stepSize =  (kbps / stepLenght) / 10 ;
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

for (j=0;j<stepSize*5;j++) {
	
	if (currentSample > stepSize) {
		steps++;
		if (steps<16) {
			wavetype = wave[steps];
		}
		currentSample = 0;
	}

	if (steps == 0 && currentSample == 0) { // handle the first step
		wavetype = wave[steps];
	}

	sample = getSample (wavetype,SR,frequency[steps],volume[steps]);

	if (sample > 127)
		sample = 127;
	if (sample < -128)
		sample = -128;

	currentSample++;
	fwrite(&sample,sizeof(char),1,file);
	
	}

	fclose(file);

}
