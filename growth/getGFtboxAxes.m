function a = getGFtboxAxes( m )
%a = getGFtboxAxes( m )
%   If m is being run from GFtbox, return the picture object, otherwise
%   return empty.  If m is not supplied then get the axes from teh GFtbox
%   window, if there is one.

    if nargin==0
        fig = getGFtboxFigure();
    else
        fig = getGFtboxFigure( m );
    end
    if ishandle( fig )
        h = guidata( fig );
        a = h.picture;
    else
        a = [];
    end
end
