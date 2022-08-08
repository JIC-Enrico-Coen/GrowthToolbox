function [d,foot] = pointPlaneDistance( varargin )
%[d,foot] = pointPlaneDistance( vxs, p )
%   Find the distance from the point p to the plane through the given three
%   vertexes vxs.  The result is always nonnegative.
%[d,foot] = pointPlaneDistance( planeCentre, planeNormal, p )
%   Find the distance from the point p to the plane through planeCentre
%   with unit normal vector planeNormal.
%   The result is positive if p is on the same side of planeCentre as
%   planeNormal.
%
%   FOOT is the intersection of the perpendicular with the plane.
%
%   P can be N points in an N*3 array, in which case D is N*1 and FOOT is
%   N*3.

    switch nargin
        case 2
            vxs = varargin{1};
            p = varargin{2};
            v1 = vxs(2,:) - vxs(1,:);
            v2 = vxs(3,:) - vxs(1,:);
            crossv1v2 = cross(v1,v2);
            normcross = norm(crossv1v2);
            if normcross==0
                if norm(v1)==0
                    if norm(v2)==0
                        d = sqrt( sum( (p-vxs(1,:)).^2, 2 ) );
                        foot = repmat( vxs(1,:), size(p,1), 1 );
                    else
                        [d,foot,~] = pointLineDistance( vxs([1 3],:), p, true );
%                         check = sum( (foot-p).*repmat( v2, size(p,1), 1 ), 2 ) % Should be zero to within rounding error.
                    end
                else
                    [d,foot,~] = pointLineDistance( vxs([1 2],:), p, true );
%                     check = sum( (foot-p).*repmat( v1, size(p,1), 1 ), 2 ) % Should be zero to within rounding error.
                end
            else
                planeNormal = crossv1v2/normcross;
                planeCentre = vxs(1,:);
                d = sum( (p-planeCentre).*planeNormal, 2 );
                foot = p - planeNormal .* d;
%                 check = sum( (foot-planeCentre).*repmat( planeNormal, size(p,1), 1 ), 2 ) % Should be zero to within rounding error.
            end
        case 3
            planeCentre = varargin{1};
            planeNormal = varargin{2};
            p = varargin{3};
            d = sum( (p-planeCentre).*planeNormal, 2 );
            foot = p - planeNormal .* d;
%             check = sum( (foot-planeCentre).*repmat( planeNormal, size(p,1), 1 ), 2 ) % Should be zero to within rounding error.
    end
end
