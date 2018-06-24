function [workspace,cuboid] = genWorkspace(m,position,orientation,varargin)
    
    opt.maniplty='yoshikawa';
    opt.verbose=false;
    opt.ikine='numerical';
    
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
            
    %Orientation Workspace   
    if max(size(position))==3
        if opt.verbose
            if max(size(orientation))==3
                error('wrong scope parameters')
            else
                disp('assuming orientation workspace')
            end
        end
        
        dim1=orientation;
        dim2=position;
        
        fDim1=@orient;
        fDim2=@translate;
    end
    
    %Constant Orientation Workspace
    if max(size(orientation))==3
        if opt.verbose
            if max(size(position))==3
                error('wrong scope parameters')
            else
                disp('assuming constant orientation workspace')
            end
        end
        
        dim1=position;
        dim2=orientation;
        
        fDim1=@translate;
        fDim2=@orient;
    end
    
    if and(max(size(position))>3, max(size(orientation))>3)
        if opt.verbose
            disp('assuming full workspace')
        end

        dim1=position;
        xmin=dim1(1);
        xmax=dim1(2);
        ymin=dim1(3);
        ymax=dim1(4);
        zmin=dim1(5);
        zmax=dim1(6);
        deltaX=dim1(7);
        deltaY=dim1(8);
        deltaZ=dim1(9);

        H = createCuboid(xmin,xmax,ymin,ymax,zmin,zmax,deltaX,deltaY,deltaZ);

        dim1=orientation;
        xmin=dim1(1);
        xmax=dim1(2);
        ymin=dim1(3);
        ymax=dim1(4);
        zmin=dim1(5);
        zmax=dim1(6);
        deltaX=dim1(7);
        deltaY=dim1(8);
        deltaZ=dim1(9);

        H2 = createCuboid(xmin,xmax,ymin,ymax,zmin,zmax,deltaX,deltaY,deltaZ);

        cuboid.position=H;
        cuboid.orientation=H2;
    
    end
    
    xmin=dim1(1);
    xmax=dim1(2);
    ymin=dim1(3);
    ymax=dim1(4);
    zmin=dim1(5);
    zmax=dim1(6);
    deltaX=dim1(7);
    deltaY=dim1(8);
    deltaZ=dim1(9);
    
    H = createCuboid(xmin,xmax,ymin,ymax,zmin,zmax,deltaX,deltaY,deltaZ);
    
    if max(size(orientation))==3
        cuboid.position=H;
        cuboid.orientation=orientation;
    else
        cuboid.orientation=H;
        cuboid.position=H;
    end
    
    workspace = zeros(size(H));
    [sizeX,sizeY,sizeZ]=size(workspace);
    
    if not(exist('H2'))
        for k=1:sizeZ
           for j=1:sizeY
              for i=1:sizeX  
                 try
                    q=inverse(m,fDim1(H{i,j,k}(1),H{i,j,k}(2),H{i,j,k}(3))*fDim2(dim2(1),dim2(2),dim2(3)));
                    %disp(q);
                    if all(not(isnan(q)))
                        workspace(i,j,k)=mani(m,q,opt.maniplty);
                    end
                 catch
                 end
              end
           end
        end
    else
        [sizeX1,sizeY1,sizeZ1]=size(H2);
        workspace=zeros(horzcat(size(workspace),size(H2)));
        for k=1:sizeZ
           for j=1:sizeY
              for i=1:sizeX
                 for k1=1:sizeZ1
                    for j1=1:sizeY1
                    	for i1=1:sizeX1 
                         try
                            q=inverse(m,fDim1(H{i,j,k}(1),H{i,j,k}(2),H{i,j,k}(3))*fDim2(H2{i,j,k}(1),H2{i,j,k}(2),H2{i,j,k}(3)));
                            if all(not(isnan(q)))
                                workspace(i,j,k,i1,j1,k1)=mani(m,q,opt.maniplty);
                            end
                         catch
                         end
                        end
                    end
                 end
              end
           end
        end
    end
    
    function output=dummy(~,~,~)
        output=1;
    end   

    function output=translate(in1,in2,in3)
        output=transl([in1,in2,in3]);
    end

    function output=orient(in1,in2,in3)
       output=trotx(in1)*troty(in2)*trotz(in3); 
    end
end

    