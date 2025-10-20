clear; close all; clc; 
f = 7; 
Fs = 42*20; 
Ts = 1/Fs; 
t = linspace(0.3, 0.7, 10000); 
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

function [yq, err] = adc_quantize(y, bit)
    y = y / max(y); y = y * (2^bit - 1) ;
    bits = 0:1:2^bit - 1;
    [~, idx] = min(abs(y(:) - bits), [], 2); 
    yq = bits(idx);
    err = mean(abs(y - yq)) / (2^bit - 1);
end