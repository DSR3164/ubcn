#include <iostream>
#include <vector>
#include <cstdint>
#define VAR 16
using namespace std;

vector<uint8_t> compute_crc(const vector<uint8_t> &data, const vector<uint8_t> &poly)
{
    int n = poly.size() - 1;
    vector<uint8_t> work = data;
    work.resize(data.size() + n, 0);

    for (int i = 0; i < (int)work.size() - n; i++)
    {
        if (work[i] == 1)
        {
            for (int j = 0; j < (int)poly.size(); j++)
                work[i + j] ^= poly[j];
        }
    }

    vector<uint8_t> crc(work.end() - n, work.end());
    return crc;
}

bool check_crc(const vector<uint8_t> &packet, const vector<uint8_t> &poly)
{
    int n = poly.size() - 1;
    vector<uint8_t> r = packet;

    for (int i = 0; i < (int)r.size() - n; i++)
    {
        if (r[i] == 1)
        {
            for (int j = 0; j < (int)poly.size(); j++)
                r[i + j] ^= poly[j];
        }
    }

    for (int i = r.size() - n; i < (int)r.size(); i++)
        if (r[i] != 0)
            return false;

    return true;
}

int main()
{
    vector<double> err_len_1;
    vector<double> err_len_2;
    vector<double> err_len_3;
    vector<vector<uint8_t>> polys = {
        {1, 1, 0},      // CRC 2
        {1, 0, 1, 0},   // CRC 3
        {1, 0, 1, 1, 0} // CRC 4
    };
    srand(time(0));
    for (int i = 2; i <= 4; ++i) // CRC length
    {
        vector<double> probs;
        for (int j = 200; j <= 2000; j += 200) // message length
        {
            double undetected = 0.0;
            for (int test = 0; test < 1000; ++test) // 100 tests
            {
                vector<uint8_t> data(j);
                for (int n = 0; n < j; n++)
                    data[n] = rand() % 2;
                vector<uint8_t> crc = compute_crc(data, polys[i - 2]);
                data.insert(data.end(), crc.begin(), crc.end());

                data[rand() % data.size()] ^= 1;
                int w = (rand() % 3 + 1);
                int start = rand() % (data.size() - w);
                for (int k = 0; k < w; k++)
                    data[start + k] ^= 1;

                if (check_crc(data, polys[i - 2]))
                    undetected++;
            }
            probs.push_back(undetected / 100.0);
        }
        if (i == 2)
            err_len_1 = probs;
        else if (i == 3)
            err_len_2 = probs;
        else
            err_len_3 = probs;
    }

    for (int i = 0; i < err_len_1.size(); ++i)
    {
        int msg_len = 200 + i * 200;
        cout << msg_len << " "
             << (double)err_len_1[i] << " "
             << (double)err_len_2[i] << " "
             << (double)err_len_3[i] << endl;
    }

    return 0;
}
// вероятность не обнаружения ошибки для CRC длиной 2 3 4 в зависимтости от длины сообщения размер сообщения от 200 2000 с шагом 200
// сто проверок на точку от 1 до 3 искаженных бит в каждом сообщении