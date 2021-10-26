function r1 = abutRect( r, positioning, distance, thickness, len )
%r1 = abutRect( r, positioning, distance, thickness, len )
%   Create a rectangle r1 abutting r on the outside according to the other
%   parameters.
%   POSITIONING is a two-character string, with the second character
%   defaulting to 'c'.  The first is 'n', 's', 'w', or 'e' and specifies
%   which side the new rectangle abuts the old.  The second is 'n', 's',
%   'w', 'e', or 'c', and indicates which end of the abutted side r1 lines
%   up with.  For example, 'nw' abuts the new rectangle on the top edge of
%   the old one, flush with its left-hand edge.
%   DISTANCE is the space between r and r1.  
%   THICKNESS is the width of r1 in the direction in which it abuts r, and
%   LEN is the width in the transverse direction.  LEN can be omitted and
%   defaults to the corresponding dimension of r, in which case the result
%   is independent of the second character of POSITIONING.

    abutVertical = (positioning(1)=='n') || (positioning(1)=='s');
    abutLow = (positioning(1)=='w') || (positioning(1)=='s');
    if length(positioning) < 2
        positioning = [ positioning 'c' ];
    end
    if nargin < 5
        if abutVertical
            len = r(3);
    	else
            len = r(4);
        end
        extralen = 0;
    else
        if abutVertical
            extralen = r(3) - len;
        else
            extralen = r(4) - len;
        end
    end
    if abutLow
        transoffset = -distance-thickness;
    elseif abutVertical
        transoffset = r(4)+distance;
    else
        transoffset = r(3)+distance;
    end
    switch positioning(2)
        case {'w','s'}
            paroffset = 0;
        case 'c'
            paroffset = round(extralen/2);
        case {'e','n'}
            paroffset = extralen;
    end
    if abutVertical
        r1 = [ r(1)+paroffset, r(2)+transoffset, len, thickness ];
    else
        r1 = [ r(1)+transoffset, r(2)+paroffset, thickness, len ];
    end
end
