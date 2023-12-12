function z = modreflective( x, y, min_y )
%z = modreflective( x, y, min_y )
%   Like mod( x, y ), except that the endpoints of the interval 0...y are
%   assumed to reflect values outside the range instead of looping them
%   around to the other end.
%
%   If min_y is given, the values are mapped to the range min_y...y+miny.
%
%   The actual formula is z = y - abs( mod( x-min_y, 2*y ) - y ) + min_y.

    if nargin < 3
        min_y = 0;
    end
    
    z = y - abs( mod( x-min_y, 2*y ) - y ) + min_y;
end