/* all indications between diagonal stroke star and star diagonal stroke are only
comments */
// line comments are likewise possible
// all indications of a line following on the two diagonal strokes are comment
// #include <stdint.h>
//#define F_CPU 8000000UL
#include <avr/io.h> // (1)
#include <util/delay.h>

int main (void) { // (2)
  int i, j;

  DDRC = 0x00;
  DDRB = 0x01;//PORTB = 0x03;
  while(1) {
    PORTB = PORTC;


/*  for (j=1; j < 20000; j = j * 2) {
      PORTB = 1;
      for (i=0; i< j; i++)
        _delay_ms(1);
      PORTB = 0;
      for (i=0; i< j; i++) ;
      _delay_ms(1);
    }*/
  }
  /* never reached */
  return 0;
// (3)equal to DDRB=0b11111111
// (4)equal to PORTB=0b00000011
// (5a)
// (5b)
// (5c)
// (6)
}

