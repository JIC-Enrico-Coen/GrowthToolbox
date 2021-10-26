function bcs = findBridgingCells( m, edges )
%cis = findBridgingCells( m, edges )
%   EDGES is a list of indexes of edges of the mesh M.  This procedure
%   attempts to return a list of all the biological cells of M which
%   straddle any such edge.  The computation is non-trivial, hence
%   "attempts".

    % For every edge of every biological cell, and every edge in the given
    % list, determine whether the two line segments have a common
    % perpendicular, and whether this perpendicular is shorter than the
    % length of either segment.
    
    bcs = [];
    
    if ~hasNonemptySecondLayer( m )
        return;
    end
    
    % Make a quick check by comparing the bounding box of each cell with
    % the bounding box of each seam edge.
    candidates = quickBridgingCheck( m, edges );
    numcandidates = size(candidates,1);
    candi = 0;
    while candi < numcandidates
        candi = candi+1;
    end
    
    % For all remaining candidates, do an exhaustive check to see if any
    % edge of a candidate cell really does cross the corresponding
    % candidate seam edge.
    isbridging = false(length(m.secondlayer.cells),1);
    errmargin = 0.001;
    for candi=1:size(candidates,1)
        ci = candidates(candi,1);
        if isbridging(ci)
            % Cell ci was already found to cross another seam edge.
            continue;
        end
        ei = candidates(candi,2);
        q01 = m.nodes( m.edgeends( ei, : ), : );
        qlen = sqrt( sum( (q01(1,:) - q01(2,:)).^2 ) );
        cedges = m.secondlayer.cells(ci).edges;
        numcelledges = length(cedges);
        for cei = 1:numcelledges
            bei = cedges(cei);
            p01 = m.secondlayer.cell3dcoords( m.secondlayer.edges(bei,[1 2]), : );
            plen = sqrt( sum( (p01(1,:) - p01(2,:)).^2 ) );
            [ds2,ps2,as2,qs2,bs2,parallel2] = lineLineDistance( p01(:,[1 2]), q01(:,[1 2]) );
            [ds,ps,as,qs,bs,parallel] = lineLineDistance( p01, q01 );
            test1 = (~parallel) && all( [as bs] > -errmargin );
            test2 = (ds < min(plen,qlen));
            if test1
                if test2
                    isbridging(ci) = true;
                    break;
                end
            end
        end
    end
    
    bcs = find(isbridging);
    fprintf( 1, '%s: %d cells that bridge seams were deleted.\n', mfilename(), length(bcs) );
    
    
    return;
    
    % OLD CODE
    
    numbioedges = size(m.secondlayer.edges,1);
    badbioedges = false(numbioedges,1);
    errmargin = 0.001;
    for bei=1:numbioedges
        p01 = m.secondlayer.cell3dcoords( m.secondlayer.edges(bei,[1 2]), : );
        plen = sqrt( sum( (p01(1,:) - p01(2,:)).^2 ) );
        for ei=1:length(edges)
            q01 = m.nodes( m.edgeends( edges(ei), : ), : );
            qlen = sqrt( sum( (q01(1,:) - q01(2,:)).^2 ) );
            [ds2,ps2,as2,qs2,bs2,parallel2] = lineLineDistance( p01(:,[1 2]), q01(:,[1 2]) );
            if intestedge && (~parallel2) && all( [as2 bs2] > 0 ) && (ds2 < min(plen,qlen))
                xxxx = 1;
            end
            [ds,ps,as,qs,bs,parallel] = lineLineDistance( p01, q01 );
            test1 = (~parallel) && all( [as bs] > -errmargin );
            test2 = (ds < min(plen,qlen));
            if test1
                if intestedge
                    xxxx = 1;
                end
                if test2
                    badbioedges(bei) = true;
                    break;
                end
            end
        end
        if mod(bei,100)==0
            fprintf( 1, '%s: %d of %d edges processed, %d%% done.\n', mfilename(), bei, numbioedges, floor(100*bei/ numbioedges) );
        end
    end
    fprintf( 1, '%s: all %d edges processed.\n', mfilename(), numbioedges );
    numbiocells = length(m.secondlayer.cells);
    bcs = false(numbiocells,1);
    for i=1:numbiocells
        bcs(i) = any( badbioedges( m.secondlayer.cells(i).edges ) );
    end
end

function candidates = quickBridgingCheck( m, edges )
% Compare the bounding box of every cell with the bounding box of every
% edge in EDGES.  The result is an N*2 vector of pairs [C,E] indicating
% which cells C might bridge which edges E.

    numedges = length(edges);
    edgeends = reshape( m.nodes( m.edgeends(edges,:)', : ), 2, [] );
    minedges = reshape( min(edgeends,[],1), [], 3 );
    maxedges = reshape( max(edgeends,[],1), [], 3 );
    numcells = length(m.secondlayer.cells);
    candidates = [];
    for ci=1:numcells
        vxindex = m.secondlayer.cells(ci).vxs;
        vxpos = m.secondlayer.cell3dcoords(vxindex,:);
        mincell = min(vxpos,[],1);
        maxcell = max(vxpos,[],1);
        candidateEdges = true( numedges, 1 );
        for coord = 1:3
            candidateEdges( ( maxcell(coord) < minedges(:,coord) ) | ( mincell(coord) > maxedges(:,coord) ) ) = false;
        end
        candidateEdges = find(candidateEdges);
        candidates = [ candidates; [ ci+zeros(length(candidateEdges),1), edges(candidateEdges) ] ];
%         for ei=1:length(edges)
%             if any( maxcell < minedges(ei,:) ) || any( mincell > maxedges(ei,:) )
%         end
        if mod(ci,1000)==0
            fprintf( 1, '%s: %d of %d cells preprocessed, %d%% done.\n', mfilename(), ci, numcells, floor(100*ci/ numcells) );
        end
    end
    fprintf( 1, '%s: %d candidates for seam-crossing found, requiring exact testing.\n', mfilename(), size(candidates,1) );
end



