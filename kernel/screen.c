#include "screen.h"
#include <stdint.h>

static int cursor_x = 0;
static int cursor_y = 0;
static uint8_t default_color =
    (COLOR_BLACK << 4) | COLOR_WHITE; 

const char hex_chars[] = "0123456789ABCDEF";

static inline uint8_t create_screen_color(uint8_t fg, uint8_t bg) {
  return (bg << 4) | (fg & 0x0F);
}

static void put_char_loc(char c, uint8_t color, int x, int y) {
  uint16_t *video = (uint16_t *)VIDEO_MEMORY;
  int index = y * VIDEO_WIDTH + x; 
  video[index] = (uint16_t)c | ((uint16_t)color << 8);
}

static void scroll_screen() {
  uint16_t *video = (uint16_t *)VIDEO_MEMORY;

  for (int y = 0; y < (VIDEO_HEIGHT - 1); y++) {
    for (int x = 0; x < VIDEO_WIDTH; x++) {
      video[y * VIDEO_WIDTH + x] = video[(y + 1) * VIDEO_WIDTH + x];
    }
  }

  for (int x = 0; x < VIDEO_WIDTH; x++) {
    video[(VIDEO_HEIGHT - 1) * VIDEO_WIDTH + x] =
        (uint16_t)' ' | ((uint16_t)default_color << 8);
  }

  cursor_y = VIDEO_HEIGHT - 1;
}

void screen_clear() {
  uint16_t *video = (uint16_t *)VIDEO_MEMORY;

  for (int i = 0; i < VIDEO_HEIGHT * VIDEO_WIDTH; i++) {
    video[i] = (uint16_t)' ' | ((uint16_t)default_color << 8);
  }

  cursor_x &= 0;
  cursor_y &= 0;
}

void screen_print_char(char c) {
  if (c == '\n') {
    cursor_x = 0;
    cursor_y++;
  } else if (c == '\t') {
    cursor_x = (cursor_x + 4) & ~(4 - 1);
  } else if (c == '\r') {
    cursor_x = 0;
  } else if (c == '\b') {
    if (cursor_x > 0) {
      cursor_x--;
      put_char_loc(' ', default_color, cursor_x, cursor_y);
    }
  } else {
    put_char_loc(c, default_color, cursor_x, cursor_y);
    cursor_x++;
  }

  if (cursor_x >= VIDEO_WIDTH) {
    cursor_x = 0;
    cursor_y++;
  }

  if (cursor_y >= VIDEO_HEIGHT) {
    scroll_screen();
  }
}

void screen_print(const char *str) {
  for (int i = 0; str[i] != '\0'; i++) {
    screen_print_char(str[i]);
  }
}

void screen_print_colored(const char *str, uint8_t fg, uint8_t bg) {
  const uint8_t old_color = default_color;
  default_color = create_screen_color(fg, bg);
  screen_print(str);
  default_color = old_color;
}

void screen_print_hexdecimal(uint32_t hex) {
  char buffer[11];
  buffer[0] = '0';
  buffer[1] = 'x';

  for (int i = 9; i >= 2; i--) {
    buffer[i] = hex_chars[hex & 0xF];
    hex >>= 4;
  }

  buffer[10] = '\0';
  screen_print(buffer);
}

void screen_print_decimal(int num) {
  if (num == 0) {
    screen_print_char('0');
    return;
  }

  if (num < 0) {
    screen_print_char('-');
    num = -num; 
  }

  char buffer[12];
  int i = 0;

  while (num > 0) {
    buffer[i++] = '0' + (num % 10);
    num /= 10;
  }

  for (int j = i - 1; j >= 0; j--) {
    screen_print_char(buffer[j]);
  }
}

void screen_set_cursor(int x, int y) {
  cursor_x = x;
  cursor_y = y;

  if (cursor_x >= VIDEO_WIDTH)
    cursor_x = VIDEO_WIDTH - 1;
  if (cursor_y >= VIDEO_HEIGHT)
    cursor_y = VIDEO_HEIGHT - 1;
}