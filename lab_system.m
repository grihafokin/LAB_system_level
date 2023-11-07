% CITE as Fokin, G. System-Level Model for Interference Evaluation in 5G 
% mmWave UDN with Location-Aware Beamforming. Information 2024, xx, xx. 

% the simulation model generates beams in the direction of given locations,
% in which UEs are served; beamforming is performed based on a known UE 
% location with a specified positioning error then, after the deployment 
% of base stations and UEs, the simulation model performs SINR estimation 
% on all UEs in the service cell, surrounded by six other interfering cells
close all; clear all; clc;
% dense-Urban-eMBB scenario according to ITU-R M.2412-0
udn.plot_enable=0;
udn.cell_num=7;               % number of cells
udn.sector_num=3;             % number of sectors

udn.radius=10;                % exclusion region radius, m
udn.UE_h = 1.5;               % UE antenna height, m
udn.gNB_h = 15;               % gNB antenna height, m
udn.eff_h=udn.gNB_h-udn.UE_h; % effective height, m
udn.txPowerDBm = 40;          % total transmit power (80 MHz), dBm
udn.txPower=(10.^((udn.txPowerDBm-30)/10)); % conversion dBm to W
udn.Am = 25;                  % back lobe suppression coefficient, dB
udn.SLAv = 20;                % side lobe suppression coefficient, dB
udn.GdB = 15;                 % antenna array gain, dBi
udn.G = 10^(udn.GdB/10);      % antenna array gain
udn.Gtx=3;                    % antenna array element gain, dBi
udn.fc=30 ;                   % carrier frequency, GHz
udn.angle_min=3;              % hpbw minimum value, degrees
udn.bw = 80e6;                % 80 MHz bandwidth
udn.rxNoiseFigure = 5;        % UE receiver noise figure, dB
udn.rxNoisePowerdB = ...
    -174 + 10*log10(udn.bw) + udn.rxNoiseFigure - 30;  % noise power, dB
udn.rxNoisePower = 10^(udn.rxNoisePowerdB/10);         % noise power, W     
udn.nrow = 32;        % number of elements in a row of rectangular array
udn.ncol = 32;        % number of elements in a column of rectangular array
% transmission power of one antenna array element, W
udn.txPowerSE = udn.txPower/(udn.nrow*udn.ncol);
udn.Gbf=10*log10(udn.nrow*udn.ncol); % max. antenna array gain with BF, dBi

udn.UE_num=64;                % number of UEs in a sector
udn.rcell=100;                % cell radius, m 
udn.accuracy=10;              % UE location uncertainty diameter, m

% hexagonal scenario of territorial distribution of gNB
[gNB, gNB_cell, gNB_sector]=lab_grid(udn.rcell);

% terrestrial distribution scenario UE_loc_est and UE_loc_true
[UE_est, UE_tru]=lab_deploy(udn, gNB, gNB_sector);

% directional radio links gNB_UE_est and gNB_UE_tru
[az_est, el_est, az_tru, el_tru] = lab_link(udn, gNB, UE_est, UE_tru);

% adjust HPBW beamwidth by location in radio links gNB_UE_est
[az_3dB, el_3dB]=lab_hpbw(udn, gNB, UE_est);
 
% estimate SINR in radio links gNB_UE_est and gNB_UE_tru
 [SINR_S_est, SINR_S_tru, SINR_SC_est, SINR_SC_tru, ...
    SINR_SCN_est, SINR_SCN_tru, SINR_SCNN_est, SINR_SCNN_tru] = ...
    lab_sinr(udn, gNB, UE_est, UE_tru, ...
    az_est, el_est, az_tru, el_tru, az_3dB, el_3dB);

udn.accuracy
SINR_S_est_mean = 10*log10(mean(cell2mat(SINR_S_est)))
SINR_S_tru_mean = 10*log10(mean(cell2mat(SINR_S_tru)))
SINR_SC_est_mean = 10*log10(mean(cell2mat(SINR_SC_est)))
SINR_SC_tru_mean = 10*log10(mean(cell2mat(SINR_SC_tru)))
SINR_SCN_est_mean = 10*log10(mean(cell2mat(SINR_SCN_est)))
SINR_SCN_tru_mean = 10*log10(mean(cell2mat(SINR_SCN_tru)))
% SINR_SCNN_est_mean = 10*log10(mean(cell2mat(SINR_SCNN_est)))
% SINR_SCNN_tru_mean = 10*log10(mean(cell2mat(SINR_SCNN_tru)))