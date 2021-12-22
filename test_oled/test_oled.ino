#include <Adafruit_SSD1306.h>

#include <SPI.h>
#include <Wire.h>
#include <Adafruit_GFX.h>


// создание объекта OLED
// адрес I2C - 0x3C
// SDA - 5, SCL - 4
Adafruit_SSD1306 display(0x3c, 5, 4);

void setup()
{
    // инициализация OLED
    display.init();
    // установить ориентацию экрана
    display.flipScreenVertically();
    // установка шрифта и размера
    display.setFont(ArialMT_Plain_24);
    // расположение текста
    display.setTextAlignment(TEXT_ALIGN_LEFT);
}

void loop()
{
    // очистить дисплей
    display.clear();
    // Вывод текста (в буфер)
    display.drawString(0, 0, "*Arduino-KIT*");
    // вывести изображение из буфера на экран
    display.display();
}
