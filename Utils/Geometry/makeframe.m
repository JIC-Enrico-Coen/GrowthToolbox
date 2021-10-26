function [v2,v3,v4] = makeframe( v1, v1a )
%[v2,v3] = makeframe( v1 )
%  V1 is a unit vector.  Chose unit vectors V2 and V3 such that [V1 V2 V3] is
%  a right-handed coordinate system.
%  If V1 is a nonzero non-unit unit vector, the resulting vectors will be
%  mutually orthogonal, but may be of arbitrary non-zero lengths.
%  If V1 is zero, V2 and V3 will be zero.
%
%[v3,v1a,v2a] = makeframe( v1, v2 )
%  Set v3 to a unit vector perpendicular to both v1 and v2, such that [v1
%  v2 v3] is a right-handed triple (has positive triple vector product).
%  v1a, if requested, is a unit vector parallel to v1, and v2a, if
%  requested, is a unit vector forming a right-handed orthonormal frame
%  with v1 and v3.
%
%The arguments must be row vectors, and the results will be also.

    if nargin==1
        if any(v1)
            v2 = findperp( v1 );
            v2 = v2/norm(v2);
        else
            v1 = zeros(size(v1));
            v2 = v1;
        end
        if nargout > 1
            v3 = cross(v1,v2,2);
        end
    else
        v2 = cross(v1,v1a);
        v2 = v2/norm(v2);
        if any(isnan(v2))
            v2 = zeros(size(v2));
        end
        if nargout > 1
            v3 = v1/norm(v1);
        end
    end
    if nargout > 2
        v4 = cross(v2,v3);
    end
end
