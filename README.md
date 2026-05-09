<div align="center">

# Rubyduino

<img width="250" height="250" alt="image copy" src="https://github.com/user-attachments/assets/156c7d41-ed42-43f3-a720-ed2e9c12b52c" />

Rubyduino compiles Ruby sketches for Arduino boards and uploads the generated firmware.

Under the hood it uses [Spinel](https://github.com/matz/spinel), a Ruby AOT compiler, vendored at a pinned revision.

</div>

## Example

<img width="500" height="281" alt="IMG_0197" src="https://github.com/user-attachments/assets/d2b1cc69-647a-4f63-b090-31b13a21e5a8" />

```ruby
pin_mode(ArduinoUNO::LED_BUILTIN, ArduinoUNO::OUTPUT)

loop do
  digital_write(ArduinoUNO::LED_BUILTIN, ArduinoUNO::HIGH)
  delay_ms(100)
  digital_write(ArduinoUNO::LED_BUILTIN, ArduinoUNO::LOW)
  delay_ms(100)
end
```

Not bad, huh?

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
rubyduino examples/hello.rb
```

Pass a serial port explicitly when auto-detection is not enough:

```bash
rubyduino -p /dev/cu.usbmodem11401 examples/hello.rb
```

## License

MIT
