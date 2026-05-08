## [Unreleased]

## [0.2.0] - 2026-05-08

- Expand the ArduinoUNO API with PWM, microsecond delays, millis/micros timing, pulse measurement, serial I/O, shift helpers, and interrupt control
- Add special code generation for `serial_print` and `serial_println` so string and integer values map to the correct runtime functions
- Add an HC-SR04 ultrasonic distance sensor example

## [0.1.3] - 2026-05-08

- Add the built-in `ArduinoUNO` prelude with FFI-backed GPIO, analog read, and millisecond delay bindings
- Replace the legacy `system("pin13:*")` sketch API with top-level helpers like `pin_mode`, `digital_write`, and `delay_ms`
- Update the default hello example to use the new ArduinoUNO API

## [0.1.2] - 2026-05-08

- Update vendored Spinel revision

## [0.1.1] - 2026-05-08

- Fix avrdude discovery for installed command

## [0.1.0] - 2026-05-08

- Initial release
