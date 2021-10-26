function m = upgradeSecondLayer( m )
%m = upgradeSecondLayer( m )
%   Upgrade old versions of the biological layer.

    if ~isfield( m.secondlayer, 'celldata' )
        m.secondlayer = newemptybiodata( m.secondlayer );
        m.secondlayer = extendCellIndexing( m.secondlayer, ...
                                            length(m.secondlayer.cells), ...
                                            size(m.secondlayer.edges,1), ...
                                            length(m.secondlayer.vxFEMcell) );
    end
end
