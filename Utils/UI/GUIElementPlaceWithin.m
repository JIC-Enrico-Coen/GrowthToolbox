function GUIElementPlaceWithin( movable, fixed, isleft, leftmargin, istop, topmargin )
%GUIElementPlaceWithin( movable, fixed, isleft, leftmargin, isright, rightmargin )
%   Place the GUI element MOVABLE relative to the GUI element FIXED.
%   MOVABLE is assumed to be a child of FIXED.
%   If ISLEFT is true, the left side of MOVABLE is placed LEFTMARGIN pixels
%   to the right of the left side of FIXED.
%   If ISLEFT is false, the right side of MOVABLE is placed LEFTMARGIN pixels
%   to the left of the right side of FIXED.
%   Similarly for ISTOP and TOPMARGIN.

%   The result of get( ..., 'Position' ) is [x y w h].

    oldmpos = get( movable, 'Position' );
    fpos = get( fixed, 'Position' );
  % fprintf( 1, '%s:\n    [x %.3f y %.3f w %.3f h %.3f]\n    [x %.3f y %.3f w %.3f h %.3f]\n', ...
  %     mfilename(), oldmpos, fpos );
    if isleft
        oldmpos(1) = leftmargin;
    else
        oldmpos(1) = fpos(3) - oldmpos(3) - leftmargin;
    end
    if istop
        oldmpos(2) = fpos(4) - oldmpos(4) - topmargin;
    else
        oldmpos(2) = topmargin;
    end
  % fprintf( 1, '    [x %.3f y %.3f w %.3f h %.3f]\n', ...
  %     oldmpos );
    set( movable, 'Position', oldmpos );
end
