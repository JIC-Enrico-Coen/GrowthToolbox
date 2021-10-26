function v = randunitvector( nvecs, ndims )
%v = randunitvector( nvecs, ndims )
%   Return an nvecs*ndims matrix of random unit row vectors uniformly
%   distributed over the surface of the ndims-dimensional sphere.  ndims
%   must be 2 or 3, and defaults to 2.  nvecs defaults to 1.

    if nargin < 1
        nvecs = 1;
    end
    if nargin < 2
        ndims = 2;
    end
    
    theta = rand(nvecs,1)*pi*2;
    v = [ cos(theta), sin(theta) ];
    if ndims==3
        phi = acos( (rand(nvecs,1)*2 - 1) );
        v = [ v(:,1).*sin(phi), v(:,2).*sin(phi), cos(phi) ];
    end
end
