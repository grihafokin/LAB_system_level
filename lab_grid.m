function [gNB, gNB_cell, gNB_sector]=lab_grid(r)
% formation of a terrestrial distribution scenario
radius = 1; % the area, not accessible to the UE, is excluded from sector
% formation of a hexagonal grid with the central gNB cell at point (0,0);
% centers of neighboring 6 cells are determined relative to central cell
gNB=[0 0]; % location of the base station of the serving central cell
for theta=30:60:330
    x= r*sqrt(3)*cosd(theta);
    y= r*sqrt(3)*sind(theta);
    gNB = [gNB; x y];
end
% cell boundaries gNB_cell of the serving and neighboring cells 
for i=1:length(gNB)
    xc = gNB(i,1);
    yc = gNB(i,2);
    xn = [(r+xc) (r/2+xc) (-r/2+xc) (-r+xc) (-r/2+xc) (r/2+xc) (r+xc)];
    yn = [yc (r*sqrt(3)/2+yc) (r*sqrt(3)/2+yc) ...
        yc (-r*sqrt(3)/2+yc) (-r*sqrt(3)/2+yc) yc];
    gNB_cell{i}=polyshape(xn,yn);
end
% sector boundaries gNB_sector of the serving and neighboring cells 
for i=1:length(gNB)
    xc = gNB(i,1);
    yc = gNB(i,2);
    % sector 1
    x1 = [xc+3*r/4 xc+r/2 xc-r/2 xc-3*r/4 xc];
    y1 = [yc+r*sqrt(3)/4 yc+r*sqrt(3)/2 yc+r*sqrt(3)/2 yc+r*sqrt(3)/4 yc];
    % sector 2
    x2 =[xc-3*r/4 xc-r xc-r/2 xc xc];
    y2 =[yc+r*sqrt(3)/4 yc yc-r*sqrt(3)/2 yc-r*sqrt(3)/2 yc];
    % sector 3
    x3 =[xc xc+r/2 xc+r xc+3*r/4 xc];
    y3 =[yc-r*sqrt(3)/2 yc-r*sqrt(3)/2 yc yc+r*sqrt(3)/4 yc];
    % area, not available for UE use, is excluded from the sector
    th = 0:pi/50:2*pi;
    xunit = radius * cos(th) + xc;
    yunit = radius * sin(th) + yc;
    poly0 = polyshape(xunit(1:end-1),yunit(1:end-1));
    % formation of complete sectors area
    poly1 = polyshape(x1,y1);
    poly2 = polyshape(x2,y2);
    poly3 = polyshape(x3,y3);
    % used (for UE distribution) sector area
    gNB_sector{i,1} = subtract(poly1, poly0);
    gNB_sector{i,2} = subtract(poly2, poly0);
    gNB_sector{i,3} = subtract(poly3, poly0);
end
end