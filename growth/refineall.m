function m = refineall( m, tension )
%m = refineall( m )
%   Split all edges of m, giving a mesh with four times as many cells.

    numnodes = size(m.nodes,1);
    numedges = size(m.edgeends,1);
    numcells = size(m.tricellvxs,1);
    pos = zeros(numedges,3);
    for ei = 1:numedges
        pos(ei,:) = butterfly( m, ei, tension );
    end
    m.nodes = [ m.nodes; pos ];
    newtri = zeros( 4*numcells, 3 );
    for ci = 1:size(m.tricellvxs,1)
        v1 = m.tricellvxs(ci,1);
        v2 = m.tricellvxs(ci,2);
        v3 = m.tricellvxs(ci,3);
        v12 = numnodes + m.celledges(ci,3);
        v23 = numnodes + m.celledges(ci,1);
        v31 = numnodes + m.celledges(ci,2);
        newtri(ci*4+[-3 -2 -1 0],:) = [ v1 v12 v31; ...
                                     v2 v23 v12; ...
                                     v3 v31 v23; ...
                                     v23 v31 v12 ];
    end
    m.tricellvxs = newtri;
    m.globalProps.prismnodesvalid = false;
    m.globalProps.trinodesvalid = true;
end
