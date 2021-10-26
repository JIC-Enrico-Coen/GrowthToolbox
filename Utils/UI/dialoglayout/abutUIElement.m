function abutUIElement( uihandle1, uihandle2, isHoriz, alignMode, distance )
%abutUIElement( uihandle1, uihandle2, isHoriz, distance )
%   Position uihandle2 relative to uihandle1.
%   If isHoriz is true, it is positioned on the same horizontal line,
%   otherwise the same vertical line.
%   alignMode = 0 if it is to be centred, -1 if left/bottom edges aligned,
%   1 is right/top edges aligned.
%   distance is the size of the gap between them.

    if nargin < 4, alignMode = 0; end
    if nargin < 5, distance = 0; end

    pos1 = get( uihandle1, 'Position' );
    pos2 = get( uihandle2, 'Position' );

    if isHoriz
        pos2(1) = pos1(1) - pos2(3) - distance;
        pos2(2) = pos1(2) + (pos1(4) - pos2(4))*(1+alignMode)/2;
    else
        pos2(2) = pos1(2) - pos2(4) - distance;
        pos2(1) = pos1(1) + (pos1(3) - pos2(3))*(1+alignMode)/2;
    end
    set( uihandle2, 'Position', pos2 );
end
