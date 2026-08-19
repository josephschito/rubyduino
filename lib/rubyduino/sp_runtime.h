#ifndef SP_ARDUINO_RUNTIME_H
#define SP_ARDUINO_RUNTIME_H

#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <avr/interrupt.h>
#include <avr/io.h>
#include <util/delay.h>
#include <util/delay_basic.h>

typedef int32_t mrb_int;
typedef double mrb_float;
typedef mrb_int sp_sym;
typedef uint8_t mrb_bool;

typedef struct {
  mrb_int first;
  mrb_int last;
} sp_Range;

typedef struct {
  mrb_int cls_id;
} sp_Class;

#define sp_int_add(a, b) ((mrb_int)((a) + (b)))
#define sp_int_sub(a, b) ((mrb_int)((a) - (b)))
#define sp_int_mul(a, b) ((mrb_int)((a) * (b)))
#define sp_int_neg(a) ((mrb_int)(-(a)))

#ifndef TRUE
#define TRUE 1
#endif
#ifndef FALSE
#define FALSE 0
#endif

static int sp_last_status = 0;

#define time(value) ((mrb_int)1)

#define SP_GC_SAVE() ((void)0)
#define SP_GC_ROOT(value) ((void)0)
#define SP_GC_RESTORE() ((void)0)

typedef void (*sp_gc_scan_func)(void *);

static void *sp_gc_alloc(size_t size, void (*free_func)(void *), sp_gc_scan_func scan_func) {
  (void)free_func;
  (void)scan_func;
  return malloc(size);
}

static void sp_gc_mark(void *ptr) {
  (void)ptr;
}

static inline mrb_int sp_idiv(mrb_int a, mrb_int b) {
  mrb_int q;
  mrb_int r;

  if (b == 0) {
    return 0;
  }

  q = a / b;
  r = a % b;
  if ((r != 0) && ((r ^ b) < 0)) {
    q--;
  }

  return q;
}

typedef struct {
  mrb_int *data;
  mrb_int start;
  mrb_int len;
  mrb_int cap;
} sp_IntArray;

typedef struct {
  mrb_float *data;
  mrb_int len;
  mrb_int cap;
} sp_FloatArray;

static const char *sp_str_dup_external(const char *s) {
  return s;
}

static sp_Range sp_range_new(mrb_int first, mrb_int last) {
  sp_Range range;
  range.first = first;
  range.last = last;
  return range;
}

static sp_IntArray *sp_IntArray_new(void) {
  sp_IntArray *array = (sp_IntArray *)malloc(sizeof(sp_IntArray));
  array->start = 0;
  array->len = 0;
  array->cap = 4;
  array->data = (mrb_int *)malloc(sizeof(mrb_int) * array->cap);
  return array;
}

static void sp_IntArray_push(sp_IntArray *array, mrb_int value) {
  if (array->len >= array->cap) {
    array->cap *= 2;
    array->data = (mrb_int *)realloc(array->data, sizeof(mrb_int) * array->cap);
  }
  array->data[array->start + array->len] = value;
  array->len++;
}

static mrb_int sp_IntArray_length(sp_IntArray *array) {
  return array->len;
}

static mrb_int sp_IntArray_get(sp_IntArray *array, mrb_int index) {
  return array->data[array->start + index];
}

static sp_FloatArray *sp_FloatArray_new(void) {
  sp_FloatArray *array = (sp_FloatArray *)malloc(sizeof(sp_FloatArray));
  array->len = 0;
  array->cap = 4;
  array->data = (mrb_float *)malloc(sizeof(mrb_float) * array->cap);
  return array;
}

static void sp_FloatArray_push(sp_FloatArray *array, mrb_float value) {
  if (array->len >= array->cap) {
    array->cap *= 2;
    array->data = (mrb_float *)realloc(array->data, sizeof(mrb_float) * array->cap);
  }
  array->data[array->len] = value;
  array->len++;
}

static mrb_int sp_FloatArray_length(sp_FloatArray *array) {
  return array->len;
}

static mrb_float sp_FloatArray_get(sp_FloatArray *array, mrb_int index) {
  return array->data[index];
}

static volatile uint32_t rd_uno_timer0_overflows = 0;
static uint8_t rd_uno_timer0_ready = 0;

ISR(TIMER0_OVF_vect) {
  rd_uno_timer0_overflows++;
}

static void rd_uno_timer0_init(void) {
  if (rd_uno_timer0_ready) {
    return;
  }

  TCCR0A |= (uint8_t)((1 << WGM00) | (1 << WGM01));
  TCCR0B = (uint8_t)((TCCR0B & (uint8_t)~((1 << CS02) | (1 << CS01) | (1 << CS00))) | (1 << CS01) | (1 << CS00));
  TIMSK0 |= (uint8_t)(1 << TOIE0);
  rd_uno_timer0_ready = 1;
  sei();
}

static int rd_uno_valid_pin(uint8_t pin) {
  return pin <= 19;
}

static volatile uint8_t *rd_uno_ddr(uint8_t pin) {
  if (pin <= 7) {
    return &DDRD;
  }
  if (pin <= 13) {
    return &DDRB;
  }
  if (pin <= 19) {
    return &DDRC;
  }
  return NULL;
}

static volatile uint8_t *rd_uno_port(uint8_t pin) {
  if (pin <= 7) {
    return &PORTD;
  }
  if (pin <= 13) {
    return &PORTB;
  }
  if (pin <= 19) {
    return &PORTC;
  }
  return NULL;
}

static volatile uint8_t *rd_uno_pin_reg(uint8_t pin) {
  if (pin <= 7) {
    return &PIND;
  }
  if (pin <= 13) {
    return &PINB;
  }
  if (pin <= 19) {
    return &PINC;
  }
  return NULL;
}

static uint8_t rd_uno_bit(uint8_t pin) {
  if (pin <= 7) {
    return pin;
  }
  if (pin <= 13) {
    return pin - 8;
  }
  return pin - 14;
}

int pin_mode(uint8_t pin, uint8_t mode) {
  volatile uint8_t *ddr = rd_uno_ddr(pin);
  volatile uint8_t *port = rd_uno_port(pin);
  uint8_t mask;

  if (!ddr || !port) {
    return 1;
  }

  mask = (uint8_t)(1 << rd_uno_bit(pin));

  if (mode == 1) {
    *ddr |= mask;
    return 0;
  }

  if (mode == 0) {
    *ddr &= (uint8_t)~mask;
    *port &= (uint8_t)~mask;
    return 0;
  }

  if (mode == 2) {
    *ddr &= (uint8_t)~mask;
    *port |= mask;
    return 0;
  }

  return 1;
}

int digital_write(uint8_t pin, uint8_t value) {
  volatile uint8_t *port = rd_uno_port(pin);
  uint8_t mask;

  if (!port) {
    return 1;
  }

  mask = (uint8_t)(1 << rd_uno_bit(pin));

  if (value) {
    *port |= mask;
  } else {
    *port &= (uint8_t)~mask;
  }

  return 0;
}

int digital_read(uint8_t pin) {
  volatile uint8_t *reg = rd_uno_pin_reg(pin);

  if (!reg) {
    return -1;
  }

  return ((*reg & (uint8_t)(1 << rd_uno_bit(pin))) != 0) ? 1 : 0;
}

int analog_read(uint8_t pin) {
  uint8_t channel = pin;

  if (pin >= 14 && pin <= 19) {
    channel = pin - 14;
  }

  if (channel > 5 || !rd_uno_valid_pin(pin)) {
    return -1;
  }

  ADMUX = (uint8_t)((1 << REFS0) | channel);
  ADCSRA = (uint8_t)((1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0));
  ADCSRA |= (uint8_t)(1 << ADSC);

  while (ADCSRA & (uint8_t)(1 << ADSC)) {
  }

  return ADC;
}

int analog_write(uint8_t pin, uint8_t value) {
  if (!rd_uno_valid_pin(pin)) {
    return 1;
  }

  pin_mode(pin, 1);

  if (value == 0) {
    return digital_write(pin, 0);
  }
  if (value == 255) {
    return digital_write(pin, 1);
  }

  if (pin == 5) {
    rd_uno_timer0_init();
    TCCR0A |= (uint8_t)(1 << COM0B1);
    OCR0B = value;
    return 0;
  }
  if (pin == 6) {
    rd_uno_timer0_init();
    TCCR0A |= (uint8_t)(1 << COM0A1);
    OCR0A = value;
    return 0;
  }
  if (pin == 9) {
    TCCR1A |= (uint8_t)((1 << WGM10) | (1 << COM1A1));
    TCCR1B = (uint8_t)((TCCR1B & (uint8_t)~((1 << CS12) | (1 << CS11) | (1 << CS10) | (1 << WGM13))) | (1 << WGM12) | (1 << CS11) | (1 << CS10));
    OCR1A = value;
    return 0;
  }
  if (pin == 10) {
    TCCR1A |= (uint8_t)((1 << WGM10) | (1 << COM1B1));
    TCCR1B = (uint8_t)((TCCR1B & (uint8_t)~((1 << CS12) | (1 << CS11) | (1 << CS10) | (1 << WGM13))) | (1 << WGM12) | (1 << CS11) | (1 << CS10));
    OCR1B = value;
    return 0;
  }
  if (pin == 3) {
    TCCR2A |= (uint8_t)((1 << WGM20) | (1 << WGM21) | (1 << COM2B1));
    TCCR2B = (uint8_t)((TCCR2B & (uint8_t)~((1 << CS22) | (1 << CS21) | (1 << CS20))) | (1 << CS22));
    OCR2B = value;
    return 0;
  }
  if (pin == 11) {
    TCCR2A |= (uint8_t)((1 << WGM20) | (1 << WGM21) | (1 << COM2A1));
    TCCR2B = (uint8_t)((TCCR2B & (uint8_t)~((1 << CS22) | (1 << CS21) | (1 << CS20))) | (1 << CS22));
    OCR2A = value;
    return 0;
  }

  return digital_write(pin, value < 128 ? 0 : 1);
}

static void sp_arduino_delay_ms(unsigned long ms) {
  while (ms > 0) {
    _delay_loop_2((uint16_t)(F_CPU / 4000UL));
    ms--;
  }
}

void delay_ms(uint32_t ms) {
  sp_arduino_delay_ms(ms);
}

void delay_us(uint32_t us) {
  while (us > 0) {
    _delay_us(1.0);
    us--;
  }
}

uint32_t micros(void) {
  uint32_t overflows;
  uint8_t counter;
  uint8_t flags;
  uint8_t sreg;

  rd_uno_timer0_init();

  sreg = SREG;
  cli();
  overflows = rd_uno_timer0_overflows;
  counter = TCNT0;
  flags = TIFR0;
  if ((flags & (uint8_t)(1 << TOV0)) && counter < 255) {
    overflows++;
  }
  SREG = sreg;

  return ((overflows << 8) + counter) * (uint32_t)(64UL / (F_CPU / 1000000UL));
}

uint32_t millis(void) {
  return micros() / 1000UL;
}

uint32_t pulse_in_timeout(uint8_t pin, uint8_t value, uint32_t timeout_us) {
  uint32_t start;
  uint32_t pulse_start;
  uint32_t width;

  if (!rd_uno_valid_pin(pin)) {
    return 0;
  }

  value = value ? 1 : 0;
  start = micros();

  while (digital_read(pin) == value) {
    if ((micros() - start) >= timeout_us) {
      return 0;
    }
  }

  while (digital_read(pin) != value) {
    if ((micros() - start) >= timeout_us) {
      return 0;
    }
  }

  pulse_start = micros();

  while (digital_read(pin) == value) {
    width = micros() - pulse_start;
    if ((micros() - start) >= timeout_us) {
      return 0;
    }
  }

  return micros() - pulse_start;
}

uint32_t pulse_in(uint8_t pin, uint8_t value) {
  return pulse_in_timeout(pin, value, 1000000UL);
}

void serial_begin(uint32_t baud) {
  uint16_t ubrr;

  if (baud == 0) {
    return;
  }

  ubrr = (uint16_t)((F_CPU / 16UL / baud) - 1UL);
  UBRR0H = (uint8_t)(ubrr >> 8);
  UBRR0L = (uint8_t)ubrr;
  UCSR0A = 0;
  UCSR0B = (uint8_t)((1 << RXEN0) | (1 << TXEN0));
  UCSR0C = (uint8_t)((1 << UCSZ01) | (1 << UCSZ00));
}

int serial_available(void) {
  return (UCSR0A & (uint8_t)(1 << RXC0)) ? 1 : 0;
}

int serial_read(void) {
  if (!serial_available()) {
    return -1;
  }
  return UDR0;
}

void serial_write(uint8_t value) {
  while (!(UCSR0A & (uint8_t)(1 << UDRE0))) {
  }
  UDR0 = value;
}

void serial_print_str(const char *value) {
  while (*value) {
    serial_write((uint8_t)*value);
    value++;
  }
}

void serial_print_int(int value) {
  char buf[12];
  char *p = &buf[11];
  unsigned int n;

  *p = '\0';
  if (value < 0) {
    serial_write((uint8_t)'-');
    n = (unsigned int)(-value);
  } else {
    n = (unsigned int)value;
  }

  do {
    p--;
    *p = (char)('0' + (n % 10));
    n /= 10;
  } while (n > 0);

  serial_print_str(p);
}

void serial_println_str(const char *value) {
  serial_print_str(value);
  serial_write((uint8_t)'\r');
  serial_write((uint8_t)'\n');
}

void serial_println_int(int value) {
  serial_print_int(value);
  serial_write((uint8_t)'\r');
  serial_write((uint8_t)'\n');
}

uint8_t shift_in(uint8_t data_pin, uint8_t clock_pin, uint8_t bit_order) {
  uint8_t value = 0;
  uint8_t i;

  for (i = 0; i < 8; i++) {
    digital_write(clock_pin, 1);
    if (bit_order == 0) {
      value |= (uint8_t)(digital_read(data_pin) << i);
    } else {
      value |= (uint8_t)(digital_read(data_pin) << (7 - i));
    }
    digital_write(clock_pin, 0);
  }

  return value;
}

void shift_out(uint8_t data_pin, uint8_t clock_pin, uint8_t bit_order, uint8_t value) {
  uint8_t i;
  uint8_t bit;

  for (i = 0; i < 8; i++) {
    if (bit_order == 0) {
      bit = (uint8_t)((value >> i) & 1);
    } else {
      bit = (uint8_t)((value >> (7 - i)) & 1);
    }

    digital_write(data_pin, bit);
    digital_write(clock_pin, 1);
    digital_write(clock_pin, 0);
  }
}

void interrupts(void) {
  sei();
}

void no_interrupts(void) {
  cli();
}

#define fflush(stream) ((void)0)

#endif
