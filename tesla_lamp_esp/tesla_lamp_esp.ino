/*
    This sketch sends a message to a TCP server

*/
#include <Adafruit_NeoPixel.h>
#include <WiFi.h>
#include <NTPClient.h>
#include <WiFiUdp.h>

#define PIN        4 // On Trinket or Gemma, suggest changing this to 1

#define NUMPIXELS 300 // Popular NeoPixel ring size

Adafruit_NeoPixel pixels(NUMPIXELS, PIN, NEO_GRBW + NEO_KHZ800);

String message;



// Определение NTP-клиента для получения времени
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "europe.pool.ntp.org", 3600 * 3, 60000);

WiFiServer server(80);
char lineBuf[80];
int charCount = 0;

const char* wifi_network_ssid = "Pixel_4513";
const char* wifi_network_password =  "87654321";

const char *soft_ap_ssid = "Tesla_lamp";
const char *soft_ap_password = "12345678";

void setup()
{

  Serial.begin(115200);
  Serial.setTimeout(3);
  delay(10);
  pixels.begin();
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
  //delay(10);
  //  Serial.println("Connecting to NTP");
  //  Serial.print(timeClient.getHours());
  //  Serial.print(":");
  //  Serial.print(timeClient.getMinutes());
  //  Serial.print(":");
  //  Serial.println(timeClient.getSeconds());
  //  Serial.println(timeClient.getFormattedTime());


  //  WiFiClient client = server.available(); // прослушка входящих клиентов
  //  if (client) {
  //    Serial.println("New client");
  //    timeClient.update();
  //    memset(lineBuf, 0, sizeof(lineBuf));
  //    charCount = 0;
  //    // HTTP-запрос заканчивается пустой строкой
  //    boolean currentLineIsBlank = true;
  //    while (client.connected()) {
  //      Serial.println("client.connected()");
  //      client.println("HTTP/1.1 200 OK");
  //      client.println("Content-Type: text/html");
  //      client.println("Connection: close");
  //      client.println();
  //
  //      // формируем веб-страницу
  //      String webPage = "<!DOCTYPE HTML>";
  //      webPage += "<html>";
  //      webPage += "<head>";
  //      webPage += "<meta name=\"viewport\" content=\"width=device-width,";
  //      webPage += "initial-scale=1\">";
  //      webPage += "</head>";
  //      webPage += "<body>";
  //      webPage += "<h1>ESP32 - Web Server</h1>";
  //      webPage += "<p>Hours:";
  //      webPage +=    timeClient.getHours();
  //      webPage += "</p>";
  //      webPage += "<p>Minutes:";
  //      webPage +=    timeClient.getMinutes();
  //      webPage += "</p>";
  //      webPage += "<p>Seconds";
  //      webPage +=    timeClient.getSeconds();
  //      webPage += "</p>";
  //      webPage += "</body></html>";
  //      client.println(webPage);
  //      break;
  //    }
  //    // Даём веб-браузеру время для получения данных
  //    delay(1000);
  //    // Закрываем соединение
  //    client.stop();
  //    Serial.println("client disconnected");
  //  }

  int LED[5] = {0, 255, 0, 0, 0};
  while (Serial.available())
  {
    String incomingString = Serial.readString();
    for (int i = 0; i < 5; i++)
    {
      String sub = getValue(incomingString, ',', i);
      LED[i] = sub.toInt();
    }
    pixels.setPixelColor(LED[0], pixels.Color(LED[1], LED[2], LED[3], LED[4]));
    Serial.println(incomingString);

  }
  if (LED[0] == 299)
  {
    //    for (int k = 0; k < 300; k++)
    //    {
    //      Serial.println( pixels.getPixelColor(k));
    //    }
    pixels.show();
    delay(10);
  }


}

String getValue(String data, char separator, int index)
{
  int found = 0;
  int strIndex[] = {0, -1};
  int maxIndex = data.length() - 1;

  for (int i = 0; i <= maxIndex && found <= index; i++) {
    if (data.charAt(i) == separator || i == maxIndex) {
      found++;
      strIndex[0] = strIndex[1] + 1;
      strIndex[1] = (i == maxIndex) ? i + 1 : i;
    }
  }

  return found > index ? data.substring(strIndex[0], strIndex[1]) : "";
}
