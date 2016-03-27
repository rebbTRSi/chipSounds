
typedef enum { triangle, noise, square, sawtooth, sine } wave;
typedef enum { false, true} bool;

struct waveDefaults {
    float p;
    float y;
    float y2;
    float phase;
    float triPhase;
};

double sines = 0.0;
float modulo = 0.0;
float PW = 1.0;
double cosine = 1.0;
const double B = 4/(float)M_PI;
const double C = -4/((float)M_PI*(float)M_PI);
const double P = 0.225;
const double D = 5.0*(float)M_PI*(float)M_PI;
const double pi2 = M_PI *2;
float p = 0.0;
float y = 0.0;
float y2 = 0.0;
float phase = 0.0;
float triPhase = 0.0;
int fixTriPhase = 0;
int fixPi = 314159265;
int fixPi2 = 628318530;
int getBps (int SR, int bitLength, int numberOfChannels) { return SR*bitLength*numberOfChannels; }
int stepSizetoSec (int stepSize) { return 1000/stepSize; }
int getStepLength (int SR, int stepSize, int bitLength, int numberOfChannels) {
 int kbps = getBps (SR,bitLength,numberOfChannels); 
 int stepSizeinS = stepSizetoSec(stepSize); 
 return kbps/stepSizeinS;
  }
int getFileSizePerSecond (int SR, int bitLength, int numberOfChannels) { return SR*(bitLength/8)*numberOfChannels; }

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
float calcSine (double f) { sines += f * cosine; cosine -= f*sines; return sines; }
float sineCoefficient (int FRuency, int SR) { return 2.0 * M_PI * FRuency / SR; }
float sineOsc (float A,int FRuency,int SR) { double coef=sineCoefficient(FRuency,SR); return A*calcSine(coef); }
float parabolicSine (double x, bool bHighPrecision) { double y=B*x+C*x*fabs(x);if (bHighPrecision) { y=P*(y*fabs(y)-y)+y; } return y; }
float BhaskaraISine (double x) { double d = fabs(x); double sgn = d == 0 ? 1.0 : x/fabs(x); return 16.0*x*(M_PI-sgn*x)/(D-sgn*4.0*x*(M_PI-sgn*x)); }
float noiseOsc (int A) { return  A*((2.0*((rand()%(127- (-128)))+ (-128))-1.0)/127); }
float squareOsc (float A, int FR, int SR) { if(p< M_PI)y=A;else y=-A;p=p+((2 * M_PI * FR)/SR);if(p>2*M_PI)p=p-(2*M_PI);return y; }
float sawtoothOsc (float A, int FR, int SR) { y2=A-(A/M_PI*phase);phase=phase+((2*M_PI*FR)/SR);if(phase>2*M_PI){phase = phase - (2 * M_PI);}return y2; }
float triangleOsc (float A, int FR, int SR) { if (triPhase < M_PI) y = -A + (2 * A / M_PI) * triPhase; else y = 3*A - (2 * A / M_PI) * triPhase; triPhase = triPhase + ((pi2 * FR) / SR); if (triPhase > pi2) triPhase = triPhase - (pi2); return y; }

float getSample (int wavetype,int SR,int FRuency,float volume,struct waveDefaults waveDefaults) {

    float sample;

switch ( wavetype ) 
    {
    case 0:
        sample = triangleOsc(volume,FRuency,SR);
        break;
    case 1:
        sample = noiseOsc(volume);
        break;
    case 2:
        sample = squareOsc(volume,FRuency,SR);
        break;
    case 3:
        sample = sawtoothOsc(volume,FRuency,SR);
        break;
    case 4:
        sample = sineOsc(volume,FRuency,SR);
        break;
    default:
        sample = 0;
        break;
    }
        return sample;
}
