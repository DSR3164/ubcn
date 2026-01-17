#include <pybind11/pybind11.h>
#include <pybind11/stl.h>
#include <pybind11/numpy.h>
#include <iostream>
#include <complex>
#include <fftw3.h>
#include <vector>
#include <string>
#include <cmath>
namespace py = pybind11;

std::vector<int> text_to_bits(const std::string &text)
{
    std::vector<int> bits;
    for (unsigned char ch : text)
    {
        for (int i = 7; i >= 0; --i)
            bits.push_back((ch >> i) & 1);
    }
    return bits;
}

std::string bits_to_text(const std::vector<int> &bits)
{
    std::string text;
    for (size_t i = 0; i < bits.size(); i += 8)
    {
        unsigned char ch = 0;
        for (int j = 0; j < 8; ++j)
            ch = (ch << 1) | bits[i + j];
        text.push_back(ch);
    }
    return text;
}

std::vector<int> crc_bits(std::vector<int> data_bits, const std::vector<int> &poly_bits)
{
    int crc_len = poly_bits.size() - 1;
    data_bits.resize(data_bits.size() + crc_len, 0);

    for (size_t i = 0; i < data_bits.size() - crc_len; ++i)
    {
        if (data_bits[i] == 1)
        {
            for (size_t j = 0; j < poly_bits.size(); ++j)
                data_bits[i + j] ^= poly_bits[j];
        }
    }
    return std::vector<int>(data_bits.end() - crc_len, data_bits.end());
}

std::vector<int> gold_sequence(int N, int x, int y)
{
    std::vector<int> out;
    out.reserve(N);
    for (int i = 0; i < N; ++i)
    {
        int tempx = ((x >> 1) & 1) ^ (x & 1);
        x = (tempx << 4) | (x >> 1);

        int tempy = ((y >> 3) & 1) ^ (y & 1);
        y = (tempy << 4) | (y >> 1);

        out.push_back((x & 1) ^ (y & 1));
    }
    return out;
}

py::array_t<double> bits_to_signal(const std::vector<int> &bits, int N)
{
    py::array_t<double> arr(bits.size() * N);
    auto buf = arr.mutable_unchecked<1>();

    size_t k = 0;
    for (int b : bits)
        for (int i = 0; i < N; ++i)
            buf(k++) = static_cast<double>(b);

    return arr;
}

py::array_t<double> add_noise(py::array_t<double> signal, double sigma)
{
    py::array_t<double> arr(signal.size());
    auto buf = signal.mutable_unchecked<1>();
    auto buf_out = arr.mutable_unchecked<1>();
    for (ssize_t i = 0; i < buf.shape(0); ++i)
    {
        double u1 = rand() / (double)RAND_MAX;
        double u2 = rand() / (double)RAND_MAX;
        double z = std::sqrt(-2 * std::log(u1)) * std::cos(2 * M_PI * u2);
        buf_out(i) = buf(i) + sigma * z;
    }
    return arr;
}

void spectrum(py::array_t<double> signal, double fs, py::array_t<double> freq, py::array_t<double> spec)
{
    auto sig_buf = signal.unchecked<1>();
    size_t N = sig_buf.shape(0);

    size_t Nc = N / 2 + 1;

    double *in = (double *)fftw_malloc(sizeof(double) * N);
    for (size_t i = 0; i < N; ++i)
        in[i] = sig_buf(i);

    fftw_complex *out = (fftw_complex *)fftw_malloc(sizeof(fftw_complex) * Nc);

    fftw_plan plan = fftw_plan_dft_r2c_1d(N, in, out, FFTW_ESTIMATE);
    fftw_execute(plan);
    fftw_destroy_plan(plan);

    auto spec_buf = spec.mutable_unchecked<1>();
    for (size_t i = 0; i < Nc; ++i)
        spec_buf(i) = std::hypot(out[i][0], out[i][1]);
    auto freq_buf = freq.mutable_unchecked<1>();
    for (size_t i = 0; i < Nc; ++i)
        freq_buf(i) = i * fs / N;

    fftw_free(in);
    fftw_free(out);
}

py::array_t<double> sync_rx(py::array_t<double> rx_signal, py::array_t<double> gold, int gold_len)
{
    int N = rx_signal.size();
    std::vector<double> base(N);
    std::vector<double> gold_vec(gold.size());

    std::memcpy(base.data(), rx_signal.data(), N * sizeof(double));
    std::memcpy(gold_vec.data(), gold.data(), gold.size() * sizeof(double));

    // FFT size >= N + gold_len
    int fft_size = 1;
    while (fft_size < N + gold_len)
        fft_size <<= 1;

    std::vector<double> x(fft_size, 0.0);
    std::vector<double> y(fft_size, 0.0);

    std::copy(base.begin(), base.end(), x.begin());
    std::copy(gold_vec.begin(), gold_vec.end(), y.begin());

    fftw_complex *X = (fftw_complex *)fftw_malloc(sizeof(fftw_complex) * (fft_size / 2 + 1));
    fftw_complex *Y = (fftw_complex *)fftw_malloc(sizeof(fftw_complex) * (fft_size / 2 + 1));
    fftw_complex *R = (fftw_complex *)fftw_malloc(sizeof(fftw_complex) * (fft_size / 2 + 1));

    fftw_plan plan_x = fftw_plan_dft_r2c_1d(fft_size, x.data(), X, FFTW_ESTIMATE);
    fftw_plan plan_y = fftw_plan_dft_r2c_1d(fft_size, y.data(), Y, FFTW_ESTIMATE);
    fftw_plan plan_r = fftw_plan_dft_c2r_1d(fft_size, R, x.data(), FFTW_ESTIMATE);

    fftw_execute(plan_x);
    fftw_execute(plan_y);

    for (int i = 0; i < fft_size / 2 + 1; i++)
    {
        R[i][0] = X[i][0] * Y[i][0] + X[i][1] * Y[i][1];
        R[i][1] = X[i][1] * Y[i][0] - X[i][0] * Y[i][1];
    }

    fftw_execute(plan_r); // обратно в x.data(), это корреляция

    // Нормировка
    for (int i = 0; i < fft_size; i++)
        x[i] /= fft_size;

    // ищем максимум
    int max_pos = std::distance(x.begin(), std::max_element(x.begin(), x.begin() + N));

    int packet_len = N - max_pos;
    py::array_t<double> arr(packet_len);
    auto buf = arr.mutable_unchecked<1>();
    for (int i = 0; i < packet_len; i++)
        buf(i) = base[(i + max_pos) % N];

    fftw_destroy_plan(plan_x);
    fftw_destroy_plan(plan_y);
    fftw_destroy_plan(plan_r);
    fftw_free(X);
    fftw_free(Y);
    fftw_free(R);

    return arr;
}

std::vector<int> samples_to_bits(py::array_t<double> &rx, int N, int total_bits, double P = 0.5)
{
    std::vector<int> bits;
    bits.reserve(total_bits);
    auto buf = rx.unchecked<1>();
    int max_samples = total_bits * N;

    for (int i = 0; i < max_samples; i += N)
    {
        double acc = 0.0;
        for (int j = 0; j < N; ++j)
            acc += buf(i + j);
        double mean = acc / N;
        bits.push_back(mean > P ? 1 : 0);
    }

    return bits;
}

bool check_crc(const std::vector<int> &packet, const std::vector<int> &poly)
{
    int n = poly.size() - 1;
    std::vector<int> r = packet;

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

py::array_t<double> create_signal_with_start(py::array_t<double> tx_signal, int start)
{
    ssize_t tx_len = tx_signal.size();
    ssize_t signal_len = tx_len * 2;

    py::array_t<double> signal(signal_len);
    auto sig_buf = signal.mutable_unchecked<1>();

    for (ssize_t i = 0; i < signal_len; ++i)
        sig_buf(i) = 0.0;

    if (start < 0)
    {
        start = 0;
        std::cout << "Start index adjusted to 0" << std::endl;
    }
    else if (start + tx_len > signal_len)
    {
        start = signal_len - tx_len;
        std::cout << "Start index adjusted to " << start << std::endl;
    }

    auto tx_buf = tx_signal.unchecked<1>();
    for (ssize_t i = 0; i < tx_len; ++i)
        sig_buf(i + start) = tx_buf(i);

    return signal;
}

py::dict one_run(int N = 50, int fs = 1000, float sigma = 0.5, int start = 2000, bool print_stats = true)
{
    std::string TEXT = "Denis Shklyaev";

    double P = 0.5;
    std::vector<int> poly = {1, 0, 1, 0, 0, 1, 1, 1};
    int GOLD_LEN = 31;
    int x0 = 0b10011;
    int y0 = 0b10101;

    std::vector<int> data_bits = text_to_bits(TEXT);
    std::vector<int> crc = crc_bits(data_bits, poly);
    std::vector<int> gold = gold_sequence(GOLD_LEN, x0, y0);
    std::vector<int> full_bits;

    full_bits.insert(full_bits.end(), gold.begin(), gold.end());
    full_bits.insert(full_bits.end(), data_bits.begin(), data_bits.end());
    full_bits.insert(full_bits.end(), crc.begin(), crc.end());

    py::array_t<double> up_bits = bits_to_signal(full_bits, N);
    py::array_t<double> signal = create_signal_with_start(up_bits, start);
    py::array_t<double> rx_signal = add_noise(signal, sigma);

    ssize_t H = signal.size();
    ssize_t Nc = H / 2 + 1;
    py::array_t<double> f_tx(Nc);
    py::array_t<double> s_tx(Nc);
    py::array_t<double> f_rx(Nc);
    py::array_t<double> s_rx(Nc);

    py::array_t<double> long_gold = bits_to_signal(gold, N);
    auto long_gold_buf = long_gold.mutable_unchecked<1>();
    if (long_gold_buf.size() < H)
    {
        py::array_t<double> tmp(H);
        auto tmp_buf = tmp.mutable_unchecked<1>();
        for (ssize_t i = 0; i < long_gold_buf.size(); ++i)
            tmp_buf(i) = long_gold_buf(i);
        for (ssize_t i = long_gold_buf.size(); i < H; ++i)
            tmp_buf(i) = 0.0;
        long_gold = tmp;
    }

    py::array_t<double> start_from_gold = sync_rx(rx_signal, long_gold, gold.size() * N);
    std::vector<int> bits = samples_to_bits(start_from_gold, N, full_bits.size(), P);

    if (bits.size() > GOLD_LEN)
        bits.erase(bits.begin(), bits.begin() + GOLD_LEN);
    if (print_stats)
        std::cout << "expected " << (data_bits.size() + crc.size())
                  << "\nbits received " << bits.size() << std::endl;

    std::string text_received;
    bool crc_ok = check_crc(bits, poly);
    if (crc_ok && print_stats)
    {
        std::cout << "CRC check passed" << std::endl;
        std::vector<int> data_received(bits.begin(), bits.end() - crc.size());
        text_received = bits_to_text(data_received);
        std::cout << "Received text: " << text_received << std::endl;
    }
    else if (print_stats)
        std::cout << "CRC check failed" << std::endl;

    // Спектры
    spectrum(signal, fs, f_tx, s_tx);
    spectrum(rx_signal, fs, f_rx, s_rx);

    py::dict result;
    result["start_from_gold"] = start_from_gold;
    result["tx_signal"] = up_bits;
    result["rx_signal"] = rx_signal;
    result["f_tx"] = f_tx;
    result["s_tx"] = s_tx;
    result["f_rx"] = f_rx;
    result["s_rx"] = s_rx;

    return result;
}

PYBIND11_MODULE(dsp, m)
{
    m.def("check_crc", &check_crc);
    m.def("sync_rx", &sync_rx);
    m.def("crc_bits", &crc_bits);
    m.def("text_to_bits", &text_to_bits);
    m.def("bits_to_text", &bits_to_text);
    m.def("gold_sequence", &gold_sequence);
    m.def("samples_to_bits", &samples_to_bits);
    m.def("bits_to_signal", &bits_to_signal);
    m.def("add_noise", &add_noise);
    m.def("spectrum", &spectrum);
    m.def("one_run", &one_run);
}
