# Ruby API Convention Audit

This audit covers the gem-owned method surface in `lib/`, `bin/rubyduino`, and the sketch-facing API assembled from `lib/rubyduino/arduino_uno.rb` plus the `serial_print`, `serial_println`, and `rand(range)` codegen hooks in `lib/rubyduino/spinel_arduino_codegen.rb`.

Vendored Spinel internals are out of scope unless Rubyduino exposes them directly.

## Executive Summary

Rubyduino currently exposes a very Arduino-shaped API with Ruby snake_case names. That is useful for porting Arduino examples, but it still goes against normal Ruby gem conventions in a few consistent ways:

- `lib/rubyduino/arduino_uno.rb` defines many methods at top level, which turns them into global/private `Object` methods in Ruby. This is convenient for sketches, but a gem should normally put public APIs behind a namespace or an explicitly included DSL module.
- The public methods are mostly procedural wrappers around hardware subsystems: `serial_*`, `spi_*`, `wire_*`, `servo_*`, and `eeprom_*`. Ruby code would normally use objects/modules with short method names, such as `serial.puts`, `spi.transfer`, `wire.transmit`, `servo.angle = 90`, and `eeprom[0]`.
- Methods that return truth values still expose C/Arduino-style integer forms (`is_alpha`, `serial_find`, `servo_attached`, `interrupt_fired`) alongside predicate aliases. The predicate aliases are good, but the Ruby-facing names should drop the `is_` prefix where possible.
- Getter/setter pairs use Java/C naming (`serial_get_timeout`, `serial_set_timeout`, `spi_set_data_mode`, `wire_set_clock`). Ruby-style APIs should prefer `timeout`, `timeout=`, `data_mode=`, `clock=`, or keyword-based configuration.
- Several helpers expose implementation details (`serial_print_str`, `serial_print_int`, `serial_print_hex`, `random_max`, `tone_for`, `pulse_in_timeout`) as public FFI functions. These should remain available for codegen/runtime compatibility, but be treated as raw/internal primitives rather than the Ruby-first API.

Recommended direction: keep the existing Arduino-compatible functions as a compatibility layer, then add Ruby-style facades and aliases. Avoid breaking current sketches until there is a clear versioned deprecation path.

## Cross-Cutting Convention Issues

### Top-Level API Pollution

Current locations:

- `lib/rubyduino/arduino_uno.rb:152-618` defines sketch helpers as top-level methods.
- `bin/rubyduino:10-88` defines CLI helper methods at top level.
- `lib/rubyduino/spinel_arduino_codegen.rb:11` defines `load_spinel_compiler` at top level.

Why this is not Ruby-esque:

- Gems should not add broad method names to `Object` unless they are intentionally building a DSL and isolate that DSL carefully.
- Names like `bit`, `constrain`, `interrupts`, `serial_read`, and `wire_read` become globally visible when the file is loaded.

Ruby-style equivalent:

- Introduce `Rubyduino::Sketch` or `Rubyduino::DSL` and include it only into compiled sketches.
- Move raw board bindings under `Rubyduino::Boards::Uno` or keep `ArduinoUNO` as a compatibility alias for `Rubyduino::Boards::Uno`.
- Move CLI helpers into `Rubyduino::CLI`.
- Move codegen loading helpers under a module or class method, for example `Rubyduino::SpinelArduinoCodegen.load_spinel_compiler`.

### Constants and Namespace Shape

Current location:

- `lib/rubyduino/arduino_uno.rb:1-44`

Issues:

- `ArduinoUNO` is less idiomatic than `ArduinoUno` as a Ruby constant name.
- Constants like `LOW`, `HIGH`, `INPUT`, `OUTPUT`, `HEX`, and `BIN` are Arduino-compatible, but Ruby-facing APIs should generally accept symbols or booleans where the domain is clear.

Ruby-style equivalent:

- Add `ArduinoUno = ArduinoUNO` or a namespaced `Rubyduino::Boards::Uno`.
- Allow `:low`, `:high`, `:input`, `:output`, `:pullup`, `:hex`, `:bin`, `:oct`, `:dec`, while preserving numeric constants for compatibility and direct register-oriented code.

## Public Sketch Method Audit

### Digital, Analog, and Pin Methods

Current methods:

- `pin_mode`, `digital_write`, `digital_read`, `analog_read`, `analog_write`

Convention issue:

- These are hardware-procedural globals. They are snake_case, which is good, but Ruby would usually model a pin as an object or use narrower verbs with predicates and bang methods for side effects.
- `digital_read` returns integer `0`/`1`; Ruby callers generally expect a predicate when asking a yes/no question.

Ruby-style equivalents to add:

- `pin(13).output!`
- `pin(13).input!`
- `pin(13).input_pullup!`
- `pin(13).high!`
- `pin(13).low!`
- `pin(13).high?`
- `pin(13).low?`
- `pin(A0).analog_read`
- `pin(9).analog_write(128)`

Keep the current methods as Arduino-compatible aliases.

### Timing and Pulse Methods

Current methods:

- `delay_ms`, `delay_us`, `millis`, `micros`, `pulse_in`, `pulse_in_timeout`, `pulse_in_long`, `arduino_yield`

Convention issue:

- `delay_ms` and `delay_us` are acceptable for embedded Ruby because they make units explicit, but `sleep_ms` and `sleep_us` would read more naturally to Rubyists.
- `pulse_in_timeout` encodes an optional behavior in the method name. Ruby normally prefers keyword arguments.
- `arduino_yield` is necessarily prefixed because `yield` is a Ruby keyword, so this name is acceptable as a compatibility escape hatch.

Ruby-style equivalents to add:

- `sleep_ms(ms)` as an alias for `delay_ms(ms)`.
- `sleep_us(us)` as an alias for `delay_us(us)`.
- `pulse_in(pin, value, timeout_us: 1_000_000)` as the preferred form.
- Keep `millis` and `micros`; optionally add `milliseconds` and `microseconds` aliases if the compiler can support them without ambiguity.

### Serial Methods

Current methods and codegen hooks:

- `serial_begin`, `serial_end`, `serial_available`, `serial_available_for_write`
- `serial_read`, `serial_read_byte_timeout`, `serial_peek`, `serial_write`, `serial_flush`
- `serial_set_timeout`, `serial_get_timeout`
- `serial_parse_int`, `serial_parse_float`
- `serial_find`, `serial_find?`, `serial_find_until`, `serial_find_until?`
- `serial_print`, `serial_println` through codegen only
- `serial_print_hex`, `serial_print_bin`, `serial_print_oct`, `serial_print_float`
- `serial_println_hex`, `serial_println_bin`, `serial_println_oct`, `serial_println_float`
- raw FFI helpers: `serial_print_str`, `serial_print_int`, `serial_println_str`, `serial_println_int`

Convention issue:

- The `serial_` prefix is a procedural namespace substitute.
- `serial_println` is Arduino terminology; Rubyists expect `puts`.
- `serial_get_timeout` and `serial_set_timeout` should be `timeout` and `timeout=`.
- `serial_find` returns integer truth; `serial_find?` is the Ruby-style form.
- Format-specific print methods are implementation detail. Ruby callers should use a keyword or format object rather than `serial_print_hex`.

Ruby-style equivalents to add:

- `serial.begin(9600)` / `Serial.begin(9600)` if a constant module is easier for codegen.
- `serial.end`
- `serial.print(value, base: :hex)` and `serial.puts(value, base: :hex)`.
- `serial.print(value, decimals: 2)` and `serial.puts(value, decimals: 2)` for floats.
- `serial.write(byte)` and `serial << byte`.
- `serial.read`, `serial.peek`, `serial.flush`.
- `serial.available` for count and `serial.available?` or `serial.any?` for boolean.
- `serial.available_for_write`.
- `serial.timeout` and `serial.timeout = ms`.
- `serial.parse_int`, `serial.parse_float`.
- `serial.find?("OK")` and `serial.find_until?("OK", "\n")`.

Keep `serial_print`, `serial_println`, and the format-specific helpers as compatibility/codegen aliases, but steer new docs toward `serial.print` and `serial.puts`.

### Random Methods

Current methods and codegen hooks:

- `random_seed`, `random_range`, `random_max`
- `rand(1..10)` is supported through codegen.

Convention issue:

- Ruby already has `srand` and `rand`.
- `random_range` and `random_max` are raw Arduino/C helper shapes.

Ruby-style equivalents to add:

- Support `srand(seed)` as the preferred alias for `random_seed(seed)`.
- Keep promoting `rand(1..10)`.
- Treat `random_range(low, high)` and `random_max(high)` as internal/runtime helpers once `rand` covers the common cases.

### Bit, Byte, and Math Helpers

Current methods:

- `bit`, `bit_read`, `bit_write`, `bit_set`, `bit_clear`
- `high_byte`, `low_byte`
- `map_value`, `constrain`, `sq`

Convention issue:

- `bit_write`, `bit_set`, and `bit_clear` return new values rather than mutating their first argument; the names read as mutators.
- Ruby already has bitwise operators, so `bit(n)` is less Ruby-like than `1 << n`.
- `constrain` duplicates Ruby's `clamp` naming.
- `sq` is an Arduino abbreviation; Ruby code generally favors `square` or direct multiplication.
- `map_value` avoids `map`, but the name is still a C/Arduino utility rather than a Ruby concept.

Ruby-style equivalents to add:

- `bit_mask(n)` or document `1 << n` as the Ruby-first form.
- `bit_at(value, n)` or `bit_set?(value, n)` for reading a bit as a boolean.
- `with_bit(value, n)`, `without_bit(value, n)`, and `with_bit(value, n, bitvalue)` for non-mutating transforms.
- `high_byte(value)` and `low_byte(value)` can stay; they are clear embedded helpers.
- `clamp(value, low, high)` as an alias for `constrain`.
- `square(value)` as an alias for `sq`.
- `remap(value, from: low..high, to: low..high)` or `map_range(value, from_low, from_high, to_low, to_high)` as a clearer alias for `map_value`.

### Character Classification

Current raw methods:

- `is_alpha`, `is_digit`, `is_alpha_numeric`, `is_space`, `is_whitespace`, `is_upper_case`, `is_lower_case`, `is_ascii`, `is_control`, `is_printable`, `is_punct`, `is_hexadecimal_digit`

Current predicate methods:

- `is_alpha?`, `is_digit?`, `is_alpha_numeric?`, `is_space?`, `is_whitespace?`, `is_upper_case?`, `is_lower_case?`, `is_ascii?`, `is_control?`, `is_printable?`, `is_punct?`, `is_hexadecimal_digit?`

Convention issue:

- The `?` aliases are an improvement, but Ruby predicate names usually omit `is_`.
- The raw methods return integer `0`/`1`; that is useful for C compatibility but not a Ruby-facing result.

Ruby-style equivalents to add:

- `alpha?`
- `digit?`
- `alphanumeric?`
- `space?`
- `whitespace?`
- `uppercase?`
- `lowercase?`
- `ascii?`
- `control?`
- `printable?`
- `punctuation?`
- `hex_digit?` or `hexadecimal_digit?`

Keep the `is_*` methods as Arduino-compatible aliases. Prefer the shorter predicates in examples and tests.

### Tone and Interrupt Methods

Current methods:

- `tone`, `no_tone`
- `interrupts`, `no_interrupts`
- `attach_interrupt`, `detach_interrupt`, `interrupt_fired`, `interrupt_fired?`, `digital_pin_to_interrupt`

Convention issue:

- `tone` is acceptable and already has an optional duration.
- `no_tone` mirrors Arduino; Ruby might express this as `tone.stop(pin)` or `pin(pin).stop_tone`.
- `interrupts` / `no_interrupts` are command-style globals. Ruby often uses block-scoped resource control for temporary state changes.
- `attach_interrupt` cannot yet take a Ruby block/callback, but Ruby users will expect `on_interrupt(...) { ... }` if they see "attach".
- `interrupt_fired?` is the Ruby-style method; `interrupt_fired` should be raw/internal.

Ruby-style equivalents to add:

- `tone(pin, frequency, duration: nil)` while keeping positional duration for compatibility.
- `stop_tone(pin)` or `tone_off(pin)` as clearer aliases for `no_tone(pin)`.
- `without_interrupts { ... }` as the preferred wrapper for short critical sections.
- `with_interrupts { ... }` only if it has a clear use case.
- `on_interrupt(pin, :rising)` as a future block form if the compiler/runtime can support callbacks.
- `interrupt(digital_pin_to_interrupt(2)).fired?` or `interrupt_fired?(n)` as the predicate form.

### EEPROM Methods

Current methods:

- `eeprom_read`, `eeprom_write`, `eeprom_update`, `eeprom_length`, `eeprom_read_int`, `eeprom_write_int`

Convention issue:

- These are procedural names for an addressable storage object.
- `length` and bracket access are familiar Ruby collection conventions.

Ruby-style equivalents to add:

- `eeprom.length`
- `eeprom[addr]`
- `eeprom[addr] = value`
- `eeprom.update(addr, value)`
- `eeprom.read_i32(addr)` and `eeprom.write_i32(addr, value)` or `eeprom.read_int(addr)` / `eeprom.write_int(addr, value)` if the current integer width remains fixed and documented.

### SPI Methods

Current methods:

- `spi_begin`, `spi_end`, `spi_set_bit_order`, `spi_set_clock_divider`, `spi_set_data_mode`, `spi_transfer`, `spi_transfer16`

Convention issue:

- The `spi_` prefix is a procedural namespace substitute.
- The setters should be assignment methods or keyword configuration.
- `spi_transfer16` uses a numeric suffix because C lacks keyword dispatch; Ruby can express this with a keyword.
- `begin`/`end` pairs are good candidates for a block API.

Ruby-style equivalents to add:

- `spi.begin` and `spi.end`.
- `spi.open { ... }` or `spi.transaction(...) { ... }`.
- `spi.bit_order = :msbfirst`.
- `spi.clock_divider = 16` or `spi.clock = hz` if the runtime supports frequency-level configuration later.
- `spi.data_mode = 0`.
- `spi.transfer(byte)`.
- `spi.transfer(word, bits: 16)` as the Ruby-facing replacement for `spi_transfer16`.

### Wire / I2C Methods

Current methods:

- `wire_begin`, `wire_end`, `wire_set_clock`, `wire_begin_transmission`, `wire_write`, `wire_end_transmission`, `wire_request_from`, `wire_available`, `wire_read`

Convention issue:

- The `wire_` prefix is a procedural namespace substitute.
- `begin_transmission` / `end_transmission` pairs are good candidates for block-scoped APIs.
- `available` and `read` fit a stream-like object better than globals.

Ruby-style equivalents to add:

- `wire.begin` and `wire.end`.
- `wire.clock = 100_000`.
- `wire.transmit(addr) { |tx| tx.write(byte) }`.
- `wire.request(addr, count, stop: true)` returning a count or a small reader object.
- `wire.available`, `wire.available?`, `wire.read`.

### Servo Methods

Current methods:

- `servo_attach`, `servo_detach`, `servo_write`, `servo_write_microseconds`, `servo_read`, `servo_read_microseconds`, `servo_attached`, `servo_attached?`

Convention issue:

- The `servo_` prefix is a procedural namespace substitute.
- `servo_write` and `servo_read` are Arduino names for angle access; Ruby should expose `angle` and `angle=`.
- `servo_attached?` is the correct Ruby predicate; `servo_attached` should be raw/internal.
- Current runtime supports one servo, so the object API should be honest about single-servo state until multi-servo support exists.

Ruby-style equivalents to add:

- `servo.attach(pin)` and `servo.detach`.
- `servo.angle` and `servo.angle = degrees`.
- `servo.microseconds` and `servo.microseconds = us`.
- `servo.attached?`.

## Raw FFI Method Audit

Current location:

- `lib/rubyduino/arduino_uno.rb:46-149`

Issue:

- Every `ffi_func` creates callable module methods on `ArduinoUNO`. That includes internal implementation helpers like `serial_print_str`, `serial_print_int`, `serial_println_str`, `serial_println_int`, `tone_for`, `random_max`, and raw integer predicate helpers.

Recommendation:

- Keep raw FFI names stable for generated C and low-level escape hatches.
- Treat them as `Rubyduino::Boards::Uno::Raw` or equivalent in docs.
- Prefer Ruby-style wrappers in examples.
- If Spinel supports visibility control for generated bindings, make raw helpers private or explicitly namespaced.

## Internal Gem Method Audit

### CLI Helpers

Current methods in `bin/rubyduino`:

- `usage`, `run!`, `capture!`, `command?`, `executable`, `runnable_executable?`, `find_port`, `find_avrdude`, `avrdude_conf_for`

Convention issue:

- They are top-level methods inside an executable. This is common in small scripts but not ideal for a gem as the CLI grows.
- `run!` and `capture!` are acceptable bang names because they abort on failure.
- `command?` and `runnable_executable?` are good predicate names.

Ruby-style equivalent:

- Move into `Rubyduino::CLI` with an instance method such as `Rubyduino::CLI.new(ARGV).run`.
- Keep helpers private inside that class/module.

### Codegen Helpers

Current methods in `lib/rubyduino/spinel_arduino_codegen.rb`:

- top-level `load_spinel_compiler`
- `SpinelArduinoCodegen#compile_no_recv_call_expr`
- private helpers: `compile_arduino_serial_print`, `arduino_serial_print_func`, `arduino_base_print_func`, `compile_arduino_rand`, `integer_literal_node?`

Convention issue:

- `load_spinel_compiler` should not be top-level.
- The module instance methods are internal compiler hooks and are appropriately scoped, with `integer_literal_node?` correctly named as a predicate.

Ruby-style equivalent:

- Move `load_spinel_compiler` into `SpinelArduinoCodegen` as a module function or into a small loader class.
- No public Ruby-style sketch aliases are needed for the private compiler methods.

## Suggested Migration Order

1. Add a `Rubyduino::DSL` or `Rubyduino::Sketch` namespace and make the current top-level methods part of that explicit DSL.
2. Add `ArduinoUno` / `Rubyduino::Boards::Uno` aliases while preserving `ArduinoUNO`.
3. Add Ruby-style predicates for character classification without `is_`.
4. Add `srand(seed)` as the preferred seed API and keep `rand(range)` as the documented random API.
5. Add `serial` facade methods, especially `serial.print`, `serial.puts`, `serial.timeout`, and `serial.timeout=`.
6. Add `eeprom`, `spi`, `wire`, and `servo` facades.
7. Add pin facades once there is a clear minimal shape for `pin(n)`.
8. Update README examples to show the Ruby-style API first, with Arduino-compatible function names documented as porting aliases.

## Compatibility Policy Recommendation

Do not remove the Arduino-compatible methods in the near term. They are valuable for users porting examples and for internal codegen. Instead:

- Mark Ruby-style methods as preferred in README and examples.
- Keep Arduino-compatible aliases indefinitely or deprecate only after a major version boundary.
- Make raw FFI helpers visibly internal through naming, namespace, or documentation.
