function m = VV_recomputeCoords( m )
%m = VV_recomputeCoords( m )
%   After the mesh vertexes of m have moved, recompute the positions of all
%   VV vertexes.

    if ~isfield(m.secondlayer,'vvlayer') || isempty(m.secondlayer.vvlayer)
        return;
    end
    
    m.secondlayer.vvlayer.mainvxs = baryToGlobalCoords( m.secondlayer.vvlayer.mainvxsFEM, m.secondlayer.vvlayer.mainvxsbcs, m.nodes, m.tricellvxs );
    m.secondlayer.vvlayer = VV_recalcVertexes( m.secondlayer.vvlayer );
end
