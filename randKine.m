function [feature,object]=randKine(DOF,type,r,dist)
    if lower(strtrim(type))=="spherical"
        if DOF==6
            % Mask Vector
            feature.D=[0 0 1 1 0 0];
            feature.A=[0 1 1 0 0 0];
            feature.alpha=[ pi/2 0 -pi/2 pi/2 -pi/2 0];
        else
            error('spherical wrist is only supported for 6-DOF manipulators');
        end
        
    elseif lower(strtrim(type))=="generic"
        if or(DOF==2,DOF>=6)                    
            feature.D=ones(1,DOF);
            feature.A=ones(1,DOF);
            feature.alpha=ones(1,DOF);
        else
            error('only 2 and 6+ DOF manipulators are supported for the generic option');
        end
        
    else
        error('cannot parse manipulator type argument');
    end
    
    if lower(strtrim(dist))=="uniform"
        for i=1:max(size(feature.D))
            if feature.D(i)==1
               feature.D(i)=r*rand(); 
            end
        end
        
        for i=1:max(size(feature.A))
            if feature.A(i)==1
               feature.A(i)=r*rand(); 
            end
        end
        
        for i=1:max(size(feature.alpha))
            if feature.alpha(i)==1
               feature.alpha(i)=2*pi*rand(); 
            end
        end
        
    elseif lower(strtrim(dist))=="normal"
        for i=1:max(size(feature.D))
            if feature.D(i)==1
               feature.D(i)=r*randn(); 
            end
        end
        
        for i=1:max(size(feature.A))
            if feature.A(i)==1
               feature.A(i)=r*randn(); 
            end
        end
        
        for i=1:max(size(feature.alpha))
            if feature.alpha(i)==1
               feature.alpha(i)=2*pi*randn(); 
            end
        end
        
    else
        error('cannot parse distribution argument');        
    end
    
    for i=1:DOF
        l(i)=Link([0 feature.D(i) feature.A(i) feature.alpha(i)]);
    end
    
    object=SerialLink(l);

end