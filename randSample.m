function [feature,label]=randSample(opt,randMani)
        feature=NaN;
        label=NaN;
        while isnan(feature)
            [featureSt,m]=randMani(opt.DOF,opt.type,opt.r,opt.dist);
            switch opt.variant
                case 'CGAN'
                    for k=1:opt.plim
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
    end