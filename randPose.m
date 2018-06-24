function [vec,mat,pose] = randPose(r,dist)
       
    if lower(strtrim(dist))=="uniform"
        p=r*rand(1,3)-r/2;
        o=2*pi*rand(1,3); 
    elseif lower(strtrim(dist))=="normal"
        p=r*randn(1,3)-r/2;
        o=2*pi*randn(1,3); 
    else
        error('cannot parse distribution argument');        
    end
    
    mat=transl(p)*trotx(o(1))*troty(o(2))*trotz(o(3));
    pose=SE3(mat);
    vec=horzcat(p,o);
end