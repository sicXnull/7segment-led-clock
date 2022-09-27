
/*
  To upload through terminal you can use: curl -F "image=@firmware.bin" esp8266-webupdate.local/update
*/

#include <math.h>
#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <ESP8266WebServer.h>
#include <ESP8266HTTPUpdateServer.h>
#include <Wire.h>
#include <uRTCLib.h>
#include <ezTime.h> /* https://github.com/ropg/ezTime minimal version 0.7.10 */
#include <SparkFun_APDS9960.h> /* https://github.com/jonn26/SparkFun_APDS-9960_Sensor_Arduino_Library */

const char* update_path = "/firmware";
const char* update_username = "admin";
const char* update_password = "admin";

const char* ssid = "wifi_clk";
const char* password = "clkCLK123";

const char* myTimeZone = "Europe/Prague";  // see https://en.wikipedia.org/wiki/List_of_tz_database_time_zones

bool disconnected = true;
Timezone localTZ;

uRTCLib rtc(URTCLIB_ADDRESS);
time_t lastRtcUpdate = 0;

ESP8266WebServer httpServer(80);
ESP8266HTTPUpdateServer httpUpdater;

// I2C Pins
#define I2C_SDA    D4
#define I2C_SCL    D3

// Global Variables
SparkFun_APDS9960 apds = SparkFun_APDS9960();
uint16_t ambient_light = 0;
uint16_t red_light = 0;
uint16_t green_light = 0;
uint16_t blue_light = 0;

//int rgb_r=7;
//int rgb_g=2;
//int rgb_b=0;

int rgb_r=30;
int rgb_g=30;
int rgb_b=0;
bool dotBlink = true;

unsigned long ambientMillis;
unsigned long ambientPeriod = 1000;

const char* statusString ()
{
  switch(timeStatus())
  {
    case timeNotSet:
      return "timeNotSet";
    case timeSet:
      return "timeSet";
    case timeNeedsSync:
      return "timeNeedsSync";
    default:
      return "unknown";
  }
}

int lightFunc (int x)
{
  int y;
  if (x <= 32)
  {
    y = x;  
  }
  else
  {
    y = 32+sqrt(x-32);
  }
  return (y*3)/4;
}

void handleRoot() {
  
  handleSetting();

  rtc.refresh();

  int sec = millis() / 1000;
  int min = sec / 60;
  int hr = min / 60;

  char ut [50];
  snprintf ( ut, 50, "%dd %02d:%02d:%02d", hr/24, hr%24, min % 60, sec % 60);

  time_t lastUpdt = ezt::lastNtpUpdateTime();
  String temp = "";
  temp = temp + 
"<html>\
  <head>\
    <title>ESP8266 based clock</title>\
  </head>\
  <body>\
    <h1>ESP8266 based clock</h1>\
    <form action=\"/\" method=\"get\">\
      <p>\
        R:<input type=\"text\" name=\"r\" value=\"" + rgb_r + "\">\
        G:<input type=\"text\" name=\"g\" value=\"" + rgb_g + "\">\
        B:<input type=\"text\" name=\"b\" value=\"" + rgb_b + "\">\
      </p>\
      <p>\
        dotBlink:<input type=\"text\" name=\"dotBlink\" value=\"" + dotBlink + "\">\
      </p>\
      <input type=\"submit\">\
    </form>\
    <p>Time: " + localTZ.dateTime() + "</p>\
    <p>Time(RFC3339_EXT): " + localTZ.dateTime(RFC3339_EXT) + "</p>\
    <p>TimeZone: \""+myTimeZone+"\" posix:" + localTZ.getPosix() + " status:" + statusString() + " lastNTPupdate: " + (UTC.now() - lastUpdt) + "s ago</p>\
    <p>Uptime: " + ut + "</p>\
    <p>Ambient light: L=" + ambient_light + " R=" + red_light + " G=" + green_light + " B=" + blue_light + "</p>\
    <p>free heap " + ESP.getFreeHeap() + "</p>\
    <p>DS3231 " + (rtc.year()+2000) + ":" + rtc.month() + ":" + rtc.day() + " " + rtc.hour() + ":" + rtc.minute() + ":" + rtc.second() + " &tau;=" + rtc.temp() + "&deg;C (update " + (UTC.now()-lastRtcUpdate) +  "s ago)</p>\
    <p><a href=\"/firmware\">Firmware update</a></p>\
  </body>\
</html>";
  httpServer.send ( 200, "text/html", temp );
}


void setup(void){
  RGBsetup();

  //Start I2C with pins defined above
  Wire.begin(I2C_SDA,I2C_SCL);

  Serial.begin(115200);
  Serial.println();
  Serial.println("Booting Sketch...");
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);

  httpServer.on ( "/", handleRoot );
  httpUpdater.setup(&httpServer, update_path, update_username, update_password);
  httpServer.begin();

  flashSizeInfo();

  setDebug(INFO);
//  setInterval(60);
//  setServer("192.168.62.252");

  // Initialize APDS-9960 (configure I2C and initial values)
  if ( apds.init() ) {
    Serial.println(F("APDS-9960 initialization complete"));
  } else {
    Serial.println(F("Something went wrong during APDS-9960 init!"));
  }
  
  // Start running the APDS-9960 light sensor (no interrupts)
  if ( apds.enableLightSensor(false) ) {
    Serial.println(F("Light sensor is now running"));
  } else {
    Serial.println(F("Something went wrong during light sensor init!"));
  }
  rtc.refresh();
  UTC.setTime(rtc.hour(), rtc.minute(), rtc.second(), rtc.day(), rtc.month(), rtc.year()+2000);
  ambientMillis = millis();
}

void loop(void){
  // Wait for connection
  if ( WiFi.status() == WL_CONNECTED )
  {
    if (disconnected)
    {
      Serial.println ( "" );
      Serial.print ( "Connected to " );
      Serial.println ( ssid );
      Serial.print ( "IP address: " );
      Serial.println ( WiFi.localIP() );

      disconnected = false;
      
      Serial.printf("HTTPUpdateServer ready!\nOpen http://");
      Serial.print ( WiFi.localIP() );
      Serial.printf("%s in your browser and login with username '%s' and password '%s'\n", 
                    update_path, update_username, update_password);
    
      //waitForSync(5);
      updateNTP();
      //localTZ.setDefault();
      localTZ.setLocation(myTimeZone);
    } else {}
  }
  else
  {
    disconnected = true;
  }

  unsigned long currentMillis = millis();
  if (currentMillis - ambientMillis >= ambientPeriod)
  {
    ambientMillis = currentMillis;
    // Read the light levels (ambient, red, green, blue)
    if (  !apds.readAmbientLight(ambient_light) ||
          !apds.readRedLight(red_light) ||
          !apds.readGreenLight(green_light) ||
          !apds.readBlueLight(blue_light) ) {
      Serial.println("Error reading light values");
    }
    else
    {
      rgb_r = lightFunc(ambient_light);
      if (rgb_r > 255)
      {
        rgb_r = 255;
      } 
      else if (rgb_r < 2)
      {
        rgb_r = 2;
      }
      rgb_g = rgb_r - 2;
    }
  }
  if (timeStatus() == timeSet)
  {
    //  RTCLib::set(byte second, byte minute, byte hour, byte dayOfWeek, byte dayOfMonth, byte month, byte year)
    time_t t = UTC.now();
    time_t deltaTime = t - lastRtcUpdate;
    if ((deltaTime > 3600) || (deltaTime < 0))
    {
      rtc.set(second(t), minute(t), hour(t), weekday(t), day(t), month(t), year(t)-2000);
      lastRtcUpdate = t;
    }
  }
  httpServer.handleClient();
  showTime(localTZ.now());
  events();
}

