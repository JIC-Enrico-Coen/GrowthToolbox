function relPosUIElement( uihandle1, uihandle2, relhoriz, relvert )
%relPosUIElement( uihandle1, uihandle2, relhoriz, relvert )
%   Position a UI element uihandle2 within uihandle1.
%
%   If relhoriz is positive, it is 1 more than the desired distance from
%   the left edge of uihandle1 to the left edge of uihandle2.  If negative,
%   it is similarly applied to the right hand sides.  If zero, no horizontal
%   repositioning is done.
%
%   relvert similarly applies to vertical repositioning, with positive
%   values applying to the bottom edge and negative to the top edge.

    pos1 = get( uihandle1, 'Position' );
    pos2 = get( uihandle2, 'Position' );
    if relhoriz > 0
        pos2(1) = pos1(1) + relhoriz - 1;
    elseif relhoriz < 0
        pos2(1) = pos1(1) + pos1(3) - pos2(3) + relhoriz + 1;
    end
    if relvert > 0
        pos2(2) = pos1(2) + relvert - 1;
    elseif relvert < 0
        pos2(2) = pos1(2) + pos1(4) - pos2(4) + relvert + 1;
    end
    set( uihandle2, 'Position', pos2 );
end

