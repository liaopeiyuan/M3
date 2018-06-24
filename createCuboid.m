function H = createCuboid(xmin,xmax,ymin,ymax,zmin,zmax,deltaX,deltaY,deltaZ)
    
    i=xmin;
    j=ymin;
    k=zmin;
    c1=1;
    c2=1;
    c3=1;

    H=cell( int32(((xmax-xmin)/deltaX)+1), int32(((ymax-ymin)/deltaY)+1), int32(((zmax-zmin)/deltaZ)+1) );
    %The coordinates of the node is stored in a 3-D cell array

    for k=zmin:deltaZ:zmax
        c2=1;    
        for j=ymin:deltaY:ymax    
            c1=1;        
            for i=xmin:deltaX:xmax        
                H{c1, c2, c3}=[i,j,k];            
                c1=c1+1;            
            end        
            c2=c2+1;        
        end    
        c3=c3+1;    
    end
    
end

