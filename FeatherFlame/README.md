# FeatherFlame

*in agris* = in the field 

## Software 

* Program the FeatherFlame for 1-6 thermocouple sensors via [sketches](https://github.com/devanmcg/FireScienceDIY/tree/master/FeatherFlame/sketches) for the [Arduino IDE](https://www.arduino.cc/en/Main/Software). 
* Learn how to import data into the [**R** statistical environment](https://www.r-project.org) and calculate rate of spread using [example data](https://github.com/devanmcg/FireScienceDIY/tree/master/FeatherFlame/OakvilleExample) from the University of North Dakota's Oakville Prairie. 

## Hardware 

The system relies on [Adafruit Industries](adafruit.com) Feather system of small, mobile, Arduino-based microcontrollers.

### Parts list 

* [Adafruit wishlist]( http://www.adafruit.com/wishlists/459876)
* Thermocouples \& wire from [Omega Engineering](omega.com)
  - [Overbraided ceramic fiber insulated K-type thermocouple leads](https://www.omega.com/pptst/XCIB.html)
  - [Connectors](https://www.omega.com/pptst/SMPW-CC.html). 
  Plastic are fine if protected from fire (see below).
  Ceramic are nice but expensive.
  - Extra TC wire for leads: [Part number HH-K-24-SLE-50](https://www.omega.com/pptst/SLE_Wire.html)
* A [PCB](https://github.com/devanmcg/FireScienceDIY/tree/master/FeatherFlame/PCB) design that one can order themselves from [OSH Park](https://oshpark.com/shared_projects/cAXzsQJw).
* Fire protection
  - A heavy-duty box; I use the Pelican 1020 case mostly because there was a pile of them in my lab when I started my job. 
  - A low, round metal canister to protect the Pelican case from melting. 
  I use a galvanized 26 gauge, 10-inch round HVAC cap from the hardware store. 
  - *Steel junction boxes* for plastic TC connectors \& *metal conduit* for the leads. 
  While these aren't totally necessary (the connectors can be wrapped in foil, etc) they really pay off. 
  Otherwise the lead wires will get lback and brittle, will get jumbled in storage and knotted in transit, and will get itchy fiberglass into one's hands whenever handling them. 
  All components last longer when protected from heat and flame. 
  Use leads several meters long to get datalogger away from probe ends and remove fuels around components.
 
### Images

Illustrated schematic of parts and wiring: 
<img src="https://github.com/devanmcg/FireScienceDIY/blob/master/FeatherFlame/PCB/FeatherFlame6tc_bb.png" width="1000">
  
FeatherFlame protected from fire in the field:
<img src="https://github.com/devanmcg/FireScienceDIY/blob/master/FeatherFlame/OakvilleExample/FeatherFlame.png" width="1000">

(A) Three stackable Feather boards - M0 Adalogger, datalogging shield, and OLED display - in the prototype. 
The board has microSD removable storage and an ATmega microcontroller. 
3.7v li-po battery not shown.
    
(B) An example of how the FeatherFlame is deployed *in agris*. 
We affix three thermocouple probes to rods that form a 1m equilateral triangle 15cm from the ground, a fourth probe on the soil surface, and a fifth probe in the center of the triangle. 
       
(C) The dataloggers are protected from surface flame fronts by first scraping away vegetative matter so the box can be placed on mineral soil, then covering with a galvanized steel HVAC end cap. 
   Dataloggers are placed away from the probe array to minimize disruption to fuels around the probes, which is made possible by leads protected by flexible metal conduit or high-temperature foil HVAC tape.
   
(D) The steel junction box protects the connectors between the overbraided thermocouple probes and the leads from the datalogger. 
  

