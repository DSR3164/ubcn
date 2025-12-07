clc; clear; close all;
%% Задание исходных данных
TxPowerBS = 46; % dBm в 10^4.6 = 39 810,7 больше 1мВт ~ 39.8 Вт
SectorsCount = 3; % Количество сот
TxPowerUE = 24; % dBm ~ 0.25 Вт
AntGainBS = 21; % dBi
PenetrationM = 15; % dB
IM = 1; % dB
% Модель распространения сигнала для макросот: COST 231 Hata
% Модель распространения сигнала для фемто- и микросот: UMiNLOS;
Carrier = 1.8; % 1.8 GHz
BandwidthUL = 10; % 10 MHz
BandwidthDL = 20; % 20 MHz
% Дуплекс UL и DL: FDD;
NoiseFigureBS = 2.4; % dB
NoiseFigureUE = 6; % dB
SINRDL = 2; % dB
SINRUL = 4; % dB
MIMOBS = 2;
Area = 100; % Площадь территории, на которой требуется спроектировать сеть, квадратные метры
CentersArea = 4000000; % Площадь ТЦ и БЦ, где требуется спроектировать сеть на базе микро- и фемтосот, квадратные метры
% Базовые станции с фидерами
FeederLoss = 3; % db ~ 2dB фидер + 0.4dB МШУ + 0.5dB Джампер
MIMOGain = 3; % dB
d = 1:1:5000; % растояние между BS и UE, метры
ThermalNoise = -174 + 10 * log10(BandwidthDL * 1e6);
RxSensBS = NoiseFigureBS + ThermalNoise + SINRUL;
RxSensUE = NoiseFigureUE + ThermalNoise + SINRDL;

%% Расчет бюджета восходящего канала
MAPL_UL = TxPowerUE - FeederLoss + AntGainBS + MIMOGain - RxSensBS - IM - PenetrationM;

%% Расчет бюджета нисходящего канала
MAPL_DL = TxPowerBS - FeederLoss + AntGainBS + MIMOGain - RxSensUE - IM - PenetrationM;

fprintf("MAPL Uplink = %.2fdB\n", MAPL_UL);
fprintf("MAPL Downlink = %.2fdB\n", MAPL_DL);

figure;
yline(MAPL_DL, 'g--', 'DisplayName', 'MAPL DL', 'LineWidth', 1.5); hold on;
yline(MAPL_UL, 'r--', 'DisplayName', 'MAPL UL', 'LineWidth', 1.5); hold on;
plot(d, FSPM(d, Carrier), "DisplayName", "FSPM"); hold on;
plot(d, UMiNLOS(d, Carrier), "DisplayName", "UMiNLOS"); hold on;
plot(d, Hata(d, Carrier), "DisplayName", "Hata"); hold on;
plot(d, Walfisch_Ikegami(d, Carrier, 1), "DisplayName", "Walfisch Ikegami LOS"); hold on;
plot(d, Walfisch_Ikegami(d, Carrier, 0), "DisplayName", "Walfisch Ikegami NLOS");
xlabel('Distance, meter'); ylabel('dB');
grid on;
legend;

figure;
D = 100:5:500; % Начальное приближение для расчета дальности
f = linspace(400, 2400, length(D));
temp = linspace(-100, 100, length(D));
[T, F] = meshgrid(temp, f);
Z = hataplane(f, temp, D);
s = surf(T, F, Z, Z);
xlabel("Температура, °C");
ylabel("Частота, Мгц");
zlabel("Дальность соты, М");
xlim([min(T(:)) max(T(:))])
ylim([min(F(:)) max(F(:))])
zlim([min(Z(:)) max(Z(:))])
colormap(jet);
colorbar;

% Дистанции для каждой модели
distances = [
    getDistance(10000:21000, FSPM(10000:21000, Carrier), MAPL_UL, 1), ...
    getDistance(d, Walfisch_Ikegami(d, Carrier, 1), MAPL_UL, 1), ...
    getDistance(d, UMiNLOS(d, Carrier), MAPL_UL, 1), ...
    getDistance(d, Hata(d, Carrier), MAPL_UL, 1), ...
    getDistance(d, Walfisch_Ikegami(d, Carrier, 0), MAPL_UL, 1), ...
    ];
disp(distances);
models = ["FSPM", "Walfisch-Ikegami LOS", "UMiNLOS", "Okumura-Hata", "Walfisch-Ikegami NLOS"];
S = 1.95 * distances.^2;
for i = 1:length(S)
    count_square(CentersArea, S(i), models(i));
end

function d = getDistance(distances, loss, MAPL, show)
diff = abs(loss - MAPL);
[~, idx] = min(diff);
d = distances(idx);
if show
    fprintf("\nDistance ≈ %.0f; Loss %.2f = %.2f MAPL\n", d, loss(idx), MAPL);
end
end

function z = hataplane(f, temp, D)
k = 1.380649e-23;
BW = 10e6;

[T, F] = meshgrid(temp, f);

Tkelv = T + 273.15;
ThermalNoise = 10*log10(k .* Tkelv .* BW) + 30;
RxSensBS = 2.4 + ThermalNoise + 4;
MAPL_UL = 24 - 3 + 21 + 3 - RxSensBS - 1 - 15;
z = zeros(size(F));

for ii = 1:size(F,1)
    for jj = 1:size(F,2)
        ft = F(ii,jj);
        z(ii, jj) = getDistance(D, Hata(D, ft*1e-3), MAPL_UL(ii,jj), 0);
    end
end
end



function loss = FSPM(distance, f)
% Частота в Гц
% Дистанция в метрах

f = f * 1e9; % Приводим к ГГц
c = 3 * 1e8; % Скорость света
lambda = c/f; % Длина волны
loss = 20 * log10(4*pi*distance./lambda);
end

function loss = UMiNLOS(distance, f)
% Частота в ГГц
% Дистанция в метрах

loss = 26 * log10(f) + 22.7 + 36.7 * log10(distance);
end

function loss = Hata(distance, f)
% distance — вектор (м)
% f — Гц

hBS = 60;
hms = 1.8;

a = 3.2 * (log10(11.75*hms))^2 - 4.97;

mask_far = (distance >= 1);
mask_near = ~mask_far;

s = zeros(size(distance));
s(mask_far)  = 44.9 - 6.55 * log10(f);
s(mask_near) = 47.88 + 13.9 * log10(f) - 13.9 * log10(hBS) * (1 / log10(50));

A = 46.3;
B = 33.9;
Lclutter = 3;

loss = A + B .* log10(f) ...
    - 13.82 * log10(hBS) ...
    - a ...
    + s .* log10(distance) ...
    + Lclutter;
end

function loss = Walfisch_Ikegami(distance, f, los)
% distance — вектор (м)
% f — МГц

f = f * 1e3;
d = distance * 1e-3;

hBS = 30;
hms = 1.8;
h = 30;
w = 15;
b = 30;
fi = 40;

if los
    loss = 42.6 + 20*log10(f) + 26*log10(d);
else
    L0 = 32.44 + 20*log10(f) + 20*log10(d);
    L_ori = 2.5 + 0.075*(fi - 35);
    L2 = -16.9 - 10*log10(w) + 10*log10(f) + 20*log10(h - hms) + L_ori;
    k_a = 54 - 0.8*(hBS - h) .* min(d/0.5, 1);
    k_d = 18 - 15*(hBS - h)/h;
    k_f = -4 + 0.7*(f/925 - 1);
    L1 = k_a + k_d*log10(d) + k_f*log10(f) - 9*log10(b);
    L_r = L1 + L2;
    L_r(L_r < 0) = 0;
    loss = L0 + L_r;
end
end

function count = count_square(area, square, model)
count = ceil(area / square);
fprintf("%d по модели %s ≈ %.4f км^2\n", count, model, square*1e-6);
end