function h = plotIndexedLines( edges, v1, v2, varargin )
%h = plotlines( edges, v1, v2, ... )
%   EDGES is an N*2 array.
%   V1 is an A*3 array
%   V2 is a B*3 array.
%	The first column of EDGES indexes rows of V1, and the second column
%	rows of V2.  Line segments will be drawn joining these points.
%   The result is a single line handle.
%   The remaining arguments after v2 specify plotting options which are the
%   same for all the lines to be plotted.

    numlines = size( edges, 1 );
    xx = [v1(edges(:,1),1)'; v2(edges(:,2),1)'; nan(1,numlines)];
    yy = [v1(edges(:,1),2)'; v2(edges(:,2),2)'; nan(1,numlines)];
    
    xx1 = [v1(edges(:,1),1)'; v2(edges(:,2),1)'];
    yy1 = [v1(edges(:,1),2)'; v2(edges(:,2),2)'];
    
    if size(v1,2)==2
        h = lineMulticolor( xx(:), ...
              yy(:), ...
              varargin{:} );
    else
        zz = [v1(edges(:,1),3)'; v2(edges(:,2),3)'; nan(1,numlines)];
        zz1 = [v1(edges(:,1),3)'; v2(edges(:,2),3)'];

        h = lineMulticolor( xx1, ...
              yy1, ...
              zz1, ...
              varargin{:} );
    end
end
