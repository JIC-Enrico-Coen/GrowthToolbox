function [vvlayer,ok] = vvFromCells( vvxs, vcells, walldivs )
%[vvlayer,ok] = vvFromCells( vvxs, vcells, edgedivs )
%   Construct a complete VV layer from the minimum data.
%   VVXS is the 3D positions of the cell wall junctions.
%   VCELLS lists for every cell the sequence of its vertexes (cell wall
%   junctions) in anticlockwise order.
%   WALLDIVS is the number of segments to divide each wall into, on
%   average.

    ok = true;
    numcells = length(vcells);
    
    vvlayer.mainvxs = vvxs;
    vvlayer.vcells = vcells;        

    % Build an array of quads [vx1,vx2,cell,cvi], where VX1 and VX2 are
    % consecutive wall junctions of CELL, and CVI is the index of VX1 in
    % that cell.  Each quad represents a section of cell wall joining wall
    % junctions. A wall will occur twice in this list if it has a
    % cell on both sides, otherwise once.
    vvc = [];
    vvci = 0;
    for i=1:numcells
        c = vcells{i};
        vvc1 = [ c', c([2:end 1])', zeros(length(c),1)+i, (1:length(c))' ];
        vvc( (vvci+1):(vvci+length(c)), : ) = vvc1;
        vvci = vvci + length(c);
    end
    vvc( (vvci+1):end, : ) = [];
    vvlayer.vvc = vvc;

    % Build an array of tuples [v1,v2,c1,c2,c1v1,c2v2].
    % v1 and v2 are indexes of two wall junctions at opposite ends of a
    % wall.  c1 and c2 are the indexes of the cells on either side,
    % c2 being zero if there is a cell on only one side.
    % [v1,v2,c1] and [v2,v1,c2] are both in clockwise order.
    % c1v1 is the index of v1 in c1, and
    % c2v2 is the index of v2 in c2, or zero if c2 is zero.
    % This array has one row for every wall.
    [vvx,vvxi] = sortrows( [vvc;vvc(:,[2 1 3 4])] );
    vvreps = [ all( vvx(1:(end-1),[1 2])==vvx(2:end,[1 2]), 2 ); false ];
    parity = vvxi <= size(vvc,1);
    okreps = vvreps & parity;
    vvcc2 = [ vvx(okreps,:), vvx( [false;okreps(1:(end-1))], [3 4] ) ];
    singles = parity & (~vvreps) & (~[false;vvreps(1:(end-1))]);
    vvcc1 = vvx(singles,:);
    vvcc1 = [vvcc1, zeros(size(vvcc1,1),2)];
    vvcc = [ vvcc2; vvcc1 ];
    vvcc = vvcc(:,[1 2 3 5 4 6]);
    numwalls = size(vvcc,1);
    vvlayer.vvcc = vvcc;
    
    % For each cell, build a list of its wall indexes.  These are
    % indexes into the first dimension of vvlayer.vvcc.
    [ce,p] = sortrows( [vvcc(:,[3 5]); vvcc(:,[4 6])] );
    tophalf = p>size(vvcc,1);
    p(tophalf) = p(tophalf) - size(vvcc,1);
    first = find(ce(:,1)>0,1);
    foo = first - 1 + find( ce(first:(end-1),1) ~= ce((first+1):end,1) );
    Cstarts = [first; foo+1];
    Cends = [ foo; size(ce,1) ];
    cellwalls = cell( 1, numcells );
    for i=1:numcells
        ec = p( Cstarts(i):Cends(i) );
        cellwalls{i} = ec';
    end
    vvlayer.cellwalls = cellwalls;
    
    % Compute the length of every wall, and the number of segments it is to
    % be divided into.
    walllengths = sqrt(sum( (vvxs(vvcc(:,1),:) - vvxs(vvcc(:,2),:)).^2, 2 ));
    % Find the average length.
    avwalllength = sum(walllengths)/length(walllengths);
    % Compute the number of segments in each edge, and the total number of
    % segments.
    seglength = avwalllength/double(walldivs);
    wallsegs = max( 1, round( walllengths/seglength ) );
    numwallsegs = sum(wallsegs);
    vvlayer.wallsegs = wallsegs;
    
    % We will have the following numbers of vertexes:
    %   cell centres: numcells
    %   wall vertexes: numwallsegs
    %   membrane vertexes: sum of total number of edge segments for each cell.    numvxC = numcells;
    numvxW = numwallsegs;
%     numvxM = numwallsegs + sum(wallsegs(vvcc(:,4) ~= 0));

    vvptsWi = zeros( numvxW, 4 );  % [wall, wallsegment, cell, cell]
    vvptsMi = zeros( numvxW, 3 );  % [wall, wallsegment, cell]
    nbW = zeros( numvxW, 4 ); % [ m1, m2, c1, c2 ]

    vwi = 0;
    vmi = 0;
    wallside = 0;
    wallcells = [];
    wallsides = [];
    for i=1:numwalls
        n = vvlayer.wallsegs(i);
        c1 = vvlayer.vvcc(i,3);
        c2 = vvlayer.vvcc(i,4);
        wallside = wallside+1;
        wallcells = [ wallcells; [c1 c2] ];
        if c2==0
            wallsides = [ wallsides; [wallside+1 0] ];
            wallside = wallside+1;
        else
            wallsides = [ wallsides; [wallside+1 wallside+2] ];
            wallside = wallside+2;
        end
        vvptsWi((vwi+1):(vwi+n),:) = [ i+zeros(n,1), (1:n)', c1+zeros(n,1), c2+zeros(n,1) ];
        vvptsMi((vmi+1):(vmi+n),:) = [ i+zeros(n,1), (1:n)', c1+zeros(n,1) ];
        nbW((vwi+1):(vwi+n),1) = (vmi+1):(vmi+n);
        nbW((vwi+1):(vwi+n),3) = c1;
        vmi = vmi+n;
        c2 = vvlayer.vvcc(i,4);
        if c2 ~= 0
            nbW((vwi+1):(vwi+n),2) = (vmi+1):(vmi+n);
            nbW((vwi+1):(vwi+n),4) = c2;
            vvptsMi((vmi+1):(vmi+n),:) = [ i+zeros(n,1), (1:n)', c2+zeros(n,1) ];
            vmi = vmi+n;
        end
        vwi = vwi+n;
    end
    vvlayer.vvptsWi = vvptsWi;
    vvlayer.vvptsMi = vvptsMi;
    vvlayer.nbW = nbW;

    % Edges between cell centres and cell wall vertexes.
    foo = find( vvptsWi(1:(end-1),1) ~= vvptsWi(2:end,1) );
    startsW = [1; foo+1];
    endsW = [foo; size(vvptsWi,1)];
    foo = find( vvptsMi(1:(end-1),1) ~= vvptsMi(2:end,1) );
    startsM = [1; foo+1];
    endsM = [foo; size(vvptsMi,1)];
    allcw = [];
    allcm = [];
    cellW = cell(numcells,1);
    cellM = cell(numcells,1);
    for i=1:numcells
        w = cellwalls{i};
        cwvi = [];
        cmvi = [];
        for j=1:length(w)
            wi = w(j);
            s = startsW(wi);
            e = endsW(wi);
            sM = startsM(wi);
            eM = endsM(wi);
            nM = e-s+1;
            if i==vvptsWi(s,3)
                wvis = s:e;
                mvis = sM:(sM+nM-1);
            else
                wvis = e:-1:s;
                mvis = eM:-1:(eM-nM+1);
            end
            cwvi = [ cwvi, wvis ];
            cmvi = [ cmvi, mvis ];
        end
        vvlayer.cellwallvxs{i} = cwvi;
        cellW{i} = cwvi';
        cellM{i} = cmvi';
        allcw = [ allcw; [ i+zeros(length(cwvi),1), cellW{i} ] ];
        allcm = [ allcm; [ i+zeros(length(cmvi),1), cellM{i} ] ];
    end
    
    vvlayer.cellW = cellW;
    vvlayer.cellM = cellM;
    vvlayer.edgeCM = allcm;
    vvlayer.edgeCW = allcw;
    vvlayer.edgeWM = [ vvlayer.edgeCW(:,2), vvlayer.edgeCM(:,2) ];
    
    % Edges between membrane vertexes
    foo = find( any( vvlayer.vvptsMi(1:(end-1),[1 3]) ~= vvlayer.vvptsMi(2:end,[1 3]), 2 ) );
    MCstarts = [1; foo+1];
    MCends = [foo; size(vvlayer.vvptsMi,1)];
    edgeMM = [];
    edgeMMi = 0;
    for i=1:length(MCstarts)
        s = MCstarts(i);
        e = MCends(i);
        es = [ (s:(e-1))', ((s+1):e)' ];
%         edgeMM = [ edgeMM; es ];
        edgeMM( (edgeMMi+1):(edgeMMi+size(es,1)), : ) = es;
        edgeMMi = edgeMMi + size(es,1);
    end
    
    % Now add the edges joining one membrane segment to another.
    foo = find( vvlayer.vvptsMi(1:(end-1),1) ~= vvlayer.vvptsMi(2:end,1) );
    Mstarts = [1; foo+1];
    Mends = [foo; size(vvlayer.vvptsMi,1)];
    for i=1:numcells
        es = cellwalls{i};
        last = vvcc(es,1) ~= vcells{i}';
        s = Mstarts(es);
        e = Mends(es);
        ns = e - s + 1;
        inc = vvlayer.vvptsMi(s,3) ~= i;
        dec = vvlayer.vvptsMi(e,3) ~= i;
        s(inc) = s(inc) + ns(inc)/2;
        e(dec) = e(dec) - ns(dec)/2;
        sl = s(last);
        el = e(last);
        s(last) = el;
        e(last) = sl;
        foo = [ e([end 1:(end-1)]), s ];
%         edgeMM = [ edgeMM; foo ];
        edgeMM( (edgeMMi+1):(edgeMMi+size(foo,1)), : ) = foo;
        edgeMMi = edgeMMi + size(foo,1);
    end
    edgeMM( (edgeMMi+1):end, : ) = [];
    vvlayer.edgeMM = edgeMM;
    aa = [ (1:size(edgeMM,1))', edgeMM ];
    bb = [aa(:,[2 1]); aa(:,[3 1]) ];
    cc = sortrows(bb);
    vvlayer.Medgeedge = reshape(cc(:,2),2,[])';

    % Edges between wall vertexes
    foo = find( vvlayer.vvptsWi(1:(end-1),1) ~= vvlayer.vvptsWi(2:end,1) );
    Wstarts = [1; foo+1];
    Wends = [foo; size(vvlayer.vvptsWi,1)];
    edgeWW = [];
    edgeWWi = 0;
    for i=1:length(Wstarts)
        s = Wstarts(i);
        e = Wends(i);
        es = [ (s:(e-1))', ((s+1):e)' ];
%         edgeWW = [ edgeWW; es ];
        edgeWW( (edgeWWi+1):(edgeWWi+size(es,1)), : ) = es;
        edgeWWi = edgeWWi + size(es,1);
    end
    edgeWW( (edgeWWi+1):end, : ) = [];
    % Now add the edges joining one wall segment to another.
    vc = sortrows( [reshape( vvcc(:,[1 2]), [], 1 ), ...
                    repmat( (1:size(vvcc,1))', 2, 1 ), ...
                    [ zeros(numwalls,1); ones(numwalls,1)] ] );
    % junctions = [ (1:size(vvxs,1))', reshape( vc(:,2), 3, [] )', reshape( vc(:,3), 3, [] )' ];
    junctions = zeros( size(vvxs,1), 7 );
    i=1;
    nvc = size(vc,1);
    oldvi = 0;
    while i <= nvc
        vi = vc(i,1);
        if vi==oldvi
            j = j+1;
        else
            junctions(vi,1) = vi;
            j = 2;
        end
        junctions(vi,[j,j+3]) = vc(i,[2 3]);
        oldvi = vi;
        i = i+1;
    end
    % Junctions is an array with one row for each junction and seven
    % columns.  The columns contain the vertex index (redundant -- this is
    % equal to the row index), indexes (into vvcc) of the three wall
    % segments it belonds to, and three booleans, indicating whether it is
    % at the beginning (false) or end (true) of the respective wall
    % segments.
    % We now need to determine the wall vertex indexes
    triples = junctions(:,4) ~= 0;
    j3 = junctions(triples,:);
    j2 = junctions(~triples,[1 2 3 5 6]);
    s = Wstarts(j3(:,2:4));
    e = Wends(j3(:,2:4));
    useEnds = j3(:,5:7)==1;
    s(useEnds) = e(useEnds);
    edgeWW3 = reshape( s(:,[1 2 2 3 3 1])', 2, [] )';
    edgeWW = [ edgeWW; edgeWW3 ];
    s = Wstarts(j2(:,2:3));
    e = Wends(j2(:,2:3));
    useEnds = j2(:,4:5)==1;
    s(useEnds) = e(useEnds);
    edgeWW = [ edgeWW; s ];
    vvlayer.edgeWW = edgeWW;
    
    foo = sortrows(vvlayer.edgeWM);
    pairs = find( foo(1:(end-1),1)==foo(2:end,1) );
    vvlayer.edgeMWM = reshape( foo( [pairs,pairs+1], 2 ), [], 2 );
    
    vvlayer.edges = [ vvlayer.edgeCM; vvlayer.edgeMM; vvlayer.edgeWW; vvlayer.edgeWM; vvlayer.edgeMWM ];
    vvlayer.numEdgesCM = size(vvlayer.edgeCM,1);
    vvlayer.numEdgesMM = size(vvlayer.edgeMM,1);
    vvlayer.numEdgesWW = size(vvlayer.edgeWW,1);
    vvlayer.numEdgesWM = size(vvlayer.edgeWM,1);
    vvlayer.numEdgesMWM = size(vvlayer.edgeMWM,1);
    
    vvlayer = VV_recalcVertexes( vvlayer );
    
    vvlayer.vvpts = [ vvlayer.vvptsC; vvlayer.vvptsW; vvlayer.vvptsM ];
    vvlayer.numptsC = size(vvlayer.vvptsC,1);
    vvlayer.numptsW = size(vvlayer.vvptsW,1);
    vvlayer.numptsM = size(vvlayer.vvptsM,1);
    
    vvlayer.mgens = zeros(size(vvlayer.vvpts,1),0);
    vvlayer.mgendict = struct( 'indexToName', [], 'nameToIndex', struct() );
    vvlayer.mgendict.indexToName = {};
%     vvlayer.reactLeft = [];
%     vvlayer.reactRight = [];
%     vvlayer.reactLR = [];
%     vvlayer.reactRL = [];
    
    vvlayer.mgenC = zeros( size(vvlayer.vvptsC,1),0);
    vvlayer.mgenW = zeros( size(vvlayer.vvptsW,1),0);
    vvlayer.mgenM = zeros( size(vvlayer.vvptsM,1),0);
    vvlayer.cellpolarity = zeros(size(vvlayer.vvptsC,1),3);
    
    return;
    
    
    cla;
    hold on
    if true
        v1 = vvptsM(edgeMM(:,1),:);
        v2 = vvptsM(edgeMM(:,2),:);
        linesegs( v1, v2, 'Color', [0.7 0.7 0.7] );
        v1 = vvptsW(edgeWW(:,1),:);
        v2 = vvptsW(edgeWW(:,2),:);
        linesegs( v1, v2, 'Color', [0.8 0.5 0.3] );
        v1 = vvptsW(edgeWM(:,1),:);
        v2 = vvptsM(edgeWM(:,2),:);
        linesegs( v1, v2, 'Color', [0.3 0.9 0.6] );
        v1 = vvptsC(edgeCM(:,1),:);
        v2 = vvptsM(edgeCM(:,2),:);
        linesegs( v1, v2, 'Color', [0.1 0.1 0.6] );
    else
        starts = vvptsM;
        ends = vvptsC( vvlayer.vvptsMi(:,3), : );
        linesegs( starts, ends, 'Color', [0.7 0.7 0.7] )
        % line( [starts(:,1)';ends(:,1)'],[starts(:,2)';ends(:,2)'],[starts(:,3)';ends(:,3)'], 'Color', [0.7 0.7 0.7] );
        for i=1:numcells
            c = vcells{i};
            v = vvxs(c([1:end 1]),:);
            line(v(:,1),v(:,2),v(:,3), 'Color', [0.7 0.7 0.7] );
        end
    end
    plotpts(gca,vvptsC,'k.','MarkerSize',15);
    plotpts(gca,vvptsW,'ko');
    plotpts(gca,vvptsM,'r.','MarkerSize',10);
    for i=1:numcells
        text( vvptsC(i,1), vvptsC(i,2), vvptsC(i,3), sprintf( '%d', i ), 'FontSize', 16 );
    end
    [x,y,z] = cylinder();
    x = x*0.8;
    y = y*0.8;
    z = 1.2*(z*2-1);
    colormap([1 1 1]);
    surf(x,y,z, zeros(size(x)), 'linestyle', 'none');
    hold off;
    axis equal;
end

function linesegs( v1, v2, varargin )
        line( [v1(:,1)';v2(:,1)'],[v1(:,2)';v2(:,2)'],[v1(:,3)';v2(:,3)'], varargin{:} );
end
