function plotvecs( theaxes, v1, v2, varargin )
%plotvecs( v, ... )
%   Plot a set of line segments.  V1 and V2 are both N*2 or N*3 matrices.
%   Plot a line from each member of V1 to the corresponding member of V2.
%   Pass all remaining arguments to plot3.

    if size(v1,2)==2
        plot( theaxes, [v1(:,1)'; v2(:,1)'], [v1(:,2)'; v2(:,2)'], varargin{:} );
    else
        plot3( theaxes, [v1(:,1)'; v2(:,1)'], [v1(:,2)'; v2(:,2)'], [v1(:,3)'; v2(:,3)'], varargin{:} );
    end
end
