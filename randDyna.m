function [feature,object]=randDyna(DOF,type,r,dist)
    [feature,object]=randKine(DOF,type,r,dist);
    
    feature.mass=[];
    feature.R=[];
    feature.l=[];
    feature.I=[];
    feature.B=[];
    feature.Tc=[];
    feature.G=[];
    feature.Jm=[];
        
    for t=1:6
        feature.mass(t)=10*rand;
        feature.R(t,:)=-0.1*rand(1,3)+0.05*ones(1,3);

        feature.l(t,:)=rand(1,3);
        feature.I(:,:,t)=diag(feature.l(t,:));

        feature.B(t)=0.005*rand;

        feature.Tc(t,:)=[0.5*rand,-0.5*rand];

        feature.G(t)=-100*rand+50;
        feature.Jm(t)=5e-4*rand;
    end
    
    l=object.links;
    
    for i=1:max(size(l))
        l(i).m=feature.mass(i);
        l(i).r=feature.R(i,:);
        l(i).I=feature.I(:,:,i);
        l(i).B=feature.B(i);
        l(i).Tc=feature.Tc(i,:);
        l(i).G=feature.G(i);
        l(i).Jm=feature.Jm(i);
    end

    object=SerialLink(l);

end