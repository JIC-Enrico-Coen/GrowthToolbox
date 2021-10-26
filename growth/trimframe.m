function f = trimframe( f, sz, bgcolor )
%f = trimframe( f, sz )
%   Force the movie frame f to have the given size sz (a two-element
%   vector).
%   If the frame is too big, chop pixels off the edges.
%   If it's too small, pad it out with bgcolor.
%   Maintain the centering of the frame.

    if nargin < 3
        bgcolor = [1 1 1];
    end
    ibgcolor = uint8color( bgcolor );
    szf = size(f);
    dsz = sz - szf([1 2]);
    hdsz = floor( abs(dsz)/2 );
    hdsz1 = abs(dsz) - hdsz;
    if dsz(1) > 0
        szf11 = szf(1)+1;
        f( szf11 : sz(1), :, 1 ) = ibgcolor(1);
        f( szf11 : sz(1), :, 2 ) = ibgcolor(2);
        f( szf11 : sz(1), :, 3 ) = ibgcolor(3);
        f( [ (hdsz(1)+1) : sz(1), 1:hdsz(1) ], :, : ) = f;
    elseif dsz(1) < 0
        f = f( (hdsz(1)+1):(szf(1) - hdsz1(1)), :, : );
    end
    if dsz(2) > 0
        szf21 = szf(2)+1;
        f( :, szf21 : sz(2), 1 ) = ibgcolor(1);
        f( :, szf21 : sz(2), 2 ) = ibgcolor(2);
        f( :, szf21 : sz(2), 3 ) = ibgcolor(3);
        f( :, [ (hdsz(2)+1) : sz(2), 1:hdsz(2) ], : ) = f;
    elseif dsz(2) < 0
        f = f( :, (hdsz(2)+1):(szf(2) - hdsz1(2)), : );
    end
end
