f = 7; 
Fs = 42*20; 
Ts = 1/Fs; 
t = linspace(0, 1, 10000); 
w = 1200; h = 800; % Размер графика  

%% ------------------13 
y = cos(4*pi*f*t) + cos(6*pi*f*t); 
y = y + abs(min(y)); y = y / max(y);
figure('Position', [(1920-w)/2, (1080-h)/2, w, h], 'MenuBar', 'none', 'ToolBar', 'none'); 
plot(t, y/2, 'DisplayName', 'Исходный сигнал (приведен к max = 1)'); 

errs = []; 
for index = 1:4

    subplot(4, 1, index); 
    title('График квантованной функции'); 
    xlabel('Время, с'); 
    ylabel('Амплитуда'); 
    legend; 
    grid on; 
    [yq, err] = adc_quantize(y, index + 2);
    yn = y * (2^(index + 2) - 1);
    hold on; plot(t, yn, 'DisplayName', 'Исходная функция'); 
    hold on; plot(t, yq, 'DisplayName', sprintf('%d Bits', index + 2)); 
    ylim([0 max(yq)]) 
    errs(index) = err; 
end 

disp(table([3, 4, 5, 6]', errs', 'VariableNames', {'Разрядность', 'Средняя ошибка'})) 

figure
subplot(3, 1, 1);
bit = 3;
yn = ((y / max(y)) * 2 - 0.4) * (2^bit - 1);
[yq, err] = clip_quantize(y, bit);
plot(t, yq); hold on;
plot(t, yn, "LineStyle", "--"); hold off;
title('Сигнал и его квантованная функция');
ylabel('Leves');
xlabel('t, ');
ylim([min(yn) max(yn)])
xlim([0 0.5])
grid on

Fs = 1000; Duration = 1000;
t = linspace(0, Duration, Duration*Fs); 
y = cos(4*pi*f*t) + cos(6*pi*f*t); 
y = y + abs(min(y)); y = y / max(y);
[yq, err] = clip_quantize(y, bit);

subplot(3, 1, 2);
N = length(y);
Y = abs(fft(y));
freqs = (0:N-1)*(Fs/N);
plot(freqs, 20 * log10(Y/max(abs(Y))));
ylabel('dB');
xlabel('f, Hz');
title('Спектр частот сигнала');
xlim([0 35]);
grid on

subplot(3, 1, 3);
N = length(yq);
Y = abs(fft(yq))/N;
freqs = (0:N-1)*(Fs/N);
plot(freqs, 20 * log10(Y/max(abs(Y))));
ylabel('dB');
xlabel('f, Hz');
title('Спектр частот сигнала с клипом');
xlim([0 35]);
grid on

function [yq, err] = adc_quantize(y, bit)
    y = y / max(y); y = y * (2^bit - 1) ;
    bits = 0:1:2^bit - 1;
    [~, idx] = min(abs(y(:) - bits), [], 2); 
    yq = bits(idx);
    err = mean(abs(y - yq)) / (2^bit - 1);
end

function [yq, err] = clip_quantize(y, bit)
    y = ((y / max(y)) * 2 - 0.4); y = y * (2^bit - 1);
    bits = 0:1:2^bit - 1;
    [~, idx] = min(abs(y(:) - bits), [], 2); 
    yq = bits(idx);
    err = mean(abs(y - yq)) / (2^bit - 1);
end
