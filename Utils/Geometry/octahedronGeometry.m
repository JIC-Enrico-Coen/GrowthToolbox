function [vxs,trivxs] = octahedronGeometry()
%[vxs,trivxs] = octahedronGeometry()
%   Returns the vertex positions and triangles of a standard regular
%   octahedron with unit radius.

    vxs = [ 1 0 0; 0 1 0; 0 0 1; -1 0 0; 0 -1 0; 0 0 -1 ];
    trivxs = [ 1 2 3;
               2 4 3;
               4 5 3;
               5 1 3;
               5 4 6;
               1 5 6;
               2 1 6;
               4 2 6 ];
end
