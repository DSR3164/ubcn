clear; close all; clc;
%% ------------------8
% Визуальный анализ максимальная частота - 11008Гц
% Необходимая частота дискретизации - 22016Гц

%% ------------------9
[y, Fs] = audioread('voice.wav');
t = linspace(0, length(y), length(y)); 
w = 1200; h = 400; % Размер графика 

%% ------------------10
FS = length(y)/2.052381;
fprintf('Полученная частота дискретизации = %d\n', Fs)
fprintf('Вычисленная частота дискретизации = %.2f\n',FS)

%% ------------------11
div = 10;
y1 = downsample(y, div);
demo = audioplayer(y1, Fs/div);
figure('Position', [(1920-w)/2, (1080-h)/2, w, h], 'MenuBar', 'none', 'ToolBar', 'none');
plot(t, y);
hold on;
t1 = linspace(0, length(y), length(y)/div);
plot(t1, y1, "Color", 'r');
% play(demo);

%% ------------------12
N = length(y);
N1 = length(y1);
Fs1 = Fs/div;

yfft = fft(y);
y1fft = fft(y1);

Y_amp = abs(yfft);
Y1_amp = abs(y1fft);

f_axis = (0:floor(N/2)) * (Fs / N);
f1_axis = (0:floor(N/20)) * (Fs / N);

figure('Position', [(1920-w)/2, (1080-h)/2, w, h], 'MenuBar', 'none', 'ToolBar', 'none');
plot(f_axis, Y_amp(1:end/2+1));
title('Амплитудный спектр исходного сигнала');
xlabel('Частота, Гц');
ylabel('Амплитуда');
xlim([0 Fs1/2])
grid on;

figure('Position', [(1920-w)/2, (1080-h)/2, w, h], 'MenuBar', 'none', 'ToolBar', 'none');
plot(f1_axis, Y1_amp(1:ceil(end/2)));
title('Амплитудный спектр прореженного сигнала');
xlabel('Частота, Гц');
ylabel('Амплитуда');
xlim([0 Fs1/2])
grid on;
