function pts1 = projectPtsToAAPlane( pts, dir, whichAxis, value, bounds )
%pts1 = projectPtsToAAPlane( pts, dir, whichAxis )
%   PTS is an N*3 array of 3D points.  DIR is a 1*3 3D vector.  All of the
%   points are projected in the direction DIR (positively or negatively)
%   until they hit the plane defined by X=value, Y=value, or Z=value,
%   depending on the value of whichAxis (1, 2, or 3 respectively).
%
%   The resulting 3D points are returned in pts1.

    k = (value - pts(:,whichAxis))/dir(whichAxis);
    pts1 = pts + k*dir;
    pts1(:,whichAxis) = value;
    if nargin >= 5
        % If all of the points
        otherdims = [ mod(whichAxis,3)+1, mod(whichAxis+1,3)+1 ];
        numpts = size(pts,1);
        outsideBounds = any( all( pts1(:,otherdims) > repmat( bounds(2,otherdims), numpts, 1 ), 1 ) ...
                                | all( pts1(:,otherdims) < repmat( bounds(1,otherdims), numpts, 1 ), 1 ) );
        if any( outsideBounds )
            pts1 = [];
        end
    end
end

