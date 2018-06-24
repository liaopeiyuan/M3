function output = threshold(m,pose,varargin)
    opt.maniplty='yoshikawa';
    opt.verbose=false;
    opt.ikine='numerical';
    opt.cutoff=0.3;
    
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