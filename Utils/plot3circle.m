function h = plot3circle( centre, v1, v2, numpts, varargin )
% plot3circle( centre, numpts, v1, v2, varargin )
%   Plot a circle or ellipse in 3d with the given centre, radii v1 and v2,
%   and numpts points.  The remaining arguments are passed to plot3.
%   centre, v1, and v2 can all be k*3 matrices, to plot k circles at once.

    if (nargin < 4) || (numpts <= 0)
        numpts = 16;
    end
    h = -ones( size(centre,1), 1 );
    for i=1:size(centre,1)
        p = circlepoints( 1, centre(i,:), numpts, 0, v1(i,:), v2(i,:) );
        h(i) = plot3( [p(:,1);p(1,1)], [p(:,2);p(1,2)], [p(:,3);p(1,3)], varargin{:} );
    end
end
