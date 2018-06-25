function [features,labels]=NNsample(num,parallel,varargin)
    opt.format='csv';
    opt.variant='CGAN';
    opt.mani='kine';
    opt.DOF=6;
    opt.type='spherical';
    opt.r=0.5;
    opt.dist='uniform';
    opt.poseR=0.8;
    opt.ikine='analytic';
    opt.plim=50;
    opt.testRatio=0.01;
    opt.cutoff=0.03;
    
    opt = tb_optparse(opt, varargin);
    
    switch opt.mani
        case 'kine'
            randMani=@randKine;
        case 'dyna'
            randMani=@randDyna;
        otherwise
            error('cannot parse manipulator argument')
    end
    
    [initF,initL]=randSample(opt,randMani);
    disp(initF)
    [~,fSize]=size(initF);
    [~,lSize]=size(initL);
    features=zeros(num,fSize);
    labels=zeros(num,lSize);
    clear initF initL fSize lSize
        
    if parallel
        parfor i=1:num
            [features(i,:),labels(i,:)]=randSample(opt,randMani);
            if mod(i,200)==0
               disp(strcat(num2str(i),' samples generated')) 
            end
        end
    else
        for i=1:num
            [features(i,:),labels(i,:)]=randSample(opt,randMani);
            if mod(i,200)==0
               disp(strcat(num2str(i),' samples generated')) 
            end
        end
    end
    
    %{
    function [feature,label]=randomSample(opt)
        [featureSt,m]=randMani(opt.DOF,opt.type,opt.r,opt.dist);
        switch opt.variant
            case 'CGAN'
                for k=1:plim
                [vec,~,pose]=randPose(opt.poseR,opt.dist);
                output=threshold(m,pose,'ikine',opt.ikine);
                if not(isnan(output))
                    label=vec;
                    if opt.mani=='kine'
                        feature=horzcat(featureSt.D,featureSt.A,featureSt.alpha);
                    end
                    if opt.mani=='dyna'
                        feature=horzcat(feature,featureSt.mass,...
                                        reshape(featureSt.R,1,[]),...
                                        reshape(featureSt.l,1,[]),...
                                        featureSt.B,...
                                        reshape(featureSt.Tc,1,[]),...
                                        featureSt.G,featureSt.Jm);
                    end
                    break;
                end  
                end  
            otherwise
                error('cannot parse variant argument')
        end
    end
    %}
        
    switch opt.format
        case 'csv'
            csvwrite('featureTrain.csv',features(1:int32((1-opt.testRatio)*num),:))
            csvwrite('labelTrain.csv',labels(1:int32((1-opt.testRatio)*num),:))
            
            csvwrite('featureTest.csv',features(int32((1-opt.testRatio)*num):max(size(features)),:))
            csvwrite('labelTest.csv',labels(int32((1-opt.testRatio)*num):max(size(features)),:))
            
            movefile featureTrain.csv data
            movefile labelTrain.csv data
            movefile featureTest.csv data
            movefile labelTest.csv data
        otherwise
                error('cannot parse format argument')
    end
        
end

    

