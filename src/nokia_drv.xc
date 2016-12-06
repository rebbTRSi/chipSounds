/*
 * nokia_drv.xc
 *
 *  Created on: Jan 11, 2014
 *      Author: CJ
 */

#include <xs1.h>
#include <timer.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include "nokia_drv.h"
int PUS = 1;
// Driver Functions
void init(void){
    begin(CONTRAST);
}

void setup(void){
   SCE <:0 ;                    //enable display
   delay_microseconds(PUS);     //minimum delay is 100ns but using 1us
}

void begin(char contrast){
    setup();
    RST <: 0;
    LED <: 0;
    delay_microseconds(PUS);
    RST <: 1;
    delay_microseconds(PUS);
    lcd_cmd(0x21);              //extended mode
    lcd_cmd(0x14);              //bias
    lcd_cmd(contrast);          //vop
    lcd_cmd(0x20);              //basic mode
    lcd_cmd(0x0c);              //non-inverted display - use 0x0d to invert display
    cls();
}

void led(int led_value){
    LED <: led_value;           //controls backlight
}

void SPI(char c){
    //data = DIN
    //clock = SCLK
    //MSB first
    //value = c
    int i;
    int ch;

    for (i=0;i<8;i++){          //feed bits one at a time
        ch = ((c & (1 << (7-i))) > 0);
        DIN <: ch;
        delay_microseconds(WUS);
        SCLK <: 1;
        delay_microseconds(WUS);
        SCLK <: 0;
    }
}

void lcd_cmd(char c){
    DC <: 0;                    //puts LCD into command mode
    delay_microseconds(WUS);
    SPI(c);
}

void lcd_data(char c){
    DC <: 1;                    //puts LCD into data mode
    delay_microseconds(WUS);
    SPI(c);
}

//Drawing Functions
int center_word(int r, char *word){
    //centers a word on row r
    int l,c;
    if (r>5) return -1;
    l=strlen(word);
    c=(COLUMNS - l)/2;
    if (c <= 0) c=0;
    gotorc(r,c);
    text(word);
    return 0;
}

int gotorc(int r, int c){
    //moves LCD internal address to byte row r and font column c
    if ((r>6) || (c>13)) return -1;
    lcd_cmd(c*6+128);
    lcd_cmd(r+64);
    return 0;
}

int gotoxy(int x, int y){
    //moves LCD internal address to byte row y and pixel column x
    if ((x>48) || (y>5)) return 1;
    lcd_cmd(x+128);
    lcd_cmd(y+64);
    return 0;
}

void text(char *words){
    //write strings of characters to screen at current internal LCD address
    int i,j,sp;
    for (i=0;i<strlen(words);i++)
    {
        if (words[i]==0x0a){
            sp = 14 - ((strlen(words)-1) % 14);
            if (sp<14) {
               for (j=0;j<sp;j++)
                  display_char(0x20);
            }
        }
        display_char(words[i]);
    }
}

void display_char(char c){
    //writes a character from the font table to screen at current internal LCD address
    int index,i;
    index=(c-32)*5;
    if (c>=32 && c<=127){
        for (i=0;i<5;i++){
            lcd_data(font[index+i]);
        }
        lcd_data(0);
    }
}

void cls(void){
    //clear the LCD by writing zero bytes to every location
    int i,j;
    gotoxy(0,0);
    for (i=0;i<84;i++){
        for (j=0;j<6;j++)
            lcd_data(0);
    }
}

void cls_buf(void){
    //zeros the pixel buffer
    int i;
    for (i=0;i<504;i++){
       img_buf[i]=0x00;
    }
}

void disp_buf(void){
    //dumps the pixel buffer to screen a byte at a time
    int i;
    gotoxy(0,0);
    for (i=0;i<504;i++){
       lcd_data(img_buf[i]);
    }
}

int char_in_buf(int x,int y,char c){
    //puts a character from the font table into the pixel buffer
    int index,i;
    index=(c-32)*5;
    if ((x+(y*84)+ 6)>505) return -1;
    if (c>=32 && c<=127){
        for (i=0;i<5;i++){
            img_buf[x+(y*84)+i]=(font[index+i]);
        }
    }
    return 0;
}

int setpixel(int x,int y){
    //turns on a pixel in the pixel buffer
    unsigned char c;
    int index,ypos,bit;
    if ((x>83) || (y>47)) return -1;
    ypos = (int) y/8;
    index = x + (ypos*84);
    bit = y % 8;
    c = (1 << bit);
    img_buf[index]=img_buf[index] | c;
    return 0;
}

int getpixel(int x,int y){
    //reads the status of a pixel in the pixel buffer - 1=set, 0=unset
    unsigned char c;
    int index,ypos,bit;
    if ((x>83) || (y>47)) return -1;
    ypos = (int) y/8;
    index = x + (ypos*84);
    bit = y % 8;
    c = (1 << bit);
    return img_buf[index] & c;
}

int unsetpixel(int x,int y){
    //turns off a pixel in the pixel buffer
    unsigned char c;
    int index,ypos,bit;
    if ((x>83) || (y>47)) return -1;
    ypos = (int) y/8;
    index = x + (ypos*84);
    bit = y % 8;
    c = (1 << bit);
    img_buf[index] &= ~(1 << bit);
    return 0;
}

void circle(int xc, int yc, int rad){
    //draws a circle of pixels in the pixel buffer at (xc,yc) of radius rad
    int i,x,y;
    float angle;
    for (i=0;i<359;i++)
    {
        angle = (float) i * 0.0174532925;
        x=rad*cos(angle)+xc;
        y=rad*sin(angle)+yc;
        if ((x>0) && (x<84) && (y>0) && (y<48))
           setpixel(x,y);
    }
}

void line(int x1, int y1, int x2, int y2){
    //draws a line of pixels in the pixel buffer from (x1,y1) to (x2,y2)
    float slopeyx,slopexy;
    float fx1,fx2,fy1,fy2,b;
    int x,y;

    fx1=(float) x1;
    fx2=(float) x2;
    fy1=(float) y1;
    fy2=(float) y2;
    if ((y1!=y2) || (x1!=x2)){
       if (x2!=x1) slopeyx = (fy2-fy1)/(fx2-fx1); else slopeyx=1000000;
       if (y2!=y1) slopexy = (fx2-fx1)/(fy2-fy1); else slopexy=1000000;
       if (abs(slopeyx) < abs(slopexy)){
           b=fy1-(fx1*slopeyx);
           if (x2>x1){
               for (x=x1;x<x2;x++){
                   y=slopeyx*x+b;
                   if ((x>=0) && (x<84) && (y>=0) && (y<48))
                       setpixel(x,y);
               }
           } else {
               for (x=x2;x<x1;x++){
                   y=slopeyx*x+b;
                   if ((x>=0) && (x<84) && (y>=0) && (y<48))
                       setpixel(x,y);
               }
           }
       } else {
           b=fx1-(fy1*slopexy);
           if (y2>y1){
               for (y=y1;y<y2;y++){
                   x=slopexy*y+b;
                   if ((x>=0) && (x<84) && (y>=0) && (y<48))
                       setpixel(x,y);
               }
           } else {
               for (y=y2;y<y1;y++){
                   x=slopexy*y+b;
                   if ((x>=0) && (x<84) && (y>=0) && (y<48))
                       setpixel(x,y);
               }
           }
       }
    }
}
