#ifndef SP_ARDUINO_RUNTIME_H
#define SP_ARDUINO_RUNTIME_H

#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <avr/eeprom.h>
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

/* Forward declarations so that intra-file callers see proper prototypes
 * regardless of definition order. */
void serial_write(uint8_t value);
void serial_print_str(const char *value);
void serial_print_int(int value);
int serial_read(void);
int serial_peek(void);
int digital_write(uint8_t pin, uint8_t value);
int digital_read(uint8_t pin);
int pin_mode(uint8_t pin, uint8_t mode);
uint32_t millis(void);
int32_t map_value(int32_t value, int32_t from_low, int32_t from_high, int32_t to_low, int32_t to_high);

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

static int16_t rd_uno_serial_peek_buf = -1;
static uint32_t rd_uno_serial_timeout_ms = 1000;

int serial_available(void) {
  if (rd_uno_serial_peek_buf != -1) {
    return 1;
  }
  return (UCSR0A & (uint8_t)(1 << RXC0)) ? 1 : 0;
}

int serial_read(void) {
  int v;

  if (rd_uno_serial_peek_buf != -1) {
    v = rd_uno_serial_peek_buf;
    rd_uno_serial_peek_buf = -1;
    return v;
  }

  if (!(UCSR0A & (uint8_t)(1 << RXC0))) {
    return -1;
  }
  return UDR0;
}

int serial_peek(void) {
  if (rd_uno_serial_peek_buf != -1) {
    return rd_uno_serial_peek_buf;
  }
  if (!(UCSR0A & (uint8_t)(1 << RXC0))) {
    return -1;
  }
  rd_uno_serial_peek_buf = (int16_t)UDR0;
  return rd_uno_serial_peek_buf;
}

void serial_end(void) {
  UCSR0B = 0;
  rd_uno_serial_peek_buf = -1;
}

void serial_flush(void) {
  /* Wait until the TX shift register is empty. */
  while (!(UCSR0A & (uint8_t)(1 << UDRE0))) {
  }
  while (!(UCSR0A & (uint8_t)(1 << TXC0))) {
  }
  /* Clear the TXC0 flag (write 1 to it). */
  UCSR0A |= (uint8_t)(1 << TXC0);
}

int serial_available_for_write(void) {
  return (UCSR0A & (uint8_t)(1 << UDRE0)) ? 1 : 0;
}

void serial_set_timeout(uint32_t timeout_ms) {
  rd_uno_serial_timeout_ms = timeout_ms;
}

uint32_t serial_get_timeout(void) {
  return rd_uno_serial_timeout_ms;
}

int serial_read_byte_timeout(void) {
  uint32_t start = millis();

  while (1) {
    int v = serial_read();
    if (v != -1) {
      return v;
    }
    if ((millis() - start) >= rd_uno_serial_timeout_ms) {
      return -1;
    }
  }
}

static int rd_uno_serial_peek_blocking(uint32_t deadline_ms) {
  while (1) {
    int v = serial_peek();
    if (v != -1) {
      return v;
    }
    if (millis() >= deadline_ms) {
      return -1;
    }
  }
}

int32_t serial_parse_int(void) {
  uint32_t deadline = millis() + rd_uno_serial_timeout_ms;
  int32_t value = 0;
  int negative = 0;
  int saw_digit = 0;
  int v;

  for (;;) {
    v = rd_uno_serial_peek_blocking(deadline);
    if (v == -1) {
      return 0;
    }
    if (v == '-' || (v >= '0' && v <= '9')) {
      break;
    }
    (void)serial_read();
  }

  if (v == '-') {
    negative = 1;
    (void)serial_read();
  }

  for (;;) {
    v = serial_peek();
    if (v == -1) {
      if (millis() >= deadline) {
        break;
      }
      continue;
    }
    if (v < '0' || v > '9') {
      break;
    }
    value = value * 10 + (v - '0');
    saw_digit = 1;
    (void)serial_read();
  }

  if (!saw_digit) {
    return 0;
  }
  return negative ? -value : value;
}

double serial_parse_float(void) {
  uint32_t deadline = millis() + rd_uno_serial_timeout_ms;
  double value = 0.0;
  double frac = 0.1;
  int negative = 0;
  int seen_dot = 0;
  int saw_digit = 0;
  int v;

  for (;;) {
    v = rd_uno_serial_peek_blocking(deadline);
    if (v == -1) {
      return 0.0;
    }
    if (v == '-' || v == '.' || (v >= '0' && v <= '9')) {
      break;
    }
    (void)serial_read();
  }

  if (v == '-') {
    negative = 1;
    (void)serial_read();
  }

  for (;;) {
    v = serial_peek();
    if (v == -1) {
      if (millis() >= deadline) {
        break;
      }
      continue;
    }
    if (v == '.') {
      if (seen_dot) {
        break;
      }
      seen_dot = 1;
      (void)serial_read();
      continue;
    }
    if (v < '0' || v > '9') {
      break;
    }
    if (seen_dot) {
      value += (v - '0') * frac;
      frac *= 0.1;
    } else {
      value = value * 10.0 + (v - '0');
    }
    saw_digit = 1;
    (void)serial_read();
  }

  if (!saw_digit) {
    return 0.0;
  }
  return negative ? -value : value;
}

static uint8_t rd_uno_serial_find_impl(const char *target, const char *terminator) {
  uint32_t deadline = millis() + rd_uno_serial_timeout_ms;
  size_t target_pos = 0;
  size_t term_pos = 0;
  size_t target_len = strlen(target);
  size_t term_len = terminator ? strlen(terminator) : 0;

  if (target_len == 0) {
    return 1;
  }

  while (millis() < deadline) {
    int v = serial_read();
    if (v == -1) {
      continue;
    }
    if ((char)v == target[target_pos]) {
      target_pos++;
      if (target_pos == target_len) {
        return 1;
      }
    } else {
      target_pos = ((char)v == target[0]) ? 1 : 0;
    }

    if (term_len > 0) {
      if ((char)v == terminator[term_pos]) {
        term_pos++;
        if (term_pos == term_len) {
          return 0;
        }
      } else {
        term_pos = ((char)v == terminator[0]) ? 1 : 0;
      }
    }
  }
  return 0;
}

uint8_t serial_find(const char *target) {
  return rd_uno_serial_find_impl(target, NULL);
}

uint8_t serial_find_until(const char *target, const char *terminator) {
  return rd_uno_serial_find_impl(target, terminator);
}

static void rd_uno_print_unsigned_base(uint32_t value, uint8_t base) {
  char buf[33];
  char *p = &buf[32];
  uint32_t v = value;

  *p = '\0';
  if (base < 2) {
    base = 10;
  }
  do {
    p--;
    uint8_t digit = (uint8_t)(v % base);
    *p = (char)((digit < 10) ? ('0' + digit) : ('A' + (digit - 10)));
    v /= base;
  } while (v > 0);

  serial_print_str(p);
}

void serial_print_hex(uint32_t value) {
  rd_uno_print_unsigned_base(value, 16);
}

void serial_print_bin(uint32_t value) {
  rd_uno_print_unsigned_base(value, 2);
}

void serial_print_oct(uint32_t value) {
  rd_uno_print_unsigned_base(value, 8);
}

void serial_println_hex(uint32_t value) {
  rd_uno_print_unsigned_base(value, 16);
  serial_write((uint8_t)'\r');
  serial_write((uint8_t)'\n');
}

void serial_println_bin(uint32_t value) {
  rd_uno_print_unsigned_base(value, 2);
  serial_write((uint8_t)'\r');
  serial_write((uint8_t)'\n');
}

void serial_println_oct(uint32_t value) {
  rd_uno_print_unsigned_base(value, 8);
  serial_write((uint8_t)'\r');
  serial_write((uint8_t)'\n');
}

static void rd_uno_print_float(double value, uint8_t decimals) {
  if (value < 0.0) {
    serial_write((uint8_t)'-');
    value = -value;
  }

  /* Round to the requested number of decimals. */
  double rounding = 0.5;
  uint8_t i;
  for (i = 0; i < decimals; i++) {
    rounding /= 10.0;
  }
  value += rounding;

  uint32_t int_part = (uint32_t)value;
  double remainder = value - (double)int_part;
  serial_print_int((int)int_part);

  if (decimals > 0) {
    serial_write((uint8_t)'.');
    while (decimals > 0) {
      remainder *= 10.0;
      uint8_t digit = (uint8_t)remainder;
      serial_write((uint8_t)('0' + digit));
      remainder -= (double)digit;
      decimals--;
    }
  }
}

void serial_print_float(double value, uint8_t decimals) {
  rd_uno_print_float(value, decimals);
}

void serial_println_float(double value, uint8_t decimals) {
  rd_uno_print_float(value, decimals);
  serial_write((uint8_t)'\r');
  serial_write((uint8_t)'\n');
}

static void serial_print_float_default(double value) {
  rd_uno_print_float(value, 2);
}

static void serial_println_float_default(double value) {
  rd_uno_print_float(value, 2);
  serial_write((uint8_t)'\r');
  serial_write((uint8_t)'\n');
}

#ifndef E2END
#define E2END 1023
#endif

uint16_t eeprom_length(void) {
  return (uint16_t)(E2END + 1);
}

uint8_t eeprom_read(uint16_t addr) {
  if (addr > E2END) {
    return 0;
  }
  return eeprom_read_byte((const uint8_t *)(uintptr_t)addr);
}

void eeprom_write(uint16_t addr, uint8_t value) {
  if (addr > E2END) {
    return;
  }
  eeprom_write_byte((uint8_t *)(uintptr_t)addr, value);
}

void eeprom_update(uint16_t addr, uint8_t value) {
  if (addr > E2END) {
    return;
  }
  eeprom_update_byte((uint8_t *)(uintptr_t)addr, value);
}

int32_t eeprom_read_int(uint16_t addr) {
  uint32_t v;
  if ((uint32_t)addr + 4 > (uint32_t)E2END + 1) {
    return 0;
  }
  v = eeprom_read_dword((const uint32_t *)(uintptr_t)addr);
  return (int32_t)v;
}

void eeprom_write_int(uint16_t addr, int32_t value) {
  if ((uint32_t)addr + 4 > (uint32_t)E2END + 1) {
    return;
  }
  eeprom_update_dword((uint32_t *)(uintptr_t)addr, (uint32_t)value);
}

#define RD_SPI_MOSI_PIN 11
#define RD_SPI_MISO_PIN 12
#define RD_SPI_SCK_PIN  13
#define RD_SPI_SS_PIN   10

void spi_begin(void) {
  /* MOSI, SCK, SS as outputs; MISO as input. */
  pin_mode(RD_SPI_MOSI_PIN, 1);
  pin_mode(RD_SPI_SCK_PIN, 1);
  pin_mode(RD_SPI_SS_PIN, 1);
  pin_mode(RD_SPI_MISO_PIN, 0);
  digital_write(RD_SPI_SS_PIN, 1);

  /* Enable SPI, master, default to MSB first, mode 0, fosc/4 (~4 MHz). */
  SPCR = (uint8_t)((1 << SPE) | (1 << MSTR));
  SPSR = 0;
}

void spi_end(void) {
  SPCR &= (uint8_t)~(1 << SPE);
}

void spi_set_bit_order(uint8_t order) {
  if (order) {
    SPCR |= (uint8_t)(1 << DORD);
  } else {
    SPCR &= (uint8_t)~(1 << DORD);
  }
}

void spi_set_data_mode(uint8_t mode) {
  SPCR = (uint8_t)((SPCR & (uint8_t)~((1 << CPOL) | (1 << CPHA))) | (uint8_t)((mode & 0x03) << CPHA));
}

void spi_set_clock_divider(uint8_t divider) {
  /*
   * divider mapping (Arduino constants):
   *   SPI_CLOCK_DIV4   = 0  -> SPR1=0, SPR0=0, SPI2X=0
   *   SPI_CLOCK_DIV16  = 1  -> SPR1=0, SPR0=1, SPI2X=0
   *   SPI_CLOCK_DIV64  = 2  -> SPR1=1, SPR0=0, SPI2X=0
   *   SPI_CLOCK_DIV128 = 3  -> SPR1=1, SPR0=1, SPI2X=0
   *   SPI_CLOCK_DIV2   = 4  -> SPR1=0, SPR0=0, SPI2X=1
   *   SPI_CLOCK_DIV8   = 5  -> SPR1=0, SPR0=1, SPI2X=1
   *   SPI_CLOCK_DIV32  = 6  -> SPR1=1, SPR0=0, SPI2X=1
   */
  uint8_t spr = (uint8_t)(divider & 0x03);
  uint8_t spi2x = (divider >= 4) ? 1 : 0;

  SPCR = (uint8_t)((SPCR & (uint8_t)~((1 << SPR1) | (1 << SPR0))) | spr);
  if (spi2x) {
    SPSR |= (uint8_t)(1 << SPI2X);
  } else {
    SPSR &= (uint8_t)~(1 << SPI2X);
  }
}

uint8_t spi_transfer(uint8_t value) {
  SPDR = value;
  /* The wait must be a single read to satisfy the SPIF clear semantics. */
  asm volatile("nop");
  while (!(SPSR & (uint8_t)(1 << SPIF))) {
  }
  return SPDR;
}

uint16_t spi_transfer16(uint16_t value) {
  uint8_t hi;
  uint8_t lo;

  if (SPCR & (uint8_t)(1 << DORD)) {
    /* LSB first: low byte first. */
    lo = spi_transfer((uint8_t)(value & 0xFF));
    hi = spi_transfer((uint8_t)(value >> 8));
  } else {
    hi = spi_transfer((uint8_t)(value >> 8));
    lo = spi_transfer((uint8_t)(value & 0xFF));
  }

  return (uint16_t)(((uint16_t)hi << 8) | lo);
}

#define RD_WIRE_BUF_LEN 32

static uint8_t rd_wire_tx_buf[RD_WIRE_BUF_LEN];
static uint8_t rd_wire_tx_len = 0;
static uint8_t rd_wire_tx_addr = 0;

static uint8_t rd_wire_rx_buf[RD_WIRE_BUF_LEN];
static uint8_t rd_wire_rx_len = 0;
static uint8_t rd_wire_rx_pos = 0;

static int rd_wire_wait_twint(void) {
  uint16_t spin = 0;
  while (!(TWCR & (uint8_t)(1 << TWINT))) {
    spin++;
    if (spin > 30000) {
      return 0;
    }
  }
  return 1;
}

static uint8_t rd_wire_status(void) {
  return (uint8_t)(TWSR & 0xF8);
}

static int rd_wire_start(void) {
  TWCR = (uint8_t)((1 << TWINT) | (1 << TWSTA) | (1 << TWEN));
  return rd_wire_wait_twint();
}

static void rd_wire_stop(void) {
  TWCR = (uint8_t)((1 << TWINT) | (1 << TWSTO) | (1 << TWEN));
  /* Wait for STOP to clear (TWSTO goes low). */
  while (TWCR & (uint8_t)(1 << TWSTO)) {
  }
}

static int rd_wire_send_byte(uint8_t byte) {
  TWDR = byte;
  TWCR = (uint8_t)((1 << TWINT) | (1 << TWEN));
  return rd_wire_wait_twint();
}

static int rd_wire_recv_byte(uint8_t ack) {
  if (ack) {
    TWCR = (uint8_t)((1 << TWINT) | (1 << TWEN) | (1 << TWEA));
  } else {
    TWCR = (uint8_t)((1 << TWINT) | (1 << TWEN));
  }
  return rd_wire_wait_twint();
}

void wire_begin(void) {
  TWSR = 0;
  TWBR = (uint8_t)(((F_CPU / 100000UL) - 16UL) / 2UL);
  TWCR = (uint8_t)(1 << TWEN);
}

void wire_end(void) {
  TWCR = 0;
}

void wire_set_clock(uint32_t speed_hz) {
  if (speed_hz == 0) {
    return;
  }
  TWSR = 0;
  TWBR = (uint8_t)(((F_CPU / speed_hz) - 16UL) / 2UL);
}

void wire_begin_transmission(uint8_t addr) {
  rd_wire_tx_addr = addr;
  rd_wire_tx_len = 0;
}

uint8_t wire_write(uint8_t byte) {
  if (rd_wire_tx_len >= RD_WIRE_BUF_LEN) {
    return 0;
  }
  rd_wire_tx_buf[rd_wire_tx_len++] = byte;
  return 1;
}

uint8_t wire_end_transmission(uint8_t stop) {
  uint8_t i;

  if (!rd_wire_start()) {
    return 4;
  }
  if (rd_wire_status() != 0x08 && rd_wire_status() != 0x10) {
    rd_wire_stop();
    return 4;
  }

  if (!rd_wire_send_byte((uint8_t)((rd_wire_tx_addr << 1) & 0xFE))) {
    rd_wire_stop();
    return 4;
  }
  if (rd_wire_status() != 0x18) {
    /* SLA+W not acknowledged. */
    rd_wire_stop();
    return 2;
  }

  for (i = 0; i < rd_wire_tx_len; i++) {
    if (!rd_wire_send_byte(rd_wire_tx_buf[i])) {
      rd_wire_stop();
      return 4;
    }
    if (rd_wire_status() != 0x28) {
      /* data NACK */
      rd_wire_stop();
      return 3;
    }
  }

  if (stop) {
    rd_wire_stop();
  }

  rd_wire_tx_len = 0;
  return 0;
}

uint8_t wire_request_from(uint8_t addr, uint8_t count, uint8_t stop) {
  uint8_t i;
  uint8_t got = 0;

  if (count > RD_WIRE_BUF_LEN) {
    count = RD_WIRE_BUF_LEN;
  }
  rd_wire_rx_len = 0;
  rd_wire_rx_pos = 0;

  if (count == 0) {
    return 0;
  }

  if (!rd_wire_start()) {
    return 0;
  }
  if (rd_wire_status() != 0x08 && rd_wire_status() != 0x10) {
    rd_wire_stop();
    return 0;
  }

  if (!rd_wire_send_byte((uint8_t)(((addr << 1) | 0x01) & 0xFF))) {
    rd_wire_stop();
    return 0;
  }
  if (rd_wire_status() != 0x40) {
    /* SLA+R not acknowledged. */
    rd_wire_stop();
    return 0;
  }

  for (i = 0; i < count; i++) {
    uint8_t is_last = (uint8_t)(i == (uint8_t)(count - 1));
    if (!rd_wire_recv_byte((uint8_t)(is_last ? 0 : 1))) {
      break;
    }
    rd_wire_rx_buf[got++] = TWDR;
  }

  if (stop) {
    rd_wire_stop();
  }

  rd_wire_rx_len = got;
  return got;
}

int wire_available(void) {
  return (int)(rd_wire_rx_len - rd_wire_rx_pos);
}

int wire_read(void) {
  if (rd_wire_rx_pos >= rd_wire_rx_len) {
    return -1;
  }
  return rd_wire_rx_buf[rd_wire_rx_pos++];
}

#define RD_SERVO_MIN_US 544
#define RD_SERVO_MAX_US 2400

static int8_t rd_servo_pin = -1;
static uint16_t rd_servo_pulse_us = 1500;
static uint8_t rd_servo_phase = 0;

ISR(TIMER1_COMPA_vect) {
  if (rd_servo_pin < 0) {
    return;
  }
  if (rd_servo_phase == 1) {
    digital_write((uint8_t)rd_servo_pin, 0);
    OCR1A = (uint16_t)((uint32_t)(20000UL - rd_servo_pulse_us) * 2UL);
    rd_servo_phase = 0;
  } else {
    digital_write((uint8_t)rd_servo_pin, 1);
    OCR1A = (uint16_t)((uint32_t)rd_servo_pulse_us * 2UL);
    rd_servo_phase = 1;
  }
  TCNT1 = 0;
}

void servo_attach(uint8_t pin) {
  if (!rd_uno_valid_pin(pin)) {
    return;
  }
  pin_mode(pin, 1);
  cli();
  rd_servo_pin = (int8_t)pin;
  rd_servo_pulse_us = 1500;
  rd_servo_phase = 0;
  TCCR1A = 0;
  TCCR1B = (uint8_t)((1 << WGM12) | (1 << CS11));
  OCR1A = (uint16_t)(rd_servo_pulse_us * 2UL);
  TCNT1 = 0;
  TIFR1 = (uint8_t)(1 << OCF1A);
  TIMSK1 |= (uint8_t)(1 << OCIE1A);
  sei();
}

void servo_detach(void) {
  cli();
  TIMSK1 &= (uint8_t)~(1 << OCIE1A);
  if (rd_servo_pin >= 0) {
    digital_write((uint8_t)rd_servo_pin, 0);
  }
  rd_servo_pin = -1;
  sei();
}

void servo_write_microseconds(uint16_t us) {
  if (us < RD_SERVO_MIN_US) {
    us = RD_SERVO_MIN_US;
  }
  if (us > RD_SERVO_MAX_US) {
    us = RD_SERVO_MAX_US;
  }
  cli();
  rd_servo_pulse_us = us;
  sei();
}

void servo_write(uint8_t angle) {
  if (angle > 180) {
    angle = 180;
  }
  servo_write_microseconds((uint16_t)map_value((int32_t)angle, 0, 180, RD_SERVO_MIN_US, RD_SERVO_MAX_US));
}

uint16_t servo_read_microseconds(void) {
  return rd_servo_pulse_us;
}

uint8_t servo_read(void) {
  return (uint8_t)map_value((int32_t)rd_servo_pulse_us, RD_SERVO_MIN_US, RD_SERVO_MAX_US, 0, 180);
}

uint8_t servo_attached(void) {
  return (rd_servo_pin >= 0) ? 1 : 0;
}

void arduino_yield(void) {
  /* Cooperative-multitasking hook. No-op on UNO since there's no
   * scheduler — defined so portable sketches that call it for ESP32
   * etc. still compile here. */
}

/* WS2812 / NeoPixel driver.
 *
 * Buffer is sized for up to RD_NEOPIXEL_MAX pixels (3 bytes each, GRB
 * order). The bit-bang in neopixel_show is hand-tuned for 16 MHz AVR;
 * each iteration of the inner loop hits T1H ~= 0.8 us, T0H ~= 0.4 us,
 * full bit period ~= 1.25 us. Interrupts are disabled across the
 * frame so timer ISRs don't stretch the high pulse and turn 0 bits
 * into 1 bits.
 */
#ifndef RD_NEOPIXEL_MAX
#define RD_NEOPIXEL_MAX 64
#endif

static uint8_t rd_neopixel_buf[RD_NEOPIXEL_MAX * 3];
static uint8_t rd_neopixel_pin = 255;
static uint16_t rd_neopixel_count = 0;

void neopixel_begin(uint8_t pin, uint16_t count) {
  uint16_t i;

  if (!rd_uno_valid_pin(pin)) {
    return;
  }
  if (count > RD_NEOPIXEL_MAX) {
    count = RD_NEOPIXEL_MAX;
  }

  pin_mode(pin, 1);
  digital_write(pin, 0);
  rd_neopixel_pin = pin;
  rd_neopixel_count = count;

  for (i = 0; i < (uint16_t)RD_NEOPIXEL_MAX * 3; i++) {
    rd_neopixel_buf[i] = 0;
  }
}

void neopixel_set_pixel(uint16_t index, uint8_t r, uint8_t g, uint8_t b) {
  if (index >= rd_neopixel_count) {
    return;
  }
  /* WS2812 wants GRB order on the wire. */
  rd_neopixel_buf[index * 3 + 0] = g;
  rd_neopixel_buf[index * 3 + 1] = r;
  rd_neopixel_buf[index * 3 + 2] = b;
}

void neopixel_clear(void) {
  uint16_t i;
  for (i = 0; i < rd_neopixel_count * 3; i++) {
    rd_neopixel_buf[i] = 0;
  }
}

void neopixel_show(void) {
  volatile uint8_t *port;
  uint8_t mask;
  uint8_t hi;
  uint8_t lo;
  uint8_t b;
  uint8_t bit;
  uint8_t *p;
  uint16_t bytes;

  if (rd_neopixel_count == 0 || rd_neopixel_pin == 255) {
    return;
  }

  port = rd_uno_port(rd_neopixel_pin);
  mask = (uint8_t)(1 << rd_uno_bit(rd_neopixel_pin));
  hi = (uint8_t)(*port | mask);
  lo = (uint8_t)(*port & (uint8_t)~mask);
  p = rd_neopixel_buf;
  bytes = rd_neopixel_count * 3;

  cli();
  while (bytes > 0) {
    b = *p++;
    bytes--;

    /* MSB-first bit-bang. The NOP counts target ~13 cycles high for a
     * 1 bit and ~6 cycles high for a 0 bit at 16 MHz. WS2812 tolerates
     * +/- 150 ns on each phase. */
    bit = 8;
    while (bit > 0) {
      *port = hi;
      if (b & 0x80) {
        __builtin_avr_delay_cycles(8);
        *port = lo;
        __builtin_avr_delay_cycles(2);
      } else {
        __builtin_avr_delay_cycles(2);
        *port = lo;
        __builtin_avr_delay_cycles(8);
      }
      b <<= 1;
      bit--;
    }
  }
  sei();

  /* WS2812 reset: at least 50 us low. The loop overhead already gave
   * us some margin, but pad just in case. */
  _delay_us(50);
}

/* DHT11 / DHT22 temperature + humidity driver.
 *
 * Single-wire timing protocol:
 *   1. MCU pulls line low for >=18 ms (DHT11) or >=1 ms (DHT22)
 *   2. MCU releases, line floats high via pull-up
 *   3. Sensor responds with ~80us low + ~80us high
 *   4. Sensor sends 40 bits: humid_high, humid_low, temp_high, temp_low, checksum
 *   5. Each bit: ~50us low then high for 26-28us (0) or 70us (1)
 *
 * dht_read returns 0 on success, negative on error. Successful reads
 * stash temperature/humidity * 10 so Ruby callers can format with one
 * decimal place. The sensor must be polled at most every ~2 seconds.
 */
static int16_t rd_dht_temp_x10 = 0;
static int16_t rd_dht_humid_x10 = 0;

static int rd_dht_wait_for(uint8_t pin, uint8_t state, uint32_t max_us) {
  uint32_t start = micros();
  while (digital_read(pin) != state) {
    if ((micros() - start) > max_us) {
      return -1;
    }
  }
  return (int)(micros() - start);
}

int8_t dht_read(uint8_t pin, uint8_t type) {
  uint8_t data[5];
  uint32_t bit_start;
  uint32_t bit_high;
  uint8_t i;
  uint8_t sum;

  if (!rd_uno_valid_pin(pin)) {
    return -1;
  }

  data[0] = 0;
  data[1] = 0;
  data[2] = 0;
  data[3] = 0;
  data[4] = 0;

  /* MCU start pulse. */
  pin_mode(pin, 1);
  digital_write(pin, 0);
  if (type == 11) {
    delay_ms(18);
  } else {
    delay_us(1100);
  }
  digital_write(pin, 1);
  pin_mode(pin, 0);
  delay_us(40);

  /* Sensor response: ~80us low, ~80us high, then first bit starts. */
  if (rd_dht_wait_for(pin, 0, 200) < 0) return -2;
  if (rd_dht_wait_for(pin, 1, 200) < 0) return -3;
  if (rd_dht_wait_for(pin, 0, 200) < 0) return -4;

  for (i = 0; i < 40; i++) {
    /* Wait for the bit's high pulse to start. */
    if (rd_dht_wait_for(pin, 1, 200) < 0) return -5;

    bit_start = micros();
    while (digital_read(pin) == 1) {
      if ((micros() - bit_start) > 200) return -6;
    }
    bit_high = micros() - bit_start;

    data[i >> 3] <<= 1;
    if (bit_high > 40) {
      data[i >> 3] |= 1;
    }
  }

  sum = (uint8_t)((data[0] + data[1] + data[2] + data[3]) & 0xFF);
  if (sum != data[4]) {
    return -7;
  }

  if (type == 11) {
    rd_dht_humid_x10 = (int16_t)data[0] * 10;
    rd_dht_temp_x10 = (int16_t)data[2] * 10;
  } else {
    int16_t humid = (int16_t)(((uint16_t)data[0] << 8) | data[1]);
    int16_t temp = (int16_t)(((uint16_t)(data[2] & 0x7F) << 8) | data[3]);
    if (data[2] & 0x80) {
      temp = (int16_t)-temp;
    }
    rd_dht_humid_x10 = humid;
    rd_dht_temp_x10 = temp;
  }

  return 0;
}

int16_t dht_temperature_x10(void) {
  return rd_dht_temp_x10;
}

int16_t dht_humidity_x10(void) {
  return rd_dht_humid_x10;
}

/* Dallas 1-Wire bit-bang. The bus is open-drain — the host pulls low
 * by switching to OUTPUT, releases by switching back to INPUT and
 * letting the external pull-up restore the line.
 *
 * Timing (microseconds):
 *   Reset:   pull low 480, release, sample after 70 (presence pulse if 0)
 *   Write 1: pull low 6,  release, total slot 70
 *   Write 0: pull low 60, release, total slot 70
 *   Read:    pull low 6,  release, sample after 9, total slot 70
 */
static void rd_onewire_low(uint8_t pin) {
  pin_mode(pin, 1);
  digital_write(pin, 0);
}

static void rd_onewire_release(uint8_t pin) {
  pin_mode(pin, 0);
}

uint8_t onewire_reset(uint8_t pin) {
  uint8_t presence;
  uint8_t sreg = SREG;

  cli();
  rd_onewire_low(pin);
  _delay_us(480);
  rd_onewire_release(pin);
  _delay_us(70);
  presence = (digital_read(pin) == 0) ? 1 : 0;
  SREG = sreg;
  _delay_us(410);
  return presence;
}

static void rd_onewire_write_bit(uint8_t pin, uint8_t bit) {
  uint8_t sreg = SREG;
  cli();
  rd_onewire_low(pin);
  if (bit) {
    _delay_us(6);
    rd_onewire_release(pin);
    _delay_us(64);
  } else {
    _delay_us(60);
    rd_onewire_release(pin);
    _delay_us(10);
  }
  SREG = sreg;
}

static uint8_t rd_onewire_read_bit(uint8_t pin) {
  uint8_t bit;
  uint8_t sreg = SREG;
  cli();
  rd_onewire_low(pin);
  _delay_us(6);
  rd_onewire_release(pin);
  _delay_us(9);
  bit = (digital_read(pin) == 1) ? 1 : 0;
  SREG = sreg;
  _delay_us(55);
  return bit;
}

void onewire_write_byte(uint8_t pin, uint8_t value) {
  uint8_t i;
  for (i = 0; i < 8; i++) {
    rd_onewire_write_bit(pin, (uint8_t)(value & 0x01));
    value >>= 1;
  }
}

uint8_t onewire_read_byte(uint8_t pin) {
  uint8_t value = 0;
  uint8_t i;
  for (i = 0; i < 8; i++) {
    if (rd_onewire_read_bit(pin)) {
      value |= (uint8_t)(1 << i);
    }
  }
  return value;
}

/* DS18B20 helpers. Single-device-on-bus convenience: SKIP ROM (0xCC)
 * skips the address-match step; CONVERT T (0x44) starts the
 * conversion; READ SCRATCHPAD (0xBE) returns the 9-byte scratchpad.
 *
 * Reading is non-blocking once the conversion completes — caller
 * should sleep ~750 ms (12-bit resolution) after request_temperature
 * before calling read_temperature_x10.
 */
uint8_t ds18b20_request_temperature(uint8_t pin) {
  if (!onewire_reset(pin)) {
    return 0;
  }
  onewire_write_byte(pin, 0xCC);
  onewire_write_byte(pin, 0x44);
  return 1;
}

int16_t ds18b20_read_temperature_x10(uint8_t pin) {
  uint8_t raw_lo;
  uint8_t raw_hi;
  int16_t raw;

  if (!onewire_reset(pin)) {
    return 0;
  }
  onewire_write_byte(pin, 0xCC);
  onewire_write_byte(pin, 0xBE);
  raw_lo = onewire_read_byte(pin);
  raw_hi = onewire_read_byte(pin);

  raw = (int16_t)(((uint16_t)raw_hi << 8) | raw_lo);
  /* DS18B20 reports temperature * 16 (1/16 °C resolution).
   * Convert to tenths-of-degree: temp_x10 = raw * 10 / 16 = raw * 5 / 8. */
  return (int16_t)(((int32_t)raw * 5) / 8);
}

/* HD44780 16x2 character LCD in 4-bit mode.
 *
 * Wiring assumption: R/W tied to ground (write-only). The host drives
 * RS, E, and the upper-nibble data lines D4..D7.
 */
static uint8_t rd_lcd_rs = 255;
static uint8_t rd_lcd_en = 255;
static uint8_t rd_lcd_d4 = 255;
static uint8_t rd_lcd_d5 = 255;
static uint8_t rd_lcd_d6 = 255;
static uint8_t rd_lcd_d7 = 255;
static uint8_t rd_lcd_cols = 16;
static uint8_t rd_lcd_rows = 2;

static void rd_lcd_pulse(void) {
  digital_write(rd_lcd_en, 1);
  _delay_us(1);
  digital_write(rd_lcd_en, 0);
  _delay_us(50);
}

static void rd_lcd_write_nibble(uint8_t nibble) {
  digital_write(rd_lcd_d4, (uint8_t)(nibble & 0x01));
  digital_write(rd_lcd_d5, (uint8_t)((nibble >> 1) & 0x01));
  digital_write(rd_lcd_d6, (uint8_t)((nibble >> 2) & 0x01));
  digital_write(rd_lcd_d7, (uint8_t)((nibble >> 3) & 0x01));
  rd_lcd_pulse();
}

static void rd_lcd_send(uint8_t value, uint8_t mode) {
  digital_write(rd_lcd_rs, mode);
  rd_lcd_write_nibble((uint8_t)(value >> 4));
  rd_lcd_write_nibble((uint8_t)(value & 0x0F));
}

static void rd_lcd_command(uint8_t cmd) {
  rd_lcd_send(cmd, 0);
}

static void rd_lcd_data(uint8_t value) {
  rd_lcd_send(value, 1);
}

void lcd_begin(uint8_t rs, uint8_t en, uint8_t d4, uint8_t d5, uint8_t d6, uint8_t d7, uint8_t cols, uint8_t rows) {
  rd_lcd_rs = rs;
  rd_lcd_en = en;
  rd_lcd_d4 = d4;
  rd_lcd_d5 = d5;
  rd_lcd_d6 = d6;
  rd_lcd_d7 = d7;
  rd_lcd_cols = cols;
  rd_lcd_rows = rows;

  pin_mode(rs, 1);
  pin_mode(en, 1);
  pin_mode(d4, 1);
  pin_mode(d5, 1);
  pin_mode(d6, 1);
  pin_mode(d7, 1);
  digital_write(rs, 0);
  digital_write(en, 0);

  /* Power-up wait. */
  delay_ms(50);

  /* HD44780 datasheet boot sequence to enter 4-bit mode. */
  rd_lcd_write_nibble(0x03);
  delay_ms(5);
  rd_lcd_write_nibble(0x03);
  _delay_us(160);
  rd_lcd_write_nibble(0x03);
  _delay_us(160);
  rd_lcd_write_nibble(0x02);

  /* 4-bit, 2-line, 5x8 dots. */
  rd_lcd_command((uint8_t)(rows > 1 ? 0x28 : 0x20));
  /* Display on, cursor off, blink off. */
  rd_lcd_command(0x0C);
  /* Entry mode: increment, no shift. */
  rd_lcd_command(0x06);
  /* Clear. */
  rd_lcd_command(0x01);
  delay_ms(2);
}

void lcd_clear(void) {
  rd_lcd_command(0x01);
  delay_ms(2);
}

void lcd_home(void) {
  rd_lcd_command(0x02);
  delay_ms(2);
}

void lcd_set_cursor(uint8_t col, uint8_t row) {
  static const uint8_t row_offsets[4] = {0x00, 0x40, 0x14, 0x54};
  if (row >= rd_lcd_rows) {
    row = (uint8_t)(rd_lcd_rows - 1);
  }
  rd_lcd_command((uint8_t)(0x80 | (col + row_offsets[row])));
}

void lcd_write_char(uint8_t ch) {
  rd_lcd_data(ch);
}

void lcd_print_str(const char *s) {
  while (*s) {
    rd_lcd_data((uint8_t)*s);
    s++;
  }
}

void lcd_print_int(int32_t value) {
  char buf[12];
  char *p = &buf[11];
  uint32_t n;

  *p = '\0';
  if (value < 0) {
    rd_lcd_data((uint8_t)'-');
    n = (uint32_t)(-value);
  } else {
    n = (uint32_t)value;
  }

  do {
    p--;
    *p = (char)('0' + (n % 10));
    n /= 10;
  } while (n > 0);

  lcd_print_str(p);
}

/* 4-wire stepper motor. Mirrors the bundled Arduino Stepper library:
 * tracks current step number, step delay (derived from RPM), and the
 * four-wire coil sequence. Half/four-step driver chips (e.g.
 * ULN2003 with a 28BYJ-48) work the same way. */
static uint16_t rd_stepper_steps_per_rev = 200;
static uint16_t rd_stepper_step_delay_us = 60000;
static uint8_t rd_stepper_pins[4] = {255, 255, 255, 255};
static int32_t rd_stepper_step_number = 0;

static void rd_stepper_drive(int32_t step) {
  uint8_t phase = (uint8_t)(((step % 4) + 4) % 4);
  /* Standard full-step sequence: A B Aa Bb */
  static const uint8_t pattern[4][4] = {
    {1, 0, 1, 0},
    {0, 1, 1, 0},
    {0, 1, 0, 1},
    {1, 0, 0, 1}
  };
  uint8_t i;
  for (i = 0; i < 4; i++) {
    digital_write(rd_stepper_pins[i], pattern[phase][i]);
  }
}

void stepper_begin(uint16_t steps_per_revolution, uint8_t p1, uint8_t p2, uint8_t p3, uint8_t p4) {
  rd_stepper_steps_per_rev = steps_per_revolution > 0 ? steps_per_revolution : 200;
  rd_stepper_pins[0] = p1;
  rd_stepper_pins[1] = p2;
  rd_stepper_pins[2] = p3;
  rd_stepper_pins[3] = p4;
  pin_mode(p1, 1);
  pin_mode(p2, 1);
  pin_mode(p3, 1);
  pin_mode(p4, 1);
  digital_write(p1, 0);
  digital_write(p2, 0);
  digital_write(p3, 0);
  digital_write(p4, 0);
  rd_stepper_step_number = 0;
  rd_stepper_step_delay_us = 60000;
}

void stepper_set_speed(uint16_t rpm) {
  if (rpm == 0) {
    rd_stepper_step_delay_us = 60000;
    return;
  }
  rd_stepper_step_delay_us = (uint16_t)(60UL * 1000UL * 1000UL / (uint32_t)rd_stepper_steps_per_rev / (uint32_t)rpm);
}

void stepper_step(int16_t steps) {
  int8_t direction = (steps < 0) ? -1 : 1;
  uint16_t remaining = (uint16_t)((steps < 0) ? -steps : steps);

  while (remaining > 0) {
    rd_stepper_step_number += direction;
    rd_stepper_drive(rd_stepper_step_number);

    /* delay_us only takes uint32, but we keep the value <= ~30ms to
     * stay inside the 16-bit field for fast iteration. */
    delay_us((uint32_t)rd_stepper_step_delay_us);
    remaining--;
  }
}

/* Bit-banged software serial.
 *
 * Half-duplex: write blocks for the duration of the byte, read polls
 * the start bit and samples on the bit centers. The bit period is
 * derived from the baud rate. Common baud rates up to 38400 work
 * reliably on a 16 MHz UNO; higher rates suffer from interrupt jitter.
 */
static uint8_t rd_soft_rx_pin = 255;
static uint8_t rd_soft_tx_pin = 255;
static uint16_t rd_soft_bit_period_us = 833; /* 1200 baud default */

void soft_serial_begin(uint8_t rx, uint8_t tx, uint32_t baud) {
  rd_soft_rx_pin = rx;
  rd_soft_tx_pin = tx;
  if (baud == 0) baud = 9600;
  rd_soft_bit_period_us = (uint16_t)(1000000UL / baud);

  if (tx != 255) {
    pin_mode(tx, 1);
    digital_write(tx, 1); /* idle high */
  }
  if (rx != 255) {
    pin_mode(rx, 0);
  }
}

void soft_serial_write(uint8_t byte) {
  uint8_t i;
  uint8_t sreg;

  if (rd_soft_tx_pin == 255) {
    return;
  }

  sreg = SREG;
  cli();
  /* Start bit: low. */
  digital_write(rd_soft_tx_pin, 0);
  delay_us((uint32_t)rd_soft_bit_period_us);
  /* 8 data bits, LSB first. */
  for (i = 0; i < 8; i++) {
    digital_write(rd_soft_tx_pin, (uint8_t)(byte & 0x01));
    byte >>= 1;
    delay_us((uint32_t)rd_soft_bit_period_us);
  }
  /* Stop bit: high. */
  digital_write(rd_soft_tx_pin, 1);
  delay_us((uint32_t)rd_soft_bit_period_us);
  SREG = sreg;
}

void soft_serial_print_str(const char *s) {
  while (*s) {
    soft_serial_write((uint8_t)*s);
    s++;
  }
}

int soft_serial_read(void) {
  uint8_t value = 0;
  uint8_t i;
  uint8_t sreg;

  if (rd_soft_rx_pin == 255) {
    return -1;
  }
  if (digital_read(rd_soft_rx_pin) == 1) {
    return -1; /* line is idle, no start bit waiting */
  }

  sreg = SREG;
  cli();
  /* Skip the start bit and align to bit centers. */
  delay_us((uint32_t)(rd_soft_bit_period_us + (rd_soft_bit_period_us >> 1)));
  for (i = 0; i < 8; i++) {
    if (digital_read(rd_soft_rx_pin)) {
      value |= (uint8_t)(1 << i);
    }
    delay_us((uint32_t)rd_soft_bit_period_us);
  }
  SREG = sreg;
  return (int)value;
}

/* IR remote receiver — NEC protocol decode.
 *
 * Wiring: a TSOP38xx-style demodulating receiver puts the bare command
 * stream on the pin, idle-high.
 *
 * NEC frame:
 *   9.0 ms low (AGC pulse)
 *   4.5 ms high
 *   32 bits, each 0.56 ms low followed by ~0.56 ms (0) or ~1.69 ms (1) high
 *   final 0.56 ms low stop bit
 */
static uint32_t rd_ir_last = 0;

int8_t ir_receive(uint8_t pin, uint32_t timeout_ms) {
  uint32_t deadline = micros() + timeout_ms * 1000UL;
  uint32_t bit_start;
  uint32_t bit_high;
  uint32_t frame = 0;
  uint8_t i;

  if (!rd_uno_valid_pin(pin)) {
    return -1;
  }

  pin_mode(pin, 0);

  while (digital_read(pin) == 1) {
    if (micros() > deadline) return -2;
  }

  bit_start = micros();
  while (digital_read(pin) == 0) {
    if ((micros() - bit_start) > 12000) return -3;
  }
  if ((micros() - bit_start) < 7000) return -4;

  bit_start = micros();
  while (digital_read(pin) == 1) {
    if ((micros() - bit_start) > 6000) return -5;
  }
  if ((micros() - bit_start) < 3500) return -6;

  for (i = 0; i < 32; i++) {
    bit_start = micros();
    while (digital_read(pin) == 0) {
      if ((micros() - bit_start) > 1500) return -7;
    }
    bit_start = micros();
    while (digital_read(pin) == 1) {
      if ((micros() - bit_start) > 3000) return -8;
    }
    bit_high = micros() - bit_start;
    frame >>= 1;
    if (bit_high > 1000) {
      frame |= 0x80000000UL;
    }
  }

  rd_ir_last = frame;
  return 0;
}

uint32_t ir_command(void) {
  return rd_ir_last;
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

int is_graph(int c) {
  /* Printable but not whitespace — Arduino's isGraph(). */
  return (c > 32 && c <= 126) ? 1 : 0;
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
