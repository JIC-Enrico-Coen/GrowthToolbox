function d = pointPlaneDistance( varargin )
%d = pointPlaneDistance( vxs, p )
%   Find the distance from the point p to the plane through the given three
%   vertexes vxs.  The result is always nonnegative.
%d = pointPlaneDistance( planeCentre, planeNormal, p )
%   Find the distance from the point p to the plane through planeCentre
%   with unit normal vector planeNormal.
%   The result is positive if p is on the same side of planeCentre as
%   planeNormal.
%
%   P can be N points in an N*3 array, in which case D is N*1.

    switch nargin
        case 2
            vxs = varargin{1};
            p = varargin{2};
            v1 = vxs(2,:) - vxs(1,:);
            v2 = vxs(3,:) - vxs(1,:);
            parallelogram_area = norm(cross(v1,v2));
            parallelepiped_volume = det( [ v1; v2; (p - vxs(1,:)) ] );
            if parallelogram_area==0
                d = 0;
            else
                d = abs(parallelepiped_volume/parallelogram_area);
            end
        case 3
            planeCentre = varargin{1};
            planeNormal = varargin{2};
            p = varargin{3};
            d = sum( (p-planeCentre).*planeNormal, 2 );
    end
end
