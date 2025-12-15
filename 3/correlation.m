clc; clear; close all;
%% 3
f1 = 16;
f2 = 16 + 4;
f3 = 16 * 2 + 1;

t = linspace(0, 1, 1000);

s1 = cos(2 * pi * f1 * t);
s2 = cos(2 * pi * f2 * t);
s3 = cos(2 * pi * f3 * t);

a = 4*s1 + 2*s2 + 2*s3;
b = 2*s1 + s2;

c_sa = xcorr(s1, a);
c_sb = xcorr(s1, b);
nc_sa = xcorr(s1, a, 'coeff');
nc_sb = xcorr(s1, b, 'coeff');

fprintf("Corr s1(t) & a: %.2f\n",   c_sa(length(a)/2));
fprintf("Corr s1(t) & b: %.2f\n",   c_sb(length(a)/2));
fprintf("NCorr s1(t) & a: %.2f\n",  nc_sa(length(a)/2));
fprintf("NCorr s1(t) & b: %.2f\n",  nc_sb(length(a)/2));

a = [0.3, 0.2, -0.1, 4.2, -2, 1.5, 0];
b = [0.3, 4, -2.2, 1.6, 0.1, 0.1, 0.2];

%% 5
N = length(a);
result = zeros(1, N);

for k = 0:N-1
    b_shift = circshift(b, k);
    
    result(k+1) = sum(a .* b_shift)/sqrt(sum(a .* a).*sum(b_shift .* b_shift));
end

%% 6
subplot(2,1,1);
plot(0:N-1, a);
grid on;
subplot(2,1,2);
plot(0:N-1, b);
grid on;

%% 7
figure();
plot(0:length(result)-1, result);
grid on;
[val, idx] = max(result);
fprintf("Max = %.f id = %.f\n", val, idx);

%% 6
figure();
subplot(2,1,1);
plot(0:N-1, a);
grid on;
subplot(2,1,2);
plot(0:N-1, circshift(b, idx-1));
grid on;