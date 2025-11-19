% Исходные параметры
f = 7;% Гц
t = linspace(0, 1, 1000);  % Временная ось 1 секунда, 1000 точек
w = 1200; % ширина окна
h = 400; % высота окна

% Сигнал
y = cos(4*pi*f*t) + cos(6*pi*f*t);

% Визуализация
figure('Position', [(1920-w)/2, (1080-h)/2, w, h], 'MenuBar', 'none', 'ToolBar', 'none');
plot(t, y, 'LineWidth', 1.5);
title('Непрерывный сигнал y(t) = cos(4π7t) + cos(6π7t)');
xlabel('Время, сек');
ylabel('Амплитуда');
grid on;
