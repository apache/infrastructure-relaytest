#include <stdio.h>

int main(void) {
  int c=0;
  int o=1;
  while(1) {
    c=getchar();
    if (c==EOF) return(0);
    if (c=='\0') printf(" ");
    else if (o) printf("%c",c);
    if (c=='K') o=0;
    if (c=='Z') o=0;
    if (c=='D') o=0;
  }
}
