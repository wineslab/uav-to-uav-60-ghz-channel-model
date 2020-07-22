clear all
close all

load('dataset_min_pathloss_alt_6-15.mat')

dist_vector = zeros(1, numel(pl_struct_join));
num_other_beams = numel(pl_struct_join(1).beam_diffs);
beam_n = zeros(num_other_beams, numel(pl_struct_join));
deg_tx_n = zeros(num_other_beams, numel(pl_struct_join));
deg_rx_n = zeros(num_other_beams, numel(pl_struct_join));

for index = 1:numel(pl_struct_join)
    dist_vector(index) = pl_struct_join(index).dist;
    for b_i = 1:numel(pl_struct_join(index).beam_diffs)
        beam_n(b_i, index) = pl_struct_join(index).beam_diffs(b_i);
        deg_tx_n(b_i, index) = pl_struct_join(index).beam_diffs_deg_tx(b_i);
        deg_rx_n(b_i, index) = pl_struct_join(index).beam_diffs_deg_rx(b_i);
    end
end

markers = {'+','o','*','x','v','d','^','s','>','<'};

distance = unique(dist_vector);

%% ABG fit
for b_i = 1:num_other_beams
    index_2 = 1;
    
    x = [];
    y_2 = [];
    for dir_index = 1:numel(pl_struct_join)
        dist = pl_struct_join(dir_index).dist;
        if ~isempty(pl_struct_join(dir_index).beam_diffs(b_i))
            minima = pl_struct_join(dir_index).beam_diffs(b_i);
            support = 10*log10(pl_struct_join(dir_index).dist * ones(length(minima), 1));
            y_2(index_2:(index_2 + length(minima) - 1)) = minima;
            x(index_2:(index_2 + length(minima) - 1)) = support;
            index_2 = index_2 + length(minima);
        end
    end
    
    X = [ones(1, length(x)); x].';
    m_q(b_i, :) = X \ y_2';
    
    fit_line_beams(b_i, :) = m_q(b_i, 1) + m_q(b_i, 2) * 10 * log10(distance);
    
    % compute std dev
    diff_2 = [];
    for dir_index = 1:numel(pl_struct_join)
        dist = pl_struct_join(dir_index).dist;
        diff_2(dir_index) = pl_struct_join(dir_index).beam_diffs(b_i) - (m_q(b_i, 1) + m_q(b_i, 2) * 10 * log10(dist));
    end
    sigma_sq_abg_beams(b_i) = sum(diff_2.^2)/length(diff_2);
end

%% plot

tikz_enable = false;

for b_i = 8
    figure, hold on,
    plot(distance, fit_line_beams(b_i, :), strcat('-.'), 'DisplayName', strcat('ABG - second best beam'))
    plot(dist_vector, beam_n(b_i, :), markers{1}, 'DisplayName', strcat(num2str(b_i), '-th best beam values'))
    plot(distance_all, fit_line_ci_all, strcat('-'), 'DisplayName', strcat('CI, 6-15'))
    legend('-DynamicLegend')
    grid on
    xlabel('UAV-to-UAV distance')
    ylabel('Pathloss [dB]')
    
    
    if(tikz_enable)
       matlab2tikz(strcat('abg_best_', num2str(b_i), '.tex'), 'width', '\fwidth', 'height', '\fheight')
    end

end

figure, hold on,
for b_i = 1:num_other_beams
    plot(distance, fit_line_beams(b_i, :), strcat('-', markers{b_i}), 'DisplayName', strcat(num2str(b_i), '-th best beam values'))
end
plot(distance_all, fit_line_ci_all, strcat('--'), 'DisplayName', strcat('CI, 6-15'))
legend('-DynamicLegend')
grid on
xlabel('UAV-to-UAV distance')
ylabel('Pathloss [dB]')

tikz_enable = false;
if(tikz_enable)
   matlab2tikz('abg_best_beams.tex', 'width', '\fwidth', 'height', '\fheight')
end

