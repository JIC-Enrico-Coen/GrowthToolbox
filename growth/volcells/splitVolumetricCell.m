function newvolcells = splitVolumetricCell( volcells, vci, divcentre, divnormal )
%volcells = splitVolumetricCell( volcells, vci, divcentre, divnormal )
%   Split the volumetric cell indexed by VCI through the plane that passes
%   through the point DIVCENTRE and whose normal vector is DIVNORMAL.

%             vxs3d: [12×3 double]
%           facevxs: {8×1 cell}
%         polyfaces: {[1 2 3 4 5 6 7 8]}
%     polyfacesigns: {[1 1 1 1 1 1 1 1]}
%           edgevxs: [18×2 double]
%         faceedges: {8×1 cell}
%              vxfe: [12×1 double]
%              vxbc: [12×4 double]

% 1. For every vertex of cell VCI, determine which side of the plane it is
% on. With a certain tolerance it may be marked as being on the plane.

    newvolcells = volcells;
    [ok,errs] = validVolcells( newvolcells );
    if ok
        timedFprintf( 'Initial volcells is valid.\n' );
    else
        timedFprintf( 'Initial volcells is invalid.\n' );
        xxxx = 1;
    end
    
    TOLVXS = 0; % 5e-4;
    TOLEDGES = 0.01;
    
    % Set up some numberings.

    cellfaces = volcells.polyfaces{vci}; % Indexed by rel face, contains abs face.
    cellvxsi = unique( cell2mat( volcells.facevxs(cellfaces) ) ); % Indexed by rel vx, contains abs vx.
    cellvxspos = volcells.vxs3d( cellvxsi, : );
    if isempty(divcentre)
        divcentre = mean( cellvxspos, 1 );
    end
    vxdists = pointPlaneDistance( divcentre, divnormal, cellvxspos ); % Indexed by vertexes of vci.
    vxdists(abs(vxdists) <= TOLVXS) = 0;
    vxsides = sign(vxdists);
    celledgesi = unique( cell2mat( volcells.faceedges(cellfaces) ) );
    celledgevxs = volcells.edgevxs(celledgesi,:);
    abstorelvxindex = zeros( size(volcells.vxs3d,1), 1 );
    abstorelvxindex( cellvxsi ) = (1:length(cellvxsi))';
    abstoreledgeindex = zeros( size(volcells.edgevxs,1), 1 );
    abstoreledgeindex( celledgesi ) = (1:length(celledgesi))';
    abstorelfaceindex = zeros( length(volcells.facevxs), 1 );
    abstorelfaceindex( volcells.polyfaces{vci} ) = (1:length(volcells.polyfaces{vci}))';
    
% 2. For each edge of the cell, classify it with respect to the division plane as:
%   (a) both ends on one side
%   (b) both ends on opposite sides
%   (c) one end on the plane
%   (d) both ends on the plane

    relcelledgevxs = abstorelvxindex( celledgevxs );
    
    edgesides = vxsides( relcelledgevxs );
    edgesidesSAVE = edgesides;
    definitesides = edgesides ~= 0;
    definitesidesSAVE = definitesides;
    splitedgescellmap = all(definitesides,2) & (edgesides(:,1) ~= edgesides(:,2)); % Indexed by local edge.
    splitedgescellmapSAVE = splitedgescellmap;

    splitbcs = reshape( vxdists( relcelledgevxs( splitedgescellmap, : ) ), [], 2 ); % Correcting for Matlab idiocy around arrays.
    splitbcs = [ -splitbcs(:,2), splitbcs(:,1) ];
    splitbcs = splitbcs ./ sum( splitbcs, 2 ); % Indexed by split edges.
    splitbcsSAVE = splitbcs;

    snapbcs = splitbcs <= TOLEDGES; % Indexed by split edges.
%     snapedges = any( snapbcs, 2 ); % Indexed by split edges.
%     if any( snapedges )
%         xxxx = 1;
%     end
%     splitbcs( snapbcs(:,1), 1 ) = 0;
%     splitbcs( snapbcs(:,1), 2 ) = 1;
%     splitbcs( snapbcs(:,2), 1 ) = 0;
%     splitbcs( snapbcs(:,2), 2 ) = 1;

    foo = relcelledgevxs( splitedgescellmap, : );
    snaprelvxsi = unique( foo( snapbcs(:,[2 1]) ) ); % Relative vx indexes of the vertexes snapped to the splitting plane.
    snaprelvxsmap = false( length(cellvxsi), 1 );
    snaprelvxsmap( snaprelvxsi ) = true;
    unsplitedgemap = any( snaprelvxsmap( relcelledgevxs ), 2 );
    
    vxsides( snaprelvxsi ) = 0;
%     splitbcs( snapedges, : ) = [];
    
    edgesides = vxsides( relcelledgevxs ); % Indexed by relative edge index.
    definitesides = edgesides ~= 0;
    splitedgescellmap = all(definitesides,2) & (edgesides(:,1) ~= edgesides(:,2)); % Indexed by local edge.

    splitbcs = reshape( vxdists( relcelledgevxs( splitedgescellmap, : ) ), [], 2 ); % Correcting for Matlab idiocy around arrays.
    splitbcs = [ -splitbcs(:,2), splitbcs(:,1) ];
    splitbcs = splitbcs ./ sum( splitbcs, 2 ); % Indexed by split edges.
%     splitedgescelllist = find( splitedgescellmap ); % Values are relative edge indexes.
%     splitedgescellmap( splitedgescelllist(snapedges) ) = false;
    
    
    
    
    
    splitedgeslist = celledgesi( splitedgescellmap ); % Absolute edge indexes.
    splitedgesmap = false( size(volcells.edgevxs,1), 1 ); % Indexed by absolute edge.
    splitedgesmap( splitedgeslist ) = true;
    planereledges = all( edgesides==0, 2 ); % Indexed by relative edge.
    planeabsedges = celledgesi( planereledges );
    splitedgesmap( planeabsedges ) = false;
    
    % Make new vertexes and set them into the edges.
    
    addedvxs3d = cellvxspos( relcelledgevxs( splitedgescellmap, 1 ), : ) .* splitbcs(:,1) + cellvxspos( relcelledgevxs( splitedgescellmap, 2 ), : ) .* splitbcs(:,2);
    newvxs3d = [ volcells.vxs3d; addedvxs3d ];
    numoldvxs = size( volcells.vxs3d, 1 );
    numnewvxs = size( addedvxs3d, 1 );
    newvxsi = ((numoldvxs+1):(numoldvxs+numnewvxs))';
    numvxsvci = length(vxsides);
    vxsides = [ vxsides; zeros( numnewvxs, 1 ) ]; % vxsides is indexed by relative indexes of vci after edge-splitting.
    abstorelvxindex = [ abstorelvxindex; ((numvxsvci+1):(numvxsvci+numnewvxs))' ];
    
    newvolcells.vxs3d = newvxs3d;
    newvolcells.vxfe = [ newvolcells.vxfe; uint32( zeros( numnewvxs, 1 ) ) ];
    newvolcells.vxbc = [ newvolcells.vxbc; zeros( numnewvxs, 4 ) ];
    
    % Each split edge must be replaced by two edges.
    newedges1 = [ celledgevxs(splitedgescellmap,1), newvxsi ];
    newedges2 = [ celledgevxs(splitedgescellmap,2), newvxsi ];
    newedgevxs = [ volcells.edgevxs; newedges2 ]; % Indexed by absolute edge.
    newedgevxs( splitedgeslist, : ) = newedges1;
    
    numoldedges = size( volcells.edgevxs, 1 );
    numnewedges = numnewvxs;
    newedgesi = ((numoldedges+1):(numoldedges+numnewedges))';
    oldtonewedge = zeros( numoldedges, 1 );
    oldtonewedge( splitedgeslist ) = newedgesi;
    
    newvolcells.edgevxs = newedgevxs;
    
    % Fields now valid: vxs3d, edgevxs.

    % Each face that includes any of the split edges must have its split
    % edges replaced by the edges it splits into. Its vertex list must be
    % similarly augmented.
    for fi=1:length(newvolcells.facevxs)
        facevxs1 = volcells.facevxs{fi}; % Absolute vertex indexes.
        faceedges1 = volcells.faceedges{fi}; % Absolute edge indexes.
        issplitedge = splitedgesmap( faceedges1 ); % Indexed by the edges of face fi.
        if (vci==4) && (fi==26)
            xxxx = 1;
        end
        if ~any( issplitedge )
            continue;
        end
        reind1 = cumsum( 1 + issplitedge );
        newfaceedges1 = zeros( reind1(end), 1 );
        newfaceedges1( reind1 ) = faceedges1;
        newissplitedge2 = false( 1, reind1(end) );
        newissplitedge2( reind1 ) = issplitedge;
        newissplitedge1 = newissplitedge2([2:end 1] );
        splitfaceedgesenses = volcells.edgevxs( faceedges1(issplitedge), 2 ) ~= facevxs1( issplitedge );
        % The two sides of the == should be the same pair of vertexes, in
        % the same or opposite order.

        % Insert the new edges.
        edgeinserts1 = faceedges1( issplitedge );
        edgeinserts1( ~splitfaceedgesenses ) = oldtonewedge( edgeinserts1( ~splitfaceedgesenses ) );
        edgeinserts2 = faceedges1( issplitedge );
        edgeinserts2( splitfaceedgesenses ) = oldtonewedge( edgeinserts2( splitfaceedgesenses ) );
        if any(edgeinserts1==0) || any(edgeinserts2==0)
            timedFprintf( 'When splitting face %d, zero entries in edgeinserts1 or edgeinserts2.\n', fi );
            edgeinserts1
            edgeinserts2
            error( 'When splitting face %d, zero entries in edgeinserts1 or edgeinserts2.', fi );
            xxxx = 1;
        end
        newfaceedges1( newissplitedge1 ) = edgeinserts1;
        newfaceedges1( newissplitedge2 ) = edgeinserts2;
        foo = newedgevxs( edgeinserts1, : )==newedgevxs( edgeinserts2, : );
        ok_foo = all(~foo(:,1)) && all(foo(:,2));
        if ~ok_foo
            timedFprintf( 'When splitting face %d, edge check failed. Should be false in first column and true in second.\n', fi );
            error( 'When splitting face %d, edge check failed. Should be false in first column and true in second.', fi );
            xxxx = 1;
        end
        
        % Insert the new vertexes.
        insertedvxs = newedgevxs( edgeinserts1, : );
        newfacevxs1 = zeros( reind1(end), 1 );
        newfacevxs1( reind1 ) = facevxs1;
        newfacevxs1( newissplitedge1 ) = newfacevxs1( newissplitedge2 );
        newfacevxs1( newissplitedge2 ) = insertedvxs(:,2);
        

        
        
        fee = [ newfacevxs1, newfacevxs1([2:end 1]) ];
        edgesense = newvolcells.edgevxs( newfaceedges1, 1 )==newfacevxs1;
        fee( ~edgesense, : ) = fee( ~edgesense, [2 1] );
        agreement = fee==newvolcells.edgevxs( newfaceedges1, : );
        cycleerrors = sum(~agreement(:));
        if cycleerrors > 0
            timedFprintf( 1, 3, 'Face %d has %d errors in cyclicity.\n', ...
                fi, cycleerrors );
            xxxx = 1;
        end
        
        
        
        
        
        
        newvolcells.facevxs{fi} = newfacevxs1;
        newvolcells.faceedges{fi} = newfaceedges1;
    end
    
    if (vci==4)
        xxxx = 1;
    end
    % Fields now valid: vxs3d, edgevxs, facevxs, faceedges.
    
    % Fields now valid: vxs3d, edgevxs, facevxs, faceedges.
    % newvolcells should now be a valid volcells structure. The required
    % edges have been split, but not yet the faces or the cells.
    [ok,errs] = validVolcells( newvolcells );
    if ok
        timedFprintf( 'newvolcells is valid after splitting edges.\n' );
    else
        timedFprintf( 'newvolcells is invalid after splitting edges.\n' );
        error( 'newvolcells is invalid after splitting edges.' );
        xxxx = 1;
    end
    xxxx = 1;
    
%     newwallvxsmap = vxsides==0; % Indexed by vertexes of vci, including the new vertexes.
    
    % Find the faces that are split, and split them.
    % A face is split if it contains at least two non-adjacent zero vertexes.
    numoldfaces = length(volcells.facevxs);
    facesplitedgevxs = zeros( numoldfaces, 2 ); % Indexed by absolute face index and edge end.
    splitfacesmap = false(numoldfaces,1); % Indexed by absolute face index.
    newfacevxs1 = cell(numoldfaces,1); % Indexed by absolute face index.
    newfacevxs2 = cell(numoldfaces,1); % Indexed by absolute face index.
    newfaceedges1 = cell(numoldfaces,1); % Indexed by absolute face index.
    newfaceedges2 = cell(numoldfaces,1); % Indexed by absolute face index.
    
    % Determine which faces should be split.
    for relfi=1:length(cellfaces) % Relative face index.
        fi = cellfaces( relfi ); % Absolute face index.
        fiv = newvolcells.facevxs{fi}; % Absolute vertex indexes.
        relfiv = abstorelvxindex( fiv ); % Relative vertex indexes.
        fivsides = vxsides( relfiv ); % Indexed by vertexes of current face.
        splitfacesmap(fi) = any(fivsides == -1) && any(fivsides == 1);
    end
    
    % Split the faces.
    numfacesplitsdone = 0;
%     excludedvxsi = false( size( newvolcells.vxs3d, 1 ), 1 );
    for relfi=1:length(cellfaces) % Relative face index.
        fi = cellfaces( relfi ); % Absolute face index.
        if ~splitfacesmap(fi)
            continue;
        end
        fiv = newvolcells.facevxs{fi}; % Absolute vertex indexes.
        relfiv = abstorelvxindex( fiv ); % Relative vertex indexes.
        fivsides = vxsides( relfiv ); % Indexed by vertexes of current face.
        
        if sum( fivsides==0 ) > 2
            xxxx = 1;
        end
        
        nfv = length(fiv);
        fie = newvolcells.faceedges{fi}; % Absolute edge indexes.
%         relfie = reledgeindex( fie ); % Relative edge indexes.
        
        fivsides1 = fivsides( [2:end 1] );
        transitions = 3*fivsides + fivsides1; % Ranges from -4 to 4.
        transcounts = sumArray( transitions+5, ones(nfv,1), [9,1] );
        if ~all(transcounts([3 7])==0)
            % Transition between -1 and 1 in either direction.
            % Should never happen, because those edges would have been
            % split and a zero vertex inserted between them.
            timedFprintf( 'Transition between -1 and 1 for face %d.\n', fi );
            fivsides'
            transcounts'
            xxxx = 1;
            continue;
        elseif ~all(transcounts([2 4 6 8])==1)
            % Too many transitions to or from 0.
            % Should never happen.
            timedFprintf( 'Too many 0/1 or 0/-1 transitions for face %d.\n', fi );
            fivsides'
            transcounts'
            xxxx = 1;
        end
        
        z1start = mod( find(transitions == -3,1), nfv ) + 1;
        z1end = find(transitions == 1,1);
        z2start = mod( find(transitions == 3,1), nfv ) + 1;
        z2end = find(transitions == -1,1);
        
        % If z1start==z1end then we select that vertex. Similarly for
        % z2start and z2end. We only have complications when either set
        % contains more than one element.
        
        % As a first attempt, try selecting the lowest-numbered vertex.
        [vx1,vxi1] = minWithinSegment( fiv, z1start, z1end );
        [vx2,vxi2] = minWithinSegment( fiv, z2start, z2end );
%         [vx1,vxi1] = minWithinSegment1( fiv, z1start, z1end, excludedvxsi(fiv) );
%         [vx2,vxi2] = minWithinSegment1( fiv, z2start, z2end, excludedvxsi(fiv) );
        
        if isempty(vx1) || isempty(vx2)
            error( 'Excluded too many vertexes.' );
        end
        % vx1 and vx2 are absolute vertex indexes.
        % vxi1 and vxi2 are indexes of these vertexes in the face fi.
        fivis = sort( [vxi1 vxi2] );
        
        if (z1start ~= z1end) || (z2start ~= z2end)
            timedFprintf( 'Warning: multiple candidate split points:\n    rel [%d %d] [%d %d]\n    abs [%d %d] [%d %d]\n', ...
                z1start, z1end, z2start, z2end, fiv([z1start, z1end, z2start, z2end]) );
%             excludedfacevxs = fivsides==0; % Indexed by vertexes of current face.
%             excludedfacevxs( fivis ) = false;
%             excludedvxsi( fiv ) = excludedfacevxs;  % Indexed by absolute vertexes.
            xxxx = 1;
        end
        
        
        
        fi1 = fi;
        fiv1 = fiv;
        
        % Make a new edge.
        numfacesplitsdone = numfacesplitsdone+1;
        facesplitedgevxs(numfacesplitsdone,:) = sort( [vx1 vx2] );
        newedgei = size(newvolcells.edgevxs,1) + numfacesplitsdone;
        
        % Split the face into two faces.
        newfacevxs1{numfacesplitsdone} = fiv( fivis(1):fivis(2) );
        newfacevxs2{numfacesplitsdone} = fiv( [ fivis(2):end 1:fivis(1) ] );
        newfaceedges1{numfacesplitsdone} = [ fie( fivis(1):(fivis(2)-1) ); newedgei ];
        newfaceedges2{numfacesplitsdone} = [ fie( [ fivis(2):end, 1:(fivis(1)-1) ] ); newedgei ];
        
        xxxx = 1;
    end
    facesplitedgevxs( (numfacesplitsdone+1):end, : ) = [];
    curnumfaces = length( newvolcells.facevxs );
    newfaceindexes = ((curnumfaces+1):(curnumfaces+numfacesplitsdone))';
    facesplitmapping = zeros( numoldfaces, 1 );  % Indexed by absolute face index. Values are absolute face indexes.
    facesplitmapping( splitfacesmap ) = newfaceindexes;
    newvolcells.edgevxs = [ newvolcells.edgevxs; facesplitedgevxs ];
    newfacevxs1( (numfacesplitsdone+1):end ) = [];
    newfacevxs2( (numfacesplitsdone+1):end ) = [];
    newfaceedges1( (numfacesplitsdone+1):end ) = [];
    newfaceedges2( (numfacesplitsdone+1):end ) = [];
    newvolcells.facevxs( splitfacesmap ) = newfacevxs1;
    newvolcells.facevxs = [ newvolcells.facevxs; newfacevxs2 ];
    newvolcells.faceedges( splitfacesmap ) = newfaceedges1;
    newvolcells.faceedges = [ newvolcells.faceedges; newfaceedges2 ];
    % Insert new faces into all volumetric cells.
    for vi=1:length(newvolcells.polyfaces)
        pf = newvolcells.polyfaces{vi};
        spfs = splitfacesmap(pf);
        newvolcells.polyfaces{vi} = [ pf; facesplitmapping( pf( spfs ) ) ];
        ps = newvolcells.polyfacesigns{vi};
        newvolcells.polyfacesigns{vi} = [ ps; ps( spfs ) ];
    end
    
    [ok,errs] = validVolcells( newvolcells );
    if ok
        timedFprintf( 'newvolcells is valid after splitting faces.\n' );
    else
        timedFprintf( 'newvolcells is invalid after splitting faces.\n' );
        xxxx = 1;
    end
    xxxx = 1;
    
%     planeedges1 = planeedges;
%     planeedges1( any( excludedvxsi( celledgevxs( planeedges, : ) ), 2 ) ) = false;
    newwalledgeslist = [ ((size(newvolcells.edgevxs,1)-numfacesplitsdone+1):size(newvolcells.edgevxs,1))'; celledgesi( planereledges ) ];
    newwalledgevxs = newvolcells.edgevxs(newwalledgeslist,:);
%     cycles = findCycles( newwalledgevxs );
    [cycle1,perm1] = findCycle1( newwalledgevxs );
    if isempty(cycle1)
        % Something went wrong.
        error( 'Cannot form new face from new edges and vertexes.' );
    end
    
    newwallvxs = cycle1;
    newwalledges = newwalledgeslist( perm1 );
    % Add this face to newvolcells.facevxs, newvolcells.faceedges.
    newwallindex = length( newvolcells.facevxs ) + 1;
    newvolcells.facevxs{newwallindex} = newwallvxs;
    newvolcells.faceedges{newwallindex} = newwalledges;
    
    % Divide the original polyhedron into two.
    planesides = zeros( length(newvolcells.polyfaces{vci}), 1 );
    for relfi=1:length(newvolcells.polyfaces{vci})
        fi = newvolcells.polyfaces{vci}(relfi);
        planevxsides = vxsides( abstorelvxindex( newvolcells.facevxs{fi} ) );
        if all(planevxsides==0)
            planesides(relfi) = 0;
        elseif all(planevxsides <= 0)
            planesides(relfi) = -1;
        elseif all(planevxsides >= 0)
            planesides(relfi) = 1;
        else
            timedFprintf( 'Invalid face (rel %d/abs %d) straddles splitting plane.\n', relfi, fi );
            planesides(relfi) = 2;
            xxxx = 1;
        end
    end
    oldnumcells = length( newvolcells.polyfaces );
    polyfaces1 = planesides <= 0;
    polyfaces2 = planesides >= 0;
    oldpolyfaces1 = newvolcells.polyfaces{vci};
    oldpolysigns = newvolcells.polyfacesigns{vci};
    newpolyfaces1 = oldpolyfaces1( polyfaces1 );
    newpolyfaces2 = oldpolyfaces1( polyfaces2 );
    newpolyfacesigns1 = oldpolysigns( polyfaces1 );
    newpolyfacesigns2 = oldpolysigns( polyfaces2 );
    newcellindex = oldnumcells + 1;
    
    
    
    
    edgeToTest = 2;
    firstNewEdge = newwalledges(edgeToTest);
    for npfi=1:length( newpolyfaces1 )
        fi = newpolyfaces1(npfi);
        fes = newvolcells.faceedges{fi};
        fese = find( fes==firstNewEdge, 1 );
        if ~isempty( fese )
            break;
        end
    end
    if isempty( fese )
        % error
        error( 'Cannot locate firstNewEdge %d in something or other.', firstNewEdge );
        xxxx = 1;
    else
        % npfi: rel face index of a face of volcell vci that contains
        % firstNewEdge.
        % fi: abs face index of a face of volcell vci that contains
        % firstNewEdge.
        % fes: the edge list of that face.
        % fese: index of firstNewEdge in fes.
        vi1a = fese;
        vi2a = mod(vi1a,length(fes)) + 1;
        edgevxs1 = newvolcells.facevxs{fi}([vi1a,vi2a]);
        vi1b = edgeToTest;
        vi2b = mod( edgeToTest, length(newwallvxs) ) + 1;
        edgevxs2 = newwallvxs([vi1b,vi2b]);
        fisense = newpolyfacesigns1(npfi);
        if all(edgevxs1==edgevxs2)
            newWallSenseForVol1 = ~fisense;
        elseif all(edgevxs1==edgevxs2([2 1]))
            newWallSenseForVol1 = fisense;
        else
            % error
            error( 'Cannot determine sense of new wall.' );
            xxxx = 1;
        end
    end
    
    
%     firstSplitFaceOldHalf = splitfaceslist(1);
%     firstSplitFaceNewHalf = newfaceindexes(1);
%     firstSplitFaceOldEdges = newvolcells.faceedges{firstSplitFaceOldHalf};
%     firstSplitFaceNewEdges = newvolcells.faceedges{firstSplitFaceNewHalf};
%     locateFirstEdgeInFirstFace = find( firstSplitFaceOldEdges==firstNewEdge, 1 );
%     if isempty(locateFirstEdgeInFirstFace)
%         % Error.
%         timedFprintf( 'Attempting to find sense of new cell wall, but first new edge does not occur in first new face.\n' );
%         return;
%     end
%     firstVxOfFirstEdgeInFirstFace = newvolcells.facevxs{firstSplitFaceOldHalf}(locateFirstEdgeInFirstFace);
%     newWallSameSenseAsFirstFaceOldHalf = find( newvolcells.edgevxs(firstNewEdge,:)==firstVxOfFirstEdgeInFirstFace, 1 ) == 2;
    
%     newWallSenseForVol1 = (planesides( firstSplitFaceOldHalf ) < 0) ...
%                           ~= (polyfaces1(firstSplitFaceOldHalf) ~= newWallSameSenseAsFirstFaceOldHalf );
    
    newvolcells.polyfaces{vci,1} = [ newpolyfaces1; newwallindex ];
    newvolcells.polyfacesigns{vci,1} = [ newpolyfacesigns1; newWallSenseForVol1 ];
    newvolcells.polyfaces{newcellindex,1} = [ newpolyfaces2; newwallindex ];
    newvolcells.polyfacesigns{newcellindex,1} = [ newpolyfacesigns2; ~newWallSenseForVol1 ];
    
    % After returning we will need to compute vxfe and vxbc for the new
    % vertexes. These have been filled in as zero.
    [ok,errs] = validVolcells( newvolcells );
    if ok
        timedFprintf( 'newvolcells is valid after splitting polyhedron.\n' );
    else
        timedFprintf( 'newvolcells is invalid after splitting polyhedron.\n' );
        xxxx = 1;
    end
    xxxx = 1;
end

function [cycle,perm] = findCycle1( edges )
    cycle = [];
    perm = [];
    if isempty(edges)
        return;
    end
    [edges1,edgeperm] = sortrows( [ [ edges; edges(:,[2 1]) ], repmat( (1:size(edges,1))', 2, 1 ) ] );
    firstedge2 = find( edgeperm==1, 1 );
    vxs = edges1(1:2:end,1);
    vxscheck = edges1(2:2:end,1);
    if any( vxs ~= vxscheck )
        timedFprintf( 'findCycle1: edges do not form a cycle.\n' );
        return;
    end
    
    vxis = [ binsearchall( vxs, edges1(:,[1 2]) ), edges1(:,3) ];
    
    cycle = zeros(length(vxs),1);
    perm = zeros(length(vxs),1);
    nextEdge2 = firstedge2;
    prevVx = vxis(nextEdge2,1);
    curVx = vxis(nextEdge2,2);
    cycle([1 2]) = [ prevVx curVx ];
    perm(1) = vxis( firstedge2, 3 ); % floor((firstedge2+1)/2);
    vxis(nextEdge2,:) = 0;
    ci = 2;
    iters = 0;
    while iters < length(vxs)
        nextEdge2 = curVx*2;
        if vxis(nextEdge2,2)==prevVx
            nextEdge2 = nextEdge2-1;
        end
        nextVx = vxis(nextEdge2,2);
        perm(ci) = vxis(nextEdge2,3);
        if nextVx==cycle(1)
            break;
        end
        if nextVx==0
            timedFprintf( 'findCycle1: edges do not form a cycle.\n' );
            cycle = [];
            perm = [];
            return;
        end
        ci = ci+1;
        cycle(ci) = nextVx;
        prevVx = curVx;
        curVx = nextVx;
        vxis(nextEdge2,[1 2]) = 0;
        iters = iters+1;
        xxxx = 1;
    end
    cycle = vxs(cycle);
end

function [vi,ai] = minWithinSegment( a, segstart, segend )
    if segstart <= segend
        v = a( segstart:segstart );
    else
        v = a( [segstart:end 1:segstart] );
    end
    [vi,ai] = min( v );
    if segstart <= segend
        ai = ai + segstart - 1;
    else
        ai = mod1( ai + segstart - 1, length(a) );
    end
end

function v = getSegment( a, segstart, segend )
    len = length(a);
    segstart = mod1( segstart, len );
    segend = mod1( segend, len );
    if segstart <= segend
        v = a( segstart:segstart );
    else
        v = a( [segstart:end 1:segstart] );
    end
end

function [vi,ai] = minWithinSegment1( a, segstart, segend, excludedmap )
    len = length(a);
    invalidValue = 1 + max(a);
    a( excludedmap ) = invalidValue;
    v = getSegment( a, segstart, segend );
    if any( v==invalidValue )
        xxxx = 1;
    end
    [vi,ai] = min( v );
    ai = ai + segstart - 1;
    ai = mod1( ai, len );
end

function [wallvxs,walledges,wallarea] = trySplit( facevxs, faceedges, edgevxs, vxs3d )
end

