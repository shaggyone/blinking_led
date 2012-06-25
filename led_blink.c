/* all indications between diagonal stroke star and star diagonal stroke are only
comments */
// line comments are likewise possible
// all indications of a line following on the two diagonal strokes are comment
// #include <stdint.h>
// #define F_CPU 8000000UL
#include <avr/io.h>
#include <util/delay.h>

int main (void) { // (2)
  DDRB = 0x01;

  while(1) {
    PORTB = 1;
    _delay_ms(500);
    PORTB = 0;
    _delay_ms(500);
  }
  /* never reached */
  return 0;
}

