// Copyright 2009 Fredrik Petrini
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#include <xs1.h>
#include <stdio.h>

void pwm_server(chanend c_samples, out port p_pwm_output, int pwm_frequency)
{
	unsigned int time;
	unsigned int duty_cycle;
	unsigned int state;
	unsigned int period = (XS1_TIMER_HZ / pwm_frequency);
	short sample;
	timer t_pwm;

	state = 0;
	t_pwm :> time;
	while(1)
	{
		select
		{
		case c_samples :> sample:
			duty_cycle = (((sample*20)+(1<<15)) * period)>>16;
			break;
		case t_pwm when timerafter(time) :> int _:

			p_pwm_output <: state;
			if(state)
				time += duty_cycle;
			else
				time += period - duty_cycle;
			state = !state;
			break;
		}
	}
}
