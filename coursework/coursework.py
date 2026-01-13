import numpy as np
import matplotlib.pyplot as plt

def text_to_bits(text):
    bits = []
    for ch in text:
        b = format(ord(ch), '08b')
        bits.extend([int(x) for x in b])
    return bits


def crc_bits(data_bits, poly_bits):
    data = data_bits.copy()
    crc_len = len(poly_bits) - 1
    data.extend([0] * crc_len)

    poly = poly_bits
    for i in range(len(data_bits)):
        if data[i] == 1:
            for j in range(len(poly)):
                data[i + j] ^= poly[j]

    return data[-crc_len:]


def gold_sequence(N, x, y):
    out = []
    for _ in range(N):
        tempx = ((x & 0x2) >> 1) ^ (x & 0x1)
        x = (tempx << 4) | (x >> 1)

        tempy = ((y & 0x8) >> 3) ^ (y & 0x1)
        y = (tempy << 4) | (y >> 1)

        out.append((x & 1) ^ (y & 1))
    return out


def bits_to_signal(bits, N):
    signal = []
    for b in bits:
        signal.extend([b] * N)
    return np.array(signal)

def add_noise(signal, sigma):
    noise = np.random.normal(0, sigma, len(signal))
    return signal + noise

def spectrum(signal, fs):
    spec = np.abs(np.fft.fft(signal))
    freq = np.fft.fftfreq(len(signal), 1 / fs)
    return freq, spec

def decision(signal, N, P):
    bits = []
    for i in range(0, len(signal), N):
        avg = np.mean(signal[i:i+N])
        bits.append(1 if avg > P else 0)
    return bits

# 1
TEXT = "Denis Shklyaev"
N = 50
fs = 1000
sigma = float(input("Enter noise standard deviation: "))
P = 0.5

poly = [1, 0, 1, 0, 0, 1, 1, 1]
CRC_LEN = 250

GOLD_LEN = 31
x0 = 0b10011
y0 = 0b10101

# 2
data_bits = text_to_bits(TEXT)

# 3
crc = crc_bits(data_bits, poly)
print("CRC:", crc)

# 4
gold = gold_sequence(GOLD_LEN, x0, y0)
full_bits = gold + data_bits + crc

# 5
tx_signal = bits_to_signal(full_bits, N)
signal = np.zeros(len(tx_signal) * 2)
start = int(input("Enter start index: "))
if start < 0:
    start = 0
    print("Start index adjusted to 0")
elif start + len(tx_signal) > len(signal):
    start = len(signal) - len(tx_signal)
    print(f"Start index adjusted to {len(signal) - len(tx_signal)}")

signal[start:start+len(tx_signal)] = tx_signal

rx_signal = add_noise(signal, sigma)

f_tx, s_tx = spectrum(signal, fs)
f_rx, s_rx = spectrum(rx_signal, fs)

detected_bits = decision(rx_signal[start:start+len(tx_signal)], N, P)

plt.figure()
plt.plot(full_bits)
plt.title("Собранные биты (Голд + данные + CRC)")
plt.figure()
plt.plot(signal)
plt.title("Переданный сигнал")
plt.figure()
plt.plot(rx_signal)
plt.title("Принятый сигнал с шумом")
plt.figure()
plt.plot(f_tx, s_tx, label="Спектр переданного сигнала")
plt.plot(f_rx, s_rx, label="Спектр принятого сигнала")
plt.title("Спектр")
plt.legend()
plt.show()
