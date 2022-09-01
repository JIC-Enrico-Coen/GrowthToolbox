function bbox = scaleBbox( bbox, scale, scalecentre )
%bbox = scaleBbox( bbox, scale, scalecentre )
%   Scale an axis-aligned bounding box relative to a given point
%   SCALECENTRE. BBOX is a 2*N matrix. SCALECENTRE defaults to the centre
%   of the box.

    if nargin < 3
        scalecentre = mean( bbox, 1 );
    end
    bbox = scale * (bbox - scalecentre) + scalecentre;
end