%------------------4
Fs = 42*4;
Ts = 1/Fs;
t_digital = 0:Ts:1-Ts;
f = 7;
t = linspace(0, 1, 1000); 
w = 1200;
h = 400;

y = cos(4*pi*f*t) + cos(6*pi*f*t);

y_digital = cos(4*pi*f*t_digital) + cos(6*pi*f*t_digital);
y_digital(:)

% Визуализация
figure('Position', [(1920-w)/2, (1080-h)/2, w, h], 'MenuBar', 'none', 'ToolBar', 'none');
plot(t, y, 'LineWidth', 1.5);
hold on;
stem(t_digital, y_digital, 'filled', 'r', 'MarkerSize', 3);
title('Аналоговый сигнал и его оцифровка');
xlabel('Время, сек');
ylabel('Амплитуда');
grid on;

%------------------5
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
xlim([0 Fs/4]);

%------------------6

% Визуализация
figure('Position', [(1920-w)/2, (1080-h)/2, w, h], 'MenuBar', 'none', 'ToolBar', 'none');
nexttile
plot(t, y, 'LineWidth', 1);
title('Аналоговый сигнал');
xlabel('Время, сек');
ylabel('Амплитуда');
grid on;


nexttile
plot(t_digital, y_digital, 'LineWidth', 1, 'Color', 'b');
hold on;
scatter(t_digital, y_digital,'filled', 'b',"Marker","diamond");
title('Восстановленный сигнал');
xlabel('Время, сек');
ylabel('Амплитуда');
grid on;