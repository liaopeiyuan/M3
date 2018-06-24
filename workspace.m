function cuboid = workspace(m,position,orientation,params)
    
    opt.maniplty=false;
    opt.verbose=false;
    opt.ikine='numerical';
    
    opt = tb_optparse(opt, params);
    
    switch lower(strtrim(opt.ikine))
        case 'numerical'
            inverse=@ikine;
        case 'analytic'
            inverse=@ikine6s; 
        otherwise
            error('cannot parse inverse kinematics argument');
    end
            
       
    if max(size(position))==3
        if opt.verbose
            if max(size(orientation))==3
                error('wrong scope parameters')
            else
                disp('assuming orientation workspace')
            end
        else
            
        end
    end
    
    if max(size(orientation))==3
        if opt.verbose
            if max(size(position))==3
                error('wrong scope parameters')
            else
                disp('assuming constant orientation workspace')
            end
        else
            
        end       
    end
    
    if and(max(size(position))==6, max(size(position))==6)
        if opt.verbose
            disp('assuming full workspace')
        else
        end
    end

    [sizeX,sizeY,sizeZ]=size(P);
end

    