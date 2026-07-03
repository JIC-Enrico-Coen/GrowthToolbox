function bbox = symmetriseBbox( bbox, centre )
%bbox = symmetriseBbox( bbox, centre )
%   Force the bounding box to be symmetric about the specified centre
%   (default [0 0 0]) by expanding it as necessary.

    if nargin < 2
        centre = zeros(1,numel(bbox)/2);
    end
    
    delta1 = centre - bbox(1:2:end);
    delta2 = bbox(2:2:end) - centre;
    maxdelta = max( delta1, delta2 );
    bbox(1:2:end) = centre - maxdelta;
    bbox(2:2:end) = centre + maxdelta;
end
