function nbcis = nbvcells( m,  cis )
%cis = nbcells( m,  ci )
%   Find all finite elements that share a vertex with any element in cis.

    vxs = m.tricellvxs( cis, : );
    nce = [m.nodecelledges{vxs(:)}];
    nbcis = unique( nce(2,:) );
    if nbcis(1)==0
        nbcis(1) = [];
    end
end
