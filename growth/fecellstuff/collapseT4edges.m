function m = collapseT4edges( m, eis )
%m = collapseT4edges( m, edges )
%   Collapse each of the specified edges to a point.
%   This applies only to volumetric meshes made of first-order tetrahedral
%   elements.

    if islogical(eis)
        numToElide = sum(eis);
    else
        numToElide = length(eis);
    end
    if numToElide==0
        % Nothing to do;
        return;
    end

    timedFprintf( 1, '%d edges are candidates for elision.\n', numToElide );
    
    if ~exist('graph/conncomp','file')
        % Cannot proceed.
        timedFprintf( 1, '**** Requires Matlab functions graph() and conncomp(), available in Matlab version 8.6.0 (R2015b) or greater.\n' );
        return;
    end

    if ~checkConnectivityNewMesh(m)
        xxxx = 1;
    end
    
    
% 1.  Divide the edges into connected groups.  Then treat each group
% separately.

    numvxs = getNumberOfVertexes( m );

    % Reindex the vertexes to be 1...V where V is the number of distinct
    % vertexes in edges.
    edges = m.FEconnectivity.edgeends(eis,:);
    v = unique(edges(:));
    cptvxs = zeros(1,numvxs);
    cptvxs(v) = 1:length(v);
    edges1 = reshape( cptvxs( edges ), size(edges) );
    
    % Initialise a boolean map of the vertexes to delete.
    
    % Find the connected components.
    g = graph( edges1(:,1), edges1(:,2) );
    cpts = conncomp( g );
    % graph and conncomp are Matlab functions.  The result of conncomp is a
    % vector listing for every vertex of g the index of its component.
    timedFprintf( 1, '%d clumps are candidates for elision.\n', max(cpts(:)) );
    
    
    % We now want to select a subset of the clumps, such that the resulting
    % set of vertex merges leaves a valid mesh.
    % The method is based on the following claims:
    % 1. checkRemeshValidity correctly determines whether the result of
    %    collapsing a given set of edges is a valid mesh.
    % 2. If each of a set of clumps can on its own be individually
    %    collapsed, and no vertex of any clump is adjacent to any vertex of
    %    any other clump, then the whole set or clumps can be collapsed.
    % The adjacency condition in (2) is equivalent to no tetrahedron having
    % vertexes in more than one clump.
    % So we go through the clumps one by one.  A clump is rejected if it
    % cannot be validly collapsed, or if it touches any tetrahedron that
    % touches any already accepted clump.  The latter condition is checked
    % first, because it is faster, and it is likely to often be true.
    numFEs = getNumberOfFEs( m );
    mungedcpts = sortrows([cpts', v])';
    [s,e] = runends( mungedcpts(1,:) );
    forbiddentetras = false( numFEs, 1 );
    clumpmap = false( 1, length(s) );
    for i=1:length(s)
        clumpvxs = mungedcpts(2,s(i):e(i));
        vxmap = false( numvxs, 1 );
        vxmap(clumpvxs) = true;
        tetramap = any( vxmap(m.FEsets.fevxs), 2 );
        if any( forbiddentetras & tetramap )
            mungedcpts( 1, s(i):e(i) ) = 0;
        else
            ok = checkRemeshValidity( m.FEnodes, m.FEsets.fevxs(tetramap,:), [clumpvxs 0] );
            if ~ok
                mungedcpts( 1, s(i):e(i) ) = 0;
            else
                forbiddentetras(tetramap) = true;
                clumpmap(i) = true;
            end
        end
    end
    
    if ~any(clumpmap)
        return;
    end
    timedFprintf( 1, '%d clumps will be elided.\n', sum(clumpmap) );
    mungedcpts = mungedcpts( :, mungedcpts(1,:) ~= 0 );
    [starts,ends] = runends( mungedcpts(1,:) );

    % Record these in order to report the change in size at the end.
    oldnumvxs = size( m.FEnodes, 1 );
    oldnumedges = size( m.FEconnectivity.edgeends, 1 );
    oldnumfaces = size( m.FEconnectivity.faces, 1 );
    oldnumtetras = size( m.FEsets.fevxs, 1 );
    
    

% 2.  Find the centroid of each group of vertexes.  Move the first vertex
% of the group there and mark the remaining vertexes for deletion.  (Except
% for surface vertexes: always prefer a surface vertex. NOT IMPLEMENTED)
% Interpolate morphogens, clamp, and production values for the retained
% vertex.
%     [scpts,vperm] = sort(cpts);
    numcpts = length(starts);  % scpts(end);
%     [starts,ends] = runends( scpts );
    renumberVxs = 1:numvxs;
    for i=1:numcpts
        srange = starts(i):ends(i);
        vrange = mungedcpts(2,srange);  % vperm(srange);
        vxtypes = m.FEconnectivity.vertexloctype(vrange);
        [besttype,keepvertex] = max( vxtypes );
        othervertexes = [ 1:(keepvertex-1), (keepvertex+1):length(vxtypes) ];
        keepvertex = vrange(keepvertex);
        mungedcpts(1,srange) = keepvertex;
        othervertexes = vrange(othervertexes);
        bestvxs = vrange(vxtypes==besttype);
        centroid = sum( m.FEnodes( bestvxs, : ), 1 )/length(bestvxs);
        m.FEnodes(keepvertex,:) = centroid;
        m.FEnodes(othervertexes,:) = NaN;
        for mi=1:size(m.morphogens,2)
            switch m.mgen_interpType{mi}
                case {'mid','average'}
                    m.morphogens(keepvertex,mi) = mean( m.morphogens(vrange,mi) );
                case {'max','min'}
                    % Both min and max use the maximum when amalgamating
                    % vertexes.
                    m.morphogens(keepvertex,mi) = max( m.morphogens(vrange,mi) );
            end
        end
        m.morphogenclamp(keepvertex,mi) = max( m.morphogenclamp(vrange,mi) );
        m.mgen_production(keepvertex,mi) = mean( m.mgen_production(vrange,mi) );
        m.mgen_absorption(keepvertex,mi) = mean( m.mgen_absorption(vrange,mi) );
        m.fixedDFmap(keepvertex,:) = any( m.fixedDFmap( vrange, : ), 1 );
        % All vertexes in a component except the first are to be deleted.
        renumberVxs(othervertexes) = keepvertex;
    end
    

%     allvxcpts = zeros(1,numvxs);
%     allvxcpts( mungedcpts(2,:) ) = mungedcpts(1,:);
    
    
%     mungedcpts( :, mungedcpts(1,:)==mungedcpts(2,:) ) = [];
    vxsToElideMap = false( numvxs, 1 );
    vxsToElideMap(mungedcpts(2,:)) = true;
    reassignVxs = 1:numvxs;
    reassignVxs( mungedcpts(2,:) ) = mungedcpts(1,:);
    % Every FE that contains two or more elided vertexes is to be deleted.
    % Every FE that contains a single elided vertex has that vertex
    % renumbered.
    
    numElidedPerFE = sum( vxsToElideMap( m.FEsets(1).fevxs ), 2 );
    fesToDeleteMap = numElidedPerFE > 1;
    fesToRenumberMap = numElidedPerFE == 1;
    foo = m.FEsets(1).fevxs( fesToRenumberMap, : );
    foo = reassignVxs(foo);
    m.FEsets(1).fevxs( fesToRenumberMap, : ) = foo;
    
    
    
%     m.FEsets(1).fevxs = reassignVxs( m.FEsets(1).fevxs );
    m = recalculateSecondLayerFEs( m, numElidedPerFE > 0 );
    m = renumberMesh3D( m, 'fedelmap', fesToDeleteMap );
% 
% 
%     % An edge is to be deleted if both its ends are in the same component.
%     edgeCpts = allvxcpts(m.FEconnectivity.edgeends);
% %     edgeCpts = cpts(cptvxs(m.FEconnectivity.edgeends));
%     edgesToRetainMap = (edgeCpts(:,1)==0) | (edgeCpts(:,1) ~= edgeCpts(:,2));
%     
%     % An element is to be deleted if any of its edges is.
%     FEsToRetain = all( edgesToRetainMap(m.FEconnectivity.feedges), 2 );
%     
%     
%     
%     m = deleteGeometry3D( m, vxsToDeleteMap, ~edgesToRetainMap, [], ~FEsToRetain );

    newnumvxs = size( m.FEnodes, 1 );
    newnumedges = size( m.FEconnectivity.edgeends, 1 );
    newnumfaces = size( m.FEconnectivity.faces, 1 );
    newnumtetras = size( m.FEsets.fevxs, 1 );
    timedFprintf( 1, 'Deleted %d elements, %d faces, %d edges, %d vertexes.\n', ...
        oldnumtetras - newnumtetras, ...
        oldnumfaces - newnumfaces, ...
        oldnumedges - newnumedges, ...
        oldnumvxs - newnumvxs );
end