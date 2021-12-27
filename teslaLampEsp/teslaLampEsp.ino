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

struct FLAKE
{
  byte x0 = 0;
  byte y0 = 30;
  byte x1 = 0;
  byte y1 = 29;
};

struct EDROP
{
  byte x = 0;
  byte y = 30;
};

String getStringValue(String data, char separator, int index)
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

int getXY(uint8_t x, uint8_t y)
{
  int num = 0;
  if (x % 2)
  {
    num = ((x + 1) * 30) - y - 1;
  }
  else
  {
    num = (x * 30) + y;
  } //num = (x*30)+y;
  //((x+1)*60)-y;}

  return num;
}

void listDir(fs::FS &fs, const char *dirname, uint8_t levels)
{
  Serial.printf("Listing directory: %s\r\n", dirname);

  File root = fs.open(dirname);
  if (!root)
  {
    Serial.println("- failed to open directory");
    return;
  }
  if (!root.isDirectory())
  {
    Serial.println(" - not a directory");
    return;
  }

  File file = root.openNextFile();
  while (file)
  {
    if (file.isDirectory())
    {
      Serial.print("  DIR : ");
      Serial.println(file.name());
      if (levels)
      {
        listDir(fs, file.name(), levels - 1);
      }
    }
    else
    {
      Serial.print("  FILE: ");
      Serial.print(file.name());
      Serial.print("\tSIZE: ");
      Serial.println(file.size());
    }
    file = root.openNextFile();
  }
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
      String sub = getStringValue(incomingString, ',', i);
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
  for (int i = 0; i < steps; i++)
  {
    for (int j = 0; j < 300; j++)
    {
      float r = f_img[j][0] + (s_img[j][0] - f_img[j][0]) * i / steps;
      float g = f_img[j][1] + (s_img[j][1] - f_img[j][1]) * i / steps;
      float b = f_img[j][2] + (s_img[j][2] - f_img[j][2]) * i / steps;
      float w = f_img[j][3] + (s_img[j][3] - f_img[j][3]) * i / steps;
      pixels.setPixelColor(j, r, g, b, w);
    }
    pixels.show();
    delay(time / 500);
  }
}

void play_snow(float speed = 0.5, int time = 10000, byte f_count = 15)
{
  unsigned long start_time = millis();

  // pixels.fill(pixels.Color(0, 0, 0, 3), 0, 299);
  uint32_t color = pixels.Color(0, 0, 0, 3);

  FLAKE flakes[f_count];
  for (int i = 0; i < f_count; i++)
  {
    flakes[i].x0 = random(0, 10);
    flakes[i].x1 = constrain(flakes[i].x0 + random(-1, 2), 0, 9);
    flakes[i].y0 = 29 - i;
    flakes[i].y1 = flakes[i].y0 - 1;
  }
  while ((millis() - start_time) < time)
  {
    pixels.clear();
    pixels.fill(pixels.Color(0, 0, 3, 0), 0, 299);
    for (int j = 0; j < 20; j++)
    {
      // pixels.fill(pixels.Color(0, 0, 0, 3), 0, 299);
      for (int i = 0; i < f_count; i++)
      {
        pixels.setPixelColor(getXY(flakes[i].x0, flakes[i].y0), 0, 0, 0, 20 - j);
        pixels.setPixelColor(getXY(flakes[i].x1, flakes[i].y1), 0, 0, 0, j);
      }
      delayMicroseconds(speed * 100.0);
      pixels.show();
    }
    for (int i = 0; i < f_count; i++)
    {
      flakes[i].x0 = flakes[i].x1;
      flakes[i].x1 = constrain(flakes[i].x0 + random(-1, 2), 0, 9);
      if (flakes[i].y1 == 0)
        flakes[i].y1 = 29;
      flakes[i].y0 = flakes[i].y1;
      flakes[i].y1 = flakes[i].y0 - 1;
    }
  }
}

void play_rain(float speed = 20, int time = 10000, byte f_count = 13)
{
  EDROP dp[f_count];

  unsigned long start_time = millis();

  for (int i = 0; i < f_count; i++)
  {
    dp[i].x = random(0, 10);
    dp[i].y = 26 - i*(26/f_count);
  }

  while ((millis() - start_time) < time)
  {
    pixels.clear();
    pixels.fill(pixels.Color(0, 0, 1, 0), 0, 299);

    for (int i = 0; i < f_count; i++)
    {
      pixels.setPixelColor(getXY(dp[i].x, dp[i].y), 1, 1, 5, 0);
      pixels.setPixelColor(getXY(dp[i].x, dp[i].y+1), 0, 0, 2, 0);
      pixels.setPixelColor(getXY(dp[i].x, dp[i].y+2), 0, 0, 1, 0);
    }
    delayMicroseconds(speed * 1000.0);
    pixels.show();

    for (int i = 0; i < f_count; i++)
    {
      dp[i].y = dp[i].y - 1;
      if (dp[i].y == 0)
        dp[i].y = 26;
    }
  }
}

void setup()
{

  Serial.begin(115200);
  Serial.setTimeout(3);
  delay(1000);
  pixels.begin();
  pixels.setBrightness(127);
  if (!SPIFFS.begin())
  {
    Serial.println("SPIFFS Mount Failed");
    return;
  }

  listDir(SPIFFS, "/", 0);
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

void loop()
{
  //   int LED[5] = {0, 255, 0, 0, 0};
  //   while (Serial.available())
  //   {
  //     String incomingString = Serial.readString();
  //     for (int i = 0; i < 5; i++)
  //     {
  //       String sub = getValue(incomingString, ',', i);
  //       LED[i] = sub.toInt();
  //     }
  //     pixels.setPixelColor(LED[0], pixels.Color(LED[1], LED[2], LED[3], LED[4]));
  //     Serial.println(incomingString);
  //
  //   }
  //   if (LED[0] == 299)
  //   {
  //     //    for (int k = 0; k < 300; k++)
  //     //    {
  //     //      Serial.println( pixels.getPixelColor(k));
  //     //    }
  //     pixels.show();
  //     delay(10);
  //   }
  // pixels.clear();
  // pixels.show();

  // uint16_t one_pic[300][4];
  // uint16_t two_pic[300][4];
  // for (int j = 1; j < 8; j++) //просмотр всех изображений
  // {
  //   String filename_one = String("/winter/")+String(j)+String(".txt");
  //   String filename_two = String("/winter/")+String(j+1)+String(".txt");
  //   read_file(one_pic, SPIFFS, filename_one.c_str());
  //   read_file(two_pic, SPIFFS, filename_two.c_str());

  //   change_image(one_pic,two_pic,3000);
  // }

  // read_file(one_pic, SPIFFS, "/8.txt");
  // read_file(two_pic, SPIFFS, "/1.txt");

  // change_image(one_pic,two_pic,1000);

  play_snow();
  play_rain();
}