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

    if numel(convexity)==1
        convexity = [convexity convexity];
    else
        convexity = convexity(:)';
    end
    
    % Hexagon in the Z=0 plane.
    c = 0.5;
    s = sqrt(3)/2;
    cornervxs3d = [ 1  0  0;
                    c  s  0;
                   -c  s  0;
                   -1  0  0;
                   -c -s  0;
                    c -s  0 ];
    numcornervxs = size( cornervxs3d, 1 );
    stagperm = [ staggerings(1):6 1:(staggerings(1)-1) ];
    cornervxs3d = cornervxs3d( stagperm, : );
    
    splitedges = [2 3 5 6];
    splitedges1 = mod( splitedges, 6 ) + 1;
    edgevxs3d = ( cornervxs3d( splitedges, : ) + cornervxs3d( splitedges1, : ) )/2;
    facevxs3d = cornervxs3d( splitedges([4 2]), : )/2;
          
    endvxs3d = [ cornervxs3d; edgevxs3d; facevxs3d ];
    numhexinteriorvxs = 2;
    numhextotalvxs = size(endvxs3d,1);
    numhexedgevxs = numhextotalvxs - numhexinteriorvxs;
          
    % Scale to required size.
    endvxs3d = endvxs3d * edgelength;
    
    % Two copies, top and bottom.
    convexityOffset = convexity * (1/(2*sqrt(3))) * height;
    hOffsets = [ -1 -1 -1 -1 -1 -1 0 0 0 0 1 1]';

    if convexity(1)==0
        topvxs3d = endvxs3d(1:numcornervxs,:) + [0 0 height/2];
    else
        hOffsets3d1 = [ zeros( numhextotalvxs, 2 ), hOffsets * convexityOffset(1) ];
        topvxs3d = endvxs3d + [0 0 height/2] + hOffsets3d1;
    end
    if convexity(2)==0
        bottomvxs3d = endvxs3d(1:numcornervxs,:) - [0 0 height/2];
    else
        hOffsets3d2 = [ zeros( numhextotalvxs, 2 ), hOffsets * convexityOffset(2) ];
        bottomvxs3d = endvxs3d - [0 0 height/2] - hOffsets3d2;
    end
    
    allvxs3d = [ topvxs3d; bottomvxs3d ];
    
    % Move to centre.
    allvxs3d = centre + allvxs3d;
    
    % The indexing of each face is ordered so that the right-handed
    % face normals point into the volume.
    [topfaces,topedges,topnumvxs] = hexfaces( convexity(1)==0 );
    [bottomfaces,bottomedges,~] = hexfaces( convexity(2)==0 );
    for i=1:length(bottomfaces)
        bottomfaces{i} = bottomfaces{i}(end:-1:1,1) + topnumvxs;
    end
    bottomedges = bottomedges(:,end:-1:1);
    bottomedges(bottomedges ~= 0) = bottomedges(bottomedges ~= 0) + topnumvxs;
    sidefacesarray = [ topedges, bottomedges ];
    sidefacescell = cell( size(sidefacesarray,1), 1 );
    for i=1:size(sidefacesarray,1)
        sf = sidefacesarray(i,:);
        sf = sf(sf~=0);        
        sidefacescell{i} = sf';
    end

    faceIndexing = [ topfaces; bottomfaces; sidefacescell ];

    volcells = completeSingleVolCell( allvxs3d, faceIndexing );
end

function [faces,edges,numvxs] = hexfaces( flat )
    if flat
        numvxs = 6;
        faces = { uint32( [ 1 (numvxs:-1:2) ]' ) };
        edges = [ faces{1} faces{1}([2:end 1]) ];
    else
        numvxs = 12;
        faces = { uint32( [1 10 11 12 7 2]' ); ...
                     uint32( [7 12 8 3]' ); ...
                     uint32( [8 12 11 9 5 4]' ); ...
                     uint32( [9 11 10 6]' ) };
        edges = uint32( [ 1 10  6;
                          6  9  5;
                          5  4  0;
                          4  8  3;
                          3  7  2;
                          2  1  0 ] );
    end
end

