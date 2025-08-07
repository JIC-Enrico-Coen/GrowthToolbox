function h = sphereSolidColor( ax, n, radius, centre, color, varargin )
%h = sphereSolidColor( ax, n, radius, centre, color, ... )
%   Draw a sphere in the given axes.
%
%   N is how finely the sphere is divided into latitude and longitude.
%
%   COLOR is the RGB value of the color the sphere is to be.
%   The remaining arguments are plotting options passed to Matlab's
%   surface() function. To specify a colour, give the arguments
%   'FaceColor', ... Colors can be specified either by RGB values,
%   single-letter names (e.g. 'r' is red), or full names (e.g. 'red').
%
%   A handle to the resulting Surface object is returned.
%
%   SEE ALSO: surface

    plotoptions = safemakestruct( varargin );
    plotoptions.FaceColor = 'texturemap';
    plotoptions.CDataMapping = 'direct';
    [X,Y,Z] = sphere( n );
    X = X*radius + centre(1);
    Y = Y*radius + centre(2);
    Z = Z*radius + centre(3);
    color = colorCode2rgb( color );
    img = zeros( [ size(X) 3 ] );
    for ci=1:3
        img(:,:,ci) = color(ci);
    end
    plotoptionargs = struct2args( plotoptions );
    h = surface( ax, X, Y, Z, img, plotoptionargs{:} );
end


