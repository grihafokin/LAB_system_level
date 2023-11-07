function [SINR_S_est, SINR_S_tru, SINR_SC_est, SINR_SC_tru, ...
    SINR_SCN_est, SINR_SCN_tru, SINR_SCNN_est, SINR_SCNN_tru] = ...
    lab_sinr(udn, gNB, UE_est, UE_tru, ...
    az_est, el_est, az_tru, el_tru, az_3dB, el_3dB)
Am=udn.Am; SLAv=udn.SLAv; Gbf=udn.Gbf;

%% calculate SINR in radio links gNB_UE_est and gNB_UE_tru
for i=1:udn.sector_num % cycle by the sectors with index i 
    j=1; % index of the first central serving base station gNB
    for k=1:udn.UE_num % cycle by the UEs with index k
        %% power of the useful SOI signal in the radio link gNB_UE_est
        % antenna array pattern in horizontal and vertical plane with hpbw       
        ARP_SOI_est = evalbarp(...
            az_est{j,i}(k), az_est{j,i}(k), az_3dB{j,i}(k), Am, ...
            el_est{j,i}(k), el_est{j,i}(k), el_3dB{j,i}(k), SLAv);
        % calculation of the gain of the useful signal SOI due to BF
        BF_SOI_est = evalgain(...
            az_est{j,i}(k), az_est{j,i}(k), az_3dB{j,i}(k),...
            el_est{j,i}(k), el_est{j,i}(k), el_3dB{j,i}(k), Gbf);
        % UE_est coordinates, free space path loss
        gNB_SOI=[gNB(j,1),gNB(j,2)];
        UE_loc_est = [UE_est{j,i}(k,1),UE_est{j,i}(k,2)]; 
        PL_SOI_est = evalfrisp(gNB_SOI, UE_loc_est, udn.eff_h, udn.fc);
        % useful signal power SOI, dB
        P_SOI_est = udn.txPowerDBm + udn.Gtx - ...
            PL_SOI_est + ARP_SOI_est + BF_SOI_est;
        P_SOI_est = 10^(P_SOI_est/10); % from dB to linear units
        
        % initialization of SNOI interference arrays in radio links gNB_UE_est
        P_SNOI_S_est=[]; % 1×(UE_num-1) array of interference within one sector
        P_SNOI_C_est=[]; % 1×(2×UE_num) array of interference between cell sectors
        P_SNOI_N_est=[]; % 1×(6×3×UE_num) array of interference between network cells

        %% power of the useful SOI signal in the radio link gNB_UE_tru
        % antenna array pattern in horizontal and vertical plane with hpbw
        ARP_SOI_tru = evalbarp(...
            az_tru{j,i}(k), az_est{j,i}(k), az_3dB{j,i}(k), Am, ...
            el_tru{j,i}(k), el_est{j,i}(k), el_3dB{j,i}(k), SLAv);
        % calculation of the gain of the useful signal SOI due to BF
        BF_SOI_tru = evalgain(...
            az_tru{j,i}(k), az_est{j,i}(k), az_3dB{j,i}(k),...
            el_tru{j,i}(k), el_est{j,i}(k), el_3dB{j,i}(k), Gbf);
        % UE_tru coordinates, free space path loss
        UE_loc_tru = [UE_tru{j,i}(k,1),UE_tru{j,i}(k,2)]; 
        PL_SOI_tru = evalfrisp(gNB_SOI, UE_loc_tru, udn.eff_h, udn.fc);
        % useful signal power SOI, dB
        P_SOI_tru=udn.txPowerDBm + udn.Gtx - ...
            PL_SOI_tru + ARP_SOI_tru + BF_SOI_tru;
        P_SOI_tru = 10^(P_SOI_tru/10); % from dB to linear units
        % initialization of SNOI interference arrays in radio links gNB_UE_tru
        P_SNOI_S_tru=[]; % array 1x63 interference within one sector
        P_SNOI_C_tru=[]; % 1x128 array of inter-sector interference within a cell
        P_SNOI_N_tru=[]; % array 1×1152 (1152/128=9) interference between network cells

        %% interference power SNOI_S within one sector
        for m=1:udn.UE_num % cycle through UE with indices m~=k
            if m~=k 
                %% interference power SNOI_S in the radio link gNB_UE_est
                % antenna array pattern in horizontal and vertical plane with hpbw                
                ARP_SNOI_S_est = evalbarp(...
                    az_est{j,i}(k), az_est{j,i}(m), az_3dB{j,i}(m), Am, ...
                    el_est{j,i}(k), el_est{j,i}(m), el_3dB{j,i}(m), SLAv);
                % calculation of the gain of the interference SNOI_S within one sector due to BF
                BF_SNOI_S_est = evalgain(...
                    az_est{j,i}(k), az_est{j,i}(m), az_3dB{j,i}(m),...
                    el_est{j,i}(k), el_est{j,i}(m), el_3dB{j,i}(m), Gbf);
                % intra-sector interference calculation
                I_SNOI_S_est = udn.txPowerDBm + udn.Gtx - ...
                    PL_SOI_est + ARP_SNOI_S_est + BF_SNOI_S_est;
                I_SNOI_S_est = 10^(I_SNOI_S_est/10); % from dB to linear units
                P_SNOI_S_est = [P_SNOI_S_est, I_SNOI_S_est];
                %% interference power SNOI_S in the radio link gNB_UE_tru
                % antenna array pattern in horizontal and vertical plane with hpbw   
                ARP_SNOI_S_tru = evalbarp(...
                    az_tru{j,i}(k), az_est{j,i}(m), az_3dB{j,i}(m), Am, ...
                    el_tru{j,i}(k), el_est{j,i}(m), el_3dB{j,i}(m), SLAv);
                % calculation of the gain of the interference SNOI_S within one sector due to BF
                BF_SNOI_S_tru = evalgain(...
                    az_tru{j,i}(k), az_est{j,i}(m), az_3dB{j,i}(m),...
                    el_tru{j,i}(k), el_est{j,i}(m), el_3dB{j,i}(m), Gbf);
                % intra-sector interference calculation
                I_SNOI_S_tru =udn.txPowerDBm + udn.Gtx - ...
                    PL_SOI_tru + ARP_SNOI_S_tru + BF_SNOI_S_tru; 
                I_SNOI_S_tru = 10^(I_SNOI_S_tru/10); % from dB to linear units
                P_SNOI_S_tru = [P_SNOI_S_tru, I_SNOI_S_tru];
            end 
        end 
        
        %% interference power SNOI_C between sectors within the same cell
        for l=1:udn.sector_num % cycle by sector within one cell
            if l~=i % cycle through sectors with indices l~=i
                for m=1:udn.UE_num % cycle through UE with indices m
                    %% interference power SNOI_C in the radio link gNB_UE_est
                    % calculating the direction steer_est
                    steer_SNOI_C_est = evalsteer(l, UE_loc_est, gNB_SOI);
                    % antenna array pattern in horizontal and vertical plane with gNB_UE_hpbw_est                   
                    ARP_SNOI_C_est = evalbarp(...
                        steer_SNOI_C_est, az_est{j,l}(m), az_3dB{j,l}(m), Am, ... 
                        el_est{j,i}(k), el_est{j,l}(m), el_3dB{j,l}(m), SLAv);
                    % gain of the interference between sectors within the same cell due to BF
                    BF_SNOI_C_est = evalgain(...
                        steer_SNOI_C_est, el_est{j,l}(m), az_3dB{j,l}(m),...
                        el_est{j,i}(k), el_est{j,l}(m),  el_3dB{j,l}(m), Gbf);
                    % calculation of interference between sectors within one cell
                    I_SNOI_C_est = udn.txPowerDBm + udn.Gtx - ...
                        PL_SOI_est + ARP_SNOI_C_est + BF_SNOI_C_est;
                    I_SNOI_C_est = 10^(I_SNOI_C_est/10); % from dB to linear units
                    P_SNOI_C_est = [P_SNOI_C_est, I_SNOI_C_est];
                    %% interference power SNOI_C in the radio link gNB_UE_tru
                    % direction calculation steer_SNOI_C_tru
                    steer_SNOI_C_tru = evalsteer(l, UE_loc_tru, gNB_SOI); 
                    % antenna array pattern in horizontal and vertical plane with gNB_UE_hpbw_est
                    ARP_SNOI_C_tru = evalbarp(...
                        steer_SNOI_C_tru, el_est{j,l}(m), az_3dB{j,l}(m), Am, ... 
                        el_tru{j,i}(k), el_est{j,l}(m),  el_3dB{j,l}(m), SLAv);
                    % gain of the interference between sectors within the same cell due to BF
                    BF_SNOI_C_tru = evalgain(...
                        steer_SNOI_C_tru, az_est{j,l}(m), az_3dB{j,l}(m),...
                        el_tru{j,i}(k), el_est{j,l}(m),  el_3dB{j,l}(m), Gbf); 
                    % calculation of interference between sectors within one cell
                    I_SNOI_C_tru=udn.txPowerDBm + udn.Gtx -... 
                        PL_SOI_tru + ARP_SNOI_C_tru + BF_SNOI_C_tru;
                    I_SNOI_C_tru = 10^(I_SNOI_C_tru/10); % from dB to linear units
                    P_SNOI_C_tru = [P_SNOI_C_tru, I_SNOI_C_tru];
                end 
            end 
        end
        
        %% interference power SNOI_N between network cells
        for n=2:udn.cell_num        % cycle through 6 gNB except central
            for l=1:udn.sector_num  % cycle through sectors with indexes l
                for m=1:udn.UE_num  % cycle through UE with indices m
                    % coordinates of the current gNB_SNOI_N
                    gNB_SNOI_N=[gNB(n,1),gNB(n,2)]; 
                    %% interference power SNOI_N in the radio link gNB_UE_est
                    % 2D distance in link between gNB_SNOI_N and UE_loc_est
                    d2D_SNOI_N_est=norm(UE_loc_est - gNB_SNOI_N);   
                    % 3D distance in link between gNB_SNOI_N and UE_loc_est
                    d3D_SNOI_N_est=sqrt((udn.eff_h)^2 + (d2D_SNOI_N_est)^2);
                    % tilt angle in link between gNB_SNOI_N and UE_loc_est
                    tilt_SNOI_N_est=atan2d(udn.eff_h, d3D_SNOI_N_est); 
                    % azimuth angle in link between gNB_SNOI_N and UE_loc_est
                    steer_SNOI_N_est=evalsteer(l,UE_loc_est,gNB_SNOI_N); 
                    % antenna array pattern in horizontal and vertical plane with hpbw
                    ARP_SNOI_N_est = evalbarp(...
                        steer_SNOI_N_est, az_est{n,l}(m), az_3dB{n,l}(m), Am, ... 
                        tilt_SNOI_N_est, el_est{n,l}(m),  el_3dB{n,l}(m), SLAv);
                    % gain of the interference between cells due to BF               
                    BF_SNOI_N_est = evalgain(...
                        steer_SNOI_N_est, az_est{n,l}(m), az_3dB{n,l}(m),...
                        tilt_SNOI_N_est, el_est{n,l}(m),  el_3dB{n,l}(m), Gbf);
                    % free space path loss calculation
                    PL_SNOI_N_est=21*log10(d3D_SNOI_N_est) +...
                        32.4 + 20*log10(udn.fc);
                    % calculation of interference between network cells
                    I_SNOI_N_est=udn.txPowerDBm + udn.Gtx - ...
                        PL_SNOI_N_est + ARP_SNOI_N_est + BF_SNOI_N_est;
                    I_SNOI_N_est = 10^(I_SNOI_N_est/10); % из дБ в лин. ед.
                    P_SNOI_N_est = [P_SNOI_N_est, I_SNOI_N_est]; 
                    %% interference power SNOI_N in the radio link gNB_UE_tru
                    % 2D distance in link between gNB_SNOI_N and UE_loc_tru
                    d2D_SNOI_N_tru=norm(UE_loc_tru - gNB_SNOI_N); 
                    % 3D distance in link between gNB_SNOI_N and UE_loc_tru
                    d3D_SNOI_N_tru=sqrt((udn.eff_h)^2 + (d2D_SNOI_N_tru)^2);
                    % tilt angle in link between gNB_SNOI_N and UE_loc_tru
                    tilt_SNOI_N_tru=atan2d(udn.eff_h, d3D_SNOI_N_tru);
                    % azimuth angle in link between gNB_SNOI_N and UE_loc_tru
                    steer_SNOI_N_tru = evalsteer(l, UE_loc_tru, gNB_SNOI_N);
                    % antenna array pattern in horizontal and vertical plane with hpbw
                    ARP_SNOI_N_tru = evalbarp(...
                        steer_SNOI_N_tru, az_est{n,l}(m), az_3dB{n,l}(m), Am, ... 
                        tilt_SNOI_N_tru, el_est{n,l}(m),  el_3dB{n,l}(m), SLAv);
                    % gain of the interference between cells due to BF  
                    BF_SNOI_N_tru = evalgain(...
                        steer_SNOI_N_tru, az_est{n,l}(m), az_3dB{n,l}(m),...
                        tilt_SNOI_N_tru, el_est{n,l}(m),  el_3dB{n,l}(m), Gbf);
                    % free space path loss calculation
                    PL_SNOI_N_tru=21*log10(d3D_SNOI_N_tru) +...
                        32.4 + 20*log10(udn.fc);
                     % calculation of interference between network cells
                    I_SNOI_N_tru=udn.txPowerDBm + udn.Gtx - ...
                        PL_SNOI_N_tru + ARP_SNOI_N_tru + BF_SNOI_N_tru;
                    I_SNOI_N_tru = 10^(I_SNOI_N_tru/10); % из дБ в лин. ед.
                    P_SNOI_N_tru = [P_SNOI_N_tru, I_SNOI_N_tru]; 
                end
            end 
        end 
        %% SINR calculation
        % interference power SNOI_S within one sector
        SINR_S_est{1,i}(k) = P_SOI_est/(sum(P_SNOI_S_est));
        SINR_S_tru{1,i}(k) = P_SOI_tru/(sum(P_SNOI_S_tru)); 
        % interference power SNOI_S within one sector +
        % interference power SNOI_C between sectors within the same cell
        SINR_SC_est{1,i}(k) = P_SOI_est/(sum(P_SNOI_S_est)+sum(P_SNOI_C_est));
        SINR_SC_tru{1,i}(k) = P_SOI_tru/(sum(P_SNOI_S_tru)+sum(P_SNOI_C_tru)); 
        % interference power SNOI_S within one sector +
        % interference power SNOI_C between sectors within the same cell +
        % interference power SNOI_N between network cells
        SINR_SCN_est{1,i}(k) = P_SOI_est/(sum(P_SNOI_S_est)+...
            sum(P_SNOI_C_est) + sum(P_SNOI_N_est));  
        SINR_SCN_tru{1,i}(k) = P_SOI_tru/(sum(P_SNOI_S_tru)+...
            sum(P_SNOI_C_tru)+sum(P_SNOI_N_tru));  
        % interference power SNOI_S within one sector +
        % interference power SNOI_C between sectors within the same cell +
        % interference power SNOI_N between network cells + noise
        SINR_SCNN_est{1,i}(k) = P_SOI_est / (sum(P_SNOI_S_est)+...
            sum(P_SNOI_C_est) + sum(P_SNOI_N_est) + udn.rxNoisePower);
        SINR_SCNN_tru{1,i}(k) = P_SOI_tru / (sum(P_SNOI_S_tru)+...
            sum(P_SNOI_C_tru)+sum(P_SNOI_N_tru) + udn.rxNoisePower);
    end % cycle by number of UEs k
end % cycle by number of sectors i
end