function [vi1a,vi1b,v1,vi2a,vi2b,v2] = splitPoly( direction, splitpoint, vxs )
%[vi1a,vi1b,v1,vi2a,vi2b,v2] = splitPoly( direction, splitpoint, vxs )
%   vxs contains the vertexes of a polygon as an N*3 matrix.
%   direction is a direction and splitpoint is a point.
%   This routine finds where the plane perpendicular to direction through
%   splitpoint intersects the polygon.

%   If it intersects the polygon at more than two points, we take first the
%   nearest point, then the nearest lying in roughly the opposite
%   direction.

    numvxs = size( vxs, 1 );
    sides = whichSide( direction, splitpoint, vxs );
    sides1 = [ sides(2:end); sides(1) ];
    boundary = find( sides ~= sides1 );
    if length(boundary) < 2
        vi1a = 0;
        vi1b = 0;
        v1 = 0;
        vi2a = 0;
        vi2b = 0;
        v2 = 0;
        return;
    end
    vba = boundary;
    vbb = mod(vba,numvxs) + 1;
    intersections = zeros( length(boundary), 3 );
    ratio = zeros( 1, 3 );
    MINRATIO = 1e-3;
    for i=1:length(boundary)
        [intersections(i,:),ratio(i)] = lineplaneIntersection( vxs(vba(i),:), vxs(vbb(i),:), direction, splitpoint );
        if ratio(i) <= 0
            ratio(i) = MINRATIO;
            intersections(i,:) = vxs(vba(i),:)*(1-MINRATIO) + vxs(vbb(i),:)*MINRATIO;
        elseif ratio(i) >= 1
            ratio(i) = 1 - MINRATIO;
            intersections(i,:) = vxs(vba(i),:)*MINRATIO + vxs(vbb(i),:)*(1-MINRATIO);
        end
    end
    if length(boundary)==2
        split1 = 1;
        split2 = 2;
    else
        % The boundary intersects the polygon in more than two places.  We
        % need to select the two intersection points in opposite directions
        % that are closest to the split point.
        vb = intersections - repmat( splitpoint, length(boundary), 1 );
        d = sum(vb.^2,2);
        [maxd,maxi] = max(d);
        vtest = 1 ./ dot( vb, repmat( vb(maxi,:), length(boundary), 1 ), 2 );
        [xx1,split1] = max( vtest );
        [xx2,split2] = min( vtest );
    end
    vi1a = vba(split1);
    vi1b = vbb(split1);
    v1 = intersections(split1,:);
    vi2a = vba(split2);
    vi2b = vbb(split2);
    v2 = intersections(split2,:);
end
