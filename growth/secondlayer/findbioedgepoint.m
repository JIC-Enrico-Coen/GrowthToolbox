function p = findbioedgepoint( m, ci, ei, r1, r2 )
%p = findbioedgepoint( m, ci, edgepoint )
%   m is a mesh and ci is the index of one of its biological cells.
%   ei is an index of an edge of ci.  If the vertexes of the endpoints of
%   the edge are at v1 and v2, then p is set to v1*r2 + v2*r1.
%   r2 defaults to 1-r1, giving a weighted average of the two points.
%   If r1=-1 and r2=1, this gives v2-v1, the vector along the edge.

    if nargin < 5
        r2 = 1-r1;
    end
    ei1 = mod( ei, length(m.secondlayer.cells(ci).vxs) ) + 1;
    vxs = m.secondlayer.cells(ci).vxs([ei,ei1]);
    p = [ r2, r1 ] * m.secondlayer.cell3dcoords( vxs, : );
end
