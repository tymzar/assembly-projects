#include <iostream>
#include <fstream>
#include <vector>
#include <cstring>

#define WIDTH 600
#define HEIGHT 50
#define BYTES_PER_PIXEL 3
#define IMAGE_SIZE (WIDTH * HEIGHT * BYTES_PER_PIXEL)
#define HEADER_OFFSET 54
#define BMP_FILE_SIZE (IMAGE_SIZE + HEADER_OFFSET)

extern "C" int encodeRM4SCC(unsigned char *dest_bitmap, int bar_width, char *text);

#pragma pack(push, 1) // Ensures correct alignment of the struct
struct BMPHeader
{
  char signature[2] = {'B', 'M'};
  uint32_t fileSize = BMP_FILE_SIZE;
  uint32_t reserved = 0;
  uint32_t dataOffset = HEADER_OFFSET;
  uint32_t headerSize = 40;
  uint32_t imageWidth = WIDTH;
  uint32_t imageHeight = HEIGHT;
  uint16_t planes = 1;
  uint16_t bitsPerPixel = 24;
  uint32_t compression = 0;
  uint32_t imageSize = IMAGE_SIZE;
  uint32_t xPixelsPerMeter = 0;
  uint32_t yPixelsPerMeter = 0;
  uint32_t totalColors = 2;
  uint32_t importantColors = 0;
};
#pragma pack(pop)

int main()
{
  std::vector<unsigned char> dest_bitmap(BMP_FILE_SIZE, 0);

  BMPHeader header;
  std::memcpy(dest_bitmap.data(), &header, sizeof(BMPHeader));

  // Make the whole image white
  std::memset(dest_bitmap.data() + HEADER_OFFSET, 0xff, IMAGE_SIZE);

  // Read the width in pixels of the narrowest bar
  int bar_width = 1;
  std::cout << "Enter the width of a bar (in pixels): ";
  std::cin >> bar_width;

  // read text to encode
  char text[30];
  std::cout << "Enter the text to encode: ";
  std::cin >> text;

  int result = encodeRM4SCC(dest_bitmap.data(), bar_width, text);

  if (result == 1)
  {
    throw std::runtime_error("Error: Invalid text to encode");
  }

  if (result == 0)
  {
    std::ofstream file("output.bmp", std::ios::binary);
    file.write(reinterpret_cast<char *>(dest_bitmap.data()), BMP_FILE_SIZE);
    file.close();
  }

  return 0;
}
