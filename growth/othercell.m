function ci1 = othercell( m, ci, ei )
%ci1 = othercell( m, ci, ei )
%   If ci is the cell on one side of edge ei, return the cell on the other
%   side, or zero if there is no such cell.
%   ei can be a vector, and ci1 will be a vector of the same length.

    firsts = ci==m.edgecells(ei,1);
    ci1 = zeros(1,length(ei));
    for i=1:length(ei)
        ci1(i) = m.edgecells(ei(i),1+firsts(i));
    end
end
