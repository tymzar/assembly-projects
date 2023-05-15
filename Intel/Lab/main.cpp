#include <stdio.h>

extern "C" int func(char *a);

int main(void)
{
  char text[] = "ASDFGHJKLA";
  int result;

  printf("Input string      > %s\n", text);
  result = func(text);
  printf("Conversion results> %s\n", text);
  printf("Function return> %d\n", result);

  return 0;
}
