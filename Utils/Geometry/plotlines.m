function h = plotlines( varargin )
%function h = plotlines( ends, vxs, varargin )
%h = plotlines( ends, vxs, varargin )
%   Plot a set of line segments in the given axes.
%   ENDS is an N*2 array of indexes into VXS, a K*2 or K*3 array of points.
%   The remaining arguments are plotting options common to all the lines,
%   which must all have the same colour, width, line style, etc.

    if nargin < 2
        timedFprintf( 'At least 3 arguments required.\n' );
        return;
    end
    
    a1 = varargin{1};
    if (numel(a1)==1) && ishghandle( a1 )
        ax = a1;
        varargin(1) = [];
        if nargin < 2
            timedFprintf( 'At least 3 arguments required.\n' );
            return;
        end
    else
        ax = gca();
    end
    
    ends = varargin{1};
    vxs = varargin{2};
    varargin(1:2) = [];



    h = plotIndexedLines( ax, ends, vxs, vxs, varargin{:} );
end
