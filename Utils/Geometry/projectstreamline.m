function [gradendpoint1,gradendpoint2] = projectstreamline( v, bc, vxs, positive )
%gradendpoint = projectstreamline( v, bc, vxs, positive )
%   Given v, a vector of the three values of some scalar at the vertexes
%   vxs of a triangle, and bc, the bcs of a point in the triangle.
%   Compute the bcs of the intersection of the line parallel to the
%   gradient vector of v, in either the direction of the gradient vector or
%   its opposite or both, starting from the point bc, with the first side
%   of the triangle that it hits.
%   If POSITIVE is true, only the intersection in the direction of the
%   gradient is returned.
%   If POSITIVE is false, only the intersection in the opposite direction
%   is returned.
%   If POSITIVE is not supplied, both intersections are returned.
%   If two output arguments are supplied, the positive intersection is
%   returned in gradendpoint1 and the negative in gradendpoint2.
%   If one output argument is supplied, it will hold the intersection that
%   was asked for, if POSITIVE was supplied, otherwise it will hold the
%   positive intersection.
%   Any intersection asked for which does not exist, because it lies
%   outside the triangle, is returned as the empty list.

    if nargin < 4
        positive = true;
        negative = true;
    else
        negative = ~positive;
    end    

    g = trianglegradient( vxs, v );
    if all(g==0)
      % fprintf( 1, '%s: no gradient\n', mfilename() );
        gradendpoint1 = [];
        if nargout > 1
            gradendpoint2 = [];
        end
        return;
    end
    bcg = baryCoords( vxs, [], vxs(1,:)+g ) - [1 0 0];
    
    gradendpointpos = [];
    if positive
        gradendpointpos = foo();
    end
    
    gradendpointneg = [];
    if negative
        bcg = -bcg;
        gradendpointneg = foo();
    end
    
    if nargout==2
        gradendpoint1 = gradendpointpos;
        gradendpoint2 = gradendpointneg;
    else
        if ~isempty( gradendpointpos )
            gradendpoint1 = gradendpointpos;
        else
            gradendpoint1 = gradendpointneg;
        end
    end

    function p = foo()
        p = [];
        a = -bc./bcg;
        a(a<=0) = Inf;  % Not interested in points in the wrong direction (a<0),
                        % nor the starting point (a==0).
        [besta,ai] = min(a);  % Want the first side we hit.
        if ~isempty(besta)
            p = bc + a(ai)*bcg;
            p(ai) = 0;
            if any(p < 0)
              % fprintf( 1, '%s: first intersection outside triangle\n', mfilename() );
                p = [];
            end
        else
          % fprintf( 1, '%s: no intersection in required direction\n', mfilename() );
        end
    end
end
