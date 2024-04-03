function m = renumberMesh( m, rnodes, redges, rfaces, ...
                              rnodesmap, redgesmap, rfacesmap )
% m has had vertexes, edges, and cells merged or deleted.
% rnodes is an array whose length is the number of vertexes of the old
% version of m.  If vi is the index of such a vertex, then rnodes(vi) is
% the index of the same vertex in the current mesh.  If vi has been
% deleted, rnodes(vi) is zero.
% Similarly for redges and rcells.  The ordering of indexes is assumed to
% be unchanged.
% rnodesmap, redgesmap, rcellsmap are boolean maps of the same information
% in rnodes, redges, rcells.
% At least one of rnodes or rnodesmap must be supplied; if only one is, the
% other will be computed from it.  The same applies to redges and
% redgesmap, and rcells and rcellsmap.
%
%   For foliate meshes only.

    if nargin < 5
        rnodesmap = [];
    end
    if nargin < 6
        redgesmap = [];
    end
    if nargin < 7
        rfacesmap = [];
    end
    [rnodes,rnodesmap] = makeindexmap( rnodes, rnodesmap );
    [redges,redgesmap] = makeindexmap( redges, redgesmap );
    [rfaces,rfacesmap] = makeindexmap( rfaces, rfacesmap );

    % Use the maps to eliminate items; use the renumbering arrays to
    % transform values.

    % Per-vertex data.
    if ~isempty(rnodesmap)
        nummgens = size( m.morphogens, 2 );
        oldnumnodes = size( m.nodes, 1 );
        for i=1:nummgens
            for fnc={'Dpar','Dper'}
                fn = fnc{1};
                if length(m.conductivity(i).(fn))==oldnumnodes
                    m.conductivity(i).(fn) = m.conductivity(i).(fn)(rnodesmap);
                end
            end
        end
        m.nodes = m.nodes(rnodesmap,:);
        m.morphogens = m.morphogens(rnodesmap,:);
        m.mgen_production = m.mgen_production(rnodesmap,:);
        m.mgen_absorption = m.mgen_absorption(rnodesmap,:);
        m.morphogenclamp = m.morphogenclamp(rnodesmap,:);
        m.nodecelledges = m.nodecelledges(rnodesmap);
        if ~isempty(m.growthanglepervertex)
            m.growthanglepervertex = m.growthanglepervertex(rnodesmap);
        end
        if ~isempty(m.vertexnormals)
            m.vertexnormals = m.vertexnormals(rnodesmap,:);
        end
      % if false && (length(m.globalDynamicProps.stitchDFs) > 0)
      %     for i=1:length(m.globalDynamicProps.stitchDFs)
      %         dfs = m.globalDynamicProps.stitchDFs{i};
      %     end
      % end

        if isfield( m, 'growthTensorPerVertex' )
            m.growthTensorPerVertex = ...
                m.growthTensorPerVertex( rnodesmap, : );
        end
        % Delete the locator node if necessary.
        if (m.globalDynamicProps.locatenode > 0) && rnodesmap(m.globalDynamicProps.locatenode)
            m.globalDynamicProps.locatenode = 0;
            m.globalDynamicProps.locateDFs = [0 0 0];
        end

        % Per-prism-node data.
        pnodesmap = reshape( [ rnodesmap(:), rnodesmap(:) ]', [], 1 );
        m.prismnodes = m.prismnodes(pnodesmap,:);
        m.fixedDFmap = m.fixedDFmap(pnodesmap,:);
        if ~isempty(m.displacements)
            m.displacements = m.displacements(pnodesmap,:);
        end
    end
    
    if (~isempty(redges)) || (~isempty(rfaces))
        for i=1:length(m.nodecelledges)
            nce = m.nodecelledges{i};
            e = nce(1,:);
            c = nce(2,:);
            if ~isempty(redges)
                e = redges(e);
                c = c(e~=0);
                e = e(e~=0);
            end
            if ~isempty(rfaces)
                c(c ~= 0) = rfaces(c(c ~= 0));
            end
            zi = find(c==0,1);
            % Need to rotate to put any zero cell at the end.  Perhaps complain
            % if more than one zero.
            if ~isempty(zi)
                recycle = [(zi+1):length(e), 1:zi];
                e = e(recycle);
                c = c(recycle);
            end
            m.nodecelledges{i} = [ e; c ];
        end
    end
    
    % Per-edge data.
        
    if ~isempty(redgesmap)
        m.edgecells = m.edgecells(redgesmap,:);
    end
    if ~isempty(rfaces)
        m.edgecells(m.edgecells~=0) = rfaces(m.edgecells(m.edgecells~=0));
    end
    badedges = m.edgecells(:,1)==0;
    m.edgecells(badedges,:) = m.edgecells(badedges,[2 1]);
    if ~isempty(redgesmap)
        m.currentbendangle = m.currentbendangle(redgesmap);
        m.initialbendangle = m.initialbendangle(redgesmap);
        m.seams = m.seams(redgesmap);
    end
    if ~isempty(redgesmap)
        m.edgeends = m.edgeends(redgesmap,:);
        m.edgesense = m.edgesense(redgesmap);
    end
    if ~isempty(rnodes)
        m.edgeends = rnodes(m.edgeends);
    end

    % Per-cell data.
    if ~isempty(rfacesmap)
        m.tricellvxs = m.tricellvxs(rfacesmap,:);
        m.celledges = m.celledges(rfacesmap,:);
        m.celldata = m.celldata(rfacesmap);
        if ~isempty( m.cellFrames )
            m.cellFrames = m.cellFrames(:,:,rfacesmap);
        end
        if ~isempty( m.cellFramesA )
            m.cellFramesA = m.cellFramesA(:,:,rfacesmap);
        end
        if ~isempty( m.cellFramesB )
            m.cellFramesB = m.cellFramesB(:,:,rfacesmap);
        end
        m.cellbulkmodulus = m.cellbulkmodulus(rfacesmap);
        m.cellpoisson = m.cellpoisson(rfacesmap);
        m.cellstiffness = m.cellstiffness(:,:,rfacesmap);
        m.effectiveGrowthTensor = m.effectiveGrowthTensor(rfacesmap,:);
        if ~isempty(m.directGrowthTensors)
            m.directGrowthTensors = m.directGrowthTensors(rfacesmap,:);
        end
        m.unitcellnormals = m.unitcellnormals(rfacesmap,:);
        m.gradpolgrowth = m.gradpolgrowth(rfacesmap,:,:);
        m.polfreeze = m.polfreeze(rfacesmap,:,:);
        m.polfreezebc = m.polfreezebc(rfacesmap,:,:);
        m.polfrozen = m.polfrozen(rfacesmap,:);
        if size(m.polsetfrozen,1) > 1
            m.polsetfrozen = m.polsetfrozen(rfacesmap,:);
        end
        m.cellareas = m.cellareas(rfacesmap);
        if ~isempty(m.decorBCs)
            m.decorBCs = m.decorBCs( rfacesmap( m.decorFEs ), : );
        end
        if ~isempty(m.decorFEs)
            m.decorFEs = rfaces( m.decorFEs( rfacesmap( m.decorFEs ) ) );
        end
        if ~isempty(m.growthangleperFE)
            m.growthangleperFE = m.growthangleperFE(rfacesmap,:);
        end
        if isfield( m, 'celllabel' )
            m.celllabel = m.celllabel(rfacesmap);
        end
        for i=1:length(m.tubules.tracks)
            m.tubules.tracks(i).vxcellindex = rfaces( m.tubules.tracks(i).vxcellindex );
            preserved = m.tubules.tracks(i).vxcellindex > 0;
            m.tubules.tracks(i).vxcellindex = m.tubules.tracks(i).vxcellindex(preserved);
            m.tubules.tracks(i).barycoords = m.tubules.tracks(i).barycoords(preserved,:);
        end
        m.outputs.specifiedstrain.A = m.outputs.specifiedstrain.A(rfacesmap,:);
        m.outputs.specifiedstrain.B = m.outputs.specifiedstrain.B(rfacesmap,:);
        m.outputs.actualstrain.A = m.outputs.actualstrain.A(rfacesmap,:);
        m.outputs.actualstrain.B = m.outputs.actualstrain.B(rfacesmap,:);
        m.outputs.residualstrain.A = m.outputs.residualstrain.A(rfacesmap,:);
        m.outputs.residualstrain.B = m.outputs.residualstrain.B(rfacesmap,:);
        if ~isempty(  m.outputs.rotations )
            m.outputs.rotations = m.outputs.rotations(rfacesmap,:);
        end
    end
    if ~isempty(rnodes)
        m.tricellvxs = rnodes(m.tricellvxs);
    end
    if ~isempty(redges)
        m.celledges = redges(m.celledges);
    end

    if ~isempty(rfaces)
        m.secondlayer.vxFEMcell = rfaces(m.secondlayer.vxFEMcell);
        % vxBaryCoords? These must be handled individually by every
        % procedure that modified the mesh.
    end
    
    tpnames = fieldnames( m.tubules.tubuleparams );
    for i=1:length(tpnames)
        fn = tpnames{i};
        if size( m.tubules.tubuleparams.(fn), 1 ) == length(rnodesmap)
            m.tubules.tubuleparams.(fn) = m.tubules.tubuleparams.(fn)( rnodesmap, : );
        end
    end
end

function [reindex,bitmap] = makeindexmap( reindex, bitmap )
    if isempty(bitmap)
        bitmap = reindex ~= 0;
    elseif isempty(reindex)
        reindex = makereindex(bitmap);
    end
end

function ri = makereindex( bitmap )
    x = find(bitmap);
    ri = zeros(1,length(bitmap),'int32');
    ri(x) = 1:length(x);
end

