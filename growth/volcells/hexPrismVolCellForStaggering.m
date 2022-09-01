function volcells = hexPrismVolCellForStaggering( centre, height, edgelength, staggerings, convexity )
%volcells = hexPrismVolCell( centre, height, edgelength )
%   Make a volcells structure representing a single volumetric cell whose
%   shape is a triangular prism whose axis is parallel to the Z axis. Its
%   centre is CENTRE and its height is HEIGHT. The edge length of its
%   hexagonal faces is EDGELENGTH.
%
%   The vertexes of each hexagonal face begin with one on the positive X
%   axis, and proceed anticlockwise.
%
%   The top and bottom faces may be subdivided to accommodate a hexagonal
%   prism in a layer above or below. This is specified by the STAGGERINGS
%   parameter, which consists of two numbers in the range 0 to 3, the first
%   for the top face and the second for the bottom. 0 means no subdivision.
%   1, 2, and 3 specify the first non-subdivided edge of the hexagon,
%   counting clockwise from the edge joining the first and second vertexes.
%   The opposite edge is also unsubdivided. The other four edges are
%   bisected, and joined on the hexagonal face to subdivide it into four
%   faces.

    % Hexagon in the Z=0 plane.
    c = 0.5;
    s = sqrt(3)/2;
    vxs3d = [ 1  0  0;
              c  s  0;
             -c  s  0;
             -1  0  0;
             -c -s  0;
              c -s  0 ];
    stagperm = [ staggerings(1):6 1:(staggerings(1)-1) ];
    vxs3d = vxs3d( stagperm, : );
    
    splitedges = [2 3 5 6];
    splitedges1 = mod( splitedges, 6 ) + 1;
    foo = [ (1:6)', zeros(6,1), [2:6 1]' ];
    foo(splitedges,2) = (7:10)';
    edgevxs3d = ( vxs3d( splitedges, : ) + vxs3d( splitedges1, : ) )/2;
    facevxs3d = vxs3d( splitedges([4 2]), : )/2;
          
    vxs3d = [ vxs3d; edgevxs3d; facevxs3d ];
%     hexReordering = [1 2 7 3 8 4 5 9 6 10 11 12];
%     vxs3d = vxs3d( hexReordering, : );
    numhexinteriorvxs = 2;
    numhextotalvxs = size(vxs3d,1);
    numhexedgevxs = numhextotalvxs - numhexinteriorvxs;
          
    % Scale to required size.
    vxs3d = vxs3d * edgelength;
    
    % Two copies, top and bottom.
    if numel(convexity)==1
        convexity = [convexity convexity];
    else
        convexity = convexity(:)';
    end
    convexityOffset = convexity * (1/(2*sqrt(3))) * height;
    hOffsets = [ -1 -1 -1 -1 -1 -1 0 0 0 0 1 1]';
%     hOffsets = hOffsets(hexReordering);
    hOffsets1 = hOffsets * convexityOffset(1);
    hOffsets2 = hOffsets * convexityOffset(2);
    hOffsets3d1 = [ zeros( numhextotalvxs, 2 ), hOffsets1 ];
    hOffsets3d2 = [ zeros( numhextotalvxs, 2 ), hOffsets2 ];
    
    vxs3d = [ vxs3d + [0 0 height/2] + hOffsets3d1; vxs3d - [0 0 height/2] - hOffsets3d2 ];
    
    % Move to centre.
    vxs3d = centre + vxs3d;
    
    % The indexing of each face is ordered so that the right-handed
    % face normals point into the volume.
    if convexity(1)==0
        topfaces = { uint32( [ 1 10 6 9 5 4 8 3 7 2 ]' ) };
    else
        topfaces = { uint32( [1 10 11 12 7 2]' ); ...
                     uint32( [7 12 8 3]' ); ...
                     uint32( [8 12 11 9 5 4]' ); ...
                     uint32( [9 11 10 6]' ) };
    end
    if convexity(2)==0
        bottomfaces = { uint32( [ 1 10 6 9 5 4 8 3 7 2 ]' ) };
    else
        bottomfaces = { uint32( [1 10 11 12 7 2]' ); ...
                     uint32( [7 12 8 3]' ); ...
                     uint32( [8 12 11 9 5 4]' ); ...
                     uint32( [9 11 10 6]' ) };
    end
    for i=1:length(bottomfaces)
        bottomfaces{i} = bottomfaces{i}(end:-1:1) + numhextotalvxs;
    end
    foo = [ (1:6)', zeros(6,1), [2:6 1]' ];
    foo(splitedges,2) = (7:10)';
    foo1 = foo;
    foo1(foo1 ~= 0) = foo1(foo1 ~= 0) + numhextotalvxs;
    
    sidefacesarray = uint32( [ foo, foo1( :, end:-1:1 ) ] );
    numsidefaces = size(sidefacesarray,1);
    sidefaces = cell( numsidefaces, 1 );
    for i=1:numsidefaces
        sidefaces{i} = sidefacesarray(i,sidefacesarray(i,:) ~= 0)';
    end
    
%     sidefaces = [ (1:numhexedgevxs); ...
%                   [2:numhexedgevxs 1]; ...
%                   [(numhextotalvxs+2):(numhextotalvxs+numhexedgevxs) (numhextotalvxs+1)]; ...
%                   (numhextotalvxs+1):(numhextotalvxs+numhexedgevxs) ];
%     sidefaces = num2cell( sidefaces, 1 )';
                  
    faceIndexing = [ topfaces; bottomfaces; sidefaces ];

    volcells = completeSingleVolCell( vxs3d, faceIndexing );
end

