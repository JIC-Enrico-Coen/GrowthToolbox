function GUIElementRelPlace( movable, fixed, isleft, leftmargin, istop, topmargin )
%GUIElementRelPlace( movable, fixed, isleft, leftmargin, isright, rightmargin )
%   Place the GUI element MOVABLE relative to the GUI element FIXED.
%   MOVABLE and FIXED are assumed to be children of the same parent.
%   If ISLEFT is true, the left side of MOVABLE is placed LEFTMARGIN pixels
%   to the right of the left side of FIXED.
%   If ISLEFT is false, the right side of MOVABLE is placed LEFTMARGIN pixels
%   to the left of the right side of FIXED.
%   Similarly for ISTOP and TOPMARGIN.

%   The result of get( ..., 'Position' ) is [x y w h].

    oldmpos = get( movable, 'Position' );
    fpos = get( fixed, 'Position' );
    if isleft
        oldmpos(1) = fpos(1) + leftmargin;
    else
        oldmpos(1) = fpos(1) + fpos(3) - oldmpos(3) - leftmargin;
    end
    if istop
        oldmpos(2) = fpos(2) + fpos(4) - oldmpos(4) - topmargin;
    else
        oldmpos(2) = fpos(2) + topmargin;
    end
end
