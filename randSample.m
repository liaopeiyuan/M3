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
                        feature=horzcat(featureSt.D,featureSt.A,featureSt.alpha);
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
                    
                case 'jacobian'
                    
                    for k=1:opt.plim
                        [vec,~,pose]=randPose(opt.poseR,opt.dist);
                        output=threshold(m,pose,'ikine',opt.ikine);
                        if not(isnan(output))
                            label=reshape(m.jacobe(output),1,[]);
                            feature=horzcat(featureSt.D,featureSt.A,featureSt.alpha);
                            if opt.mani=='dyna'
                                feature=horzcat(feature,featureSt.mass,...
                                                reshape(featureSt.R,1,[]),...
                                                reshape(featureSt.l,1,[]),...
                                                featureSt.B,...
                                                reshape(featureSt.Tc,1,[]),...
                                                featureSt.G,featureSt.Jm);
                            end
                            feature=horzcat(feature,vec);

                        end
                    end
                    
                case 'ikine'
                    
                    label=0;
                    x=0.3;
                    while x>0.25
                        [vec,~,pose]=randPose(opt.poseR,opt.dist);
                        
                        switch lower(strtrim(opt.ikine))
                            case 'numerical'
                                inverse=@ikine;
                            case 'analytic'
                                inverse=@ikine6s; 
                            otherwise
                                error('cannot parse inverse kinematics argument');
                        end
                        
                        try
                            output=inverse(m,pose);
                        catch
                            output=NaN;
                        end
                        
                        if not(isnan(output))
                            label=1;
                            break;
                        else
                            label=0;
                            x=rand();
                        end
                    end
                    
                    feature=horzcat(featureSt.D,featureSt.A,featureSt.alpha);
                        if opt.mani=='dyna'
                            feature=horzcat(feature,featureSt.mass,...
                                            reshape(featureSt.R,1,[]),...
                                            reshape(featureSt.l,1,[]),...
                                            featureSt.B,...
                                            reshape(featureSt.Tc,1,[]),...
                                            featureSt.G,featureSt.Jm);
                        end
                    feature=horzcat(feature,vec);
                    
                
                                 
                otherwise
                    error('cannot parse variant argument')
            end
        end
    end