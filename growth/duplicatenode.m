function m = duplicatenode( m, vi, vis )
%m = duplicatenode( m, vi, vis )
%   vis is the set of indexes of duplicates of vertex vi that are to be
%   created.  Replicate all of the per-vertex information for vertex vi,
%   for each of the new vertexes.

    numdups = length(vis);
    m.nodes(vis,:) = repmat( m.nodes(vi,:), numdups, 1 );
    pvi = [ vi*2-1, vi*2 ];
    pvis = (vis(:)*2)';
    pvis = reshape( [ pvis-1; pvis ], 1, [] );
    m.prismnodes(pvis,:) = repmat( m.prismnodes(pvi,:), numdups, 1 );
    if ~isempty(m.displacements)
        m.displacements(pvis,:) = repmat( m.displacements(pvi,:), numdups, 1 );
    end
    m.morphogens(vis,:) = repmat( m.morphogens(vi,:), numdups, 1 );
    m.morphogenclamp(vis,:) = repmat( m.morphogenclamp(vi,:), numdups, 1 );
    m.mgen_production(vis,:) = repmat( m.mgen_production(vi,:), numdups, 1 );
    m.mgen_absorption(vis,:) = repmat( m.mgen_absorption(vi,:), numdups, 1 );
    m.fixedDFmap(pvis,:) = repmat( m.fixedDFmap(pvi,:), numdups, 1 );
    if isfield( m, 'growthTensorPerVertex' )
        m.growthTensorPerVertex(vis,:) = repmat( m.growthTensorPerVertex(vi,:), numdups, 1 );
    end
end
