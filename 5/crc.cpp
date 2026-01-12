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
    srand(time(0));
    int N = 20 + VAR;
    vector<uint8_t> data(N);
    for (int i = 0; i < N; i++)
        data[i] = rand() % 2;

    vector<uint8_t> poly = {1, 0, 1, 0, 0, 1, 1, 1};

    vector<uint8_t> crc = compute_crc(data, poly);

    cout << "N = " << N << endl;
    cout << "CRC: ";
    for (auto b : crc)
        cout << (int)b;
    cout << endl;

    vector<uint8_t> tx = data;
    tx.insert(tx.end(), crc.begin(), crc.end());

    cout << (check_crc(tx, poly) ? "Ошибок нет\n" : "Ошибка обнаружена\n") << endl;

    N = 250;
    data.resize(N);
    cout << "N = " << N << endl;
    for (int i = 0; i < N; i++)
        data[i] = rand() % 2;

    crc = compute_crc(data, poly);
    cout << "CRC: ";
    for (auto b : crc)
        cout << (int)b;
    cout << endl;

    tx = data;
    tx.insert(tx.end(), crc.begin(), crc.end());

    cout << (check_crc(tx, poly) ? "Ошибок нет\n" : "Ошибка обнаружена\n") << endl;
    cout << "Искажаем биты в цикле " << N + 7 << " раз..." << endl;

    int detected = 0, not_detected = 0;

    for (int i = 0; i < tx.size(); i++)
    {
        vector<uint8_t> corrupted = tx;
        corrupted[i] ^= 1;
        if (!check_crc(corrupted, poly))
            detected++;
        else
            not_detected++;
    }

    cout << "Обнаружено ошибок: " << detected << endl;
    cout << "Не обнаружено: " << not_detected << endl;
}
