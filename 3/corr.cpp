#include <functional>
#include <iostream>
#include <iomanip>
#include <vector>
#include <cmath>

using namespace std;

double norm_correlation(vector<int> &a, vector<int> &b)
{
    if (a.size() != b.size())
        return -2;
    double acc, acc1, acc2;
    acc = 0;
    acc1 = 0;
    acc2 = 0;
    for (int i = 0; i < (int)a.size(); ++i)
    {
        acc += a[i] * b[i];
        acc1 += a[i] * a[i];
        acc2 += b[i] * b[i];
    }

    return (acc / sqrt(acc1 * acc2));
}

int correlation(vector<int> &a, vector<int> &b)
{
    if (a.size() != b.size())
        return -2;
    int acc;
    acc = 0;
    for (int i = 0; i < (int)a.size(); ++i)
        acc += a[i] * b[i];

    return acc;
}

int output(vector<char> &names, vector<vector<int>> &vectors, function<double(vector<int>&, vector<int>&)> corr)
{
    cout << "\\ a  b  c" << endl;
    for (int i = 0; i < 3; ++i)
    {
        cout << names[i] << " ";
        for (int x = 0; x < 3; ++x)
        {
            if ((i==x))
                cout << "- ";
            else
                cout << corr(vectors[i], vectors[x]) << " " << setprecision(2);
        }
        cout << endl;
    }
    cout << endl;
    return 0;
}

int main()
{
    vector<int> a = {7, 3, 2, -2, -2, -4, 1, 5};
    vector<int> b = {2, 1, 5, 0, -2, -3, 2, 4};
    vector<int> c = {2, -1, 3, -9, -2, -8, 4, -1};
    vector<char> name = {'a', 'b', 'c'};
    vector<vector<int>> vectors = {a, b, c};

    output(name, vectors, correlation);
    output(name, vectors, norm_correlation);

    return 0;
}