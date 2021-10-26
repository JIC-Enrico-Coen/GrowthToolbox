function h = plotpts( pts, varargin )
%h = plotpts( pts, ... )
%h = plotpts( gh, pts, ... )
%   Plot the 2 or 3 dimensional points with any plot options.
%   The result is a handle to a lineseries object.
%   gh can be either a handle to an axes object or a handle to a lineseries
%   object.  In the first case the data are plotted into the given axes,
%   and in the second, the data of the lineseries object are replaced by
%   the given data.  If the handle is omitted, plotting is done into the
%   axes specified by the 'Parent' option in the optional arguments, if
%   any, otherwise into the current axes.

    h = [];
    if (numel(pts)==1) && ishandle(pts)
        if isempty(varargin)
            return;
        end
        gh = pts;
        pts = varargin{1};
        varargin(1) = [];
    else
        gh = [];
    end
    if isempty(pts)
        return;
    end
    if ~isempty(gh) && ~ishandle(gh)
        % gh is invalid.
        return;
    end
    
    isAxes = ~isempty(gh) && strcmp( get( gh, 'Type' ), 'axes' );
    if isAxes
        varargin = [ varargin(:); {'Parent'; gh} ];
        gh = [];
    end
    if size(pts,2)==1
        pts(end,2) = 0;
    end
    if size(pts,2)==2
        if isempty(gh)
            h = plot( pts(:,1), pts(:,2), varargin{:} );
        else
            set( gh, 'XData', pts(:,1), 'YData', pts(:,2) );
            h = gh;
        end
    else
        if isempty(gh)
            h = plot3( pts(:,1), pts(:,2), pts(:,3), varargin{:} );
        else
            set( gh, 'XData', pts(:,1), 'YData', pts(:,2), 'ZData', pts(:,2) );
            h = gh;
        end
    end
end
