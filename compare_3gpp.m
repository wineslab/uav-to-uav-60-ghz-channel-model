close all
clear all

%% compare with 3GPP

load('dataset_best_fit_6.mat')
load('dataset_best_fit_12.mat')
load('dataset_best_fit_15.mat')
load('dataset_best_fit_6-15.mat')
load('pathloss_3gpp.mat')

c = 2.997925e8; %[m/s] - speed of light
f = 60.48e9; % Hz
fpl = 20 * log10((4 * pi * distance_12 * f) / c );


figure, hold on,
plot(distance_all, fit_line_ci_all, strcat('-'), 'DisplayName', strcat('fit 6-15 (CI)'))
plot(distances_3gpp, pathLossDbUmi + oxyLoss, strcat('--'), 'DisplayName', strcat('3GPP UMi'))
plot(distances_3gpp, pathLossDbUma + oxyLoss, strcat(':'), 'DisplayName', strcat('3GPP UMa'))
plot(distances_3gpp, pathLossDbRma + oxyLoss, strcat('-.'), 'DisplayName', strcat('3GPP RMa'))
plot(distances_3gpp, pathLossDbInoo + oxyLoss, strcat('--'), 'DisplayName', strcat('3GPP InOo'))
legend('-DynamicLegend')
grid on
xlabel('UAV-to-UAV distance')
ylabel('Pathloss [dB]')

tikz_enable = false;
if(tikz_enable)
   matlab2tikz('ci_3gpp.tex', 'width', '\fwidth', 'height', '\fheight')
end
