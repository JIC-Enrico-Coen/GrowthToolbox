function t = triangulate( vxs )
%t = triangulate( vxs )
%   Create a triangulation of the given vertexes.
%   VXS is an N*2 array listing the vertexes of a polygon in order.
%   T will be a K*3 array of triples of indexes of V.

    numvxs = size(vxs,1);
    i1s = [ 2:numvxs, 1 ];
    edges = vxs( i1s, : ) - vxs
  % angles = zeros(1,numvxs);
    angles(i1s) = vecangle2( edges(i1s,:), -edges );
    
 %  while length(angles) > 3
        [a,ai] = min(angles);
        ai1 = mod(ai,numvxs)+1;
        numnewnodes = max( floor( angles/(pi/3) + 0.5 ) - 1, 0 );
        if numnewnodes==0
        else
            anglesep = a/numnewnodes;
            e = edges(
            rotateVector( 
        end
        % remove vertex ai, angle ai, and edges ai and ai-1.
        % Replace vertex ai by new vertexes.
  %  end
end

function v1 = rotateVector( v, a )
    c = cos(a);
    s = sin(a);
    v1 = [ c*v(1) - s*v(2), s*v(1) + c*v(2) ];
end
