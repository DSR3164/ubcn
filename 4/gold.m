%% Параметры
VAR = 16;
N = 31;

x = bitand(VAR, 31);
y = bitand(x + 7, 31);

%% 1. Генерация последовательности Голда
seq = zeros(1,N);
for i = 1:N
    tempx = bitxor(bitget(x,2), bitget(x,1));
    x = bitshift(tempx, 4) + bitshift(x,-1);
    
    tempy = bitxor(bitget(y,4), bitget(y,1));
    y = bitshift(tempy, 4) + bitshift(y,-1);
    
    seq(i) = bitxor(bitget(x,1), bitget(y,1));
end

seq_pm = 2*seq - 1;

%% 2. Циклический сдвиг и автокорреляция
fprintf('Сдвиг | Последовательность | Автокорреляция\n')
for k = 0:N-1
    shifted = circshift(seq_pm, k);
    R = sum(seq_pm .* shifted) / sum(seq_pm.^2);
    
    fprintf('%3d | ', k)
    for b = 1:N
        fprintf('%d ', shifted(b)==1);
    end
    fprintf('| %.3f\n', R);
end

%% 3. Новая последовательность x=x+1, y=y-5
x2 = bitand(VAR+1, 31);
y2 = bitand((x2+7)-5, 31);

seq2 = zeros(1,N);
for i = 1:N
    tempx = bitxor(bitget(x2,2), bitget(x2,1));
    x2 = bitshift(tempx, 4) + bitshift(x2,-1);
    
    tempy = bitxor(bitget(y2,4), bitget(y2,1));
    y2 = bitshift(tempy, 4) + bitshift(y2,-1);
    
    seq2(i) = bitxor(bitget(x2,1), bitget(y2,1));
end
seq2_pm = 2*seq2 - 1;

%% 4. Взаимная корреляция
Rxy = sum(seq_pm .* seq2_pm) / sqrt(sum(seq_pm.^2)*sum(seq2_pm.^2));
fprintf('Взаимная корреляция: %.3f\n', Rxy);

%% 5. autocorr и xcorr
[acf, lags] = autocorr(seq_pm, 'NumLags', N-1);
[xcf, xlags] = xcorr(seq_pm, seq2_pm, 'coeff');

%% 6. График автокорреляции
figure
stem(lags, acf, 'filled')
xlabel('lag')
ylabel('R(lag)')
title('Автокорреляция последовательности Голда')
grid on
