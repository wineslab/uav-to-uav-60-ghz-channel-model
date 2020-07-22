close all
clear all

% set according to your MATLAB version
% import_data = @import_normalized_2019b;
import_data = @import_dataset_2019b;

dataset_path = 'dataset.csv';

% gains with three digits are repetitions of the first two digits of the
% gain
tx_gain_6 = [5, 10; ... % 6
    14, 16; %12
    18, 20; %18
    22, 25; %24
    251, 25; %28
    251, 25; %32
    251, 25; %36
    251, 25]; %40

tx_gain_12 = [5, 10, 0, 0; ... % 6
    10, 14, 0, 0; %9
    14, 16, 0, 0; %12
    16, 18, 0, 0; %15
    18, 20, 0, 0; %18
    20, 25, 0, 0; %21
    22, 24, 25, 251; %24
    0, 25, 0, 0; %27
    0, 25, 0, 0; %30
    0, 25, 0, 0; %33
    0, 25, 0, 0; %36
    251, 25, 0, 0]; %40

tx_gain_15 = [0, 10; ... % 6
    14, 0; %12
    18, 0; %18
    22, 0; %24
    0, 25; %30
    0, 25; %36
    0, 25]; %40

% import dataset
dataset = import_data(strcat(dataset_path));

% get altitude vector
alt_vec = unique(dataset.(2));

for a = 1:length(alt_vec)
    altitude = alt_vec(a);
    
    % only keep values for current altitude
    dataset_alt = dataset(dataset.(2) == altitude, :);
    
    % get distances
    distance = unique(dataset_alt.(1));
    
    if(altitude == 6)
        tx_gain = tx_gain_6;
    elseif(altitude == 12)
        tx_gain = tx_gain_12;
    elseif(altitude == 15)
        tx_gain = tx_gain_15;
    end
    
    res_list_min = zeros(numel(distance), 1);
    dist_list_min = zeros(numel(distance), 1);
    
    res_list_mean = zeros(numel(distance), 1);
    dist_list_mean = zeros(numel(distance), 1);
    
    pl_struct = struct('dist', [], 'mean', [], 'min', [], ...
        'beam_diffs', [], 'beam_diffs_deg_tx', [], 'beam_diffs_deg_rx', []);
    
    for d = 1:length(distance)        
        curr_dist = distance(d);
        
        % only keep values for current distance
        dataset_dis = dataset_alt(dataset_alt.(1) == curr_dist, :);
                
        % extract vectors
        tx_beam = dataset_dis.(3);
        rx_beam = dataset_dis.(4);
        tx_gain_idx = dataset_dis.(5);
        path_loss = dataset_dis.(16);
        
        tmp_gain_idx = 1;
        min_pl = [];
        min_pl_diff_3 = [];
        for idx = tx_gain(d, :)
            indeces = find(tx_gain_idx == idx);
            tx_beam_this = tx_beam(indeces);
            rx_beam_this = rx_beam(indeces);
            pl_this = path_loss(indeces);
            
            if(~isempty(indeces))
                [min_pl(tmp_gain_idx), min_pl_index] = min(pl_this);
                disp(strcat('gain ', num2str(idx), ' min_pl = ', num2str(min_pl(tmp_gain_idx)), ...
                    ' tx_beam_idx = ', num2str(tx_beam_this(min_pl_index)), ....
                    ' rx_beam_idx = ', num2str(rx_beam_this(min_pl_index))))
                
                best_tx_beam = tx_beam_this(min_pl_index);
                best_rx_beam = rx_beam_this(min_pl_index);
                
                % identify nine other best beams
                min_4_pl = mink(pl_this, 9); % - min_pl(tmp_gain_idx);
                % min_4_pl(min_4_pl == 0) = [];
                min_pl_diff_3(tmp_gain_idx, :) = min_4_pl(2:end);
                
                % find the difference in degrees for the tx and rx beam
                % pairs
                for bbp_index = 1:length(min_pl_diff_3(tmp_gain_idx, :))
                   index_in_pl_this = find( pl_this == min_pl_diff_3(tmp_gain_idx, bbp_index));
                   tx_beam_bbp = tx_beam_this(index_in_pl_this);
                   rx_beam_bbp = rx_beam_this(index_in_pl_this);
                   
                   diff_deg_tx(tmp_gain_idx, bbp_index) = find_beam_angle_diff(tx_beam_bbp, best_tx_beam);
                   diff_deg_rx(tmp_gain_idx, bbp_index) = find_beam_angle_diff(rx_beam_bbp, best_rx_beam);
                end
                
                tmp_gain_idx = tmp_gain_idx + 1;
            end
        end
        
        [exp_min, gain_idx] = min(min_pl);
        diff_to_consider = min_pl_diff_3(gain_idx, :);
        diff_deg_to_consider_tx = diff_deg_tx(gain_idx, :);
        diff_deg_to_consider_rx = diff_deg_rx(gain_idx, :);
        exp_mean = mean(min_pl);
        
        % find min pathloss gain tx and rx beams
        min_pl_index = find(path_loss == exp_min);
        min_pl_gain = tx_gain_idx(min_pl_index);
        min_pl_tx_beam = tx_beam(min_pl_index);
        min_pl_rx_beam = rx_beam(min_pl_index);
        
        % fill structure
        pl_struct(d).dist = distance(d);
        pl_struct(d).mean = [pl_struct(d).mean; exp_mean];
        pl_struct(d).min = [pl_struct(d).min; exp_min];
        pl_struct(d).beam_diffs = [pl_struct(d).beam_diffs, diff_to_consider];
        pl_struct(d).beam_diffs_deg_tx = [pl_struct(d).beam_diffs_deg_tx, diff_deg_to_consider_tx];
        pl_struct(d).beam_diffs_deg_rx = [pl_struct(d).beam_diffs_deg_rx, diff_deg_to_consider_rx];
    end
    
    save(strcat('dataset_min_pathloss_alt_', num2str(altitude), '.mat'), 'distance', 'altitude', 'pl_struct')
end



