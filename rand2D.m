clear all
s=500000;
feature=zeros(s,18);
pose=zeros(s,6);
parfor i=1:s
 %{ 
A=[rand,rand];
l1=Link([0 0 A(1) 0]);
l2=Link([0 0 A(2) 0]);
m=SerialLink([l1,l2]);
ct=1;
    %}
    p=rand(1,3);
    o=2*pi*rand(1,3);
    n=transl(p)*trotx(o(1))*troty(o(2))*trotz(o(3));
    [m,A]=randomManipulator6DOF("uniform",1);
    try
        k=m.ikine6s(n);
        if not(all(isnan(k)))
        %disp(k)
        if m.maniplty(k)>=0.1
            feature(i,:)=A;
            pose(i,:)=[p,o];
        end
        end
    end
    
    
end
ct=1;
while ct<=max(size(feature))
    if all(feature(ct,:)==0)
        feature(ct,:)=[];
        pose(ct,:)=[];
    else
    ct=ct+1;
    end
end
%{
ct=1
while ct<=max(size(pose))
    if all(pose(ct,:)==0)
        pose(ct,:)=[];
    else
    ct=ct+1;
    end
end
%}

