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
d = 0:1:3000; % растояние между BS и UE, метры
ThermalNoise = -174 + 10 * log(BandwidthDL);
RxSensBS = NoiseFigureBS + ThermalNoise + SINRDL;
RxSensUE = NoiseFigureUE + ThermalNoise + SINRUL;

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
plot(d, Walfisch_Ikegami(d, Carrier, 0), "DisplayName", "Walfisch Ikegami");
xlabel('Distance, meter'); ylabel('dB');
grid on;
legend;

% Дистанции для каждой модели
distances = [2193, 35, 78, 504];
models = ["FSPM", "UMiNLOS", "Okumura-Hata", "Walfisch-Ikegami"]; 
S = 1.95 * distances.^2;
for i = 1:length(S)
    count_square(CentersArea, S(i), models(i));
end

function loss = FSPM(distance, f)
    % Частота в Гц
    % Дистанция в метрах

    f = f * 1e9; % Приводим к ГГц
    c = 300000000; %% Скорость света
    lambda = f/c; %% Длина волны
    loss = 20 * log(4*pi*distance/lambda);
end

function loss = UMiNLOS(distance, f)
    % Частота в ГГц
    % Дистанция в метрах

    loss = 26 * log(f) + 22.7 + 36.7 * log(distance);
end

function loss = Hata(distance, f)
    % Для сетей LTE; частоты 150Мгц - 2ГГц
    % Высота подвеса антенны БС 30 - 200 метров
    % Высота антенны мобильного устройства 1 - 10 метров
    % В радиусе от соты 1 - 20 км
    % Частота в Гц
    % Дистанция в метрах

    hBS = 60; % высота подвеса, метры
    hms = 1.8; % высота клиентского устройства в метрах
    
    % Я выбрал DU
    a = 3.2 * (log(11.75*hms))^2 - 4.97;
    if distance >= 1
        s = 44.9 - 6.55 * log(f);
    else
        s = 47.88 + 13.9 * log(f) - 13.9 * log(hBS) * (1 / log(50));
    end
    A = 46.3;
    B = 33.9;
    Lclutter = 3;
    
    loss = A + B * log(f) - 13.82 * log(hBS) - a + s * log(distance) + Lclutter;
end

function loss = Walfisch_Ikegami(distance, f, los)
    % В условиях городской застройки с «манхэттенской» grid-образной архитектурой
    % частоты 800Мгц - 2ГГц
    % Высота подвеса антенны БС 4 - 50 метров
    % Высота антенны мобильного устройства 1 - 3 метров
    % В радиусе от соты 0.03 - 6 км
    % Частота в МГц
    % Дистанция в километрах
    % LOS - Line of Sight - Зона прямой видимости

    f = f * 1e3; % Приводим к МГц
    d = distance / 1e3; % Приводим к Км
    hBS = 30; % высота подвеса, метры
    hms = 1.8; % высота клиентского устройства в метрах
    h = 80; % средняя высота зданий, метры, среднее по 180 самым высоким зданиям НСК
    w = 15; % средняя ширина улиц, метры
    b = 30; % среднее растояние между зданиями , метры
    fi = 40; % средний угол между направлением распространения сигнала и улицей, градусы

    if los
        loss = 42.6 + 20 * log(f) + 26 * log(d);
    else 
        L0 = 32.44 + 20 * log(f) + 20 * log(d);
        if hBS > h
            L_bsh = - 18 * log(1 + hBS - h);
            k_a = 54;
            k_d = 18;
        else
            L_bsh = 0;
            if d > 0.5
                k_a = 54 - 0.8 * (hBS - h);
            else
                k_a = 54 - 0.8 * (hBS - h) * d / 0.5;
            end
            k_d = 18 - 15 * (hBS-h) / h;
        end
        k_f = - 4 + 0.7 * (f / 925 - 1);
        L1 = L_bsh + k_a + k_d * log(d) + k_f * log(f) - 9 * log(b);
        L_ori = 2.5 + 0.075 * (fi - 35);
        L2 = -16.9 - 10 * log(w) + 10 * log(f) + 20 * log(h - hms) + L_ori;
        if L1 + L2 > 0
            loss = L0 + L1 + L2;
        else
            loss = L0;
        end
    end 
end

function count = count_square(area, square, model)
    count = ceil(area / square);
    fprintf("Количество БС на %dкв.м. должно быть не меньше %d штук по модели %s\n", area, count, model);
    fprintf("\tРассчитанная площадь БС = %.2fкв.м.\n", square);
end