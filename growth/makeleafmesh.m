function mesh = makeleafmesh( xwidth, ywidth, xdivs )
%mesh = makeleafmesh( xwidth, ywidth, xdivs )  Make a leaf-shaped surface.
%INCOMPLETE.

    ydivs = floor( xdivs/3 );
    xrem = mod(x-1,3);
    % axis of leaf has xdivs+1 nodes, xdivs edges.
    
    numnodes = 3*y*y - 4*y + 2 + xrem*(y+y-1);
  % numcells = 
    
    mesh.globalProps.trinodesvalid = true;
    mesh.globalProps.prismnodesvalid = false;
end