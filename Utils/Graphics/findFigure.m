function [fig,ax] = findFigure( varargin )
%[fig,ax] = findFigure()
%   If there is a current figure, return it in FIG. Return its
%   CurrentAxes attribute in AX.
%
%[fig,ax] = findFigure( fig )
%   If the figure FIG exists, make it the current figure without
%   bringing it to the front. Return its CurrentAxes attribute in AX.
%
%   When the figure exists, the result is the same as the result of gcf().
%   When the axes exists, the result is the same as the result of gca().
%   But if either does not exist, it is not created.
%   When the figure does exist, it is made current but is not brought to
%   the front.

    if (nargin==0) || isempty(varargin{1}) || ~ishghandle(varargin{1})
        fig = get(0, 'CurrentFigure');
    else
        fig = varargin{1};
        set(0, 'CurrentFigure', fig);
    end
    
    if ishghandle(fig)
        ax = get( fig, 'CurrentAxes' );
    else
        ax = [];
    end
end
