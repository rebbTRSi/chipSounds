/*
 * nokia.h
 *
 *  Created on: Jan 5, 2014
 *      Author: CJ
 */

#ifndef NOKIA_H_
#define NOKIA_H_

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

#endif /* NOKIA_H_ */
