#include <functional>
#include <algorithm>
#include <iostream>
#include <iomanip>
#include <vector>
#include <cmath>

#define VAR 16

using namespace std;

int gold(int x, int y, vector<int> &out_list)
{
    int tempx, tempy;
    int out;
    for (int i = 0; i < 31; ++i)
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
    out = (((double)a.size() - acc) - acc) / 31;
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
        v = (v + 1)/2;
    for (auto &v : b)
        v = (v + 1)/2;
    return (acc / sqrt(acc1 * acc2));
}

int main()
{
    int x = VAR & 0x1f;
    int y = (x + 7) & 0x1f;
    int x2 = (VAR + 1) & 0x1f;
    int y2 = (x2 + 7 - 5) & 0x1f;
    int shift;
    vector<int> out;
    vector<int> out2;
    gold(x, y, out);
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

    gold(x2, y2, out2);

    cout << "\nx=x+1; y=y-5:\n"
         << "Взаимная корреляция: "
         << correlation(out, out2) << endl;
    for (auto &n: out)
        cout << n << "  ";
    return 0;
}