function pts = transformPoints( pts, transform )
%pts = transformPoints( pts, transform )
%   pts is an N*3 array, and transform is a 4*4 transformation matrix.
%   Transform the points by the matrix.
%
%   See also: maketransform

    if ~isempty(pts)
        pts = [ pts, ones(size(pts,1),1) ]*transform(:,1:3);
    end
end
