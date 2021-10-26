function m = setAbsoluteThickness( m, thickness, offset )
%m = setAbsoluteThickness( m, thickness, offset )
%   Set the current absolute thickness of the mesh everywhere.
%   The thickness parameters are not affected.  This procedure should only
%   be used when thickness is implemented physically.
%
%   The offset indicates how much of the change in thickness should be
%   applied to the two sides of the mesh. Zero means symmetric, 1 means
%   that the A side moved by the whole amount and the B side does not move,
%   -1 means the opposite, and intermediate values give intermediate
%   results. Values outside the range -1...1 are also meaningful.

    if nargin < 3
        offset = 0;
    end
    numpnodes = size( m.prismnodes, 1 );
    anodes = 1:2:(numpnodes-1);
    bnodes = 2:2:numpnodes;
    delta = m.prismnodes( anodes, : ) - m.prismnodes( bnodes, : );
    len = sqrt(sum( delta.*delta, 2 ));
    oklen = len > 0;
    anodes = anodes(oklen);
    bnodes = bnodes(oklen);
    len = len(oklen);
    delta = delta(oklen,:);
    ratios = (thickness./len - 1)/2;
    for i=1:size(delta,2)
        delta(:,i) = delta(:,i).*ratios;
    end
    m.prismnodes( anodes, : ) = m.prismnodes( anodes, : ) + delta*(1+offset);
    m.prismnodes( bnodes, : ) = m.prismnodes( bnodes, : ) + delta*(-1+offset);
    if offset ~= 0
        m.nodes = (m.prismnodes( anodes, : ) + m.prismnodes( bnodes, : ))/2;
    end
end
