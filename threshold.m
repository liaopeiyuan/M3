function output = threshold(m,pose,varargin)
    opt.maniplty='asada';
    opt.verbose=false;
    opt.ikine='analytic';
    opt.cutoff=0.03;
    
    opt = tb_optparse(opt, varargin);
    
    switch lower(strtrim(opt.ikine))
        case 'numerical'
            inverse=@ikine;
        case 'analytic'
            inverse=@ikine6s; 
        otherwise
            error('cannot parse inverse kinematics argument');
    end
    
    switch opt.maniplty
        case 'yoshikawa'
            mani=@maniplty;
        case 'asada'
            mani=@maniplty;
        otherwise
            mani=@dummy;
    end
    
    try
        q=inverse(m,pose);
        if all(not(isnan(q)))
            output=mani(m,q,opt.maniplty);
            if output<=opt.cutoff
                %figure 1
                %scatter(ct,output)
                %hold on
                %disp(output)
                output=NaN;
            end
        else
            output=NaN;
        end
    catch
        output=NaN;
    end
    
    function output=dummy(~,~,~)
        output=1;
    end   
end