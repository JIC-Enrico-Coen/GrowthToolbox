function m = makeSpaceAtBioVertexes( m, vis, amount, edgeminlength, pullinratio )
%m = makeSpaceAtBioVertexes( m, vis, amount )
%   Given a list of vertexes of the bio layer, and an "amount" of internal
%   space to be created around those vertexes, modify the bio layer
%   accordingly.  The amount can be specified per vertex or as a single
%   value to be applied to all.
%
%   At present, the "amount" is taken to mean the absolute length of the
%   portion of an edge that is ripped.  The relation between this and the
%   increase in area of all the air spaces is complex.

    if numel(amount)==1
        amount = amount + zeros(size(vis));
    end
    if nargin < 4
        edgeminlength = 0;
    end
    if nargin < 5
        pullinratio = 0.1;
    end
    amount = max( 0, amount );
    if all(amount==0)
        return;
    end
    
%     fprintf( 1, '%s: ', mfilename() );
%     fprintf( 1, ' %d', vis );
%     fprintf( 1, '\n' );

    % For each vertex in the list, determine its neighbouring cells and
    % edges.
    
    numallvxs = length( m.secondlayer.vxFEMcell );
    numedges = size( m.secondlayer.edges, 1 );
    edgeenddata = [ [ (1:numedges)'; (1:numedges)' ],  [ m.secondlayer.edges; m.secondlayer.edges(:,[2 1 4 3]) ] ];
    edgeenddata = sortrows( edgeenddata( :, [2 1 4 5 3] ) );
    edgeenddata(edgeenddata<0) = 0;
    % The rows of edgeenddata have the form [v1 e c1 c2 v2], where e is an
    % edge from v1 to v2, and c1 and c2 are the cells on either side of the
    % edge.  All rows for a given vertex v1 occur together.
    
    ends = [ find( edgeenddata( 1:(end-1), 1 ) ~= edgeenddata( 2:end, 1 ) ); size(edgeenddata,1) ];
    starts = [ 1; 1+ends(1:(end-1)) ];
    % Length of starts and of ends should equal the number of vertexes.
    
    % We are only interested in vis.
    vstarts = starts(vis);
    vends = ends(vis);
    
    % We only want vertexes with arity at least three.
    arityMinusOne = vends-vstarts;
    okverts = arityMinusOne >= 2;
    vis = vis(okverts);
    vstarts = vstarts(okverts);
    vends = vends(okverts);
    
    % Now build a list of edge-ends to rip.
    allrips = zeros(0,5,'int32');
    allrips_n = 0;
    ripstarts = zeros(0,1,'int32');
    ripstarts_n = 0;
    ripends = zeros(0,1,'int32');
    ripends_n = 0;
    for i=1:length(vis)
        thisenddata = edgeenddata( vstarts(i):vends(i), : ); % Rows are v1, edge, c1, c2, v2.
        
        % Rip only interior edges.
        rippable = ~any( thisenddata(:,[3 4]) <= 0, 2 );
        rips = thisenddata( rippable, : );
%         ripstarts(end+1) = size(allrips,1)+1;
%         allrips = [ allrips; rips ];
%         ripends(end+1) = size(allrips,1);
%         ripamounts = [ ripamounts; amount(i)+zeros(vends(i)-vstarts(i)+1,1) ];
        
        
        ripstarts_n = ripstarts_n + 1;
        ripstarts( ripstarts_n ) = allrips_n+1;
        
        allrips( (allrips_n+1):(allrips_n+size(rips,1)), : ) = rips;
        allrips_n = allrips_n + size(rips,1);
        
        ripends_n = ripends_n + 1;
        ripends(ripends_n) = allrips_n;
    end
    allrips( (allrips_n+1):end, : ) = [];
    ripstarts( (ripstarts_n+1):end ) = [];
    ripends( (ripends_n+1):end ) = [];
    
    % Now we must rip the edges.
    % Two special cases to handle: when an edge is ripped from both ends
    % and comes apart along its whole length, and when an edge is ripped
    % from one end, and comes apart all the way to the vertex at the other
    % end.
    
    % Deal with things vertex by vertex.
    % The number of new vertexes is
    curnumvxs = length(m.secondlayer.vxFEMcell);
    curnumedges = size(m.secondlayer.edges,1);
    vertexPlacementData = zeros( numallvxs, 7 );
            % Each row contains the origin position, target position,
            % and relative distance to move towards the target.
    vertexNeighbourData = zeros( numallvxs, 4, 'int32' );
            % Each row contains the origin vertex index, the target
            % vertex index, the index of the interpolated vertex, and the
            % edge.
    vertexData_n = 0;
    for i=1:length(vis)
        newedgevxlist = [];
        edgestoupdate = [];
        newedges = [];
        vi = vis(i);
        vrips = allrips( ripstarts(i):ripends(i), : );
        nrips = size(vrips,1);
        if nrips==0
            fprintf( 1, 'Cannot make space at vertex %d.\n', vi );
            continue;
        end
        
        eed = edgeenddata( vstarts(i):vends(i), [2 3 4] );
        numempty = sum( sum( eed <= 0 ) );
        eed(eed<=0) = (-1):(-1):(-numempty);
        [ecchain,perm] = makechains( eed );
        eed1 = edgeenddata( vstarts(i):vends(i), : );
        eed1 = eed1(perm,:);
        % ecchain(1,:) is a list of cells.
        % ecchain(2,:) is a list of edges.
        % The edge in place i joins the cell
        % Look for 0 or -1 in ecchain(1,:).
        spaces = find( ecchain(1,:) <= 0 );
        numspaces = length(spaces)/2;
        
        switch numspaces
            case 0
%                 fprintf( 1, 'Creating new space at vertex %d.\n', vi );
                % Rip all of the edges.
                numvxsinvolved = nrips;
                numnewvxs = nrips-1;
                numnewedges = nrips;
                newvxs = [ vi; ((curnumvxs+1):(curnumvxs+numnewvxs))' ];
                newedgevxlist = newvxs;
                edgestoupdate = ecchain(2,[end 1:(end-1)]);
                curnumvxs = curnumvxs + numnewvxs;
                newedges = (curnumedges+1):(curnumedges+numnewedges);
                curnumedges = curnumedges + numnewedges;
                rippededges = (vstarts(i):vends(i))';
                rippededges = rippededges( perm );
                rippededges = rippededges( [end 1:(end-1)] );
                othervxs = edgeenddata( rippededges, 5 );
                origin = repmat( m.secondlayer.cell3dcoords(vi,:), length(othervxs), 1 );
                delta = m.secondlayer.cell3dcoords(othervxs,:) - origin;
                d = sqrt(sum(delta.^2,2));
                realamount = min(d,amount(i));
                relativeamount = realamount./d;
%                 newvxspos = origin + delta .* repmat( relativeamount, 1, 3 );
%                 m.secondlayer.cell3dcoords( newvxs, : ) = newvxspos;
                nedges = size(ecchain,2);
                for j=1:nedges
                    c1 = ecchain(1,j);
                    nv1 = newvxs(j);
                    nv2 = newvxs(1+mod(j,nedges));
                    insertEdgeIntoCell( c1, vi, nv1, nv2, newedges(j) );
                end
                vnrange = (vertexData_n+1):(vertexData_n+numvxsinvolved);
                vertexNeighbourData(vnrange,:) = [ vi+zeros(length(othervxs),1,'int32'), othervxs, newvxs, edgeenddata(rippededges,2) ];
                vertexPlacementData(vnrange,:) = [ origin, delta, relativeamount ]; % position of endpoints and barycentric coordinate.
                vertexData_n = vertexData_n+numvxsinvolved;
                m.secondlayer.vxFEMcell(newvxs) = m.secondlayer.vxFEMcell(vi);
                m.secondlayer.vxBaryCoords(newvxs,:) = repmat( m.secondlayer.vxBaryCoords(vi,:), numvxsinvolved, 1 ); % [0 0 0];
                m.secondlayer.cell3dcoords(newvxs,:) = repmat( m.secondlayer.cell3dcoords(vi,:), numvxsinvolved, 1 ); % [0 0 0];
            case 1
%                 fprintf( 1, 'Expanding space at vertex %d.\n', vi );
                % Rip all except the first and last of the edges.
                if nrips==0
                    % Something odd.
                    fprintf( 1, 'Cannot make space at vertex %d: numspaces==1, nrips==0.\n', vi );
                    xxxx = 1;
                elseif nrips==1
                    % No change to topology.
                    % Find the ripped edge
                    vertexcelldata = edgeenddata( vstarts(i):vends(i), [3 4] );
                    edgetorip = find( all( vertexcelldata > 0, 2 ) );
                    edgedatatorip = edgeenddata( vstarts(i) + edgetorip - 1, : );
                    othervx = edgedatatorip(5);
                    origin = m.secondlayer.cell3dcoords(vi,:);
                    delta = m.secondlayer.cell3dcoords(othervx,:) - origin;
                    d = sqrt(sum(delta.^2,2));
                    realamount = min(d,amount(i));
                    relativeamount = realamount./d;
                    vertexData_n = vertexData_n + 1 ;
                    vertexNeighbourData(vertexData_n,:) = [ vi, othervx, vi, edgedatatorip(2) ];
                    vertexPlacementData(vertexData_n,:) = [ origin, delta, relativeamount ]; % position of endpoints and barycentric coordinate.
                else
                    numvxsinvolved = nrips;
                    numnewvxs = nrips-1;
                    numnewedges = nrips-1;
                    newvxs = [ vi; ((curnumvxs+1):(curnumvxs+numnewvxs))' ];
                    newedgevxlist = [ vi; newvxs; newvxs(end) ];
                    edgestoupdate = ecchain(2,1:(end-1));
                    curnumvxs = curnumvxs + numnewvxs;
                    newedges = (curnumedges+1):(curnumedges+numnewedges);
                    curnumedges = curnumedges + numnewedges;

%                     rippededges = (vstarts(i):vends(i))';
%                     rippededges = rippededges(2:(end-1));
%                     % rippededges = rippededges( [end 1:(end-1)] );
                    othervxs = eed1( 2:(end-1), 5 );
                    origin = repmat( m.secondlayer.cell3dcoords(vi,:), length(othervxs), 1 );
                    delta = m.secondlayer.cell3dcoords(othervxs,:) - origin;
                    d = sqrt(sum(delta.^2,2));
                    realamount = min(d,amount(i));
                    relativeamount = realamount./d;
                    nedges = length(newedges); % size(ecchain,2) - 3;
                    for j=1:nedges
                        c1 = ecchain(1,j+2);
                        nv1 = newvxs(j);
                        nv2 = newvxs(j+1);
                        insertEdgeIntoCell( c1, vi, nv1, nv2, newedges(j) );
                    end
                    % Replace vi by newvxs(end) in last cell ecchain(1,end)
                    lastcell = ecchain(1,end-1);
                    lastvxs = m.secondlayer.cells(lastcell).vxs;
                    lastvxs(lastvxs==vi) = newvxs(end);
                    m.secondlayer.cells(lastcell).vxs = lastvxs;
                    
                    vnrange = (vertexData_n+1):(vertexData_n+numvxsinvolved);
                    vertexNeighbourData(vnrange,:) = [ vi+zeros(length(othervxs),1,'int32'), othervxs, newvxs, eed1(2:(end-1),2) ];
                    vertexPlacementData(vnrange,:) = [ origin, delta, relativeamount ]; % position of endpoints and barycentric coordinate.
                    vertexData_n = vertexData_n+numvxsinvolved;
                    m.secondlayer.vxFEMcell(newvxs) = m.secondlayer.vxFEMcell(vi);
                    m.secondlayer.vxBaryCoords(newvxs,:) = repmat( m.secondlayer.vxBaryCoords(vi,:), numvxsinvolved, 1 ); % [0 0 0];
                    m.secondlayer.cell3dcoords(newvxs,:) = repmat( m.secondlayer.cell3dcoords(vi,:), numvxsinvolved, 1 ); % [0 0 0];
                end
            otherwise
                % Should never happen
                fprintf( 1, 'Cannot make space at vertex %d: this cannot happen.\n', vi );
                xxxx = 1; %#ok<NASGU>
        end
        
        if ~isempty( newedgevxlist )
            newedgevxdata = m.secondlayer.edges( edgestoupdate, [1 2] );
            for j=1:size(newedgevxdata,1)
                newedgevxdata(j,newedgevxdata(j,:)==vi) = newedgevxlist(j);
            end
            m.secondlayer.edges( edgestoupdate, [1 2] ) = newedgevxdata;
            m.secondlayer.generation( newedges ) = 0;
            m.secondlayer.edgepropertyindex( newedges ) = m.secondlayer.newedgeindex;
            m.secondlayer.interiorborder( newedges ) = true;
        end

        % If there are none, we rip all of the edges.
        % If there is one, and it is 0, we do nothing.
        % If there is one, and it is -1, we rip all the edges not bordering it.
        % If there are more than one, not all consecutive, then we separate
        % the vertex into two or more, but do not rip any edges.
        % If there are more than one, all consecutive (in which case there
        % must be exactly two, a 0 and a -1), we move the vertex but make
        % no change to topology.
        
        
        % A simpler way of describing this might be:
        %   For any vertex not on the border, rip every interior
        %   edge touching it.
        % Is there a simple way of finding the border vertexes?
        %   Yes, secondlayer.edges rows with 4th element <= 0.
    end
    
    clear perm
    
    vertexNeighbourData((vertexData_n+1):end,:) = [];
    vertexPlacementData((vertexData_n+1):end,:) = [];
    
    % Now we need to decide on the placement of each vertex.
    % The "normal" case is to put vi at: 
    % vertexPlacementData(vi,[1 2 3]) + vertexPlacementData(vi,7)*vertexPlacementData(vi,[4 5 6])
    % This is only correct when (a) vertexPlacementData(vi,7) < 1 (so the
    % vertex is not moved all the way to the end, and (b)
    % vertexPlacementData(vi,7) + vertexPlacementData(vi1,7) < 1, where vi1
    % is the vertex at the other end, if the other end is being ripped.
    % How do we find that other vertex?
    % Sort vertexPlacementData on its 4th column, to bring together the
    % rows for opposite ends of the same edge.  Find all cases of an edge
    % occurring twice.
    [~,vndperm] = sortrows( vertexNeighbourData, 4 );
    % invvndperm(vndperm) = 1:length(vndperm);
    ee = vertexNeighbourData( vndperm, 4 );
    firsts = find(ee(1:(end-1))==ee(2:end));
    seconds = firsts+1;
    firsts = vndperm(firsts);
    seconds = vndperm(seconds);
%     secondsof = zeros(vertexData_n,1);
%     secondsof(vndperm(seconds)) = invvndperm(find(seconds)-1);
    vertexNeighbourData(:,end+1) = 0;
    vertexNeighbourData(firsts,end) = seconds;
    vertexNeighbourData(seconds,end) = firsts;
    bothendsdist = vertexPlacementData(firsts,7) + vertexPlacementData(seconds,7);
    wholeedges = bothendsdist>=1;
    vertexPlacementData(firsts(wholeedges),7) = vertexPlacementData(firsts(wholeedges),7)./bothendsdist(wholeedges,1);
    vertexPlacementData(seconds(wholeedges),7) = vertexPlacementData(seconds(wholeedges),7)./bothendsdist(wholeedges,1);
    twoendedwholerips = false( size(vertexNeighbourData,1), 1 );
    twoendedwholerips( firsts(wholeedges) ) = true;
    twoendedwholerips( seconds(wholeedges) ) = true;
    oneendedwholerips = (~twoendedwholerips) & (vertexPlacementData(:,7) >= 1);
    
    % Every edge for which twoendedwholerip is true will be elided.  Its
    % two endpoints will be repurposed as vertexes belonging to the cells
    % on either side.  It is possible that there is a cell on only one
    % side, in which case one vertex will be eliminated.
    
    for i=firsts(wholeedges)';
        e = vertexNeighbourData(i,4);
        twoendedwholerip( e );
    end
    for i=find(oneendedwholerips)';
        v = vertexNeighbourData(i,3);
        e = vertexNeighbourData(i,4);
        oneendedwholerip( e, v );
    end
    vertexNeighbourData(firsts(wholeedges),:) = [];
    vertexPlacementData(firsts(wholeedges),:) = [];
    
    mindist = max( max(m.nodes,[],1) - min(m.nodes,[],1) ) * 0.1;
    hints = m.secondlayer.vxFEMcell( vertexNeighbourData(:,1) );
    vertexesToPlace = vertexNeighbourData(:,3);
    newpositions = vertexPlacementData(:,[1 2 3]) ...
        + repmat( vertexPlacementData(:,7), 1, 3 ) .* vertexPlacementData(:,[4 5 6]);
    m.secondlayer.cell3dcoords( vertexesToPlace, : ) = newpositions;
    for i=1:length(vertexesToPlace)
        vi = vertexesToPlace(i);
        [ m.secondlayer.vxFEMcell(vi), m.secondlayer.vxBaryCoords(vi,:), ~, ~ ] = findFE( m, newpositions(i,:), 'hint', hints(i), 'mindist', mindist );
    end
    
    % For vertexes bordering only a single cell and an air space, pull them
    % towards their neighbours in that cell.
    for i=1:length(m.secondlayer.cells)
        cev1 = m.secondlayer.cells(i);
        ee = m.secondlayer.edges(cev1.edges,4);
        spaceedges = ee < 1;
        % Where consecutive edges of a cell border an air space, their
        % common vertex is one of those to be pulled inwards.
        vtopull = spaceedges & spaceedges([end (1:(end-1))]);
        if ~any(vtopull)
            continue;
        end
        vxsbefore = cev1.vxs([end (1:(end-1))]);
        vxsafter = cev1.vxs([2:end 1]);
        
        vitopull = cev1.vxs(vtopull);
        vibefore = vxsbefore(vtopull);
        viafter = vxsafter(vtopull);
        
        vpostopull = m.secondlayer.cell3dcoords( vitopull, : );
        vposbefore = m.secondlayer.cell3dcoords( vibefore, : );
        vposafter = m.secondlayer.cell3dcoords( viafter, : );
        newpos = (pullinratio/2)*(vposbefore+vposafter) + (1-pullinratio)*vpostopull;
        
        for j=1:length(vitopull)
            vj = vitopull(j);
            [ m.secondlayer.vxFEMcell(vj), m.secondlayer.vxBaryCoords(vj,:), ~, ~ ] = ...
                findFE( m, newpos(j,:), 'hint', m.secondlayer.vxFEMcell([vj vibefore(j) viafter(j)]), 'mindist', mindist );
        end
    end
    
    
    m = removeSecondlayerCruft( m, edgeminlength );
    
    m = separateBioVertexes( m, pullinratio );
    
    if any(m.secondlayer.vxFEMcell <= 0)
        xxxx = 1;
    end
    
    validmesh(m);
    
    
    
function insertEdgeIntoCell( xci, oldv, newv1, newv2, newedge )
    ce = m.secondlayer.cells(xci);
    oldvi = find(ce.vxs==oldv,1);
    ce.vxs = [ ce.vxs(1:(oldvi-1)), newv1, newv2, ce.vxs( (oldvi+1):end ) ];
    ce.edges = [ ce.edges(1:(oldvi-1)), newedge, ce.edges( oldvi:end ) ];
    m.secondlayer.cells(xci) = ce;
    m.secondlayer.edges( newedge, : ) = [ newv1, newv2, xci, -1 ];
end

function oneendedwholerip( e, v )
    % e is an edge which is to be elided, and the end at v deleted.
    ev1 = m.secondlayer.edges(e,1);
    ev2 = m.secondlayer.edges(e,2);
    if ev2==v
        ev2 = ev1;
        ev1 = v;
        ec1 = m.secondlayer.edges(e,4);
        ec2 = m.secondlayer.edges(e,3);
    else
        ec1 = m.secondlayer.edges(e,3);
        ec2 = m.secondlayer.edges(e,4);
    end
    % ev1 and ev2 are its endpoints.
    % ec1 and ec2 are the cells on either side.  Either c1 or c2 may be <=
    % 0, representing an empty space.
    
    if ec1 > 0
        % Find e in ec1.
        cev = m.secondlayer.cells(ec1);
        cei = find(cev.edges==e,1);
        v2a = cev.vxs( indexAdd(cei,1,length(cev.vxs)) );
        if v2a ~= ev2
            xxxxx = 1;  %#ok<NASGU>
        end
        cei1 = indexSubtract(cei,1,length(cev.vxs));
        eprev = cev.edges( cei1 );
        
        cev.edges( cei ) = []; % Remove e.
        cev.vxs( cei ) = []; % Remove v1.
        m.secondlayer.cells(ec1) = cev;
        % Connect previous edge to ev2.
        m.secondlayer.edges( eprev, m.secondlayer.edges(eprev,[1 2])==ev1 ) = ev2;
    end
    
    if ec2 > 0
        % Find e in ec2.
        cev = m.secondlayer.cells(ec2);
        cei = find(cev.edges==e,1);
        v2a = cev.vxs( indexAdd(cei,1,length(cev.vxs)) );
        if v2a ~= ev1
            xxxxx = 1; %#ok<NASGU>
        end
        cei1 = indexAdd(cei,1,length(cev.vxs));
        enext = cev.edges( cei1 );
        
        cev.edges( cei ) = []; % Remove e.
        cev.vxs( cei1 ) = []; % Check this is equal to v1
        if cei1==1
            cev.vxs = cev.vxs( [end (1:(end-1))] );
        end
        m.secondlayer.cells(ec2) = cev;
        % Connect previous edge to ev2.
        m.secondlayer.edges( enext, m.secondlayer.edges(enext,[1 2])==ev1 ) = ev2;
    end
    
    % Mark e as having no cell neighbours.
    m.secondlayer.edges(e,[3 4]) = 0;
end

function twoendedwholerip( e )
    K = 0.1;
    % e is an edge which is to be elided, and its two ends assigned to the
    % cells on either side.
    ev1 = m.secondlayer.edges(e,1);
    ev2 = m.secondlayer.edges(e,2);
    ec1 = m.secondlayer.edges(e,3);
    ec2 = m.secondlayer.edges(e,4);
    % ev1 and ev2 are its endpoints.
    % ec1 and ec2 are the cells on either side.  c2 may be <= 0, representing
    % an empty space.
    
    % Find e in ec1.
    cev = m.secondlayer.cells(ec1);
    cei = find(cev.edges==e,1);
    v2a = cev.vxs( indexAdd(cei,1,length(cev.vxs)) );
    vprev = cev.vxs( indexSubtract(cei,1,length(cev.vxs)) );
    vnext = cev.vxs( indexAdd(cei,2,length(cev.vxs)) );
    if v2a ~= ev2
        xxxxx = 1; %#ok<NASGU>
    end
    cei1 = indexAdd(cei,1,length(cev.vxs));
    enext = cev.edges( cei1 );
    
    cev.edges( cei ) = [];
    cev.vxs( cei1 ) = []; % Check this is equal to v2
    if cei1==1
        cev.vxs = cev.vxs( [end (1:(end-1))] );
    end
    m.secondlayer.cells(ec1) = cev;
    m.secondlayer.edges( enext, m.secondlayer.edges(enext,[1 2])==ev2 ) = ev1;
    vxspos = m.secondlayer.cell3dcoords( [ev1,vprev,vnext], : );
    newvxpos = (1-K)*vxspos(1,:) + (K/2)*(vxspos(2,:)+vxspos(3,:));
    m.secondlayer.cell3dcoords(ev2,:) = newvxpos;
    [ m.secondlayer.vxFEMcell(ev1), m.secondlayer.vxBaryCoords(ev1,:), ~, ~ ] = findFE( m, newvxpos, 'hint', m.secondlayer.vxFEMcell(ev1) );
    
    
    if ec2 > 0
        % Find e in ec2.
        cev = m.secondlayer.cells(ec2);
        cei = find(cev.edges==e,1);
        v1a = cev.vxs( indexAdd(cei,1,length(cev.vxs)) );
        vprev = cev.vxs( indexSubtract(cei,1,length(cev.vxs)) );
        vnext = cev.vxs( indexAdd(cei,2,length(cev.vxs)) );
        if v1a ~= ev1
            xxxxx = 1; %#ok<NASGU>
        end
        cei1 = indexAdd(cei,1,length(cev.vxs));
        enext = cev.edges( cei1 );
        
        cev.edges( cei ) = [];
        cev.vxs( cei1 ) = []; % Check this is equal to v1
        if cei1==1
            cev.vxs = cev.vxs( [end (1:(end-1))] );
        end
        m.secondlayer.cells(ec2) = cev;
        m.secondlayer.edges( enext, m.secondlayer.edges(enext,[1 2])==ev1 ) = ev2;
        vxspos = m.secondlayer.cell3dcoords( [ev2,vprev,vnext], : );
        newvxpos = (1-K)*vxspos(1,:) + (K/2)*(vxspos(2,:)+vxspos(3,:));
        m.secondlayer.cell3dcoords(ev2,:) = newvxpos;
        [ m.secondlayer.vxFEMcell(ev2), m.secondlayer.vxBaryCoords(ev2,:), ~, ~ ] = findFE( m, newvxpos, 'hint', m.secondlayer.vxFEMcell(ev2) );
    end
    
    % Mark e as having no cell neighbours.
    m.secondlayer.edges(e,[3 4]) = 0;
end
end

