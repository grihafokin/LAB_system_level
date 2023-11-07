function steer = evalsteer(sector_id, UE_Loc, gNB_Loc)
% evalsteer computes steering anle in horizontal plane, directed to UE_Loc 
% in a rectangular coordinate system, centered at the base station point 
% gNB_Loc, relative to the sector bisector with identifier sector_id:
% in sector 1 bisector = 90°, 
% in sector 2 bisector = 210°, 
% in sector 3 bisector = 330°.
angle = atan2d(UE_Loc(1,2)-gNB_Loc(1,2), UE_Loc(1,1)-gNB_Loc(1,1)); 
sign=0;
% display angle in positive range 0-360°
if angle<0
    angle= 360+angle;
    sign=1;
end
% in sector 1 bisector = 90°:
if sector_id ==1
    if  angle> 270 && sign==1
        angle = angle - 360;
    end
    steer= 90-angle;  
% in sector 2 bisector = 210:
elseif sector_id ==2
    if  angle < 30 
        angle = 360 + angle;
    end
    steer = 210-angle;
% in sector 3 bisector = 330°:
elseif sector_id ==3
    if  angle < 150 && sign==0
        angle=360+angle;
    end
    steer = 330-angle;
end
end 