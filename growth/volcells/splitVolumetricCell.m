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
    
    TOL = 5e-4;
    
    % Set up some numberings.

    cellfaces = volcells.polyfaces{vci}; % Indexed by rel face, contains abs face.
    cellvxsi = unique( cell2mat( volcells.facevxs(cellfaces) ) ); % Indexed by rel vx, contains abs vx.
    cellvxspos = volcells.vxs3d( cellvxsi, : );
    if isempty(divcentre)
        divcentre = mean( cellvxspos, 1 );
    end
    vxdists = pointPlaneDistance( divcentre, divnormal, cellvxspos ); % Indexed by vertexes of vci.
    vxdists(abs(vxdists) < TOL) = 0;
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
    definitesides = edgesides ~= 0;
    splitedgescellmap = all(definitesides,2) & (edgesides(:,1) ~= edgesides(:,2)); % Indexed by local edge.
    splitedgeslist = celledgesi( splitedgescellmap ); % Absolute edge indexes.
    splitedgesmap = false( size(volcells.edgevxs,1) );
    splitedgesmap( splitedgeslist ) = true;
    numedgesplits = sum( splitedgescellmap );
    planeedges = all( edgesides==0, 2 );
    planevxs = unique( celledgevxs( edgesides==0 ) );
    
    % Make new vertexes and set them into the edges.
    
    % For every split edge we must make a new vertex.
    splitbcs = vxdists( relcelledgevxs( splitedgescellmap, : ) );
    splitbcs = [ -splitbcs(:,2), splitbcs(:,1) ];
    splitbcs = splitbcs ./ sum( splitbcs, 2 );
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
        if ~any( issplitedge )
            continue;
        end
        reind1 = cumsum( 1 + issplitedge );
        newfaceedges1 = zeros( reind1(end), 1 );
        newfaceedges1( reind1 ) = faceedges1;
        newissplitedge2 = false( 1, reind1(end) );
        newissplitedge2( reind1 ) = issplitedge;
        newissplitedge1 = newissplitedge2([2:end 1] );
        splitfaceedgesenses = volcells.edgevxs( faceedges1(issplitedge), 2 )~=facevxs1( issplitedge );
        % The two sides of the == should be the same pair of vertexes, in
        % the same or opposite order.

        % Insert the new edges.
        % SOMETHING WRONG HERE. We get zeros in edgeinserts1 and
        % edgeinserts2, which should not happen. They come from looking up
        % things in oldtonewedge
        edgeinserts1 = faceedges1( issplitedge );
        edgeinserts1( ~splitfaceedgesenses ) = oldtonewedge( edgeinserts1( ~splitfaceedgesenses ) );
        edgeinserts2 = faceedges1( issplitedge );
        edgeinserts2( splitfaceedgesenses ) = oldtonewedge( edgeinserts2( splitfaceedgesenses ) );
        if any(edgeinserts1==0) || any(edgeinserts2==0)
            timedFprintf( 'When splitting face %d, zero entries in edgeinserts1 or edgeinserts2.\n', fi );
            edgeinserts1
            edgeinserts2
            xxxx = 1;
        end
        newfaceedges1( newissplitedge1 ) = edgeinserts1;
        newfaceedges1( newissplitedge2 ) = edgeinserts2;
        foo = newedgevxs( edgeinserts1, : )==newedgevxs( edgeinserts2, : );
        ok_foo = all(~foo(:,1)) && all(foo(:,2));
        if ~ok_foo
            timedFprintf( 'When splitting face %d, edge check failed. Should be false in first column and true in second.\n', fi );
            foo
            xxxx = 1;
        end
        
        % Insert the new vertexes.
        insertedvxs = newedgevxs( edgeinserts1, : );
        newfacevxs1 = zeros( reind1(end), 1 );
        newfacevxs1( reind1 ) = facevxs1;
        newfacevxs1( newissplitedge1 ) = newfacevxs1( newissplitedge2 );
        newfacevxs1( newissplitedge2 ) = insertedvxs(:,2);
        
        newvolcells.facevxs{fi} = newfacevxs1;
        newvolcells.faceedges{fi} = newfaceedges1;
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
        xxxx = 1;
    end
    xxxx = 1;
    
    newwallvxsmap = vxsides==0; % Indexed by vertexes of vci, including the new vertexes.
    
    % Find the faces that are split, and split them.
    % A face is split if it contains at least two vertexes from newwallvxs,
    % and they are non-adjacent.
    numoldfaces = length(volcells.facevxs);
    facesplitedges = zeros( numoldfaces, 2 );
    splitfacesmap = false(numoldfaces,1);
    newfacevxs1 = cell(numoldfaces,1);
    newfacevxs2 = cell(numoldfaces,1);
    newfaceedges1 = cell(numoldfaces,1);
    newfaceedges2 = cell(numoldfaces,1);
    newedgevxs = zeros(numoldfaces,2);
    numfacesplits = 0;
    for relfi=1:length(cellfaces) % Relative face index.
        fi = cellfaces( relfi ); % Absolute face index.
        fiv = newvolcells.facevxs{fi}; % Absolute vertex indexes.
%         relfiv = relvxindex( fiv ); % Relative vertex indexes.
        fie = newvolcells.faceedges{fi}; % Absolute edge indexes.
%         relfie = reledgeindex( fie ); % Relative edge indexes.
        fivonplane = fiv > numoldvxs;
        fivonplane(~fivonplane) = newwallvxsmap( abstorelvxindex( fiv(~fivonplane) ) );
        numplanevxs = sum(fivonplane);
        if numplanevxs ~= 2
            % The face is not to be split.
            if numplanevxs > 2
                % This should never happen.
                timedFprintf( 'Face %d is cut %d times, should not exceed 2.\n', fi, numplanevxs );
            end
            continue;
        end
        if any(fivonplane & fivonplane([2:end 1]))
            % The vertexes are adjacent. The face is not split.
            continue;
        end
        
        fi1 = fi;
        fiv1 = fiv;
        
        % Make a new edge.
        numfacesplits = numfacesplits+1;
        fivis = find(fivonplane);
        facesplitedges(numfacesplits,:) = sort( fiv( fivonplane ) );
        splitfacesmap(fi) = true;
        newedgevxs(numfacesplits,:) = fiv( fivis );
        newedgei = size(newvolcells.edgevxs,1) + numfacesplits;
        
        % Split the face into two faces.
        newfacevxs1{numfacesplits} = fiv( fivis(1):fivis(2) );
        newfacevxs2{numfacesplits} = fiv( [ fivis(2):end 1:fivis(1) ] );
        newfaceedges1{numfacesplits} = [ fie( fivis(1):(fivis(2)-1) ); newedgei ];
        newfaceedges2{numfacesplits} = [ fie( [ fivis(2):end, 1:(fivis(1)-1) ] ); newedgei ];
        
        xxxx = 1;
    end
    facesplitedges( (numfacesplits+1):end, : ) = [];
    splitfaceslist = find( splitfacesmap );
    curnumfaces = length( newvolcells.facevxs );
    newfaceindexes = ((curnumfaces+1):(curnumfaces+numfacesplits))';
    facesplitmapping = zeros( numoldfaces, 1 );
    facesplitmapping( splitfacesmap ) = newfaceindexes;
    newvolcells.edgevxs = [ newvolcells.edgevxs; facesplitedges ];
    newfacevxs1( (numfacesplits+1):end ) = [];
    newfacevxs2( (numfacesplits+1):end ) = [];
    newfaceedges1( (numfacesplits+1):end ) = [];
    newfaceedges2( (numfacesplits+1):end ) = [];
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
%     pfs1 = newvolcells.polyfacesigns{vci};
%     pfs1 = [ pfs1; pfs1(splitfacesmap( newvolcells.polyfaces{vci} )) ];  % ERROR: pfs1 is 8*1 but splitfaceslist is above that.
%     newvolcells.polyfacesigns{vci} = pfs1;
%     newvolcells.polyfaces{vci} = [ newvolcells.polyfaces{vci}; newfaceindexes ];
    
    [ok,errs] = validVolcells( newvolcells );
    if ok
        timedFprintf( 'newvolcells is valid after splitting faces.\n' );
    else
        timedFprintf( 'newvolcells is invalid after splitting faces.\n' );
        xxxx = 1;
    end
    xxxx = 1;
    
    % ERROR HERE: what should newwalledgesmap be indexed by? The definition
    % here is not consistent with its use later. What we want
    % newwalledgeslist to be is the list of indexes of the edges of the new
    % face.
    
    % planeedges is a map of local edges.
    % To get a list of global face indexes, relfaceindex ...
    newwalledgeslist = [ ((size(newvolcells.edgevxs,1)-numfacesplits+1):size(newvolcells.edgevxs,1))'; celledgesi( planeedges ) ];
    newwalledgevxs = newvolcells.edgevxs(newwalledgeslist,:);
%     cycles = findCycles( newwalledgevxs );
    [cycle1,perm1] = findCycle1( newwalledgevxs );
    if isempty(cycle1)
        % Something went wrong.
        error( 'Cannot form new face from new edges and vertexes.' );
    end
    
    firstNewEdge = newwalledgeslist(1);
    firstSplitFaceOldHalf = splitfaceslist(1);
    firstSplitFaceNewHalf = newfaceindexes(1);
    firstSplitFaceOldEdges = newvolcells.faceedges{firstSplitFaceOldHalf};
    firstSplitFaceNewEdges = newvolcells.faceedges{firstSplitFaceNewHalf};
    locateFirstEdgeInFirstFace = find( firstSplitFaceOldEdges==firstNewEdge, 1 );
    if isempty(locateFirstEdgeInFirstFace)
        % Error.
        timedFprintf( 'Attempting to find sense of new cell wall, but first new edge does not occur in first new face.\n' );
        return;
    end
    firstVxOfFirstEdgeInFirstFace = newvolcells.facevxs{firstSplitFaceOldHalf}(locateFirstEdgeInFirstFace);
    newWallSameSenseAsFirstFaceOldHalf = find( newvolcells.edgevxs(firstNewEdge,:)==firstVxOfFirstEdgeInFirstFace, 1 ) == 2;
    
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
    newcellindex = oldnumcells + 1;
    
    newWallSenseForVol1 = (planesides( firstSplitFaceOldHalf ) < 0) ...
                          ~= (polyfaces1(firstSplitFaceOldHalf) ~= newWallSameSenseAsFirstFaceOldHalf );
    
    newvolcells.polyfaces{vci,1} = [ oldpolyfaces1( polyfaces1 ); newwallindex];
    newvolcells.polyfacesigns{vci,1} = [ oldpolysigns( polyfaces1 ); newWallSenseForVol1 ];
    newvolcells.polyfaces{newcellindex,1} = [ oldpolyfaces1( polyfaces2 ); newwallindex];
    newvolcells.polyfacesigns{newcellindex,1} = [ oldpolysigns( polyfaces2 ); ~newWallSenseForVol1 ];
    
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
    perm(1) = floor((firstedge2+1)/2);
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
