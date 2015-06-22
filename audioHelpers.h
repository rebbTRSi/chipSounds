
typedef enum { false, true } bool;
double sine = 0.0;
double cosine = 1.0;
const double B = 4/(float)M_PI;
const double C = -4/((float)M_PI*(float)M_PI);
const double P = 0.225;
const double D = 5.0*(float)M_PI*(float)M_PI;
float p = 0.0;
float y = 0.0;
float y2 = 0.0;
float phase = 0.0;
float triPhase = 0.0;
float vco2 = 0, vco = 1.0;
	float vcop=0;

	float vcoFR = 1, lastvcoFR=0, vcoadd, vcoFR2=0;

int getStepLength (int SR, int stepSize, int bitLength, int numberOfChannels) {
 int kbps = getBps (SR,bitLength,numberOfChannels); 
 int stepSizeinS = stepSizetoSec(stepSize); 
 return kbps/stepSizeinS;
  }
int getFileSizePerSecond (int SR, int bitLength, int numberOfChannels) { return SR*(bitLength/8)*numberOfChannels; }
int getBps (int SR, int bitLength, int numberOfChannels) { return SR*bitLength*numberOfChannels; }
int stepSizetoSec (int stepSize) { return 1000/stepSize; }
int sigTodB (int sig) { return 20*log10(sig); }
int dBtoSig () { return 0; } // TODO
int getRMS (int *sampleBuffer,int bufferLen,int numberOfChannels) {
	int kout=0; 
	for (int i=0;i<bufferLen/numberOfChannels;i++)
		{
			kout += sampleBuffer[i] * sampleBuffer[i];
		}
		kout /=  bufferLen / numberOfChannels;  
        kout = sqrt((float)kout);
        return kout;  
          }
double calcSine (double f) { sine += f * cosine; cosine -= f*sine; return sine; }
double sineCoefficient (int FRuency, int SR) { return 2.0 * M_PI * FRuency / SR; }
double getSine (int FRuency,int SR) { double coef=sineCoefficient(FRuency,SR); return calcSine(coef); }     
double parabolicSine (double x, bool bHighPrecision) { double y=B*x+C*x*fabs(x);if (bHighPrecision) { y=P*(y*fabs(y)-y)+y; } return y; }
double BhaskaraISine (double x) { double d = fabs(x); double sgn = d == 0 ? 1.0 : x/fabs(x); return 16.0*x*(M_PI-sgn*x)/(D-sgn*4.0*x*(M_PI-sgn*x)); }
double noiseOsc () { return 2.0*((rand()%(127- (-128)))+ (-128))-1.0; }
double squareOsc (int A, int FR, int SR) { if(p< M_PI)y=A;else y=-A;p=p+((2 * M_PI * FR)/SR);if(p>2*M_PI)p=p-(2*M_PI);return y; }
double sawtoothOsc (int A, int FR, int SR) { y2=A-(A/M_PI*phase);phase=phase+((2*M_PI*FR)/SR);if(phase>2*M_PI){phase = phase - (2 * M_PI);}return y2; }
double triangleOsc (int A, int FR, int SR) { if (triPhase < M_PI) y = -A + (2 * A / M_PI) * triPhase; else y = 3*A - (2 * A / M_PI) * triPhase; triPhase = triPhase + ((2 * M_PI * FR) / SR); if (triPhase > 2 * M_PI) triPhase = triPhase - (2 * M_PI); return y; }
int getSample (wavetype,SR,FRuency,volume) {
signed int sample;
switch ( wavetype ) 
	{
	case 0:
		sample = triangleOsc(volume,FRuency,SR);
		break;
	case 1:
		sample = noiseOsc();
		break;
	case 2:
		sample = squareOsc(volume,FRuency,SR);
		break;
	case 3:
		sample = sawtoothOsc(volume,FRuency,SR);
		break;
	case 4:
		sample = triangleOsc(volume,FRuency,SR);
		break;
	default:
		sample = 0;
		break;	
	}
		return sample;
}
