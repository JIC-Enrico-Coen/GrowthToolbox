function [fig,m] = getGFtboxFigure( m )
%[fig,m] = getGFtboxFigure( m )
%   If m is being run from GFtbox, return a handle to the GFtbox figure,
%   otherwise return empty.
%   If m is omitted, return a handle to the GFtbox figure, if any, and the
%   current mesh, if any.

    if (nargin==0) || isempty(m)
        [fig,m] = GFtboxFindWindow();
    elseif isempty( m.pictures )
        fig = [];
    elseif ~ishandle( m.pictures(1) )
        fig = [];
    else
        fig = ancestor( m.pictures(1), 'figure' );
        if ~ishandle( fig )
            fig = [];
        end
    end
end
