function [features,labels]=NNsample(size,dir,params)
    opt.format='csv';
    opt.variant='CGAN';
    opt.parallel=true;
    
    opt = tb_optparse(opt, params);
    
    if opt.parallel
        parfor i=1:size
        end
    else
        for i=1:size
        end
    end
end

    

