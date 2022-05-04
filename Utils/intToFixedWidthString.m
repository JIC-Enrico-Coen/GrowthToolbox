function s = intToFixedWidthString( i, n, zeroPadded )
%s = intToFixedWidthString( i, n )
%   Convert I to a string using at least as many characters as it
%   takes to convert N to a string. I and N must be integers.
%
%   If ZEROPADDED is true, extra space will be filled with zeros, otherwise
%   spaces. Spaces is the default.
%
%   If I is larger than will fit in the space implied by N, then S will
%   be as long as it needs to be.

    if nargin < 3
        zeroPadded = false;
    end
    numchars = floor( log10( abs(n) ) ) + 1;
    if n<0
        numchars = numchars+1;
    end
    if zeroPadded
        zeroMarker = '0';
    else
        zeroMarker = '';
    end
    s = sprintf( ['%', zeroMarker, '*d'], numchars, i );
end

