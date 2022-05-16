function [m,splitdata] = splitT4Edges3D( m, eis )
%[m,splitdata] = splitT4Edges3D( m, eis )
%   Split a set of edges of a linear tetrahedral volumetric mesh.

    splitdata = [];

    % Check that we are asked to do something.
    if isempty(eis)
        return;
    end
    
    % Check that m is the sort of mesh we can operate on.
    if ~isT4mesh( m )
        % Must be a T4 mesh.
        return;
    end
    
    GIVE_WARNINGS = false;
    
    oldNodes = m.FEnodes;
    oldCell3dcoords = baryToGlobalCoords( m.secondlayer.vxFEMcell, m.secondlayer.vxBaryCoords, m.FEnodes, m.FEsets.fevxs );
%     oldbcserr = max(abs( oldCell3dcoords(:) - m.secondlayer.cell3dcoords(:) ))
    oldfevxs = m.FEsets.fevxs;
    
    % Take the closure of the set of edges, to avoid splitting exactly two
    % edges of any face.
    if islogical(eis)
        requestedsplits = sum(eis);
    else
        requestedsplits = length(eis);
    end
    eis = edgeClosureLower( m, eis );
    if islogical(eis)
        eis = find(eis);
    end
    timedFprintf( 1, 'Splitting %d edges of %d requested.\n', length(eis), requestedsplits );
    numsplitedges = length(eis);
    
    % Get a boolean map of edges to split.
    numOldEdges = size(m.FEconnectivity.edgeends,1);
    splitedgemap = false(1,numOldEdges);
    splitedgemap(eis) = true;
    
    
    
    % Make a boolean map of edges per FE to be split
    splitedgeperFEmap = splitedgemap( m.FEconnectivity.feedges );
    ignoreFEs = all(splitedgeperFEmap==0,2);
    splitedgeperFEmap(ignoreFEs,:) = [];
    fesToSplit = find(~ignoreFEs);
    
    numOldFEs = size(m.FEsets(1).fevxs,1);
    numsplitsperFE = sum(splitedgeperFEmap,2);
    numNewFEperSplitType = [1 3 3 0 0 7];
    numNewFEsPerFE = numNewFEperSplitType(numsplitsperFE);
    maxNumNewFEsPerFE = max(numNewFEsPerFE);
    maxEdgesSplit = max(numsplitsperFE);
    numNewFEs = sum(numNewFEsPerFE);
    
    % This should be empty:
    badedgecounts = setdiff( unique(numsplitsperFE), [1 2 3 6] );
    if ~isempty(badedgecounts)
        timedFprintf( 1, 'Some FEs have an unexpected number of edges to split (must be 0, 1, 2, 3, or 6).\n' );
        xxxx = 1; %#ok<NASGU>
    end
    
    % Make the new vertexes
    numOldVxs = size(m.FEnodes,1);
    numNewVxs = numsplitedges;
    newVxIndexes = (numOldVxs+1):(numOldVxs+numNewVxs);
    

    splitedgeends = m.FEconnectivity.edgeends(eis,:);
    newnodes = (m.FEnodes(splitedgeends(:,1),:) + m.FEnodes(splitedgeends(:,2),:))/2;
    surfacesplitvertexes = zeros(0,3);
    
    splitdata = [splitedgeends(:,1), newVxIndexes', splitedgeends(:,2)];

    BUTTERFLY_SUBDIV = true;
    if BUTTERFLY_SUBDIV
        [s,embedding] = extractSurface( m );
        surfaceedgeindexes = embedding.edgeVolToSurfaceIndex(eis);
        surfaceedgesplits = surfaceedgeindexes ~= 0;
        surfaceedgeindexes = surfaceedgeindexes(surfaceedgesplits);
        if ~isempty(surfaceedgeindexes)
            surfacesplitvertexes = zeros( length(surfaceedgeindexes), 3 );
            for i=1:length(surfaceedgeindexes)
                sei = surfaceedgeindexes(i);
                [~,~,surfacesplitvertexes(i,:)] = butterflystencil( s, sei, m.globalProps.surfacetension, m.globalProps.edgetension );
            end
%             corrections = surfacesplitvertexes - newnodes( surfaceedgeindexes ~= 0, : )
%             newnodes( surfaceedgesplits, : ) = surfacesplitvertexes;
            surfaceedgesplits = [ false(numOldVxs,1); surfaceedgesplits ];
        end
    else
        surfaceedgesplits = false( numsplitedges, 1 );
    end
    
    % surfaceedgesplits is a boolean map of all the vertexes, old and new.
    % It is false for all old vertexes and for new vertexes placed at the
    % midpoint of their edge.  It is true for the new vertexes that are
    % displaced by butterfly subdivision.
    % surfacesplitvertexes contains the coordinates of all the displaced
    % vertexes.  We do not install them into the mesh here, but at the end
    % of the splitting, so that the displacement of the vertexes does not
    % cause spurious errors in the bookkeeping checks.
    
    
    m.FEnodes = [ m.FEnodes; newnodes ];
    oldEdgeToNewVxs = zeros(1,numOldEdges);
    oldEdgeToNewVxs(eis) = newVxIndexes;

    % Edge sharpness is inherited from the parent.
    % DOES NOT WORK. The call of connectivity3D() later will scramble things.
%     m.sharpedges = [ m.sharpedges; m.sharpedges( eis ) ];

    % New vertexes are never sharp.
    m.sharpvxs( newVxIndexes ) = false;
    

    % Split the FEs.
    curFEIndex = numOldFEs;
    femapping = zeros( numNewFEs, 2 );
    curfemapindex = 0;
    ok = true;
    numFEsSplit = length(fesToSplit);
    allbcs = zeros( 4+maxEdgesSplit,4,numFEsSplit);
    allrelfevxs = zeros( maxNumNewFEsPerFE,4,numFEsSplit);
    allfes = zeros( numFEsSplit, maxNumNewFEsPerFE );
    % There is an optimisation to be made: only store into allbcs,
    % allfevxs, and allfes info for elements that contain at least one bio
    % vertex.
    for i=1:length(fesToSplit)
        fe = fesToSplit(i);
        edges = find(splitedgeperFEmap(i,:));
        % Get absolute edge indexes.
        absedges = m.FEconnectivity.feedges( fe, edges );
        % Map them to new vertex indexes.
        newAbsVxs = oldEdgeToNewVxs(absedges);
        
        absVxIndexes = [ m.FEsets(1).fevxs(fe,:), newAbsVxs ];
        [fevxs,ok1,bcs] = split1T4( edges, m.FEnodes(newAbsVxs,:) );
        if ~ok1
            timedFprintf( 1, 'Something went wrong splitting tetrahedron %d on edges', fe );
            fprintf( 1, ' %d', edges );
            fprintf( 1, '\n' );
        end
        ok = ok && ok1;
        
%         bcs(fevxs(1,:),:)
        
        % Current coordinates of the new FEs.
        c1 = permute( reshape( m.FEnodes(absVxIndexes(fevxs'),:), size(fevxs,2), size(fevxs,1), 3 ), [1 3 2] );
        
        % Coordinates as computed from the bcs.
        c2 = baryToGlobalCoords( ones(length(absVxIndexes),1), bcs, m.FEnodes(m.FEsets(1).fevxs(fe,:),:), [1 2 3 4] );
        c3 = permute( reshape( c2(fevxs',:), size(fevxs,2), size(fevxs,1), 3 ), [1 3 2] );
        
        % c1 and c3 should be the same up to rounding error.
        errc1c3 = max(abs(c1(:)-c3(:)));
        if errc1c3 > 0.01
            xxxx = 1; %#ok<NASGU>
        end
        
        
        
        numaddedFEs = size(fevxs,1)-1;
        newFEIndexes = (curFEIndex+1):(curFEIndex+numaddedFEs);
        allbcs(1:size(bcs,1),:,i) = bcs;
        allrelfevxs(1:size(fevxs,1),:,i) = fevxs;
        allabsfevxs(1:size(fevxs,1),:,i) = absVxIndexes(fevxs);
        allfes(i,1:size(fevxs,1)) = [fe,newFEIndexes];
        absfevxs = absVxIndexes(fevxs);
        m.FEsets(1).fevxs( [fe, newFEIndexes ], : ) = absfevxs;
        curFEIndex = curFEIndex + numaddedFEs;
        femapping( (curfemapindex+1):(curfemapindex+numaddedFEs), 1 ) = fe;
        femapping( (curfemapindex+1):(curfemapindex+numaddedFEs), 2 ) = newFEIndexes;
        curfemapindex = curfemapindex+numaddedFEs;
    end
    
    if curFEIndex ~= numOldFEs + numNewFEs
        timedFprintf( 1, 'Expected to have %d elements (%d old, %d new), but have %d.\n', ...
            numOldFEs + numNewFEs, numOldFEs, numNewFEs, curFEIndex );
    end
    
    
    % Update the rest of the mesh.
    
    
    m = extrapolatePerVertexSplits( m, splitedgeends );
    
    oldFDFMap = reshape( m.fixedDFmap(splitedgeends',:), 2, length(eis), [] );
    newFDFMap = reshape( all( oldFDFMap, 1 ), length(eis), [] );
    m.fixedDFmap(newVxIndexes,:) = newFDFMap;
    
    oldfesi = femapping(:,1);
    newfesi = femapping(:,2);
    
    m.celldata(newfesi) = m.celldata(oldfesi);
    m.cellstiffness(:,:,newfesi) = m.cellstiffness(:,:,oldfesi);
    m.cellbulkmodulus(newfesi) = m.cellbulkmodulus(oldfesi);
    m.cellpoisson(newfesi) = m.cellpoisson(oldfesi);
    m.gradpolgrowth(newfesi,:) = m.gradpolgrowth(oldfesi,:);
    m.gradpolgrowth2(newfesi,:) = m.gradpolgrowth2(oldfesi,:);
    m.polfreeze(newfesi,:) = m.polfreeze(oldfesi,:);
    m.polfrozen(newfesi) = m.polfrozen(oldfesi);
    m.effectiveGrowthTensor(newfesi,:) = m.effectiveGrowthTensor(oldfesi,:);
    m.cellFrames(:,:,newfesi) = m.cellFrames(:,:,oldfesi);
    if isfield( m, 'unitcellnormals' ) && ~isempty( m.unitcellnormals )
        m.unitcellnormals(newfesi,:) = m.unitcellnormals(oldfesi,:);
    end
        
    
    if hasNonemptySecondLayer( m )
        % Now we need to update the bio layer.
        % This is complicated.
        % For each method of splitting an FE, we need a table showing how
        % bcs in the old FE are mapped to bcs of the new FEs.
        % A brute force method would be to map the old bcs to bcs relative
        % to each of the new FEs, and see for which of them all of the new
        % bcs are non-negative (or closest to being so).  For this I need
        % the bcs of all the edge-splitting points.
        
        % We need a table mapping local edge index to local bcs of the
        % midpoint of the edge.  Similarly for face centres.
        
        % allfevxs(:,:,i) lists the quads of local vertex indexes of the
        % FEs into which the i'th FE to be split was split.
        % allbcs(:,:,i) lists the bcs of the original and added vertexes.
        % The values of allfevxs(:,:,i) index into the rows of
        % allbcs(:,:,i).
        
        % For each bio vertex that was in FE i, we must determine if that
        % FE was split and if so its index j in the list of split FEs.
        % We should first calculate this for all the bio vertexes.
        
        feToSplitFE = zeros( getNumberOfFEs(m), 1 );
        feToSplitFE(fesToSplit) = (1:numFEsSplit)';
        % feToSplitFE maps indexes of FEs to indexes into the list of FEs
        % to split.  FEs that are not to be split have their indexes mapped
        % to zero.
        
        vxFEMcellSplit = [ feToSplitFE( m.secondlayer.vxFEMcell ), ...
                           m.secondlayer.vxFEMcell, ...
                           (1:length(m.secondlayer.vxFEMcell))' ];
        vxFEMcellSplit = vxFEMcellSplit( vxFEMcellSplit(:,1) ~= 0, : );
        vxFEMcellSplit = sortrows( vxFEMcellSplit );
        % For each bio vertex that lies inside an FE that is to be split,
        % vxFEMcellSplit lists:
        % 1.  An index into fesToSplit.  The value of fesToSplit at that
        % index is the FE that the vertex lies in.
        % 2.  The FE that the vertex lies in.
        % 3.  The index of the vertex.
        % The rows of vxFEMcellSplit are sorted into lexical order.  Thus
        % for every FE that is to be split, and contains any bio vertexes,
        % the rows for the vertexes lying within that FE are consecutive
        % and in increasing order of vertex index.
        
        
        
        invbcs = zeros( 4, 4, maxNumNewFEsPerFE+1 );
        % invbcs will hold a set of 4x4 matrices.  This will be reused for
        % every FE that is to be split, and will hold one matrix for every
        % child FE.  These will be used to convert barycentric
        % coordinates expressed relative to the parent FE into bcs
        % describing the same point relative to each of the child FEs.
        % ERROR?  The length of this should be the number of child FEs.
        
        % Save some data from the current state of the mesh.
        oldVxBaryCoords = m.secondlayer.vxBaryCoords;
        oldVxFEMcell = m.secondlayer.vxFEMcell;
        oldcell3dcoords = m.secondlayer.cell3dcoords;
        
        currentSplitFE = 0;
        for i=1:size(vxFEMcellSplit,1)
            % i indexes the list of bio vertexes lying in FEs that were
            % split.
            vxsfei = vxFEMcellSplit(i,1);
            % vxsfei indexes the list of finite elements to split.  This
            % also indexes the third dimension of allfevxs and allbcs, and
            % the first dimension of allfes.
            vxfei = vxFEMcellSplit(i,2);
            % vxfei indexes the old finite elements.
            biovxi = vxFEMcellSplit(i,3);
            % biovxi is the bio vertex, which lies in element vxfei.
            
            % CHECK: the bio vertex is recorded as being in the finite
            % element.
            if GIVE_WARNINGS && (m.secondlayer.vxFEMcell(biovxi) ~= vxfei)
                warning( '%s: bookkeeping error 1.', mfilename() );
                xxxx = 1; %#ok<NASGU>
            end
            if GIVE_WARNINGS && (m.secondlayer.vxFEMcell(biovxi) ~= fesToSplit(vxsfei))
                warning( '%s: bookkeeping error 2.', mfilename() );
                xxxx = 1; %#ok<NASGU>
            end
            
            % CHECK: the old bcs of the bio vertex correctly give its
            % position
            biovxFEvxs = oldNodes( oldfevxs(vxfei,:), :);
            biovxpos = oldVxBaryCoords(biovxi,:) * biovxFEvxs;
            err = max(abs(biovxpos-oldcell3dcoords(biovxi,:)));
            if GIVE_WARNINGS && (err > 2e-7)
                warning( '%s: bookkeeping error 3: %g.', mfilename(), err );
                xxxx = 1; %#ok<NASGU>
            end
            
            
            if vxsfei ~= currentSplitFE
                currentSplitFE = vxsfei;
                % Compute inverse bcs
                invbcs(:) = 0;
                for j=1:(numNewFEsPerFE(vxsfei)+1)
                    febcs = allbcs( allrelfevxs(j,:,vxsfei), :, vxsfei );
                    
                    % CHECK: febcs should be the barycentric coordinates of
                    % each vertex of the daughter FE w.r.t. the parent FE.
                    newfevi = allabsfevxs(j,:,vxsfei);
%                     newfe1 = allfes(vxsfei,j);
%                     newfevi1 = m.FEsets.fevxs(newfe1,:);
                    newfevxpos = m.FEnodes(newfevi,:);
                    newfevxposx = febcs*biovxFEvxs;
                    err = max(abs(newfevxpos(:)-newfevxposx(:)));
                    if GIVE_WARNINGS && (err > 2e-7)
                        warning( '%s: bookkeeping error 5: %g.', mfilename(), err );
                        xxxx = 1; %#ok<NASGU>
                    end
                    
                    
                    invbcs(:,:,j) = inv( febcs );
                end
            end
            oldvxbcs = oldVxBaryCoords( biovxi, : );
            
%             bc = baryCoordsN( biovxFEvxs, m.FEnodes(allabsfevxs(j,:,vxsfei),:) );
            
            
            newvxbcs = zeros( numNewFEsPerFE(vxsfei)+1, 4 );
            % newvxbcs will hold the bcs of the current vertex with respect
            % to each of the daughter FEs.

            for j=1:(numNewFEsPerFE(vxsfei)+1)
                newvxbcs(j,:) = oldvxbcs*invbcs(:,:,j);
                
                % CHECK: the new vcs and the new FE vertexes should give
                % the same location.
                newfe = allfes(vxsfei,j);
                newFEvxs = m.FEnodes( m.FEsets.fevxs(newfe,:), :);
                newvxpos = newvxbcs(j,:)*newFEvxs;
                err = max(abs(newvxpos-biovxpos));
                if GIVE_WARNINGS && (err > 2e-7)  % This one keeps happening, but not with larger errors.
                    warning( '%s: bookkeeping error 4: %g.', mfilename(), err );
                    xxxx = 1; %#ok<NASGU>
                end
            end
            [err,besti] = max( min( newvxbcs, [], 2 ) );
            oldgs = baryToGlobalCoords( oldVxFEMcell( biovxi ), oldVxBaryCoords( biovxi, : ), oldNodes, oldfevxs );
%             oldgs2 = oldcell3dcoords(biovxi,:);
            m.secondlayer.vxFEMcell( biovxi ) = allfes( vxsfei, besti );
            m.secondlayer.vxBaryCoords( biovxi, : ) = newvxbcs(besti,:);
            newgs = baryToGlobalCoords( allfes( vxsfei, besti ), newvxbcs(besti,:), m.FEnodes, m.FEsets.fevxs );
            errgs = newgs-oldgs;
            if max(abs(errgs)) > 0.01
                xxxx = 1; %#ok<NASGU>
            end
        end
        newCell3dcoords = baryToGlobalCoords( m.secondlayer.vxFEMcell, m.secondlayer.vxBaryCoords, m.FEnodes, m.FEsets.fevxs );
        bcserr = max(abs( oldCell3dcoords(:) - newCell3dcoords(:) ));
        if bcserr > 0.01
            xxxx = 1; %#ok<NASGU>
        end
    end
    
    % Now install the vertexes displaced by butterfly subdivision.
    m.FEnodes( surfaceedgesplits, : ) = surfacesplitvertexes;
    
    [m,~,~] = calcFEvolumes( m, unique(femapping(:)), true );
    m.FEconnectivity = connectivity3D( m );
end
