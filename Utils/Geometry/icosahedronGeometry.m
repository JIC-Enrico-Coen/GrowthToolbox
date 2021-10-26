function [vxs,trivxs] = icosahedronGeometry()
%[vxs,trivxs] = icosahedronGeometry()
%   Returns the vertex positions and triangles of a standard regular
%   icosahedron with unit radius.

    phi = 0.5+sqrt(1.25);
    
    vxs = [ [0 1 phi]; [0 -1 phi]; [0 1 -phi]; [0 -1 -phi]; ... % 1 2 3 4
            [1 phi 0]; [-1 phi 0]; [1 -phi 0]; [-1 -phi 0]; ... % 5 6 7 8
            [phi 0 1]; [phi 0 -1]; [-phi 0 1]; [-phi 0 -1]; ... % 9 10 11 12
          ]/sqrt(2+phi);
    rotperm = [ 5:12, 1:4 ];
    trivxs1 = [ ...
            [ 2 1 9 ]; [ 1 2 11 ]; ...
            [ 3 4 10 ]; [ 4 3 12 ]; ...
        ];
    trivxs2 = rotperm(trivxs1);
    trivxs3 = rotperm(trivxs2);
    trivxs4 = [ [ 1 5 9 ]; [ 2 9 7 ]; [ 1 11 6]; [2 8 11 ]; ...
                [ 3 10 5]; [4 7 10]; [3 6 12]; [4 12 8] ];
    trivxs = [ trivxs1; trivxs2; trivxs3; trivxs4 ];
end
