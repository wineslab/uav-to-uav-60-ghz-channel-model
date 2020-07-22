## Experimental UAV-to-UAV mmWave Channel Model

This repository contains the dataset and MATLAB scripts to generate the results for the paper M. Polese, L. Bertizzolo, L. Bonati, A. Gosain, T. Melodia, An Experimental mmWave Channel Model for UAV-to-UAV Communications, in Proc. of ACM Workshop on Millimeter-Wave Networks and Sensing Systems (mmNets), London, UK, Sept. 2020. Please cite the paper if you plan to use the model, data, or code in your publication.

## Instructions

The file `dataset.csv` contains the measured data as processed by Facebook Terragraph sounders.

You can load and save the processed data in a `.mat` file using `load_dataset.m`. Then, the scripts `fit_6.m`, `fit_12.m`, `fit_15.m` and `fit_6_12_15.m` perform the fit on the measurements. Finally, `compare_height.m`, `compare_3gpp.m`, `compare_beam_dist.m`, and `compare_beam_error_deg.m` generate the plots shown in the paper.

The parameters in the `database.csv` are defined as follows:

- `distance`: Distance between the UAVs

- `altitude`: Altitude of the UAVs from the ground

- `link_dir`: Direction of transmission, e.g., "1to2" indicates that node 1 is transmitting and node 2 is receiving

- `tx_beam`, `rx_beam`: Transmitter and receiver beam indices used for scanning

- `mcs`: IEEE 802.11ad Modulation and Coding Scheme (MCS)

- `tx_mask*`, `rx_mask*`: Transmitter and receiver antenna masks. Defines which antenna elements are active. The three hexadecimal numbers in the mask represent the active state of the specific tile (*_mask22, *_mask23, *_mask24), where a 1 in a binary position represents an active and a 0 represents an inactive element. E.g., "0xfff" specifies that all beams are active on the specific tile.

- `tx_gain_idx`: Transmitter gain indices

- `rx_rf_gain_idx`, `rx_if_gain_idx`: Receiver gains indices from the Automatic Gain Control (AGC) closed-loop feedback regulating circuit in the node amplifier chains

- `stf_snr`: SNR measure based on spatiotemporal filtering (STF)

- `post_snr`: Post-equalization SNR

- `rssi`: Received Signal Strength Indicator (RSSI)

- `rssi std`: RSSI standard deviation

- `tx temp`, `rx temp`: Transmitter and receiver nodes junsction temperature

- `eirp`: Effective Radiated Power (EIRP) at the receiver node

- `pRx`: Received power at the receiver node

- `path_loss`: Signal path loss calculated from the difference of EIRP and received power
