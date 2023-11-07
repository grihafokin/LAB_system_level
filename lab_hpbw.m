function [az_3dB, el_3dB] = lab_hpbw(udn, gNB_loc, UE_est)
% formation of beamwidth arrays
% in azimuth and elevation in radio links UE_est
az_3dB{udn.cell_num,udn.sector_num}=[];
el_3dB{udn.cell_num,udn.sector_num}=[];
for j=1:udn.cell_num % cycle by number of cells
    for i=1:udn.sector_num % cycle by number of sectors
        for k=1:udn.UE_num % cycle by number of UEs
            gNB_locj=[gNB_loc(j,1), gNB_loc(j,2)];
            UE_loc_est=[UE_est{j,i}(k,1), UE_est{j,i}(k,2)];
            dist2D_est=norm(UE_loc_est-gNB_locj);          % 2D 
            rc=udn.accuracy/2; % circle radius
            % calculation of az3dB to cover the location uncertainty zone
            % coordinates of the intersection points of two circles
            [xout,yout]=circcirc(gNB_locj(1,1), gNB_locj(1,2),...
                dist2D_est, UE_loc_est(1), UE_loc_est(2),rc); 
            p1=[xout(1,1),yout(1,1)];
            p2=[xout(1,2),yout(1,2)];
            dp1=norm(gNB_locj-p1); % point-center distance
            dp2=norm(gNB_locj-p2); % point-center distance 
            dpp=norm(p1-p2);
            % effective distance from center
            dp1_eff=sqrt((dp1^2)+(udn.eff_h^2));
            dp2_eff=sqrt((dp2^2)+(udn.eff_h^2));
            az3dB=acosd(((dp1_eff^2)+...
                (dp2_eff^2)-(dpp^2))/(2*dp1_eff*dp2_eff));
            if az3dB < udn.angle_min
                az3dB = udn.angle_min;
            end
           % calculation of el3dB to cover the location uncertainty zone
            theta = 0 : 0.01 : 2*pi; % length(theta) = 629
            xc = UE_loc_est(1) + rc*cos(theta);
            yc = UE_loc_est(2) + rc*sin(theta);
            % calculates closest and farthest point on the circle from gNB
            near=dist2D_est;
            far=near;
            for n=1:length(xc)       % length(theta) = 629
                point=[xc(1,n) yc(1,n)];
                tmp=norm(gNB_locj-point);
                if tmp<near
                    near=tmp;
                    nearestp=point;
                end
                if tmp>far
                    far=tmp;
                    farthest=point;
                end
            end
            dpp=norm(farthest-nearestp); % point-to-point distance
            % effective distance from center
            near_eff=sqrt((near^2)+(udn.eff_h^2));
            far_eff=sqrt((far^2)+(udn.eff_h^2));
            el3dB=acosd(((near_eff^2)+...
                (far_eff^2)-(dpp^2))/(2*near_eff*far_eff));
            if el3dB < udn.angle_min
                el3dB = udn.angle_min;
            end
            % save all angles of each location point           
            az_3dB{j,i}=[az_3dB{j,i};az3dB];
            el_3dB{j,i}=[el_3dB{j,i};el3dB];
        end % cycle by number of UEs
    end % cycle by number of sectors
end % cycle by number of cells
end