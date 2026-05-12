# MIDI note player
#
# Sends MIDI Note On/Off messages over serial at 31250 baud.
#
# https://docs.arduino.cc/built-in-examples/communication/Midi/

def note_on(cmd, pitch, velocity)
  serial_write(cmd)
  serial_write(pitch)
  serial_write(velocity)
end

serial_begin(31250)

loop do
  note = 0x1E
  while note < 0x5A
    note_on(0x90, note, 0x45)
    delay_ms(100)
    note_on(0x90, note, 0x00)
    delay_ms(100)
    note += 1
  end
end
