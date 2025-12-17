#include <functional>
#include <algorithm>
#include <iostream>
#include <iomanip>
#include <vector>
#include <cmath>

#define VAR 16

using namespace std;

int gold(int N, int x, int y, vector<int> &out_list)
{
    int tempx, tempy;
    int out;
    for (int i = 0; i < N; ++i)
    {
        tempx = ((x & 0x2) >> 1) ^ (x & 0x1);
        x = (tempx << 4) | (x >> 1);

        tempy = ((y & 0x8) >> 3) ^ (y & 0x1);
        y = (tempy << 4) | (y >> 1);

        out = (x & 0x1) ^ (y & 0x1);
        out_list.push_back(out);
    }
    return 0;
}

double auto_correlation(vector<int> &a, vector<int> &b)
{
    if (a.size() != b.size())
        return -2;
    double acc = 0;
    double out;
    for (int i = 0; i < (int)a.size(); ++i)
        acc += (double)(a[i] ^ b[i]);
    out = (((double)a.size() - acc) - acc) / (double)a.size();
    return out;
}

double correlation(vector<int> &a, vector<int> &b)
{
    if (a.size() != b.size())
        return -2;
    for (auto &v : a)
        v = 2 * v - 1;
    for (auto &v : b)
        v = 2 * v - 1;
    double acc, acc1, acc2;
    acc = 0.0;
    acc1 = 0.0;
    acc2 = 0.0;
    for (int i = 0; i < (int)a.size(); ++i)
    {
        acc += a[i] * b[i];
        acc1 += a[i] * a[i];
        acc2 += b[i] * b[i];
    }
    for (auto &v : a)
        v = (v + 1) / 2;
    for (auto &v : b)
        v = (v + 1) / 2;
    return (acc / sqrt(acc1 * acc2));
}

int check_sequence(vector<int> &out)
{
    const int N = out.size();

    // Баланс
    int ones = count(out.begin(), out.end(), 1);
    int zeros = N - ones;
    cout << "Нулей: " << zeros << "\nЕдиниц: " << ones << endl;
    if (abs(ones - zeros) > 1)
    {
        cout << "1 условие неудовлетворено\n";
        return -1;
    }

    // Проверка циклов
    vector<int> runs;
    int len = 1;
    for (int i = 1; i < N; ++i)
    {
        if (out[i] == out[i - 1])
            len++;
        else
        {
            runs.push_back(len);
            len = 1;
        }
    }
    runs.push_back(len);
    int total_runs = runs.size();

    for (int k = 1; k <= 4; ++k)
    {
        int cnt = count(runs.begin(), runs.end(), k);
        double ratio = (double)cnt / total_runs;
        double expected = 1.0 / pow(2.0, k);
        cout << cnt << " последовательностей длиной " << k << endl;
        if (fabs(ratio - expected) > 0.15 * expected)
        {
            cout << "2 условие неудовлетворено\n";
            return -2;
        }
    }

    // Корреляция
    for (int s = N - 1; s > 1; --s)
    {
        vector<int> shifted(out);
        rotate(shifted.begin(), shifted.begin() + s, shifted.end());
        double r = auto_correlation(out, shifted);
        if (fabs(r) > 0.3)
        {
            cout << "3 условие неудовлетворено на сдвиге " << s << " при корр = " << r << endl;
            return -3;
        }
    }

    cout << "Последовательность соответствует требованиям\n";
    return 0;
}

int main()
{
    int x = VAR & 0x1f;
    int y = (x + 7) & 0x1f;
    int x2 = (VAR + 1) & 0x1f;
    int y2 = (x2 + 7 - 5) & 0x1f;
    int shift;
    int N = 31;
    vector<int> out;
    vector<int> out2;
    gold(N, x, y, out);
    check_sequence(out);
    vector<double> norm_corr;
    for (size_t i = 0; i < out.size(); ++i)
    {
        if (i == 0)
        {
            cout << "Сдвиг\t";
            for (size_t y = 1; y <= out.size(); ++y)
                cout << y << (y > 30 ? "" : "  ");
            cout << "\tАвтокорреляция" << endl;
        }
        vector<int> shifted(out);
        shift = shifted.size() - (i % shifted.size());

        rotate(shifted.begin(),
               shifted.begin() + shift,
               shifted.end());

        norm_corr.push_back(auto_correlation(out, shifted));
        cout << i << "\t";
        for (size_t h = 0; h < out.size(); ++h)
        {
            cout << shifted[h] << (h > 8 ? "   " : "  ");
        }
        cout << fixed << setprecision(3) << "\t" << norm_corr[i] << endl;
    }
    gold(N, x2, y2, out2);
    cout << "\nx=x+1; y=y-5:\n"
         << "Взаимная корреляция: "
         << correlation(out, out2) << endl;
    check_sequence(out2);
    return 0;
}