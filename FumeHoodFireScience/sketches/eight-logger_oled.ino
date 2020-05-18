
#include <Wire.h>
#include <SPI.h>
#include <SD.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1305.h>
#include "Adafruit_MAX31855.h"
#include "RTClib.h"

// Used for software SPI
#define OLED_CLK 13
#define OLED_DC 12
#define OLED_MOSI 11
#define OLED_CS 4
#define OLED_RESET 9

Adafruit_SSD1305 display(OLED_MOSI, OLED_CLK, OLED_DC, OLED_RESET, OLED_CS);

// Logger 
const int chipSelect = 10;
int i ; 
int SensNum = 9; // n+1 
double temp[9];

//RTC
RTC_PCF8523 rtc;
int StartSec = 0; 
int counter = 0;

// Thermocouple definitions
#define DO   22
#define CLK  23
#define CS1   19
#define CS2   18
#define CS3   17
#define CS4   16
#define CS5   15
#define CS6   14
#define CS7   5
#define CS8   6

// Screen stuff
#define NUMFLAKES 10
#define XPOS 0
#define YPOS 1
#define DELTAY 2
#define LOGO16_GLCD_HEIGHT 16 
#define LOGO16_GLCD_WIDTH  16 
static const unsigned char PROGMEM logo16_glcd_bmp[] =
{ B00000000, B11000000,
  B00000001, B11000000,
  B00000001, B11000000,
  B00000011, B11100000,
  B11110011, B11100000,
  B11111110, B11111000,
  B01111110, B11111111,
  B00110011, B10011111,
  B00011111, B11111100,
  B00001101, B01110000,
  B00011011, B10100000,
  B00111111, B11100000,
  B00111111, B11110000,
  B01111100, B11110000,
  B01110000, B01110000,
  B00000000, B00110000 };



// initialize thermocouple(s)
Adafruit_MAX31855 thermocouple1(CLK, CS1, DO);
Adafruit_MAX31855 thermocouple2(CLK, CS2, DO);
Adafruit_MAX31855 thermocouple3(CLK, CS3, DO);
Adafruit_MAX31855 thermocouple4(CLK, CS4, DO);
Adafruit_MAX31855 thermocouple5(CLK, CS5, DO);
Adafruit_MAX31855 thermocouple6(CLK, CS6, DO);
Adafruit_MAX31855 thermocouple7(CLK, CS7, DO);
Adafruit_MAX31855 thermocouple8(CLK, CS8, DO);

void setup()   {                
  Serial.begin(115200);
 
  // by default, we'll generate the high voltage from the 3.3v line internally! (neat!)
  display.begin();
  // init done
  
  display.display(); // show splashscreen
  delay(1000);
  display.clearDisplay();   // clears the screen and buffer


      // draw text
  showNDSURangeScience();
  delay(1000);
  display.clearDisplay();

  RTCcheck();
  delay(1);
  display.clearDisplay();
  delay(100);

 SDcheck();
  delay(1);
  display.clearDisplay();
  delay(100);

  DateTime now = rtc.now();
  int StartSec = now.second();

 }


void loop() {
 ThermoRead();
  TempLogDisplay8();
 SerialDisplay(); 
  delay(2000);
}


void showNDSURangeScience(void) {
  display.setTextSize(2);
  display.setTextColor(WHITE);
  display.setCursor(15,12);
  display.clearDisplay();
  display.println("N D S U");
  display.setTextSize(1.5);
  display.println("  Range Science");
  display.println("  Wildland fire");
  display.display();
  delay(4000);
}


void RTCcheck (void) {
     rtc.begin();
if (!rtc.begin()) {
   display.setTextSize(1.5);
      display.setTextColor(WHITE);
      display.setCursor(0,5);
         display.clearDisplay();
         delay(1);
   display.println("RTC not running");
   display.display(); 
   Serial.println("RTC not running");
   
 if (!rtc.initialized()) {
  display.setTextSize(1.5);
      display.setTextColor(WHITE);
      display.setCursor(0,5);
         display.clearDisplay();
         delay(1);
   display.println("RTC not running");
   display.display(); 
    Serial.println("RTC is NOT running!");
    // following line sets the RTC to the date & time this sketch was compiled
     rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));
    // This line sets the RTC with an explicit date & time, for example to set
    // January 21, 2014 at 3am you would call:
    // rtc.adjust(DateTime(2016, 11, 16, 17, 40, 0));
  }
    delay(1000);
}
  else {
      rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));
      DateTime now = rtc.now();
     display.setTextSize(1);
      display.setTextColor(WHITE);
      display.setCursor(0,0);
         display.clearDisplay();
         delay(1);
     display.println("RTC initialized.");
     display.println("Current date/time:");
     if (now.month() <10) display.print('0');
        display.print(now.month(), DEC); display.print('-');
     if (now.day() <10) display.print('0');
        display.print(now.day(), DEC); display.print('-');
  display.print(now.year(), DEC); display.print(' ');
  display.print(now.hour(), DEC); display.print(':');
    if (now.minute() <10) display.print('0');
      display.print(now.minute(), DEC); display.print(':');
    if (now.second() <10) display.print('0');
  display.println(now.second(), DEC);
  display.display(); 
       delay(3000);
      }
}
void SDcheck (void) {
if (!SD.begin(chipSelect)) {
   display.setTextSize(1.5);
      display.setTextColor(WHITE);
      display.setCursor(0,5);
         display.clearDisplay();
         delay(1);
   display.println("Card failed, or not present");
   display.display(); 
    
// don't do anything more:
 return;
 }
     display.setTextSize(1.5);
      display.setTextColor(WHITE);
      display.setCursor(0,5);
         display.clearDisplay();
         delay(1);
     display.println("card initialized.");
   display.display();
    delay(1000);
  
 File dataFile = SD.open("log.txt", FILE_WRITE);
 // create a new file
//char filename[] = "LOGGER00.txt";
//for (uint8_t i = 0; i < 100; i++) {
//filename[6] = i/10 + '0';
//filename[7] = i%10 + '0';
//if (! SD.exists(filename)) {
 if (dataFile) {
// only open a new file if it doesn't exist
//File dataFile = SD.open(filename, FILE_WRITE);
display.setTextSize(1.5);
  display.setTextColor(WHITE);
  display.setCursor(0,0);
  display.clearDisplay();
  display.println("File ready. Logging!");
  display.display();
  delay(1000);
//break; // leave the loop!
}
 else {
    display.setTextSize(1.5);
  display.setTextColor(WHITE);
  display.setCursor(0,0);
  display.clearDisplay();
  display.println("No file! Not logging!");
  display.display();
  delay(5000);
  }
}

void ThermoRead (void) {
   temp[1] = thermocouple1.readCelsius();
  temp[2] = thermocouple2.readCelsius();
  temp[3] = thermocouple3.readCelsius();
  temp[4] = thermocouple4.readCelsius();
  temp[5] = thermocouple5.readCelsius();
  temp[6] = thermocouple6.readCelsius();
  temp[7] = thermocouple7.readCelsius();
  temp[8] = thermocouple8.readCelsius();
}
  void TempLogDisplay8 (void) {
      DateTime now = rtc.now();
 // This little guy gives unique ID to sub-second samples
     int ThisSec = now.second(); 
  if(StartSec==ThisSec) {
    counter=counter+ 1;
    StartSec=StartSec;
  } else {
  counter=0;
  StartSec=now.second();
  }

  File dataFile = SD.open("log.txt", FILE_WRITE);
  // If the file is available, start with writing the current date and time to the output file
  if (dataFile) {
    // Loop writes row of thermocouple data
    for (i = 1; i < 9; i++) { 
    dataFile.print(temp[i]);
    dataFile.print(", ");
 }
  // Finish line with date/time + time stamp
 dataFile.print(now.month(), DEC);
    dataFile.print('-');
    dataFile.print(now.day(), DEC);
    dataFile.print('-');
    dataFile.print(now.year(), DEC);
    dataFile.print(' ');
    dataFile.print(now.hour(), DEC);
    dataFile.print(':');
    dataFile.print(now.minute(), DEC);
    dataFile.print(':');
    dataFile.print(now.second(), DEC);
    dataFile.print('.');
    dataFile.print(counter);
    dataFile.print(", ");
    dataFile.println(now.unixtime());
    dataFile.close();

}
    display.setTextSize(1);
      display.setTextColor(WHITE);
      display.setCursor(0,0);
         display.clearDisplay();
         delay(1);
     if (now.month() <10) display.print('0');
        display.print(now.month(), DEC); display.print('-');
     if (now.day() <10) display.print('0');
        display.print(now.day(), DEC); display.print('-');
  display.print(now.year(), DEC); display.print(' ');
  display.print(now.hour(), DEC); display.print(':');
    if (now.minute() <10) display.print('0');
      display.print(now.minute(), DEC); display.print(':');
    if (now.second() <10) display.print('0');
  display.print(now.second(), DEC); display.print('.');
  display.println(counter); display.println(); 
  for (i = 1; i < 3; i++) { 
   display.print(i), display.print(" = "), display.print(temp[i]), display.print(" ");
    } display.println(); 
    for (i = 3; i < 5; i++) { 
   display.print(i), display.print(" = "), display.print(temp[i]), display.print(" ");
    }  display.println(); 
    for (i = 5; i < 7; i++) { 
   display.print(i), display.print(" = "), display.print(temp[i]), display.print(" ");
    } display.println();
     for (i = 7; i < 9; i++) { 
   display.print(i), display.print(" = "), display.print(temp[i]), display.print(" ");
    }
  display.display();
  }
  
 void SerialDisplay (void) {
    Serial.print(counter);
    Serial.print(", ");
    for (i = 1; i < 9; i++) { 
    Serial.print(temp[i]);
    Serial.print(", ");
    }
    Serial.println();

   }

void TempString8 (void) {
  String temp1 = String(thermocouple1.readCelsius() );
  String temp2 = String(thermocouple2.readCelsius() );
  String temp3 = String(thermocouple3.readCelsius() );
  String temp4 = String(thermocouple4.readCelsius() );
  String temp5 = String(thermocouple5.readCelsius() );
  String temp6 = String(thermocouple6.readCelsius() );
  String temp7 = String(thermocouple7.readCelsius() );
  String temp8 = String(thermocouple8.readCelsius() );
  String TempString = String(temp1 + ", " + temp2 + ", " + temp3 + ", " + temp4 + ", " + temp5 + ", " + temp6 + ", " + temp7 + ", " + temp8 + ", "); 
        DateTime now = rtc.now();
 // This little guy gives unique ID to sub-second samples
     int ThisSec = now.second(); 
  if(StartSec==ThisSec) {
    counter=counter+ 1;
    StartSec=StartSec;
  } else {
  counter=0;
  StartSec=now.second();
  }
    String Y = String(now.year(), DEC);
    String Mo = String(now.month(), DEC);
    String D = String(now.day(), DEC);
    String H = String(now.hour(), DEC);
    String Mi = String(now.minute(), DEC);
    String S = String(now.second(), DEC);
    String Ct = String(counter, DEC);
    String U = String(now.unixtime(), DEC);
    String TimeString = String(D+"-"+Mo+"-"+Y+" "+H+":"+Mi+":"+S+"."+Ct+", "+U);
    String RowString = String(TempString + TimeString);
   File dataFile = SD.open("log.txt", FILE_WRITE);
  // If the file is available, start with writing the current date and time to the output file
  if (dataFile) dataFile.print(RowString);
      Serial.println(RowString);

         display.setTextSize(1);
      display.setTextColor(WHITE);
      display.setCursor(0,0);
         display.clearDisplay();
         delay(1);
    
  display.println(TimeString); display.println(); 
  for (i = 1; i < 3; i++) { 
   display.print(i), display.print(" = "), display.print(temp[i]), display.print(" ");
    } display.println(); 
    for (i = 3; i < 5; i++) { 
   display.print(i), display.print(" = "), display.print(temp[i]), display.print(" ");
    }  display.println(); 
    for (i = 5; i < 7; i++) { 
   display.print(i), display.print(" = "), display.print(temp[i]), display.print(" ");
    } display.println();
     for (i = 7; i < 9; i++) { 
   display.print(i), display.print(" = "), display.print(temp[i]), display.print(" ");
    }
  display.display();
      }



   

