// FeatherFlame M0
// 6 K-type theromocouples (MAX31855)
// Data logging
// OLED screen
// RTC (DS3231)
// Optional: Interior case temp (TMP36)

#include <SPI.h>
#include <Wire.h>
#include <SD.h>
#include <Adafruit_MAX31855.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include "RTClib.h"

/************ OLED Setup ***************/
Adafruit_SSD1306 oled = Adafruit_SSD1306();

//Real-time clock (RTC)
RTC_DS3231 rtc;

int StartSec = 0; 
int counter = 0;

// Define I/O on Feather M0 for thermocouples
#define DO   10
#define CLK  12
#define CS1   A1
#define CS2   A2
#define CS3   A3
#define CS4   A4
#define CS5   A5
#define CS6   6

// Logger 
const int chipSelect = 4;

// For when the optional TMP36 is installed inside the case
int TempSense = A0 ; 

// Set number of thermocouples
int i ; 
int SensNum =7; // n + 1
double temp[7];

int LogInt = 250 ; // Logging interval

// initialize thermocouple(s)
Adafruit_MAX31855 thermocouple1(CLK, CS1, DO);
Adafruit_MAX31855 thermocouple2(CLK, CS2, DO);
Adafruit_MAX31855 thermocouple3(CLK, CS3, DO);
Adafruit_MAX31855 thermocouple4(CLK, CS4, DO);
Adafruit_MAX31855 thermocouple5(CLK, CS5, DO);
Adafruit_MAX31855 thermocouple6(CLK, CS6, DO);

// Data structure

struct dataStruct{
  String timestamp ; 
  float tc1 ;
  float tc2;
  float tc3 ;
  float tc4 ;
  float tc5 ;
  float tc6 ;
  float CaseTempC ; // optional for interior case temp
   }SixLoggerData;

void setup()   {                
 // while (!Serial);  // uncomment to have the sketch wait until Serial is ready
 Serial.begin(115200);

  oledInit() ;
  rtc.begin();
  RTCcheck();
  SDcheck() ; 
  delay(100);
 
}

void loop() {

// Sketch operations defined as subroutines below and called here
 TimeStamper(); 
 CaseTemp() ;  // optional subroutine
 TempStruct6() ;
 TempLog() ;
 oledSixLogger() ; 
 // SerialDisplay() ; // optional subroutine for testing in lab 
 delay(LogInt) ; 
 
}

void SDcheck (void) {
	if (!SD.begin(chipSelect)) {
   Serial.println("Card failed, or not present");
   oled.setTextSize(1.5);
    oled.setTextColor(WHITE);
    oled.setCursor(0,0);
    oled.clearDisplay();
         delay(1);
   oled.println("Card failed...");
   oled.println("...or not in?");
       oled.display();
 return;
 }

     Serial.println("card initialized.");
        oled.setTextSize(1.5);
    oled.setTextColor(WHITE);
    oled.setCursor(0,0);
    oled.clearDisplay();
         delay(1);
   oled.println("Card initialized.");
       oled.display();
     delay(1000);
  
  File dataFile = SD.open("log.txt", FILE_WRITE);
  if (dataFile) {
  Serial.println("File open. Logging!");
         oled.setTextSize(2);
    oled.setTextColor(WHITE);
    oled.setCursor(0,0);
    oled.clearDisplay();
         delay(1);
   oled.println("Logging!");
       oled.display();
     delay(1000);
  delay(1000);
  }  
  // If the file is not open, pop up an error
  else {
  Serial.println("No file! Not logging!");
          oled.setTextSize(1.5);
    oled.setTextColor(WHITE);
    oled.setCursor(0,0);
    oled.clearDisplay();
         delay(1);
   oled.println("No file!");
   oled.println("Not logging!");
       oled.display();
  delay(1000);
   return;
  }
}

void RTCcheck (void) {
  if (! rtc.begin()) {
    Serial.println("Couldn't find RTC");
    while (1);
  }

  if (rtc.lostPower()) {
    Serial.println("RTC lost power. Resetting date/time.");
    // following line sets the RTC to the date & time this sketch was compiled
    rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));
    DateTime now = rtc.now();
     Serial.println("Date/time updated. Current date/time from new reference: ");
     Serial.print(now.year(), DEC); Serial.print('-');
     if (now.month() <10) Serial.print('0');
        Serial.print(now.month(), DEC); Serial.print('-');
     if (now.day() <10) Serial.print('0');
        Serial.print(now.day(), DEC); Serial.print(' ');
  Serial.print(now.hour(), DEC); Serial.print(':');
    if (now.minute() <10) Serial.print('0');
      Serial.print(now.minute(), DEC); Serial.print(':');
    if (now.second() <10) Serial.print('0');
  Serial.println(now.second(), DEC);
    delay(1000);
  }
    else {
      //rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));
      DateTime now = rtc.now();
     Serial.println("RTC initialized. Using previous time reference.");
     Serial.println("Current date/time:");
     if (now.month() <10) Serial.print('0');
        Serial.print(now.month(), DEC); Serial.print('-');
     if (now.day() <10) Serial.print('0');
        Serial.print(now.day(), DEC); Serial.print('-');
  Serial.print(now.year(), DEC); Serial.print(' ');
  Serial.print(now.hour(), DEC); Serial.print(':');
    if (now.minute() <10) Serial.print('0');
      Serial.print(now.minute(), DEC); Serial.print(':');
    if (now.second() <10) Serial.print('0');
  Serial.println(now.second(), DEC);

    oled.setTextSize(1);
    oled.setTextColor(WHITE);
    oled.setCursor(0,0);
    oled.clearDisplay();
         delay(1);
   oled.println("RTC initialized w/");
   oled.println("previous time ref.");
     oled.println("Current date/time:");
     if (now.month() <10) oled.print('0');
        oled.print(now.month(), DEC); oled.print('-');
     if (now.day() <10) oled.print('0');
        oled.print(now.day(), DEC); oled.print('-');
  oled.print(now.year(), DEC); oled.print(' ');
  oled.print(now.hour(), DEC); oled.print(':');
    if (now.minute() <10) oled.print('0');
      oled.print(now.minute(), DEC); oled.print(':');
    if (now.second() <10) oled.print('0');
  oled.println(now.second(), DEC);
     oled.display();
       delay(3000);
      }
}

void CaseTemp (void) {
// This optional subroutine reads the TMP36 for interior temperature. 
   int InnerTherm = analogRead(TempSense); 
   float voltage = InnerTherm * 3.3;
    voltage /= 1024.0; 
    SixLoggerData.CaseTempC = (voltage - 0.5) * 100 ;  
}

void TempStruct6 (void) {
  SixLoggerData.tc1 = thermocouple1.readCelsius();
  SixLoggerData.tc2 = thermocouple2.readCelsius();
  SixLoggerData.tc3 = thermocouple3.readCelsius();
  SixLoggerData.tc4 = thermocouple4.readCelsius();
  SixLoggerData.tc5 = thermocouple5.readCelsius();
  SixLoggerData.tc6 = thermocouple6.readCelsius();
      }

void TempRead6 (void) {
  temp[1] = thermocouple1.readCelsius();
  temp[2] = thermocouple2.readCelsius();
  temp[3] = thermocouple3.readCelsius();
  temp[4] = thermocouple4.readCelsius();
  temp[5] = thermocouple5.readCelsius();
  temp[6] = thermocouple6.readCelsius();
      }
      
void TimeStamper (void) {
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
   SixLoggerData.timestamp = String(String(now.year(), DEC)+
                                  "-"+String(now.month(), DEC)+
                                  "-"+String(now.day(), DEC)+
                                  " "+String(now.hour(), DEC)+
                                  ":"+String(now.minute(), DEC)+
                                  ":"+String(now.second(), DEC)+
                                  "."+String(counter, DEC));
                                  }

                                  
 void TempLog (void) {
  File dataFile = SD.open("log.txt", FILE_WRITE);
  // If the file is available, start with writing the current date and time to the output file
  if (dataFile) {
    dataFile.print(SixLoggerData.timestamp); dataFile.print(", ");
    dataFile.print(SixLoggerData.tc1);   dataFile.print(", "); 
    dataFile.print(SixLoggerData.tc2);   dataFile.print(", "); 
    dataFile.print(SixLoggerData.tc3);   dataFile.print(", "); 
    dataFile.print(SixLoggerData.tc4);   dataFile.print(", "); 
    dataFile.print(SixLoggerData.tc5);   dataFile.print(", "); 
    dataFile.print(SixLoggerData.tc6);   dataFile.print(", "); 
    dataFile.println(SixLoggerData.CaseTempC);
    dataFile.close();
 }
}


void oledInit (void) {
     // Initialize OLED display
  oled.begin(SSD1306_SWITCHCAPVCC, 0x3C);  // initialize with the I2C addr 0x3C (for the 128x32)
  oled.display();
  delay(500);
  oled.clearDisplay();
  oled.display();
}

void oledSixLogger (void) {

    oled.setTextSize(1);
    oled.setTextColor(WHITE);
    oled.setCursor(0,0);
    oled.clearDisplay();
         delay(1);
         oled.println(SixLoggerData.timestamp); 
         oled.print("1: "); oled.print(SixLoggerData.tc1); oled.print(", "); 
            oled.print("4: "); oled.println(SixLoggerData.tc4); 
          oled.print("2: "); oled.print(SixLoggerData.tc2); oled.print(", "); 
            oled.print("5: "); oled.println(SixLoggerData.tc5); 
          oled.print("3: "); oled.print(SixLoggerData.tc3); oled.print(", "); 
            oled.print("6: ");  oled.println(SixLoggerData.tc6); 
     oled.display();
}

void SerialDisplay (void) {
  Serial.print(SixLoggerData.timestamp); Serial.print(", ");
    Serial.print(SixLoggerData.tc1);   Serial.print(", "); 
    Serial.print(SixLoggerData.tc2);   Serial.print(", "); 
   Serial.print(SixLoggerData.tc3);   Serial.print(", "); 
    Serial.print(SixLoggerData.tc4);   Serial.print(", "); 
    Serial.print(SixLoggerData.tc5);   Serial.print(", "); 
    Serial.print(SixLoggerData.tc6);   Serial.print(", "); 
    Serial.println(SixLoggerData.CaseTempC);
 }


