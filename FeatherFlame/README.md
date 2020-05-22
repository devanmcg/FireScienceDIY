# FeatherFlame

*in agris* = in the field 

## Software 

Program the FeatherFlame for 1-6 thermocouple sensors via [my sketch](https://github.com/devanmcg/FireScienceDIY/tree/master/FeatherFlame/sketches) for the [Arduino IDE](https://www.arduino.cc/en/Main/Software). 

`six_logger_temp_oled.ino` assumes the following components from the [FeatherFlame wishlist](http://www.adafruit.com/wishlists/459876) on [adafruit.com](http://adafruit.com) are connected as in the [fritzing](http://www.fritzing.org) image below. 
For easy assembly and compact, durable field use, I've posted  
I'm also a fan of [jlcpcb](https://jlcpcb.com). 

* Feather M0 Adalogger (microcontroller board + microSD card for data storage)
* 1-6 K-type theromocouples, each connected via a MAX31855 board
* OLED screen (optional)
* DS3231 precision real-time clock (optional)
* TMP36 temperature sensor (optional) 

<img src="https://github.com/devanmcg/FireScienceDIY/blob/master/FeatherFlame/PCB/FeatherFlame6tc_bb.png" width="600">

## Hardware 

The system relies on [Adafruit Industries](adafruit.com) Feather system of small, mobile, Arduino-based microcontrollers.

### Parts list 

* [Adafruit wishlist]( http://www.adafruit.com/wishlists/459876)
* Thermocouples \& wire from [Omega Engineering](omega.com)
  - [Overbraided ceramic fiber insulated K-type thermocouple leads](https://www.omega.com/pptst/XCIB.html)
  - [Connectors](https://www.omega.com/pptst/SMPW-CC.html)
  - Extra TC wire for leads: [Part number HH-K-24-SLE-50](https://www.omega.com/pptst/SLE_Wire.html)
  - A [PCB](https://github.com/devanmcg/FireScienceDIY/tree/master/FeatherFlame/PCB) design that one can order themselves from [OSH Park](https://oshpark.com/shared_projects/cAXzsQJw).
