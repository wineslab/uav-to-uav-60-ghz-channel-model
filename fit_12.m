clear all
%close all

altitude = 12;

load(strcat('dataset_min_pathloss_alt_', num2str(altitude), '.mat'))

min_pathloss_12 = [];
for el = 1:numel(pl_struct)
    min_pathloss_12 = [min_pathloss_12, pl_struct(el).min];
end

%% CI
% eq(7) http://www.5gworkshops.com/5GCMSIG_White%20Paper_r2dot3.pdf

c = 2.997925e8; %[m/s] - speed of light
f = 60.48e9; % Hz
fpl_reference_1m = 20 * log10((4 * pi * 1 * f) / c );

x = [];
y = [];

index = 1;
for dir_index = 1:numel(pl_struct)
    dist = pl_struct(dir_index).dist;
    if ~isempty(pl_struct(dir_index).min)
        minima = pl_struct(dir_index).min;
        support = 10*log10(pl_struct(dir_index).dist * ones(length(minima), 1));
        y(index:(index + length(minima) - 1)) = minima - fpl_reference_1m;
        x(index:(index + length(minima) - 1)) = support;
        index = index + length(minima);
    end
end

X = x.';
B_ci = X \ y';
fit_line_ci_12 = fpl_reference_1m + B_ci * 10 * log10(distance);

% compute std dev
for dir_index = 1:numel(pl_struct)
    dist = pl_struct(dir_index).dist;  
    diff(dir_index) = pl_struct(dir_index).min - (fpl_reference_1m + B_ci * 10 * log10(dist));
end
sigma_sq_db_ci_12 = sum(diff.^2)/length(diff);

%% ABG
% eq(10) http://www.5gworkshops.com/5GCMSIG_White%20Paper_r2dot3.pdf
% we cannot distinguish beta and gamma, or, at least, we need to fix one of
% the two

x = [];
y = [];

index = 1;
for dir_index = 1:numel(pl_struct)
    dist = pl_struct(dir_index).dist;
    if ~isempty(pl_struct(dir_index).min)
        minima = pl_struct(dir_index).min;
        support = 10*log10(pl_struct(dir_index).dist * ones(length(minima), 1));
        y(index:(index + length(minima) - 1)) = minima;
        x(index:(index + length(minima) - 1)) = support;
        index = index + length(minima);
    end
end

X = [ones(1, length(x)); x].';
B_abg = X \ y';
fit_line_abg_12 = B_abg(1) + B_abg(2) * 10 * log10(distance);

% compute std dev
for dir_index = 1:numel(pl_struct)
    dist = pl_struct(dir_index).dist;  
    diff(dir_index) = pl_struct(dir_index).min - ( B_abg(1) + B_abg(2) * 10 * log10(dist));
end
sigma_sq_db_abg_12 = sum(diff.^2)/length(diff);


%% plot
markers = {'+','o','*','x','v','d','^','s','>','<'};
fpl = 20 * log10((4 * pi * distance * f) / c );

figure, hold on,
plot(distance, fit_line_ci_12, strcat('-'), 'DisplayName', strcat('CI, h = ', num2str(altitude)))
plot(distance, fit_line_abg_12, strcat('-.'), 'DisplayName', strcat('ABG, h = ', num2str(altitude)))
scatter(distance, min_pathloss_12, markers{1}, 'DisplayName', strcat('h = ', num2str(altitude)))
plot(distance, fpl, strcat(':', markers{2 + 2}), 'DisplayName', 'Free space pathloss')

legend('-DynamicLegend')
grid on
xlabel('UAV-to-UAV distance')
ylabel('Pathloss [dB]')

distance_12 = distance;
save('dataset_best_fit_12.mat', 'distance_12', 'fit_line_abg_12', 'fit_line_ci_12')