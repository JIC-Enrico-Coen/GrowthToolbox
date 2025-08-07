function [vxs,tris] = icosamesh( n, r )
%[vxs,tris] = icosamesh( n, r )
%   Generate an icosahedral mesh of radius r (default 1), refined to split
%   each triangular face into n triangles (default 1) along each side.
%   N is not implemented.

    if (nargin < 1) || isempty(n)
        n = 1;
    end
    if (nargin < 2) || isempty(r)
        r = 1;
    end
    
    phi = (1+sqrt(5))/2;
    basevxs = [0  1  phi;
               0 -1  phi;
               0  1 -phi;
               0 -1 -phi ];
    basevxs = [ basevxs; basevxs(:,[3 1 2]); basevxs(:,[2 3 1]) ];
    
    basetris = [ 1 2 5, 2 1 7, 3 4 8, 4 3 6, 2 11 5, 2 7 12 ];
    basetris = reshape( [ basetris; mod(basetris+3,12)+1; mod(basetris+7,12)+1 ], [], 3 );
    basetris = [ basetris;
                 1 5 9;
                 4 12 8 ];
                
    tris = basetris;
    rvxs = sqrt(sum(basevxs.^2,2));
    vxs = (basevxs./rvxs)*r;
end
