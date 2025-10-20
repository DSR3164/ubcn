% Исходные параметры
Fs = 42;              % Гц
Ts = 1/Fs;            % Период дискретизации
t_digital = 0:Ts:1-Ts; % Временные точки для 1 секунды
f = 7;
t = linspace(0, 1, 1000); 
w = 1200; % ширина окна
h = 400; % высота окна

y = cos(4*pi*f*t) + cos(6*pi*f*t);

% Оцифрованный сигнал
y_digital = cos(4*pi*f*t_digital) + cos(6*pi*f*t_digital);
y_digital(:)

% Визуализация
figure('Position', [(1920-w)/2, (1080-h)/2, w, h], 'MenuBar', 'none', 'ToolBar', 'none');
plot(t, y, 'LineWidth', 1.5);
hold on;
stem(t_digital, y_digital, 'filled', 'r');
title('Аналоговый сигнал и его оцифровка');
xlabel('Время, сек');
ylabel('Амплитуда');
grid on;