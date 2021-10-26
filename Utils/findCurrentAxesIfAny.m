function ax = findCurrentAxesIfAny()
%ax = findCurrentAxesIfAny()
%   Get the current axes object, if there is one, otherwise return empty.
%   When this returns an axes object, it is the same one that gca would
%   return.

    currentFigure = get( 0, 'CurrentFigure' );
    ax = get( currentFigure, 'CurrentAxes' );
end
