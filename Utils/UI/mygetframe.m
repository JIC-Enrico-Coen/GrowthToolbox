function f = mygetframe( theaxes, varargin )
%f = mygetframe( theaxes )
%   Like getframe(), but protected against errors and the changing
%   behaviour of getframe from one version of Matlab to another.
%   It does not support getframe's second argument, which specifies a
%   sub-rectangle of the axes object to image.  The whole of the
%   rectangle occupied in the figure is always imaged.
%
%   If no arguments are supplied, the current axes are used.  If there is
%   no current axes object, f is returned as empty.
%
%f = mygetframe( theaxes, options... )
%   If there are further arguments, export_fig (a third-party utility) is
%   invoked instead of getframe, and those arguments are passed to
%   export_fig.
%
%   See also: getframe, export_fig

    if nargin==0
        theaxes = currentAxes();
        if isempty(theaxes)
            f = [];
            return;
        end
    end
    
    if isempty( varargin )
        try
            [pos,fig] = positionInFigure( theaxes );
            f = getframe( fig, pos );
            xxxx = 1;
        catch e
            f = [];
            fprintf( 1, '** Warning: getframe() failed: "%s"\n', ...
                e.message );
        end
    else
        try
            f = export_fig( theaxes, varargin{:} );
        catch e
            f = [];
            fprintf( 1, '** Warning: export_fig() failed: "%s"\n', ...
                e.message );
        end
    end
end

function [pos,fig] = positionInFigure( h )
% Find the position in pixels of an object in its parent figure.

    pos = getPositionInPixels(h);
    fig = ancestor(h,'figure');
    h = get(h,'Parent');
    while h ~= fig
        pos1 = getPositionInPixels(h);
        pos([1 2]) = pos([1 2]) + pos1([1 2]);
        h = get(h,'Parent');
    end
    pos(1) = pos(1)+1;  % Move the rectangle 1 pixel to the right.  If I don't
            % do this, it ends up 1 pixel too far to the left,  It is not
            % necessary to do this for the vertical direction.  I don't
            % know why this is.  Just some Matlab nonsense presumably.
end

function pos = getPositionInPixels( h )
% Get the position of an object in pixels, regardless of its 'Units'
% setting.

    units = get(h,'Units');
    needchange = ~strcmp(units,'pixels');
    if needchange
        set(h,'Units','pixels');
    end
    % The offset of [1 1] is to compensate for Matlab's
    % 1-indexing of positions expressed in pixels.
    pos = get(h,'Position') - [1 1 0 0];
    if needchange
        set(h,'Units',units);
    end
end
