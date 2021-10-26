function m = deleteGeometry3D( m, delvxs, deledges, delfaces, delFEs )
%m = deleteGeometry3D( m, delvxs, deledge, delfaces, delFEs )
% UNUSED
%
%   Delete from m all of the given vertexes, edges, faces, and elements.
%
%   If a vertex is deleted, every element containing that vertex is
%   deleted.
%
%   If an edge is deleted, every element containing that edge is
%   deleted, but elements containing one of its vertexes but not the edge
%   itself need not be.
%
%   Similarly, if a face is deleted, elements that include that face are
%   deleted.
%
%   Elements explicitly listed for deletion are deleted.
%
%   Finally, any remeining vertexes, edges, or faces no longer belonging to
%   any element are deleted.

    if ~islogical(delvxs)
        delvxsmap = false(size(m.FEnodes,1),1);
        delvxsmap(delvxs) = true;
    else
        delvxsmap = delvxs;
    end

    if ~islogical(deledges)
        deledgesmap = false(size(m.FEconnectivity.edgeends,1),1);
        deledgesmap(deledges) = true;
    else
        deledgesmap = deledges;
    end

    if ~islogical(delfaces)
        delfacesmap = false(size(m.FEconnectivity.faces,1),1);
        delfacesmap(delfaces) = true;
    else
        delfacesmap = delfaces;
    end

    if ~islogical(delFEs)
        delFEsmap = false(size(m.FEsets.fevxs,1),1);
        delFEsmap(delFEs) = true;
    else
        delFEsmap = delFEs;
    end
    
    % Find all of the FEs that must be deleted, either because they were
    % explicitly listed, or because they include a vertex, edge, or face
    % that is to be deleted.
    delFEvxsmap = any( delvxsmap(m.FEsets.fevxs), 2 );
    delFEedgesmap = any( deledgesmap(m.FEconnectivity.feedges), 2 );
    delFEfacesmap = any( delfacesmap(m.FEconnectivity.fefaces), 2 );
    
    delFEsmap = delFEsmap | delFEvxsmap | delFEedgesmap | delFEfacesmap;
    
    % Delete the FEs.
    FEsToRetain = ~delFEsmap;
    m.FEsets.fevxs = m.FEsets.fevxs( FEsToRetain, : );
    
    % Determine which vertexes belong to the remaining FEs.
    [keepvxs,ia,ic] = unique( m.FEsets.fevxs, 'stable' );
    
    % Keep only those vertexes.
    m.FEnodes = m.FEnodes(keepvxs,:);
    
    % Renumber m.FEsets.fevxs to index the reduced vertex array.
    renumberVxs(keepvxs) = 1:length(keepvxs);
    m.FEsets.fevxs = renumberVxs( m.FEsets.fevxs );
    
    % Rebuild the rest of the connectivity data.
    m.FEconnectivity = connectivity3D(m);
    if ~checkConnectivityNewMesh(m)
        xxxx = 1;
    end
    
% Recalculate other data, e.g. morphogens, edge lengths, element volumes.

    % The per-vertex data has already been interpolated as necessary.  We
    % need only delete the unused values.
    m.morphogens = m.morphogens( keepvxs, : );
    m.morphogenclamp = m.morphogenclamp( keepvxs, : );
    m.mgen_production = m.mgen_production( keepvxs, : );
    m.mgen_absorption = m.mgen_absorption( keepvxs, : );
    m.fixedDFmap = m.fixedDFmap( keepvxs, : );
    m.effectiveGrowthTensor = m.effectiveGrowthTensor( FEsToRetain, : );
    if ~isempty(m.displacements)
        m.displacements = m.displacements( keepvxs, : );
    end
    m.cellbulkmodulus = m.cellbulkmodulus( FEsToRetain, : );
    m.cellpoisson = m.cellpoisson( FEsToRetain, : );
    m.cellstiffness = m.cellstiffness( :, :, FEsToRetain );
    m.gradpolgrowth = m.gradpolgrowth( FEsToRetain, : );
    m.gradpolgrowth2 = m.gradpolgrowth2( FEsToRetain, : );
    % m.unitcellnormals = m.unitcellnormals( FEsToRetain, : );
    m.polfreeze = m.polfreeze( FEsToRetain, : );
    m.polfrozen = m.polfrozen( FEsToRetain );
    m.celldata = m.celldata( FEsToRetain );
    m.FEsets.fevolumes = m.FEsets.fevolumes( FEsToRetain );
end
