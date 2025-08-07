function [bcs,trivxs] = subdivideTriangle( n )
%[bcs,trivxs] = subdivideTriangle( n )
%   Given a triangle in space in any number of dimensions, subdivide it
%   into a mesh of triangles contaning n^2 smaller triangles and dividing
%   each edge into n segments. The result is the barycentric coordinates of
%   the points (including those of the original triangle as the first
%   three) and the triples of vertexes that make the new set of triangles.

    if n <= 1
        bcs = eye(3);
        trivxs = [1 2 3];
        return;
    end
    zz = 0:n;
    bcn = zz/n;
    bcnc = 1 - bcn;
    
    vxrowstarts = [ zz.*(zz+1), (n+1)*(n+2) ]/2;
    trirowstarts = zz.^2;
    
%     ii = 3;
%     (vxrowstarts(ii)+1):vxrowstarts(ii+1)
%     
%     ii = 1;
%     (trirowstarts(ii)+1):trirowstarts(ii+1)
    
    numvxs = vxrowstarts(end);
    numtris = trirowstarts(end);
    
    bcs = zeros( numvxs, 3 );
    trivxs = zeros( numtris, 3 );
    
    bcs(1,:) = [1 0 0];
    for ri=2:(n+1)
        bc1 = bcnc(ri);
        bc2s = ((0:(ri-1))/(ri-1)) * bcn(ri);
        bc3s = bcn(ri) - bc2s;
        vxrowindexes = (vxrowstarts(ri)+1):vxrowstarts(ri+1);
        bcs( vxrowindexes, 1 ) = bc1';
        bcs( vxrowindexes, 2 ) = bc2s';
        bcs( vxrowindexes, 3 ) = bc3s';
        
        rowstarts(ri)+1
    end
    
    xxxx = 1;
end
