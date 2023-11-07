function [az_est, el_est, az_tru, el_tru]=...
    lab_link(udn, gNB, UE_est, UE_tru)
% formation of arrays of beam orientations by azimuth and elevation
% in radio links gNB_UE_loc_est, gNB_UE_loc_tru
az_est{udn.cell_num,udn.sector_num}=[];
el_est{udn.cell_num,udn.sector_num}=[];
az_tru{1,udn.sector_num}=[];
el_tru{1,udn.sector_num}=[];
for j=1:udn.cell_num % cycle by number of cells
    for i=1:udn.sector_num % cycle by number of sectors
        for k=1:udn.UE_num % cycle by number of UEs
            UE_loc_est = UE_est{j,i}(k,:);
            gNB_loc=[gNB(j,1),gNB(j,2)];
            dist2D_loc_est=norm(UE_loc_est-gNB_loc); % 2D 
            % azimuth orientation angle in the radio link gNB_UE_loc_est
            steer_loc_est=evalsteer(i,UE_loc_est,gNB_loc);
            % tilt angle in the radio link gNB_UE_loc_est
            tilt_loc_est=atan2d(udn.eff_h, dist2D_loc_est);
            % fill arrays of beam orientations
            az_est{j,i}=[az_est{j,i}; steer_loc_est];
            el_est{j,i}=[el_est{j,i}; tilt_loc_est];
            if j==1 % for radio links gNB_UE_loc_tru in the center cell
                UE_loc_tru = UE_tru{j,i}(k,:);
                dist2D_loc_tru=norm(UE_loc_tru-gNB_loc); % 2D 
                % azimuth orientation angle in radio link gNB_UE_loc_tru
                steer_loc_true=evalsteer(i,UE_loc_tru,gNB_loc);
                % tilt angle in the radio link UE_loc_tru-gNB
                tilt_loc_true=atan2d(udn.eff_h, dist2D_loc_tru);
                % fill arrays of beam orientations
                az_tru{j,i}=[az_tru{j,i}; steer_loc_true];
                el_tru{j,i}=[el_tru{j,i}; tilt_loc_true];
            end % if j==1 
        end % cycle by number of UEs
    end % cycle by number of sectors
end % cycle by number of cells
end