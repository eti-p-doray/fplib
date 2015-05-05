#include <fstream>
#include <stdint.h>

using namespace std;

const int N = 2;
uint8_t dataset[N][4] = {
  {63,  127,  0,  0},
  {63,  128,  0,  0}
};

int main() {
  ofstream ofs("operands.txt");
  for (int i = 0; i < N; ++i)
  {
    for (int j = 3; j >= 0; --j)
    {
      ofs << dataset[i][j];
    }
  }
  return 0;
}