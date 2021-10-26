function pts = rotatePoints( pts, rot )
%pts = rotatePoints( pts, rot )
%   pts is an N*3 array, and rot is a 3*3 rotation matrix.
%   Transform the points by the matrix.
%   rot can also be a 4*4 transformation matrix.  The translation component
%   will be ignored.
%
%   See also: transformPoints, translatePoints, maketransform

    if ~isempty(pts)
        pts = pts*rot(1:3,1:3);
    end
end
