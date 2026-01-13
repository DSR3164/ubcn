import numpy as np
import matplotlib.pyplot as plt

data = np.loadtxt("a.dat")
plt.plot(data[:,0], data[:,1], label="CRC-2")
plt.plot(data[:,0], data[:,2], label="CRC-3")
plt.plot(data[:,0], data[:,3], label="CRC-4")
plt.grid()
plt.legend()
plt.xlabel("Длина сообщения")
plt.ylabel("Вероятность необнаруженной ошибки")
plt.show()
