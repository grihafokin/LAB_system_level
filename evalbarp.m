function ARP = evalbarp(steer_True, steer_Est, az3dB, Am, ...
                        tilt_True, tilt_Est, el3dB, SLAv)
% antenna array pattern in horizontal plane
A_H = 12*(((steer_True-steer_Est)/az3dB).^2); 
A_H=-(min(A_H,Am));
% antenna array pattern in vertical plane
A_V=12*(((tilt_True-tilt_Est)/el3dB).^2);
A_V=-(min(A_V,SLAv)); 
% aggregate 3D antenna array pattern
ARP = A_H + A_V; 
ARP(ARP<-Am) = - Am; % дБ
end