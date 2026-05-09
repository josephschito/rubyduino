# Arduino Standard Library Coverage in Rubyduino

Comparison of Rubyduino's exposed API (`lib/rubyduino/arduino_uno.rb`, `lib/rubyduino/spinel_arduino_codegen.rb`) against the Arduino core API (`<Arduino.h>`) plus the libraries bundled with the Arduino IDE.

## Digital I/O

- [x] `pinMode`
- [x] `digitalRead`
- [x] `digitalWrite`

## Analog I/O

- [x] `analogRead`
- [x] `analogWrite`
- [ ] `analogReference`

## Time

- [x] `delay` (as `delay_ms`)
- [x] `delayMicroseconds` (as `delay_us`)
- [x] `millis`
- [x] `micros`

## Advanced I/O

- [x] `pulseIn`
- [x] `pulseIn` with timeout (as `pulse_in_timeout`)
- [x] `shiftIn`
- [x] `shiftOut`
- [ ] `tone`
- [ ] `noTone`
- [ ] `pulseInLong`

## Interrupts

- [x] `interrupts`
- [x] `noInterrupts` (as `no_interrupts`)
- [ ] `attachInterrupt`
- [ ] `detachInterrupt`
- [ ] `digitalPinToInterrupt`

## Serial

- [x] `Serial.begin`
- [x] `Serial.available`
- [x] `Serial.read`
- [x] `Serial.write` (single byte)
- [x] `Serial.print` — string + int (via codegen)
- [x] `Serial.println` — string + int (via codegen)
- [ ] `Serial.print`/`println` for float/double, byte, with format args (BIN/HEX/OCT/DEC, decimal places)
- [ ] `Serial.write(buf, len)` overload
- [ ] `Serial.end`
- [ ] `Serial.flush`
- [ ] `Serial.peek`
- [ ] `Serial.setTimeout`
- [ ] `Serial.availableForWrite`
- [ ] `Serial.find`
- [ ] `Serial.findUntil`
- [ ] `Serial.parseInt`
- [ ] `Serial.parseFloat`
- [ ] `Serial.readBytes`
- [ ] `Serial.readBytesUntil`
- [ ] `Serial.readString`
- [ ] `Serial.readStringUntil`
- [ ] `serialEvent` callback

## Random

- [x] `random(a..b)` with literal range (via codegen)
- [ ] `random` with non-literal range (variables fall through to plain `rand`)
- [ ] `randomSeed`

## Bits & Bytes

- [ ] `bit`
- [ ] `bitRead`
- [ ] `bitWrite`
- [ ] `bitSet`
- [ ] `bitClear`
- [ ] `highByte`
- [ ] `lowByte`

## Math / Utility Helpers

- [ ] `map`
- [ ] `constrain`
- [ ] `sq`
- [x] `abs`, `min`, `max`, `pow`, `sqrt` — provided by Ruby itself, not the gem

## Character Classification

- [ ] `isAlpha`
- [ ] `isDigit`
- [ ] `isSpace`
- [ ] `isWhitespace`
- [ ] `isAlphaNumeric`
- [ ] `isAscii`
- [ ] `isControl`
- [ ] `isHexadecimalDigit`
- [ ] `isLowerCase`
- [ ] `isUpperCase`
- [ ] `isPrintable`
- [ ] `isPunct`

## Other Core

- [ ] `yield` (cooperative yield hook)
- [ ] Arduino `String` class
- [ ] `PROGMEM` / `pgm_read_*`

## Bundled Libraries

- [ ] `Wire` (I²C)
- [ ] `SPI`
- [ ] `EEPROM`
- [ ] `SoftwareSerial`
- [ ] `Servo`
- [ ] `Stepper`
- [ ] `LiquidCrystal`
- [ ] `SD`

## Constants Provided

- [x] `LOW`, `HIGH`
- [x] `INPUT`, `OUTPUT`, `INPUT_PULLUP`
- [x] `A0`–`A5`
- [x] `LED_BUILTIN`
- [x] `LSBFIRST`, `MSBFIRST`

## Highest-Impact Gaps for Sketch Authors

1. `tone` / `noTone`
2. `map` / `constrain`
3. `attachInterrupt` / `detachInterrupt`
4. Richer `Serial.print` formatting (float, HEX/BIN/etc.)
5. `Wire` / `SPI` / `EEPROM` libraries
