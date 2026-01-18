import numpy as np, time
import matplotlib.pyplot as plt
import build.dsp as dsp 

times:np.ndarray = np.zeros(1000, dtype=np.float64)

dsp.one_run(50, 1000, 0.4, 2000, True)

for i in range(1000):
    t0 = time.perf_counter()
    dsp.one_run(50, 1000, 0.4, 2000, False)
    t1 = time.perf_counter()
    times[i] = (t1 - t0) * 1e3

print(f"\nTotal: {np.sum(times)/1000:.2f} s")
print(f"Mean: {np.mean(times):,.2f} ms")
plt.figure()
plt.plot(times)
plt.title("Время выполнения")
plt.xlabel("N")
plt.ylabel("Время, мс")
plt.grid()
plt.show()