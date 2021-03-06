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
    %disp(initF)
    [~,fSize]=size(initF);
    [~,lSize]=size(initL);
    features=zeros(num,fSize);
    labels=zeros(num,lSize);
    clear initF initL fSize lSize
    
    switch opt.variant
        case 'CGAN'
            labelStr={'x','y','z','wx','wy','wz'};
        case 'jacobian'
            switch opt.DOF
                case 6
                    labelStr={'j11','j12','j13','j14','j15','j16'...
                              'j21','j22','j23','j24','j25','j26'...
                              'j31','j32','j33','j34','j35','j36'...
                              'j41','j42','j43','j44','j45','j46'...
                              'j51','j52','j53','j54','j55','j56'...
                              'j61','j62','j63','j64','j65','j66'...
                              
                    };
                otherwise
                    labelStr={};
                    for j=1:6
                       for i=1:opt.DOF
                            labelStr=horzcat(labelStr,strcat('j',num2str(i),num2str(j)));
                       end
                    end
            end
        case 'ikine'
            labelStr={'ikExists'};
    end

    switch opt.variant
        case {'CGAN','jacobian','ikine'}
            switch opt.mani
                case 'dyna'
                    switch opt.DOF
                        case 6
                            featStr={'d1','d2','d3','d4','d5','d6',...
                                     'a1','a2','a3','a4','a5','a6',...
                                     'alpha1','alpha2','alpha3','alpha4','alpha5','alpha6',...
                                     'mass1','mass2','mass3','mass4','mass5','mass6',...
                                     'r11','r12','r13','r21','r22','r23','r31','r32','r33',...
                                     'r41','r42','r43','r51','r52','r53','r61','r62','r63',...
                                     'l11','l12','l13','l21','l22','l23','l31','l32','l33',...
                                     'l41','l42','l43','l51','l52','l53','l61','l62','l63',...
                                     'b1','b2','b3','b4','b5','b6',...
                                     'tc11','tc12','tc21','tc22','tc31','tc32',...
                                     'tc41','tc42','tc51','tc52','tc61','tc62',...
                                     'g1','g2','g3','g4','g5','g6',...
                                     'jm1','jm2','jm3','jm4','jm5','jm6'                            
                            };    
                        otherwise
                            featStr={};
                            for i=1:opt.DOF
                                featStr=horzcat(featStr,strcat('d',num2str(i)));
                            end
                            for i=1:opt.DOF
                                featStr=horzcat(featStr,strcat('a',num2str(i)));
                            end
                            for i=1:opt.DOF
                                featStr=horzcat(featStr,strcat('alpha',num2str(i)));
                            end
                            for i=1:opt.DOF
                                featStr=horzcat(featStr,strcat('mass',num2str(i)));
                            end
                            for i=1:opt.DOF
                                featStr=horzcat(featStr,strcat('r',num2str(i),'1'));
                                featStr=horzcat(featStr,strcat('r',num2str(i),'2'));
                                featStr=horzcat(featStr,strcat('r',num2str(i),'3'));
                            end
                            for i=1:opt.DOF
                                featStr=horzcat(featStr,strcat('l',num2str(i),'1'));
                                featStr=horzcat(featStr,strcat('l',num2str(i),'2'));
                                featStr=horzcat(featStr,strcat('l',num2str(i),'3'));
                            end
                            for i=1:opt.DOF
                                featStr=horzcat(featStr,strcat('b',num2str(i)));
                            end
                            for i=1:opt.DOF
                                featStr=horzcat(featStr,strcat('tc',num2str(i),'1'));
                                featStr=horzcat(featStr,strcat('tc',num2str(i),'2'));
                            end
                            for i=1:opt.DOF
                                featStr=horzcat(featStr,strcat('g',num2str(i)));
                            end
                            for i=1:opt.DOF
                                featStr=horzcat(featStr,strcat('jm',num2str(i)));
                            end                                                       
                    end
                case 'kine'
                    switch opt.DOF
                        case 6
                            featStr={'d1','d2','d3','d4','d5','d6',...
                                     'a1','a2','a3','a4','a5','a6',...
                                     'alpha1','alpha2','alpha3','alpha4','alpha5','alpha6'};    
                        otherwise
                            featStr={};
                            for i=1:opt.DOF
                                featStr=horzcat(featStr,strcat('d',num2str(i)));
                            end
                            for i=1:opt.DOF
                                featStr=horzcat(featStr,strcat('a',num2str(i)));
                            end
                            for i=1:opt.DOF
                                featStr=horzcat(featStr,strcat('alpha',num2str(i)));
                            end
                            
                    end
            end
            
            switch opt.variant
                case {'jacobian','ikine'}
                    featStr=horzcat(featStr,{'x','y','z','wx','wy','wz'});
            end
            
            cell2csv('featureTrain.csv',featStr,',')
            cell2csv('labelTrain.csv',labelStr,',')

            cell2csv('featureTest.csv',featStr,',')
            cell2csv('labelTest.csv',labelStr,',')
    end
        
    if parallel
        parfor i=1:num
            [features(i,:),labels(i,:)]=randSample(opt,randMani);
            if mod(i,200)==0
               disp(strcat('sample number ',num2str(i),' created')) 
               
            end
        end
    else
        for i=1:num
            [features(i,:),labels(i,:)]=randSample(opt,randMani);
            if mod(i,200)==0
               disp(strcat('sample number ',num2str(i),' created')) 
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
            dlmwrite('featureTrain.csv',features(1:int32((1-opt.testRatio)*num),:),'-append','delimiter',',','roffset',1)
            dlmwrite('labelTrain.csv',labels(1:int32((1-opt.testRatio)*num),:),'-append','delimiter',',','roffset',1)           
            dlmwrite('featureTest.csv',features(int32((1-opt.testRatio)*num)+1:max(size(features)),:),'-append','delimiter',',','roffset',1)
            dlmwrite('labelTest.csv',labels(int32((1-opt.testRatio)*num)+1:max(size(features)),:),'-append','delimiter',',','roffset',1)           
        otherwise
                error('cannot parse format argument')
    end
    
    switch opt.format
        case 'csv'
            movefile featureTrain.csv data
            movefile labelTrain.csv data
            movefile featureTest.csv data
            movefile labelTest.csv data           
        otherwise
            error('cannot parse format argument')
    end  
        
end
