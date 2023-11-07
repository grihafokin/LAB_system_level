function PL = evalfrisp(gNB_loc, UE_loc, eff_h, fc)
dist2D=norm(gNB_loc-UE_loc);              % 2D 
dist3D=sqrt((eff_h)^2+(dist2D)^2); % 3D
% free space path loss in gNB_loc-UE_loc radio link, dB 
PL = 32.4 + 21*log10(dist3D) + 20*log10(fc);
end