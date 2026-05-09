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

static uint8_t rd_uno_admux_ref = (uint8_t)(1 << REFS0);

void analog_reference(uint8_t type) {
  /* Arduino constants: EXTERNAL=0 -> REFS=00, DEFAULT=1 -> REFS=01, INTERNAL=3 -> REFS=11. */
  rd_uno_admux_ref = (uint8_t)((type & 0x03) << REFS0);
}

int analog_read(uint8_t pin) {
  uint8_t channel = pin;

  if (pin >= 14 && pin <= 19) {
    channel = pin - 14;
  }

  if (channel > 5 || !rd_uno_valid_pin(pin)) {
    return -1;
  }

  ADMUX = (uint8_t)(rd_uno_admux_ref | channel);
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

uint32_t bit(uint8_t n) {
  return (uint32_t)1 << n;
}

uint8_t bit_read(uint32_t value, uint8_t n) {
  return (uint8_t)((value >> n) & (uint32_t)1);
}

uint32_t bit_set(uint32_t value, uint8_t n) {
  return value | ((uint32_t)1 << n);
}

uint32_t bit_clear(uint32_t value, uint8_t n) {
  return value & (uint32_t)~((uint32_t)1 << n);
}

uint32_t bit_write(uint32_t value, uint8_t n, uint8_t bitvalue) {
  return bitvalue ? bit_set(value, n) : bit_clear(value, n);
}

uint8_t high_byte(uint16_t value) {
  return (uint8_t)((value >> 8) & 0xFF);
}

uint8_t low_byte(uint16_t value) {
  return (uint8_t)(value & 0xFF);
}

int32_t map_value(int32_t value, int32_t from_low, int32_t from_high, int32_t to_low, int32_t to_high) {
  int32_t from_span = from_high - from_low;
  int32_t to_span = to_high - to_low;

  if (from_span == 0) {
    return to_low;
  }

  return (int32_t)(((int64_t)(value - from_low) * (int64_t)to_span) / (int64_t)from_span) + to_low;
}

int32_t constrain(int32_t value, int32_t low, int32_t high) {
  if (value < low) {
    return low;
  }
  if (value > high) {
    return high;
  }
  return value;
}

int32_t sq(int32_t value) {
  return value * value;
}

int is_alpha(int c) {
  return ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z')) ? 1 : 0;
}

int is_digit(int c) {
  return (c >= '0' && c <= '9') ? 1 : 0;
}

int is_alpha_numeric(int c) {
  return (is_alpha(c) || is_digit(c)) ? 1 : 0;
}

int is_space(int c) {
  return (c == ' ' || c == '\t' || c == '\n' || c == '\v' || c == '\f' || c == '\r') ? 1 : 0;
}

int is_whitespace(int c) {
  return (c == ' ' || c == '\t') ? 1 : 0;
}

int is_upper_case(int c) {
  return (c >= 'A' && c <= 'Z') ? 1 : 0;
}

int is_lower_case(int c) {
  return (c >= 'a' && c <= 'z') ? 1 : 0;
}

int is_ascii(int c) {
  return (c >= 0 && c <= 127) ? 1 : 0;
}

int is_control(int c) {
  return ((c >= 0 && c <= 31) || c == 127) ? 1 : 0;
}

int is_printable(int c) {
  return (c >= 32 && c <= 126) ? 1 : 0;
}

int is_punct(int c) {
  if (c >= '!' && c <= '/') return 1;
  if (c >= ':' && c <= '@') return 1;
  if (c >= '[' && c <= '`') return 1;
  if (c >= '{' && c <= '~') return 1;
  return 0;
}

int is_hexadecimal_digit(int c) {
  if (c >= '0' && c <= '9') return 1;
  if (c >= 'a' && c <= 'f') return 1;
  if (c >= 'A' && c <= 'F') return 1;
  return 0;
}

void random_seed(uint32_t seed) {
  if (seed == 0) {
    return;
  }
  srand((unsigned int)seed);
}

int32_t random_max(int32_t high) {
  if (high <= 0) {
    return 0;
  }
  return (int32_t)((unsigned long)rand() % (unsigned long)high);
}

int32_t random_range(int32_t low, int32_t high) {
  int32_t span;
  if (high <= low) {
    return low;
  }
  span = high - low;
  return low + (int32_t)((unsigned long)rand() % (unsigned long)span);
}

static volatile uint8_t rd_uno_tone_pin = 255;
static volatile uint8_t *rd_uno_tone_port_reg = NULL;
static volatile uint8_t rd_uno_tone_port_mask = 0;
static volatile int32_t rd_uno_tone_toggles_remaining = 0;

ISR(TIMER2_COMPA_vect) {
  if (rd_uno_tone_port_reg == NULL) {
    return;
  }

  *rd_uno_tone_port_reg ^= rd_uno_tone_port_mask;

  if (rd_uno_tone_toggles_remaining > 0) {
    rd_uno_tone_toggles_remaining--;
    if (rd_uno_tone_toggles_remaining == 0) {
      TCCR2A = 0;
      TCCR2B = 0;
      TIMSK2 = 0;
      *rd_uno_tone_port_reg &= (uint8_t)~rd_uno_tone_port_mask;
      rd_uno_tone_port_reg = NULL;
      rd_uno_tone_pin = 255;
    }
  }
}

static void rd_uno_tone_stop(void) {
  TCCR2A = 0;
  TCCR2B = 0;
  TIMSK2 &= (uint8_t)~(1 << OCIE2A);
  if (rd_uno_tone_port_reg) {
    *rd_uno_tone_port_reg &= (uint8_t)~rd_uno_tone_port_mask;
  }
  rd_uno_tone_port_reg = NULL;
  rd_uno_tone_pin = 255;
  rd_uno_tone_toggles_remaining = 0;
}

void tone_for(uint8_t pin, uint16_t frequency, uint32_t duration_ms) {
  uint8_t prescaler_bits;
  uint32_t prescaler_value;
  uint32_t ocr;

  if (frequency == 0) {
    rd_uno_tone_stop();
    return;
  }
  if (!rd_uno_valid_pin(pin)) {
    return;
  }

  pin_mode(pin, 1);

  static const uint16_t prescalers[7] = {1, 8, 32, 64, 128, 256, 1024};
  static const uint8_t prescaler_cs[7] = {1, 2, 3, 4, 5, 6, 7};
  uint8_t i;
  prescaler_bits = 0;
  prescaler_value = 0;
  for (i = 0; i < 7; i++) {
    uint32_t candidate = (F_CPU / (2UL * (uint32_t)prescalers[i] * (uint32_t)frequency));
    if (candidate > 0 && candidate <= 256) {
      prescaler_bits = prescaler_cs[i];
      prescaler_value = (uint32_t)prescalers[i];
      ocr = candidate - 1;
      break;
    }
  }
  if (prescaler_bits == 0) {
    return;
  }
  (void)prescaler_value;

  cli();
  rd_uno_tone_pin = pin;
  rd_uno_tone_port_reg = rd_uno_port(pin);
  rd_uno_tone_port_mask = (uint8_t)(1 << rd_uno_bit(pin));
  if (duration_ms > 0) {
    uint32_t toggles = (uint32_t)((uint32_t)2 * (uint32_t)frequency * duration_ms / 1000UL);
    if (toggles == 0) {
      toggles = 1;
    }
    rd_uno_tone_toggles_remaining = (int32_t)toggles;
  } else {
    rd_uno_tone_toggles_remaining = 0;
  }

  TCCR2A = (uint8_t)(1 << WGM21);
  TCCR2B = prescaler_bits;
  OCR2A = (uint8_t)ocr;
  TCNT2 = 0;
  TIMSK2 = (uint8_t)(1 << OCIE2A);
  sei();
}

void no_tone(uint8_t pin) {
  if (!rd_uno_valid_pin(pin)) {
    return;
  }
  cli();
  if (rd_uno_tone_pin == pin || rd_uno_tone_pin == 255) {
    rd_uno_tone_stop();
  }
  sei();
}

static volatile uint8_t rd_uno_int_flags[2] = {0, 0};

ISR(INT0_vect) {
  rd_uno_int_flags[0] = 1;
}

ISR(INT1_vect) {
  rd_uno_int_flags[1] = 1;
}

void attach_interrupt(uint8_t interrupt_num, uint8_t mode) {
  uint8_t shift;

  if (interrupt_num > 1) {
    return;
  }
  if (mode > 3) {
    return;
  }

  shift = (uint8_t)(interrupt_num * 2);

  cli();
  EICRA = (uint8_t)((EICRA & (uint8_t)~((uint8_t)0x03 << shift)) | (uint8_t)((mode & 0x03) << shift));
  EIFR = (uint8_t)(1 << interrupt_num);
  EIMSK |= (uint8_t)(1 << interrupt_num);
  rd_uno_int_flags[interrupt_num] = 0;
  sei();
}

void detach_interrupt(uint8_t interrupt_num) {
  if (interrupt_num > 1) {
    return;
  }
  cli();
  EIMSK &= (uint8_t)~(1 << interrupt_num);
  rd_uno_int_flags[interrupt_num] = 0;
  sei();
}

uint8_t interrupt_fired(uint8_t interrupt_num) {
  uint8_t fired;
  if (interrupt_num > 1) {
    return 0;
  }
  cli();
  fired = rd_uno_int_flags[interrupt_num];
  rd_uno_int_flags[interrupt_num] = 0;
  sei();
  return fired;
}

int8_t digital_pin_to_interrupt(uint8_t pin) {
  if (pin == 2) {
    return 0;
  }
  if (pin == 3) {
    return 1;
  }
  return -1;
}

#define fflush(stream) ((void)0)

#endif
