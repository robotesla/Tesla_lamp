/*
    This sketch sends a message to a TCP server

*/
#include <Adafruit_NeoPixel.h>
#include <WiFi.h>
#include <NTPClient.h>
#include <WiFiUdp.h>
#include "FS.h"
#include "SPIFFS.h"

#define PIN 4 // On Trinket or Gemma, suggest changing this to 1

#define NUMPIXELS 300 // Popular NeoPixel ring size

Adafruit_NeoPixel pixels(NUMPIXELS, PIN, NEO_GRBW + NEO_KHZ800);

String message;

// Определение NTP-клиента для получения времени
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "europe.pool.ntp.org", 3600 * 3, 60000);

WiFiServer server(80);
char lineBuf[80];
int charCount = 0;

const char *wifi_network_ssid = "Pixel_4513";
const char *wifi_network_password = "87654321";

const char *soft_ap_ssid = "Tesla_lamp";
const char *soft_ap_password = "12345678";

void setup()
{

  Serial.begin(115200);
  Serial.setTimeout(3);
  delay(10);
  pixels.begin();
  pixels.setBrightness(127);
  if (!SPIFFS.begin())
  {
    Serial.println("SPIFFS Mount Failed");
    return;
  }
  //  // We start by connecting to a WiFi network
  //  WiFi.mode(WIFI_MODE_APSTA);
  //  WiFi.softAP(soft_ap_ssid, soft_ap_password);
  //  WiFi.begin(wifi_network_ssid, wifi_network_password);
  //
  //  Serial.println();
  //  Serial.println();
  //  Serial.print("Waiting for WiFi... ");
  //
  //  while (WiFi.status() != WL_CONNECTED) {
  //    Serial.print(".");
  //    delay(500);
  //  }
  //
  //  Serial.println("");
  //  Serial.println("WiFi connected");
  //  Serial.println("IP address in STA: ");
  //  Serial.println(WiFi.localIP());
  //  Serial.print("ESP32 IP as soft AP: ");
  //  Serial.println(WiFi.softAPIP());
  //  timeClient.begin();
  //  server.begin();
  //  delay(500);
}

void read_file(uint16_t (*array)[4], fs::FS &fs, const char *path)
{

  // static int array[300][4];

  Serial.printf("Reading file: %s\r\n", path);
  File file = fs.open(path);

  uint16_t LED[5] = {0, 255, 0, 0, 0};
  while (file.available())
  {
    String incomingString = file.readStringUntil('\n');
    // Serial.println("read_string");
    // Serial.println(incomingString);
    for (int i = 0; i < 5; i++)
    {
      String sub = getValue(incomingString, ',', i);
      LED[i] = sub.toInt();
    }
    //pixels.setPixelColor(LED[0], pixels.Color(LED[1], LED[2], LED[3], LED[4]));
    array[LED[0]][0] = LED[1];
    array[LED[0]][1] = LED[2];
    array[LED[0]][2] = LED[3];
    array[LED[0]][3] = LED[4];
  }
  file.close();
  // pixels.show();
}

String getValue(String data, char separator, int index)
{
  int found = 0;
  int strIndex[] = {0, -1};
  int maxIndex = data.length() - 1;

  for (int i = 0; i <= maxIndex && found <= index; i++)
  {
    if (data.charAt(i) == separator || i == maxIndex)
    {
      found++;
      strIndex[0] = strIndex[1] + 1;
      strIndex[1] = (i == maxIndex) ? i + 1 : i;
    }
  }

  return found > index ? data.substring(strIndex[0], strIndex[1]) : "";
}

void show_image(uint16_t (*array)[4])
{
  for (int i = 0; i < 300; i++)
    {
      pixels.setPixelColor(i, pixels.Color(array[i][0], array[i][1], array[i][2], array[i][3]));
    }
    pixels.show();
}

void change_image(uint16_t (*f_img)[4], uint16_t (*s_img)[4], int time = 3000)
{
  int steps = 500;
  for(int i = 0; i < steps; i++)
  {
    for (int j = 0; j < 300; j++)
    {
      float r = f_img[j][0] + (s_img[j][0] - f_img[j][0])*i/steps;
      float g = f_img[j][1] + (s_img[j][1] - f_img[j][1])*i/steps;
      float b = f_img[j][2] + (s_img[j][2] - f_img[j][2])*i/steps;
      float w = f_img[j][3] + (s_img[j][3] - f_img[j][3])*i/steps;
      pixels.setPixelColor(j, r, g, b, w);
    }
    pixels.show();
    delay(time/500);
  }
}

void loop()
{
  //  int LED[5] = {0, 255, 0, 0, 0};
  //  while (Serial.available())
  //  {
  //    String incomingString = Serial.readString();
  //    for (int i = 0; i < 5; i++)
  //    {
  //      String sub = getValue(incomingString, ',', i);
  //      LED[i] = sub.toInt();
  //    }
  //    pixels.setPixelColor(LED[0], pixels.Color(LED[1], LED[2], LED[3], LED[4]));
  //    Serial.println(incomingString);
  //
  //  }
  //  if (LED[0] == 299)
  //  {
  //    //    for (int k = 0; k < 300; k++)
  //    //    {
  //    //      Serial.println( pixels.getPixelColor(k));
  //    //    }
  //    pixels.show();
  //    delay(10);
  //  }
  // pixels.clear();
  // pixels.show();

  uint16_t one_pic[300][4];
  uint16_t two_pic[300][4];

  for (int j = 1; j < 8; j++) //просмотр всех изображений
  {
    String filename_one = String("/")+String(j)+String(".txt");
    String filename_two = String("/")+String(j+1)+String(".txt");
    read_file(one_pic, SPIFFS, filename_one.c_str());
    read_file(two_pic, SPIFFS, filename_two.c_str());

    change_image(one_pic,two_pic,1000);
  }

  read_file(one_pic, SPIFFS, "/8.txt");
  read_file(two_pic, SPIFFS, "/1.txt");

  change_image(one_pic,two_pic,1000);
  // change_image(two_pic,one_pic);


}