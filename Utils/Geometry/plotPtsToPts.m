function h = plotPtsToPts( v1, v2, varargin )
%h = plotlines( v1, v2, ... )
%   V1 and V2 are A*3 arrays.
%	Line segments will be drawn joining corresponding points of V1 and V2.
%   The result is a single line handle.
%   The remaining arguments after v2 specify plotting options which are the
%   same for all the lines to be plotted.

    numlines = size( v1, 1 );
    xx = [v1(:,1)'; v2(:,1)'; nan(1,numlines)];
    yy = [v1(:,2)'; v2(:,2)'; nan(1,numlines)];
    zz = [v1(:,3)'; v2(:,3)'; nan(1,numlines)];
    
    if isempty(varargin)
        oldh = [];
    else
        oldh = varargin{1};
        if isempty( oldh )
            varargin(1) = [];
        else
            if (numel(oldh)==1) && ishandle(oldh)
                varargin(1) = [];
            else
                oldh = [];
            end
        end
    end
    
    if ~isempty(oldh)
        h = oldh;
        set( h, 'XData', xx(:), 'YData', yy(:), 'ZData', zz(:), varargin{:} );
    else
        h = line( xx(:), ...
              yy(:), ...
              zz(:), ...
              varargin{:} );
    end
end
