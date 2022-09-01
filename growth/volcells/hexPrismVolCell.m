function volcells = hexPrismVolCell( centre, height, edgelength )
%volcells = hexPrismVolCell( centre, height, edgelength )
%   Make a volcells structure representing a single volumetric cell whose
%   shape is a triangular prism whose axis is parallel to the Z axis. Its
%   centre is CENTRE and its height is HEIGHT. The edge length of its
%   hexagonal faces is EDGELENGTH.
%
%   The vertexes of each hexagonal face begin with one on the positive X
%   axis, and proceed anticlockwise.

    % Hexagon in the Z=0 plane.
    c = 0.5;
    s = sqrt(3)/2;
    vxs3d = [ 1  0  0;
              c  s  0;
             -c  s  0;
             -1  0  0;
             -c -s  0;
              c -s  0 ];
          
    % Scale to required size.
    vxs3d = vxs3d * edgelength;
    
    % Two copies, top and bottom.
    vxs3d = [ vxs3d + [0 0 height/2]; vxs3d - [0 0 height/2] ];
    
    % Move to centre.
    vxs3d = centre + vxs3d;
    
    % The indexing of each face is ordered so that the right-handed
    % face normals point into the volume.
    faceIndexing = [ { uint32( [1 6:-1:2]' );  % Top face.
                       uint32( (7:12)' ) };    % Bottom face.
                     num2cell( uint32( [ (1:6)' [2:6 1]' [8:12 7]' (7:12)' ]' ), 1 )' ];  % Sides.

    volcells = completeSingleVolCell( vxs3d, faceIndexing );
end

