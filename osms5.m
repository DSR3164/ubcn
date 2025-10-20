% Исходные параметры
Fs = 42;              % Гц
Ts = 1/Fs;            % Период дискретизации
t_digital = 0:Ts:1-Ts; % Временные точки для 1 секунды
f = 7;
w = 1200; % ширина окна
h = 400; % высота окна

y_digital = cos(4*pi*f*t_digital) + cos(6*pi*f*t_digital);
% Длина сигнала
N = length(y_digital);

% Выполнение FFT
Y = fft(y_digital);

% Амплитудный спектр (нормируем)
Y_mag = abs(Y)/N;

% Частотная ось
f_axis = (0:N-1)*(Fs/N);

% Визуализация спектра
figure('Position', [(1920-w)/2, (1080-h)/2, w, h], 'MenuBar', 'none', 'ToolBar', 'none');
stem(f_axis, Y_mag, 'filled');
title('Амплитудный спектр оцифрованного сигнала');
xlabel('Частота, Гц');
ylabel('Амплитуда');
grid on;
xlim([0 Fs/2+3]);