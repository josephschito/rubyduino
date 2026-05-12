<div align="center">

# Rubyduino

<img width="250" height="250" alt="image copy" src="https://github.com/user-attachments/assets/156c7d41-ed42-43f3-a720-ed2e9c12b52c" />

Rubyduino compiles Ruby sketches for Arduino boards and uploads the generated firmware.

Under the hood it uses [Spinel](https://github.com/matz/spinel), a Ruby AOT compiler, vendored at a pinned revision.

</div>

## Hello, Blink

```ruby
pin_mode(ArduinoUno::LED_BUILTIN, ArduinoUno::OUTPUT)

loop do
  digital_write(ArduinoUno::LED_BUILTIN, ArduinoUno::HIGH)
  sleep_ms(1000)
  digital_write(ArduinoUno::LED_BUILTIN, ArduinoUno::LOW)
  sleep_ms(1000)
end
```

<img width="500" height="281" alt="IMG_0197" src="https://github.com/user-attachments/assets/d2b1cc69-647a-4f63-b090-31b13a21e5a8" />

## Installation

```bash
gem install rubyduino
```

The command expects the AVR toolchain to be available in `PATH`, including `avr-gcc`, `avr-objcopy`, and `avrdude`.

On macOS, install the AVR tools with Homebrew:

```bash
brew tap osx-cross/avr
brew install avr-gcc avrdude
```

On Debian/Ubuntu:

```bash
sudo apt install gcc-avr avr-libc avrdude
```

On Fedora:

```bash
sudo dnf install avr-gcc avr-libc avrdude
```

## Usage

```bash
rubyduino examples/builtin/01_basics/blink.rb
```

Pass a serial port explicitly when auto-detection is not enough:

```bash
rubyduino -p /dev/cu.usbmodem11401 examples/builtin/01_basics/blink.rb
```

## Two API styles

Rubyduino exposes the same functionality two ways. Pick whichever reads better — both compile to identical AVR code.

**Arduino-compatible (porting `.ino` sketches)**

```ruby
pin_mode(13, ArduinoUno::OUTPUT)
digital_write(13, ArduinoUno::HIGH)
delay_ms(500)

serial_begin(9600)
serial_println("hello")
serial_println(value, ArduinoUno::HEX)
```

**Ruby-style (modules, predicates, idiomatic naming)**

```ruby
Pin.mode(13, ArduinoUno::OUTPUT)
Pin.high(13)
sleep_ms(500)

Serial.begin(9600)
Serial.println_str("hello")
Serial.println_hex(value)

Eeprom.write(0, 0xAB); v = Eeprom.read(0)
Spi.begin; reply = Spi.transfer(0x9F)
Wire.begin; Wire.transmit(0x68); Wire.write(0x6B); Wire.end_transmission
Servo.attach(9); Servo.angle = 90
```

Other Ruby-idiomatic helpers: `clamp`, `square`, `sleep_ms`, `sleep_us`, `srand`, `stop_tone`, predicate aliases like `alpha?`, `digit?`, `hex_digit?`, `interrupt_fired?`, `servo_attached?`, plus `without_interrupts { ... }` for critical sections.

## What's covered

The full Arduino UNO core API plus most of the bundled libraries — see [`plans/arduino_api_coverage.md`](plans/arduino_api_coverage.md) for the precise checklist.

**Core API:** `pin_mode`, `digital_read/write`, `analog_read/write`, `analog_reference`, `delay_ms`, `delay_us`, `millis`, `micros`, `pulse_in`, `pulse_in_long`, `shift_in/out`, `tone`, `no_tone`, `attach_interrupt`, `detach_interrupt`, all bit/byte macros, `map_value`, `constrain`, `sq`, all 13 character classifiers (with `?` aliases), full Serial including `parse_int`, `parse_float`, `find?`, formatted print (HEX/BIN/OCT/float), `random_seed` + `rand(low..high)` codegen.

**Bundled libraries:** EEPROM, SPI, Wire (I²C master), Servo (single-servo on Timer1).

**Common third-party hardware**, all bit-banged in `lib/rubyduino/sp_runtime.h`:

| Driver         | Helpers                                                         | Wiring                |
|----------------|-----------------------------------------------------------------|-----------------------|
| WS2812 / NeoPixel | `neopixel_begin`, `neopixel_set_pixel`, `neopixel_show`, `neopixel_clear` | data pin only         |
| DHT11 / DHT22  | `dht_read?`, `dht_temperature_x10`, `dht_humidity_x10`          | 1 wire + pull-up      |
| 1-Wire / DS18B20 | `onewire_*`, `ds18b20_request_temperature`, `ds18b20_read_temperature_x10` | 1 wire + 4.7k pull-up |
| HD44780 LCD (4-bit) | `lcd_begin`, `lcd_print_str`, `lcd_print_int`, `lcd_set_cursor`, `lcd_clear` | RS, EN, D4–D7         |
| Stepper        | `stepper_begin`, `stepper_set_speed`, `stepper_step`            | 4 GPIO                |
| SoftwareSerial | `soft_serial_begin`, `soft_serial_write`, `soft_serial_print_str`, `soft_serial_read` | RX + TX pins      |
| IR remote (NEC) | `ir_receive?`, `ir_command`                                     | TSOP38xx demodulator  |

## Examples

Every Arduino built-in example for an UNO ships as a Ruby port:

- [`examples/builtin/01_basics`](examples/builtin/01_basics) — Blink, Fade, AnalogReadSerial, etc.
- [`examples/builtin/02_digital`](examples/builtin/02_digital) — BlinkWithoutDelay, Debounce, tone melodies, …
- [`examples/builtin/03_analog`](examples/builtin/03_analog) — AnalogInOutSerial, Calibration, Smoothing, …
- [`examples/builtin/04_communication`](examples/builtin/04_communication) — ASCIITable, Dimmer, Midi, …
- [`examples/builtin/05_control`](examples/builtin/05_control) — Arrays, switchCase, while, …
- [`examples/builtin/06_sensors`](examples/builtin/06_sensors) — ADXL3xx, Knock, Memsic2125, Ping
- [`examples/builtin/07_display`](examples/builtin/07_display) — barGraph, RowColumnScanning
- [`examples/builtin/08_strings`](examples/builtin/08_strings) — character_analysis (the rest depend on the Arduino `String` class)

Hardware-driver examples live in [`examples/hardware`](examples/hardware):

- `neopixel_rainbow.rb` — 8-pixel WS2812 rainbow chase
- `dht22_serial.rb` — temperature/humidity over Serial
- `ds18b20_serial.rb` — DS18B20 temperature read every second
- `lcd_hello.rb` — 16x2 HD44780 hello-world
- `stepper_loop.rb` — 4-wire stepper full forward/back rotation
- `software_serial_passthrough.rb` — bridge between hardware and software UART
- `ir_remote_decode.rb` — print decoded NEC IR frames

## Tests

```bash
bundle exec rake test
```

The test suite has three layers:

1. **Codegen tests** — exercise the Ruby → C compiler hooks.
2. **Native logic tests** — extract pure-logic helpers and compile/run them with `clang` on the host.
3. **AVR compile tests** — run the full pipeline through `avr-gcc` and inspect ELF output for ISR vectors and symbols.

Bulk-compile coverage walks every sketch in `examples/builtin/**` and `examples/hardware/**` and verifies it links cleanly for `atmega328p`.

## License

MIT
