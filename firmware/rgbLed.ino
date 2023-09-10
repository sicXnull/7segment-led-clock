 #include <Adafruit_NeoPixel.h>

#define LED_PIN      4 /* D2 */
#define LEDS_PER_SEGMENT 2 /* for 7-segment digits only */
#define DIGITS 4 /* 4="88:88" or 6="88:88:88" */

#if DIGITS == 6
#  define SEC_01_DIGIT (0)
#  define SEC_10_DIGIT (SEC_01_DIGIT + 1)
#  define MIN_01_DIGIT (SEC_10_DIGIT + 1)
#  define MIN_DOTS (2)
#else
#  define MIN_01_DIGIT (0)
#  define MIN_DOTS (0)
#endif
#define MIN_10_DIGIT (MIN_01_DIGIT + 1)
#define HOUR_01_DIGIT (MIN_10_DIGIT + 1)
#define HOUR_10_DIGIT (HOUR_01_DIGIT + 1)
#define HOUR_DOTS (MIN_DOTS + 2)

#define SEGMENTS_PER_DIGIT 7 /* for 7-segment digits , don't change*/


Adafruit_NeoPixel pixels = Adafruit_NeoPixel(14*4 + 2, LED_PIN, NEO_GRB + NEO_KHZ800);

uint32_t rgb[LEDS_PER_SEGMENT*7*4 + 2];

void RGBsetup() {
  pixels.begin(); // This initializes the NeoPixel library.
  for (int i=0; i<LEDS_PER_SEGMENT*7*4 + 2; i++)
  {
    rgb[i]=0;
  }
}

const uint8_t hexTable[] =
{
  0x7d, // 0 0x00   xxxxx.x
  0x30, // 1 0x01   .xx....               bit #
  0x5b, // 2 0x02   x.xx.xx
  0x7a, // 3 0x03   xxxx.x.             ....3....
  0x36, // 4 0x04   .xx.xx.             .       .
  0x6e, // 5 0x05   xx.xxx.             2       4
  0x6f, // 6 0x06   xx.xxxx             .       .
  0x38, // 7 0x07   .xxx...             ....1....
  0x7f, // 8 0x08   xxxxxxx             .       .
  0x7e, // 9 0x09   xxxxxx.             0       5
  0x3f, // A 0x0a   .xxxxxx             .       .       
  0x67, // b 0x0b   xx..xxx             ....6....
  0x43, // c 0x0c   x....xx
  0x73, // d 0x0d   xxx..xx
  0x4f, // E 0x0e   x..xxxx
  0x0f, // F 0x0f   ...xxxx
  0x1e, // ° 0x10   ..xxxx.
  0x4d, // C 0x11   x..xx.x
  0x02, // - 0x12   .....x.
  0x40, // _ 0x13   x......
  0x00, //   0x14   .......
};

const uint8_t pos2segment[DIGITS] =
{
#if DIGITS == 6
  SEC_01_DIGIT*LEDS_PER_SEGMENT*SEGMENTS_PER_DIGIT,                  // 88:88:8x    hh:mm:ss
  SEC_10_DIGIT*LEDS_PER_SEGMENT*SEGMENTS_PER_DIGIT,                  // 88:88:x8    hh:mm:ss
#endif
  MIN_01_DIGIT*LEDS_PER_SEGMENT*SEGMENTS_PER_DIGIT + MIN_DOTS,       // 88:8x...    hh:mm...
  MIN_10_DIGIT*LEDS_PER_SEGMENT*SEGMENTS_PER_DIGIT + MIN_DOTS,       // 88:8x...    hh:mm...
  HOUR_01_DIGIT*LEDS_PER_SEGMENT*SEGMENTS_PER_DIGIT + HOUR_DOTS,     // 88:8x...    hh:mm...
  HOUR_10_DIGIT*LEDS_PER_SEGMENT*SEGMENTS_PER_DIGIT + HOUR_DOTS,     // 88:8x...    hh:mm...
};

void sevenSegment(int pos, int val)
{
  uint8_t digit = hexTable[val];
  uint32_t color = pixels.Color(rgb_r, rgb_g, rgb_b);
  int j = pos2segment[pos];
  for (uint8_t i=0; i<7; i++)
  {
    if (0 != (digit & ((uint8_t)1 << i)))
    {
      int k;
      for (k=0; k<LEDS_PER_SEGMENT ; k++)
      {
        rgb[j++] = color;
      }
    }
    else
    {
      int k;
      for (k=0; k<LEDS_PER_SEGMENT ; k++)
      {
        rgb[j++] = 0;
      }
    }
  }
}

void time2sys(time_t t)
{
  setTime(t);
}

time_t last_t;

void showTime(time_t t)
{
  if (t != last_t)
  {
    last_t = t;
    int h = hour(t);
    if (h > 12)
    { 
      h = h - 12;
    }
    if (h == 0)
    { 
      h = 12;
    }
    if (h >= 10)
    { 
      sevenSegment(HOUR_10_DIGIT, h / 10);
    }
    else
    {
      sevenSegment(HOUR_10_DIGIT, 0x14);
    }
    sevenSegment(HOUR_01_DIGIT, h % 10);
    int m = minute(t);
    sevenSegment(MIN_10_DIGIT, m / 10);
    sevenSegment(MIN_01_DIGIT, m % 10);
    int s = second(t);
    
#if DIGITS == 6
    sevenSegment(SEC_10_DIGIT, s / 10);
    sevenSegment(SEC_01_DIGIT, s % 10);
#endif

    uint32_t dotColor;
    if (dotBlink && (s&1)) 
    {
      dotColor = 0;
    }
    else
    {
      dotColor = pixels.Color(rgb_r, rgb_g, rgb_b);
    }
#if DIGITS == 6
    rgb[MIN_01_DIGIT*LEDS_PER_SEGMENT*SEGMENTS_PER_DIGIT + 0] = dotColor;
    rgb[MIN_01_DIGIT*LEDS_PER_SEGMENT*SEGMENTS_PER_DIGIT + 1] = dotColor;
#endif
    rgb[HOUR_01_DIGIT*LEDS_PER_SEGMENT*SEGMENTS_PER_DIGIT + MIN_DOTS + 0] = dotColor;
    rgb[HOUR_01_DIGIT*LEDS_PER_SEGMENT*SEGMENTS_PER_DIGIT + MIN_DOTS + 1] = dotColor;
    for (int i=0; i<LEDS_PER_SEGMENT*7*4 + 2; i++)
    {
      pixels.setPixelColor(i, rgb[i]);
    }
    yield();
    pixels.show(); // This sends the updated pixel color to the hardware.
  }
}

uint8_t v_0_255(int v)
{
  if (v<0) return 0;
  if (v>255) return 255;
  return v;
}

void handleSetting() {
  // get the value of request argument "state" and convert it to an int
  int httpArgs = httpServer.args();
  int i;
  for (i = 0; i<httpArgs; i++)
  {
    if (httpServer.argName(i) == "r")
    {
      rgb_r = v_0_255(httpServer.arg(i).toInt());
    } else
    if (httpServer.argName(i) == "g")
    {
      rgb_g = v_0_255(httpServer.arg(i).toInt());
    } else
    if (httpServer.argName(i) == "b")
    {
      rgb_b = v_0_255(httpServer.arg(i).toInt());
    } else
    if (httpServer.argName(i) == "dotBlink")
    {
      dotBlink = (httpServer.arg(i).toInt() != 0);
    } else {}
  }
}
