function h = getGFtboxHandles( varargin )
%h = getGFtboxHandles( m )
%   If m is being run from GFtbox, return the GUI handles, otherwise return
%   empty.

    fig = getGFtboxFigure( varargin{:} );
    if ishandle( fig )
        h = guidata( fig );
    else
        h = [];
    end
end
