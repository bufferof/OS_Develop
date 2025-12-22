#include "screen.h"

int strlen(const char *str) {
  int len = 0;
  while (str[len])
    len++;
  return len;
}

int strcmp(const char *str1, const char *str2) {
  while (*str1 && (*str1 == *str2)) {
    str1++;
    str2++;
  }

  return *(unsigned char *)str1 - *(unsigned char *)str2;
}

void process_command(const char *cmd) {
  if (!strcmp(cmd, "help")) {
    screen_print("there is no help Lmao");
  }
}

void kernel_main() {
  screen_clear();

  screen_print_colored("========================================\n",
                       COLOR_LIGHT_CYAN, COLOR_BLACK);
  screen_print_colored("    Welcome to MyOS v0.1\n", COLOR_YELLOW, COLOR_BLACK);
  screen_print_colored("========================================\n",
                       COLOR_LIGHT_CYAN, COLOR_BLACK);
  screen_print("\n");

  screen_print("System initialized successfully!\n");
  screen_print("Type 'help' for available commands.\n\n");

  screen_print("Kernel loaded at: ");
  screen_print_hexdecimal((uint32_t)kernel_main);
  screen_print("\n\n");

  process_command("help");

  while (1) {
    // HLT 명령: CPU를 대기 상태로
    __asm__ __volatile__("hlt");
  }
}
