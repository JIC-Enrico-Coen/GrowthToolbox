function a = currentAxes()
%a = currentAxes()
%   Return the current axes object, if there is one, otherwise [].
%   This is the same as gca(), except that if there is no current axes,
%   none is created.

    f = currentFigure();
    if isempty(f)
        a = [];
    else
        a = get( f, 'CurrentAxes' );
    end
end