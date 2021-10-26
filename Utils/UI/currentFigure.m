function f = currentFigure()
%f = currentFigure()
%   Return the current figure, if there is one, otherwise [].
%   This is the same as gcf(), except that if there is no current figure,
%   none is created.

    f = get( 0, 'CurrentFigure' );
end