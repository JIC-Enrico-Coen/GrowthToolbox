function [pp,bc,pbc] = projectPointToLine( vxs, p, segmentOnly )
%[pp,bc,pbc] = projectPointToLine( vxs, p )
%   Project P perpendicularly onto the line defined by the two vertexes
%   VXS, giving point P1.  VXS is a 2*D matrix of two row vectors of any
%   dimensionality D.  If the two points coincide, then PP is set equal to
%   both.    BC is set to the barycentric coordinates of the point
%   with respect to VXS, as a 1*D row vector.  The equality PP == BCS*VXS
%   holds.  P may be an N*D matrix of row vectors for any N.

    if nargin < 3
        segmentOnly = false;
    end
    
    v21 = vxs(2,:) - vxs(1,:);
    v21dsq = sum(v21.^2);
    
%     v21dsq = bsxfun(@plus,sum(vxs(2,:).^2,2),sum(vxs(1,:).^2,2)') - 2*(vxs(2,:)*vxs(1,:)');
    
    if v21dsq==0
        % There is only one point.
        np = size(p,1);
        pp = repmat( vxs(1,:), np, 1 );
        bc = [ ones(np,1), zeros(np,1) ];
    else
        p = bsxfun(@minus,p,vxs(1,:));
        a = p*(v21'/v21dsq);
        pbc = [ 1-a, a ];
        if segmentOnly
            a(a<0) = 0;
            a(a>1) = 1;
        end
        bc = [ 1-a, a ];
        pp = bc*vxs;
    end
end
