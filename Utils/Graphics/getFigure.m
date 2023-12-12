function [result,ax] = getFigure( varargin )
%[fig,ax] = getFigure( ... )
%   Make a new figure and return it in FIG. If AX is requested, make also
%   an axes object in the figure.
%
%[fig,ax] = getFigure( fig, ... )
%   If the figure FIG already exists, make it the current figure without
%   bringing it to the front. If FIG is an integer not corresponding to an
%   existing figure, make that figure and return its handle. If FIG is
%   anything else, make a new figure and return it.
%
%   If the output argument AX is requested, then if we have a figure, set
%   AX to its current axes, if any, otherwise create an axes object in the
%   figure (which makes it the figure's current axes) and return it.
%
%[s,ax] = getFigure( s, fn, ... )
%   s is expected to be a struct. If s is empty, or does not have the
%   fieldname fn, then this is equivalent to [s.(fn),ax] = getFigure().
%   Otherwise, it is equivalent to [s.(fn),ax] = getFigure( s.(fn) ).
%   If the AX result is not requested then no axes object is created in the
%   figure.
%
%   Any number of option-value pairs can also be given, to set properties
%   of the figure. E.g. [fig,ax] = getFigure( 'Name', 'foo' ).
%
%   This function differs from Matlab's figure() in several ways, but the
%   main motivation for writing it was the ability to make an existing
%   figure current without bringing it to the front.
%
%   After calling this, the figure that is returned will be the same as
%   what gcf() returns, and if the AX output was requested, it will be the
%   same as what gca() returns.

    if nargin==0
        fig = figure();
        result = fig;
    else
        arg1 = varargin{1};
        if ishghandle(arg1)
            fig = arg1;
            result = fig;
            % This is how to make a figure current without bringing it to
            % the front.
            set(0, 'CurrentFigure', fig);
            varargin(1) = [];
        elseif isstruct( arg1 )
            result = arg1;
            fn = varargin{2};
            fig = [];
            if isfield( result, fn )
                fig = result.(fn);
                if isDeletedHandle(fig)
                    fig = [];
                end
            end
            if isempty(fig)
                fig = figure();
                result.(fn) = fig;
            end
            varargin([1 2]) = [];
        else
            fig = figure();
            result = fig;
            if isempty(arg1)
                varargin(1) = [];
            elseif ischar(arg1) || isstring(arg1)
                % Nothing
            elseif any(ishandle(arg1)) || any(isDeletedHandle(arg1))
                varargin(1) = [];
            end
        end
    end
    
    ax = [];

    if ishghandle(fig)
        if ~isempty( varargin )
            set( fig, varargin{:} );
        end
        if nargout > 1
            % This is how to find the current axes of a figure. If a figure
            % contains any axes objects, one of them is always the current
            % axes of that figure.
            ax = fig.CurrentAxes;
            if isempty(ax)
                % There are no axes objects in the figure, so make one.
                ax = axes( fig );
            end
        end
    end
end
