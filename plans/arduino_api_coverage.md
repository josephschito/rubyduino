# Arduino Standard Library Coverage in Rubyduino

Comparison of Rubyduino's exposed API (`lib/rubyduino/arduino_uno.rb`, `lib/rubyduino/spinel_arduino_codegen.rb`) against the Arduino core API (`<Arduino.h>`) plus the libraries bundled with the Arduino IDE.

## Digital I/O

- [x] `pinMode`
- [x] `digitalRead`
- [x] `digitalWrite`

## Analog I/O

- [x] `analogRead`
- [x] `analogWrite`
- [x] `analogReference` (as `analog_reference`)

## Time

- [x] `delay` (as `delay_ms`)
- [x] `delayMicroseconds` (as `delay_us`)
- [x] `millis`
- [x] `micros`

## Advanced I/O

- [x] `pulseIn`
- [x] `pulseIn` with timeout (as `pulse_in_timeout`)
- [x] `pulseInLong` (as `pulse_in_long`)
- [x] `shiftIn`
- [x] `shiftOut`
- [x] `tone` (with optional duration)
- [x] `noTone` (as `no_tone`)

## Interrupts

- [x] `interrupts`
- [x] `noInterrupts` (as `no_interrupts`)
- [x] `attachInterrupt` (as `attach_interrupt`, flag-based polling rather than callback)
- [x] `detachInterrupt` (as `detach_interrupt`)
- [x] `digitalPinToInterrupt` (as `digital_pin_to_interrupt`)
- [x] `interrupt_fired?` predicate (rubyduino-specific, replaces callback model)

## Serial

- [x] `Serial.begin`
- [x] `Serial.available`
- [x] `Serial.read`
- [x] `Serial.write` (single byte)
- [x] `Serial.print` — string + int (via codegen)
- [x] `Serial.println` — string + int (via codegen)
- [x] `Serial.print`/`println` with HEX/BIN/OCT/DEC base (via codegen)
- [x] `Serial.print`/`println` for float (via codegen + dedicated formatter)
- [x] `Serial.end` (as `serial_end`)
- [x] `Serial.flush` (as `serial_flush`)
- [x] `Serial.peek` (as `serial_peek`)
- [x] `Serial.setTimeout` (as `serial_set_timeout`)
- [x] `Serial.getTimeout` (as `serial_get_timeout`)
- [x] `Serial.availableForWrite` (as `serial_available_for_write`)
- [x] `Serial.find` (as `serial_find` + `serial_find?`)
- [x] `Serial.findUntil` (as `serial_find_until` + `serial_find_until?`)
- [x] `Serial.parseInt` (as `serial_parse_int`)
- [x] `Serial.parseFloat` (as `serial_parse_float`)
- [x] `Serial.readByteTimeout` (rubyduino-specific primitive for read_bytes-style loops)
- [ ] `Serial.write(buf, len)` overload
- [ ] `Serial.readBytes` / `readBytesUntil` — buildable on top of `serial_read_byte_timeout`
- [ ] `Serial.readString` / `readStringUntil`
- [ ] `serialEvent` callback

## Random

- [x] `random(a..b)` with literal range (via codegen)
- [x] `random(low..high)` with non-literal range (via codegen → `random_range`)
- [x] `randomSeed` (as `random_seed`)
- [x] `random_range(low, high)` and `random_max(high)` callable directly

## Bits & Bytes

- [x] `bit` / `bitRead` / `bitWrite` / `bitSet` / `bitClear` / `highByte` / `lowByte` (snake_case)

## Math / Utility Helpers

- [x] `map` (as `map_value`)
- [x] `constrain`
- [x] `sq`
- [x] `abs`, `min`, `max`, `pow`, `sqrt` — provided by Ruby itself, not the gem

## Character Classification

- [x] `isAlpha`/`isDigit`/`isAlphaNumeric`/`isSpace`/`isWhitespace`/`isUpperCase`/`isLowerCase`/`isAscii`/`isControl`/`isPrintable`/`isPunct`/`isHexadecimalDigit` (snake_case + `?` predicate variants)

## Other Core

- [x] `yield` (as `arduino_yield` — Ruby keyword conflict requires the prefix)
- [ ] Arduino `String` class
- [ ] `PROGMEM` / `pgm_read_*`

## Bundled Libraries

- [x] `Wire` (I²C master mode)
- [x] `SPI`
- [x] `EEPROM`
- [x] `Servo` (single-servo, Timer1)
- [ ] `SoftwareSerial`
- [ ] `Stepper`
- [ ] `LiquidCrystal`
- [ ] `SD`

## Constants Provided

- [x] `LOW`, `HIGH`
- [x] `INPUT`, `OUTPUT`, `INPUT_PULLUP`
- [x] `A0`–`A5`
- [x] `LED_BUILTIN`
- [x] `LSBFIRST`, `MSBFIRST`
- [x] `BIN`, `OCT`, `DEC`, `HEX`
- [x] `INT_LOW` / `INT_CHANGE` / `INT_FALLING` / `INT_RISING`
- [x] `AREF_EXTERNAL` / `AREF_DEFAULT` / `AREF_INTERNAL`
- [x] `SPI_MODE0..3`, `SPI_CLOCK_DIV2..128`

## Remaining Gaps

- `Serial.readBytes` / `readBytesUntil` / `readString` / `readStringUntil` (buildable in user code over `serial_read_byte_timeout`)
- `serialEvent` callback
- Arduino `String` class
- `PROGMEM` / `pgm_read_*`
- `SoftwareSerial`, `Stepper`, `LiquidCrystal`, `SD`
- True multi-servo support (current implementation handles one servo)
- Function-pointer callbacks for `attachInterrupt` (current model uses flag polling)
