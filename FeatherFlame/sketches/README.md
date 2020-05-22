Use these files to program the FeatherFlame via the [Arduino IDE](https://www.arduino.cc/en/Main/Software). 

`six_logger_temp_oled.ino` assumes the following components from the [FeatherFlame wishlist](http://www.adafruit.com/wishlists/459876) on [adafruit.com](http://adafruit.com):
* Feather M0 Adalogger (microcontroller board + microSD card for data storage)
* 1-6 K-type theromocouples, each connected via a MAX31855 board
* Data logging
* OLED screen (optional)
* DS3231 precision real-time clock (optional)
* TMP36 temperature sensor (optional) 

<img src="https://github.com/devanmcg/FireScienceDIY/blob/master/FeatherFlame/PCB/FeatherFlame6tc_bb.png" width="600">

`force_RTC_reset.ino` just forces a reset of the real-time clock in the DS3231, which the script *should* do automatically, but when synchronised timestamps are important for all dataloggers deployed for a fire event, one can't be too careful!
If you have problems getting synchronised timestamps, make sure the coin batteries are good and see if this script helps you get back on track.
