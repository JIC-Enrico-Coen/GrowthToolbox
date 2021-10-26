function [X,Yleft,Yright,A] = polygonArea( d, vxs, n )
%a = polygonArea( d, vxs )
%   Compute a representation of the area of a polygon in 3D cut off by a
%   plane perpendicular to d.  The polygon vertexes are in the N*3 array
%   vxs. d must be a unit row vector.  n is a vector normal to the polygon.
%   If omitted, it defaults to [0 0 1].

    numvxs = size(vxs,1);
    if size(vxs,2)==2
        vxs = [ vxs, zeros( numvxs, 1 ) ];
    end
    if length(d)==2
        d = [ d, 0 ];
    end
    if nargin < 3
        n = [0 0 1];
    end
    xx = dot( vxs, repmat( d, numvxs, 1 ), 2 );
    v3 = cross( n, d );
    v3 = v3/norm(v3);
    yy = dot( vxs, repmat( v3, numvxs, 1 ), 2 );
    
    [X,Yleft,Yright,A] = polygonArea2( [xx,yy] );
end
