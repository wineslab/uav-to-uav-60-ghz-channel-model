function [num_beam_diff_tx] = find_beam_angle_diff(tx_beam, best_tx_beam)

if(tx_beam >= 32)
    tx_beam = 31 - tx_beam;
end
if(best_tx_beam >= 32)
    best_tx_beam = 31 - best_tx_beam;
end

num_beam_diff_tx = abs(tx_beam - best_tx_beam) * 1.4; % 1.4 is the beam width in our experiments
end

