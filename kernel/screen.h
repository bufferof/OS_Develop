#ifndef SCREEN_H
#define SCREEN_H

#include <stdint.h>

#define VIDEO_MEMORY 0xB8000

#define VIDEO_WIDTH 80
#define VIDEO_HEIGHT 25

#define COLOR_BLACK 0
#define COLOR_BLUE 1
#define COLOR_GREEN 2
#define COLOR_CYAN 3
#define COLOR_RED 4
#define COLOR_MAGENTA 5
#define COLOR_BROWN 6
#define COLOR_LIGHT_GREY 7
#define COLOR_DARK_GREY 8
#define COLOR_LIGHT_BLUE 9
#define COLOR_LIGHT_GREEN 10
#define COLOR_LIGHT_CYAN 11
#define COLOR_LIGHT_RED 12
#define COLOR_LIGHT_MAGENTA 13
#define COLOR_YELLOW 14
#define COLOR_WHITE 15

// 비디오 색상 비트 구조
//  [ 15 ........ 8 ][ 7 ....... 0 ]
//     색상 속성          ASCII 문자

void screen_clear();
void screen_print_char(char c);
void screen_print(const char *str);
void screen_print_colored(const char *str, uint8_t fg, uint8_t bg);
void screen_print_hexdecimal(uint32_t hex);
void screen_print_decimal(int num);
void screen_set_cursor(int x, int y);

#endif