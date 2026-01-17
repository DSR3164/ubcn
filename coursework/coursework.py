import numpy as np, time
import matplotlib.pyplot as plt
import build.dsp as dsp 

sigma = float(input("Enter noise standard deviation: "))
start = int(input("Enter start index: "))

result:dict = {}
txfx:list[np.ndarray] = []
txsx:list[np.ndarray] = []
rxfx:list[np.ndarray] = []
rxsx:list[np.ndarray] = []

for i in [25, 50, 100]:
    result = dsp.one_run(i, 1000, sigma, start, False)
    f_tx = np.array(result["f_tx"])
    s_tx = np.array(result["s_tx"])
    txfx.append(f_tx.copy())
    txsx.append(s_tx.copy())

    f_rx = np.array(result["f_rx"])
    s_rx = np.array(result["s_rx"])
    rxfx.append(f_rx.copy())
    rxsx.append(s_rx.copy())

    result.clear()

result = dsp.one_run(50, 1000, sigma, start, True)
start_from_gold = result["start_from_gold"]
tx_signal = result["tx_signal"]
rx_signal = result["rx_signal"]

plt.figure()
plt.stairs(start_from_gold)
plt.legend(["Принятые биты", "Биты после оцифровки"])
plt.title("Собранные биты (Голд + данные + CRC)")
plt.grid()

plt.figure()
plt.plot(tx_signal)
plt.title("Переданный сигнал")
plt.grid()

plt.figure()
plt.plot(rx_signal)
plt.title("Принятый сигнал с шумом")
plt.grid()

plt.figure()
ax1 = plt.subplot(2, 1, 1)
ax2 = plt.subplot(2, 1, 2)

for i in range(3):
    ax1.plot(txfx[i], 20 * np.log10(txsx[i] + 1e-15), label=f"Спектр переданного сигнала, N = {25*2**(i)}", alpha=0.5)
    ax2.plot(rxfx[i], 20 * np.log10(rxsx[i] + 1e-15), label=f"Спектр принятого сигнала, N = {25*2**(i)}", alpha=0.5)
ax1.set_title("Спектры переданных сигналов")
ax1.set_xlabel("Частота, Гц")
ax1.set_ylabel("Амплитуда")
ax1.grid(True)
ax1.legend()

ax2.set_title("Спектры принятых сигналов")
ax2.set_xlabel("Частота, Гц")
ax2.set_ylabel("Амплитуда")
ax2.grid(True)
ax2.legend()
plt.show()
