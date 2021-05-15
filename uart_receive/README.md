# UART audio receiver
* Reading audio from UART rx pin
* UART config 8N1, 115200 baud rate
* One channel, 11520 sample rate for audio, 8bit depth
* Display sound on leds and play on speaker
* Only quick and dirty test

## Shell command for send audio throught UART to Spartan 3 board
```
#!/bin/sh
sox -t pulseaudio default  -t wav - lowpass 5500 | sox -t wav - -r 11520 -b 8 -c 1 -t wav - | cat > /dev/ttyS0
```
