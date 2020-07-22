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

tikz_enable = false;
for b_i = 1:8
    figure, hold on,
    plot(dist_vector, deg_tx_n(b_i, :), markers{1}, 'DisplayName', strcat(num2str(b_i), ' TX err'))
    plot(dist_vector, deg_rx_n(b_i, :), markers{2}, 'DisplayName', strcat(num2str(b_i), ' RX err'))
    legend('-DynamicLegend')
    grid on
    xlabel('UAV-to-UAV distance')
    ylabel('Pathloss [dB]')
    
    
    if(tikz_enable)
       matlab2tikz(strcat('abg_best_', num2str(b_i), '.tex'), 'width', '\fwidth', 'height', '\fheight')
    end

end

mean(deg_tx_n + deg_rx_n, 2)
