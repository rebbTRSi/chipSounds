/*
 * nokia_drv.h
 *
 *  Created on: Jan 11, 2014
 *      Author: CJ
 */

#ifndef NOKIA_DRV_H_
#define NOKIA_DRV_H_

//GPIO pins that correspond to the pins of the LCD
out port   DC = XS1_PORT_1I;
out port  RST = XS1_PORT_1H;
out port  LED = XS1_PORT_1L;

//Pins that simulate the SPI to the pins of the LCD
out port  SCE = XS1_PORT_1G;
out port SCLK = XS1_PORT_1K;
out port  DIN = XS1_PORT_1J;

int ROWS = 6;               //max number of rows (0 to 5)
int COLUMNS = 14;           //max number of font columns (0 to 13)
int ON = 1;
int OFF = 0;
int CONTRAST = 0xc4;
int WUS=1;                  //delay for signal transitions of LCD in uS

char font[] ={                      //font of ascii 32 to 126.  127 is custom char
    0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x5f, 0x00, 0x00,
    0x00, 0x07, 0x00, 0x07, 0x00,
    0x14, 0x7f, 0x14, 0x7f, 0x14,
    0x24, 0x2a, 0x7f, 0x2a, 0x12,
    0x23, 0x13, 0x08, 0x64, 0x62,
    0x36, 0x49, 0x55, 0x22, 0x50,
    0x00, 0x05, 0x03, 0x00, 0x00,
    0x00, 0x1c, 0x22, 0x41, 0x00,
    0x00, 0x41, 0x22, 0x1c, 0x00,
    0x14, 0x08, 0x3e, 0x08, 0x14,
    0x08, 0x08, 0x3e, 0x08, 0x08,
    0x00, 0x50, 0x30, 0x00, 0x00,
    0x08, 0x08, 0x08, 0x08, 0x08,
    0x00, 0x60, 0x60, 0x00, 0x00,
    0x20, 0x10, 0x08, 0x04, 0x02,
    0x3e, 0x51, 0x49, 0x45, 0x3e,
    0x00, 0x42, 0x7f, 0x40, 0x00,
    0x42, 0x61, 0x51, 0x49, 0x46,
    0x21, 0x41, 0x45, 0x4b, 0x31,
    0x18, 0x14, 0x12, 0x7f, 0x10,
    0x27, 0x45, 0x45, 0x45, 0x39,
    0x3c, 0x4a, 0x49, 0x49, 0x30,
    0x01, 0x71, 0x09, 0x05, 0x03,
    0x36, 0x49, 0x49, 0x49, 0x36,
    0x06, 0x49, 0x49, 0x29, 0x1e,
    0x00, 0x36, 0x36, 0x00, 0x00,
    0x00, 0x56, 0x36, 0x00, 0x00,
    0x08, 0x14, 0x22, 0x41, 0x00,
    0x14, 0x14, 0x14, 0x14, 0x14,
    0x00, 0x41, 0x22, 0x14, 0x08,
    0x02, 0x01, 0x51, 0x09, 0x06,
    0x32, 0x49, 0x79, 0x41, 0x3e,
    0x7e, 0x11, 0x11, 0x11, 0x7e,
    0x7f, 0x49, 0x49, 0x49, 0x36,
    0x3e, 0x41, 0x41, 0x41, 0x22,
    0x7f, 0x41, 0x41, 0x22, 0x1c,
    0x7f, 0x49, 0x49, 0x49, 0x41,
    0x7f, 0x09, 0x09, 0x09, 0x01,
    0x3e, 0x41, 0x49, 0x49, 0x7a,
    0x7f, 0x08, 0x08, 0x08, 0x7f,
    0x00, 0x41, 0x7f, 0x41, 0x00,
    0x20, 0x40, 0x41, 0x3f, 0x01,
    0x7f, 0x08, 0x14, 0x22, 0x41,
    0x7f, 0x40, 0x40, 0x40, 0x40,
    0x7f, 0x02, 0x0c, 0x02, 0x7f,
    0x7f, 0x04, 0x08, 0x10, 0x7f,
    0x3e, 0x41, 0x41, 0x41, 0x3e,
    0x7f, 0x09, 0x09, 0x09, 0x06,
    0x3e, 0x41, 0x51, 0x21, 0x5e,
    0x7f, 0x09, 0x19, 0x29, 0x46,
    0x46, 0x49, 0x49, 0x49, 0x31,
    0x01, 0x01, 0x7f, 0x01, 0x01,
    0x3f, 0x40, 0x40, 0x40, 0x3f,
    0x1f, 0x20, 0x40, 0x20, 0x1f,
    0x3f, 0x40, 0x38, 0x40, 0x3f,
    0x63, 0x14, 0x08, 0x14, 0x63,
    0x07, 0x08, 0x70, 0x08, 0x07,
    0x61, 0x51, 0x49, 0x45, 0x43,
    0x00, 0x7f, 0x41, 0x41, 0x00,
    0x02, 0x04, 0x08, 0x10, 0x20,
    0x00, 0x41, 0x41, 0x7f, 0x00,
    0x04, 0x02, 0x01, 0x02, 0x04,
    0x40, 0x40, 0x40, 0x40, 0x40,
    0x00, 0x01, 0x02, 0x04, 0x00,
    0x20, 0x54, 0x54, 0x54, 0x78,
    0x7f, 0x48, 0x44, 0x44, 0x38,
    0x38, 0x44, 0x44, 0x44, 0x20,
    0x38, 0x44, 0x44, 0x48, 0x7f,
    0x38, 0x54, 0x54, 0x54, 0x18,
    0x08, 0x7e, 0x09, 0x01, 0x02,
    0x0c, 0x52, 0x52, 0x52, 0x3e,
    0x7f, 0x08, 0x04, 0x04, 0x78,
    0x00, 0x44, 0x7d, 0x40, 0x00,
    0x20, 0x40, 0x44, 0x3d, 0x00,
    0x7f, 0x10, 0x28, 0x44, 0x00,
    0x00, 0x41, 0x7f, 0x40, 0x00,
    0x7c, 0x04, 0x18, 0x04, 0x78,
    0x7c, 0x08, 0x04, 0x04, 0x78,
    0x38, 0x44, 0x44, 0x44, 0x38,
    0x7c, 0x14, 0x14, 0x14, 0x08,
    0x08, 0x14, 0x14, 0x18, 0x7c,
    0x7c, 0x08, 0x04, 0x04, 0x08,
    0x48, 0x54, 0x54, 0x54, 0x20,
    0x04, 0x3f, 0x44, 0x40, 0x20,
    0x3c, 0x40, 0x40, 0x20, 0x7c,
    0x1c, 0x20, 0x40, 0x20, 0x1c,
    0x3c, 0x40, 0x30, 0x40, 0x3c,
    0x44, 0x28, 0x10, 0x28, 0x44,
    0x0c, 0x50, 0x50, 0x50, 0x3c,
    0x44, 0x64, 0x54, 0x4c, 0x44,
    0x00, 0x08, 0x36, 0x41, 0x00,
    0x00, 0x00, 0x7f, 0x00, 0x00,
    0x00, 0x41, 0x36, 0x08, 0x00,
    0x10, 0x08, 0x08, 0x10, 0x08,
    0xAA, 0xAA, 0xAA, 0xAA, 0xAA,
};

char img_buf[505];                  //array that contains the pixel buffer

void init(void);
int gotorc(int r, int c);
int gotoxy(int x, int y);
void text(char *words);
void display_char(char c);
void cls(void);
void setup(void);
void begin(char contrast);
void led(int led_value);
void SPI(char c);
void lcd_cmd(char c);
void lcd_data(char c);
int center_word(int r, char *word);
void cls_buf(void);
void disp_buf(void);
int char_in_buf(int x,int y,char c);
int setpixel(int x,int y);
void circle(int xc, int yc, int rad);
void line(int x1, int y1, int x2, int y2);
int unsetpixel(int x,int y);
int getpixel(int x,int y);

#endif /* NOKIA_DRV_H_ */