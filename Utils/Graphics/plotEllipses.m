function [points,h] = plotEllipses( ax, centres, eaxes, resolution, whichaxes, varargin )
    if (nargin < 4) || isempty( resolution )
        resolution = 20;
    end
    if (nargin < 5) || isempty( whichaxes )
        whichaxes = 'ellipse';
    end
    
    dims = size(centres,2);
    
    plotoptions = varargin;
    if isempty(plotoptions)
        plotoptions = { '-k' };
    end
    
    numellipses = size(centres,1);
    
    switch whichaxes
        case 'ellipse'
            theta = linspace(0,pi*2,resolution+1)';
        case 'major'
            theta = pi*[ 0.5; 1.5 ];
        case 'minor'
            theta = [ 0; pi ];
        case 'cross'
            theta = pi*[0; 1; NaN; 0.5; 1.5];
    end
    pointsperellipse = length(theta)+1;
    c = cos(theta);
    s = sin(theta);
    
    points = zeros( pointsperellipse*numellipses, dims );
    ptsi = 0;
    
    for i=1:numellipses
        points( (ptsi+1):(ptsi+pointsperellipse), : ) = [ c*eaxes(1,:,i) + s*eaxes(2,:,i); nan(1,dims) ] ...
                                                        + repmat( centres(i,:), pointsperellipse, 1 );
        ptsi = ptsi + pointsperellipse;
    end
    
    if any(imag(points) ~= 0)
        xxxx = 1;
    end
    
    h = plotpts( ax, points, plotoptions{:} );
end
