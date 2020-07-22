load('dataset_best_fit_6.mat')
load('dataset_best_fit_12.mat')
load('dataset_best_fit_15.mat')
load('dataset_best_fit_6-15.mat')

fpl = 20 * log10((4 * pi * distance_12 * f) / c );

figure, hold on
plot(distance_6, fit_line_abg_6, strcat('--'), 'DisplayName', strcat('fit 6 (ABG)'))
plot(distance_12, fit_line_abg_12, strcat('-.'), 'DisplayName', strcat('fit 12 (ABG)'))
plot(distance_15, fit_line_abg_15, strcat('-'), 'DisplayName', strcat('fit 15 (ABG)'))
plot(distance_12, fpl, strcat(':'), 'DisplayName', strcat('FPL'))
legend('-DynamicLegend')
grid on
xlabel('UAV-to-UAV distance')
ylabel('Pathloss [dB]')

figure, hold on
plot(distance_6, fit_line_ci_6, strcat('--'), 'DisplayName', strcat('fit 6 (CI)'))
plot(distance_12, fit_line_ci_12, strcat('-.'), 'DisplayName', strcat('fit 12 (CI)'))
plot(distance_15, fit_line_ci_15, strcat(':'), 'DisplayName', strcat('fit 15 (CI)'))
plot(distance_all, fit_line_ci_all, strcat('-'), 'DisplayName', strcat('fit 6-15 (CI)'))
plot(distance_12, fpl, strcat(':'), 'DisplayName', strcat('FPL'))
scatter(distance_12, min_pathloss_12, markers{1}, 'DisplayName', strcat('h = 12'))
scatter(distance_6, min_pathloss_6, markers{2}, 'DisplayName', strcat('h = 15'))
scatter(distance_15, min_pathloss_15, markers{3}, 'DisplayName', strcat('h = 6'))
legend('-DynamicLegend')
grid on
xlabel('UAV-to-UAV distance')
ylabel('Pathloss [dB]')

tikz_enable = false;
if(tikz_enable)
   matlab2tikz('ci_height.tex', 'width', '\fwidth', 'height', '\fheight')
end