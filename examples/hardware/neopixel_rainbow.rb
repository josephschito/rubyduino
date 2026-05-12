# NeoPixel rainbow chase
#
# Cycles a rainbow across an 8-pixel WS2812 strip wired to D6.
# Adjust DATA_PIN / NUM_PIXELS for your hardware.

DATA_PIN = 6
NUM_PIXELS = 8

def color_wheel(pos)
  pos = pos % 256
  if pos < 85
    [pos * 3, 255 - pos * 3, 0]
  elsif pos < 170
    pos = pos - 85
    [255 - pos * 3, 0, pos * 3]
  else
    pos = pos - 170
    [0, pos * 3, 255 - pos * 3]
  end
end

neopixel_begin(DATA_PIN, NUM_PIXELS)

offset = 0
loop do
  i = 0
  while i < NUM_PIXELS
    rgb = color_wheel((i * 256 / NUM_PIXELS) + offset)
    neopixel_set_pixel(i, rgb[0], rgb[1], rgb[2])
    i += 1
  end
  neopixel_show
  offset = (offset + 1) % 256
  sleep_ms(20)
end
