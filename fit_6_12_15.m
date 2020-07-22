clear all
%close all

altitude = 12;
load(strcat('dataset_min_pathloss_alt_', num2str(altitude), '.mat'))
min_pathloss_12 = [];
for el = 1:numel(pl_struct)
    min_pathloss_12 = [min_pathloss_12, pl_struct(el).min];
end
distance_12 = distance;
pl_struct_12 = pl_struct;

altitude = 15;
load(strcat('dataset_min_pathloss_alt_', num2str(altitude), '.mat'))
min_pathloss_15 = [];
for el = 1:numel(pl_struct)
    min_pathloss_15 = [min_pathloss_15, pl_struct(el).min];
end
distance_15 = distance;
pl_struct_15 = pl_struct;

altitude = 6;
load(strcat('dataset_min_pathloss_alt_', num2str(altitude), '.mat'))
min_pathloss_6 = [];
for el = 1:numel(pl_struct)
    min_pathloss_6 = [min_pathloss_6, pl_struct(el).min];
end
distance_6 = distance;
pl_struct_6 = pl_struct;

pl_struct_join = struct('dist', [], 'alt', [],  'min', [], 'beam_diffs', [], ...
    'beam_diffs_deg_tx', [], 'beam_diffs_deg_rx', []);

% join
tmp_index = 1;
for dir_index = 1:numel(pl_struct_6)
    pl_struct_join(tmp_index).dist = pl_struct_6(dir_index).dist;
    pl_struct_join(tmp_index).alt = 6;
    pl_struct_join(tmp_index).min = pl_struct_6(dir_index).min;
    pl_struct_join(tmp_index).beam_diffs = pl_struct_6(dir_index).beam_diffs;
    pl_struct_join(tmp_index).beam_diffs_deg_tx = pl_struct_6(dir_index).beam_diffs_deg_tx;
    pl_struct_join(tmp_index).beam_diffs_deg_rx = pl_struct_6(dir_index).beam_diffs_deg_rx;
    tmp_index = tmp_index + 1;
end
for dir_index = 1:numel(pl_struct_12)
    pl_struct_join(tmp_index).dist = pl_struct_12(dir_index).dist;
    pl_struct_join(tmp_index).alt = 12;
    pl_struct_join(tmp_index).min = pl_struct_12(dir_index).min;
    pl_struct_join(tmp_index).beam_diffs = pl_struct_12(dir_index).beam_diffs;
    pl_struct_join(tmp_index).beam_diffs_deg_tx = pl_struct_12(dir_index).beam_diffs_deg_tx;
    pl_struct_join(tmp_index).beam_diffs_deg_rx = pl_struct_12(dir_index).beam_diffs_deg_rx;
    tmp_index = tmp_index + 1;
end
for dir_index = 1:numel(pl_struct_15)
    pl_struct_join(tmp_index).dist = pl_struct_15(dir_index).dist;
    pl_struct_join(tmp_index).alt = 15;
    pl_struct_join(tmp_index).min = pl_struct_15(dir_index).min;
    pl_struct_join(tmp_index).beam_diffs = pl_struct_15(dir_index).beam_diffs;
    pl_struct_join(tmp_index).beam_diffs_deg_tx = pl_struct_15(dir_index).beam_diffs_deg_tx;
    pl_struct_join(tmp_index).beam_diffs_deg_rx = pl_struct_15(dir_index).beam_diffs_deg_rx;
    tmp_index = tmp_index + 1;
end

distance = 6:3:42;

%% CI
% eq(7) http://www.5gworkshops.com/5GCMSIG_White%20Paper_r2dot3.pdf

c = 2.997925e8; %[m/s] - speed of light
f = 60.48e9; % Hz
fpl_reference_1m = 20 * log10((4 * pi * 1 * f) / c );

x = [];
y = [];

index = 1;
for dir_index = 1:numel(pl_struct_join)
    dist = pl_struct_join(dir_index).dist;
    if ~isempty(pl_struct_join(dir_index).min)
        minima = pl_struct_join(dir_index).min;
        support = 10*log10(pl_struct_join(dir_index).dist * ones(length(minima), 1));
        y(index:(index + length(minima) - 1)) = minima - fpl_reference_1m;
        x(index:(index + length(minima) - 1)) = support;
        index = index + length(minima);
    end
end

X = x.';
B_ci = X \ y';
fit_line_ci_all = fpl_reference_1m + B_ci * 10 * log10(distance);

% compute std dev
diff = [];
for dir_index = 1:numel(pl_struct_join)
    dist = pl_struct_join(dir_index).dist;  
    diff(dir_index) = pl_struct_join(dir_index).min - (fpl_reference_1m + B_ci * 10 * log10(dist));
end
sigma_sq_db_ci_all = sum(diff.^2)/length(diff);

%% ABG
% eq(10) http://www.5gworkshops.com/5GCMSIG_White%20Paper_r2dot3.pdf
% we cannot distinguish beta and gamma, or, at least, we need to fix one of
% the two

x = [];
y = [];

index = 1;
for dir_index = 1:numel(pl_struct_join)
    dist = pl_struct_join(dir_index).dist;
    if ~isempty(pl_struct_join(dir_index).min)
        minima = pl_struct_join(dir_index).min;
        support = 10*log10(pl_struct_join(dir_index).dist * ones(length(minima), 1));
        y(index:(index + length(minima) - 1)) = minima;
        x(index:(index + length(minima) - 1)) = support;
        index = index + length(minima);
    end
end

X = [ones(1, length(x)); x].';
B_abg = X \ y';
fit_line_abg_all = B_abg(1) + B_abg(2) * 10 * log10(distance);

% compute std dev
diff = [];
for dir_index = 1:numel(pl_struct_join)
    dist = pl_struct_join(dir_index).dist;  
    diff(dir_index) = pl_struct_join(dir_index).min - ( B_abg(1) + B_abg(2) * 10 * log10(dist));
end
sigma_sq_db_abg_all = sum(diff.^2)/length(diff);


%% plot
markers = {'+','o','*','x','v','d','^','s','>','<'};
fpl = 20 * log10((4 * pi * distance * f) / c );

figure, hold on,
plot(distance, fit_line_ci_all, strcat('-'), 'DisplayName', strcat('CI, 6-15'))
plot(distance, fit_line_abg_all, strcat('-.'), 'DisplayName', strcat('ABG, 6-15'))
scatter(distance_12, min_pathloss_12, markers{1}, 'DisplayName', strcat('h = 12'))
scatter(distance_6, min_pathloss_6, markers{2}, 'DisplayName', strcat('h = 15'))
scatter(distance_15, min_pathloss_15, markers{3}, 'DisplayName', strcat('h = 6'))
plot(distance, fpl, strcat(':', markers{2 + 2}), 'DisplayName', 'Free space pathloss')

tikz_enable = false;
if(tikz_enable)
   matlab2tikz('ci_abg_all.tex', 'width', '\fwidth', 'height', '\fheight')
end

legend('-DynamicLegend')
grid on
xlabel('UAV-to-UAV distance')
ylabel('Pathloss [dB]')

distance_all = distance;
save('dataset_best_fit_6-15.mat', 'distance_all', 'fit_line_abg_all', 'fit_line_ci_all')
save('dataset_min_pathloss_alt_6-15.mat', 'distance_all', 'pl_struct_join', 'fit_line_ci_all')