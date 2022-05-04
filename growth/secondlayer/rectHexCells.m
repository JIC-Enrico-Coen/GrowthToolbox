function [vxs,edges,polyvxs,polyedges] = rectHexCells( varargin )
    vxs = [];
    edges = [];
    polys = [];
    
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'bbox', [0 4 0 3], 'divisions', [5 6], 'spacing', [], 'firsthexoffsets', [0.2 0.5 1], ...
        'lasthexoffsets', [0.2 0.5 1], 'angle', 30, 'noise', 0, 'plot', true );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'bbox', 'divisions', 'spacing', 'firsthexoffsets', 'lasthexoffsets', 'angle', 'noise', 'plot' );
    if ~ok, return; end
    
    s.bbox = reshape( s.bbox, 2, 2 );
    bboxsize = s.bbox(2,:) - s.bbox(1,:);
    bboxcentre = (s.bbox(1,:) + s.bbox(2,:))/2;
    centredbbox = s.bbox - bboxcentre;
    
    if isempty( s.firsthexoffsets )
        s.firsthexoffsets = 1;
    end
    
    if isempty( s.lasthexoffsets )
        s.lasthexoffsets = 1;
    end
    
    if size( s.firsthexoffsets, 1 )==1
        s.firsthexoffsets = [ s.firsthexoffsets; s.firsthexoffsets ];
    end
    
    if size( s.lasthexoffsets, 1 )==1
        s.lasthexoffsets = [ s.lasthexoffsets; s.lasthexoffsets ];
    end
    
    if isempty( s.divisions )
        s.divisions = bboxsize./s.spacing;
    end
    if numel(s.divisions) == 1
        s.divisions = bboxsize * (s.divisions/mean(bboxsize));
    end
    % Force s.divisions to be a pair of odd integers.
    s.divisions = round( s.divisions );
    evens = mod( s.divisions, 2 ) == 0;
    s.divisions(evens) = s.divisions(evens) + 1;

    xwidth = bboxsize(1);
    ywidth = bboxsize(2);
    numcolumns = s.divisions(1);
    numrows = max( s.divisions(2), 3 );
    
    numrowpairs = floor((numrows-2)/2);
    oddrows = mod(numrows,2)==1;
    
    hedgesperrow = [ numcolumns, numcolumns*2 + zeros(1,numrows-1), numcolumns];
    vxsperrow = hedgesperrow+1;
    numpolys = numrows * numcolumns + numrowpairs + oddrows;
    
    
    xvals = linspace( 0, xwidth, vxsperrow(1) )';
    xvals2 = linspace( 0, xwidth, vxsperrow(2) )';
    xdelta = xvals2(2)-xvals2(1);
    if oddrows
        xvalslast = xvals;
    else
        xvalslast = [ 0; xvals2(2:2:end); xwidth ];
    end
    
    allxvals = [ xvals; repmat( xvals2, numrows-1, 1 ); xvalslast ];
    ycentres = linspace( 0, ywidth, numrows+1 )';
    ydelta = ycentres(2)-ycentres(1);
    middleycentres = ycentres(2:(end-1));
    nummiddlevxrows = length(middleycentres);
    
    absyoffset = 0.5 * xdelta * tan( s.angle*pi/180 );
    
%     s.firsthexoffsets = s.firsthexoffsets(:);
%     s.lasthexoffsets = s.lasthexoffsets(:);
    numfirsthexoffsets = size( s.firsthexoffsets, 2 );
    numlasthexoffsets = size( s.lasthexoffsets, 2 );
    
    if numlasthexoffsets > nummiddlevxrows
        s.lasthexoffsets( :, (nummiddlevxrows+1):end ) = [];
    end
    if numfirsthexoffsets > nummiddlevxrows
        s.firsthexoffsets( :, (nummiddlevxrows+1):end ) = [];
    end
    
    maxyoffset = max(s.firsthexoffsets,[],2);
    yoffsets1 = [ s.firsthexoffsets, maxyoffset+zeros( 1, nummiddlevxrows-numfirsthexoffsets ) ];
    yoffsets2 = [ maxyoffset+zeros( 1, nummiddlevxrows-numlasthexoffsets ), s.lasthexoffsets(:,end:-1:1) ];
    yoffsets = absyoffset * min( yoffsets1, yoffsets2 );
    
    yoffsets = min( yoffsets, ydelta/3 );
    
    foo = [-yoffsets(1,:); yoffsets(2,:)]';
    foo(2:2:end,:) = -foo(2:2:end,:);
    foo = [ repmat( foo, 1, numcolumns ), foo(:,1) ];
    foo(:,[1 end]) = 0;
    foo = foo + middleycentres;
    foo = foo';
    
    allyvals = [ zeros( length(xvals), 1 ); foo(:); ywidth + zeros( length(xvalslast), 1 ) ];
    
    vxs = [ allxvals, allyvals ];
    numvxs = size(vxs,1);
    
    hedges = [ (1:numvxs)', (2:(numvxs+1))' ];
    vxrowlengths = [ length(xvals), length(xvals2)+zeros(1,nummiddlevxrows), length(xvalslast) ];
    non_hedges = cumsum( vxrowlengths );
    hedges( non_hedges, : ) = [];
    
     vedgesfirst = [ (1:length(xvals))', length(xvals)+(1:2:length(xvals2))' ];
    lastrowvxstart0 = length(allxvals) - length(xvalslast);
    penultrowvxstart0 = lastrowvxstart0 - length(xvals2);
    vi2 = lastrowvxstart0 + (1:length(xvalslast))';
    if oddrows
%         vedgeslast = length(allxvals) + 1 - vedgesfirst;
%         vedgeslast = vedgeslast( end:-1:1, [2 1] );
        vi1 = penultrowvxstart0 + (1:2:length(xvals2))';
    else
        vi1 = penultrowvxstart0 + [1; (2:2:length(xvals2))'; length(xvals2)];
    end
    vedgeslast = [vi1 vi2];
    
    oddrowvxs = [ 1; (2:2:length(xvals2))'; length(xvals2) ];
    evenrowvxs = (1:2:length(xvals2))';
    oddrowedges = [ oddrowvxs, oddrowvxs + length(xvals2) ];
    evenrowedges = length(xvals2) + [ evenrowvxs, evenrowvxs + length(xvals2) ];
    rowpairvedges = [ oddrowedges; evenrowedges ];
    nummidrowedges = size(rowpairvedges,1);
    numvedges = length(xvals) + length(xvalslast) + numrowpairs * nummidrowedges + oddrows*size(oddrowedges,1);
    vedges = zeros( numvedges, 2 );
    vedges( 1:size(vedgesfirst,1), : ) = vedgesfirst;
    vedges( (end-size(vedgeslast,1)+1):end, : ) = vedgeslast;
    ei = size(vedgesfirst,1);
    rowpairedgevxstart = length(xvals);
    for i=1:numrowpairs
        vedges( (ei+1):(ei+nummidrowedges), : ) = rowpairvedges + rowpairedgevxstart;
        ei = ei + nummidrowedges;
        rowpairedgevxstart = rowpairedgevxstart + 2*length(xvals2);
    end
    if oddrows
        vedges( (ei+1):(ei+size(oddrowedges,1)), : ) = oddrowedges + rowpairedgevxstart;
    end
    
    edges = [ hedges; vedges ];
    edges = sort( edges, 2 );
    
    % Now we need to find the polygons.
    % 1. Create for each vertex a list of its incident edges and its neighbouring vertexes along each edge.
    % Record also the direction of the edge relative to the vertex.
    
    numedges = size(edges,1);
    vv = sparse( numvxs, numvxs );
    vv( sub2ind( [numvxs numvxs], edges(:,1), edges(:,2) ) ) = (1:numedges)';
    vv( sub2ind( [numvxs numvxs], edges(:,2), edges(:,1) ) ) = (1:numedges)';
    vnbs = cell( numvxs, 1 );
    vedges = cell( numvxs, 1 );
    vsenses = cell( numvxs, 1 );
    for i=1:numvxs
        vnbs{i} = find( vv(i,:) > 0 );
        vedges{i} = vv( i, vnbs{i} );
        vsenses{i} = i < vnbs{i};
    end
    
    % 2. Sort each list into clockwise order.
    edgevecs = vxs(edges(:,2),:) - vxs(edges(:,1),:);
    for i=1:numvxs
        ves = vedges{i};
        vevecs = edgevecs( ves, : );
        rev = ~vsenses{i};
        vevecs( rev, : ) = -vevecs( rev, : );
        veangles = atan2( vevecs(:,2), vevecs(:,1) );
        veangles(veangles<0) = veangles(veangles<0) + 2*pi;
        [veangles,p] = sort( veangles );
        vnbs{i} = vnbs{i}(p);
        vedges{i} = vedges{i}(p);
        vsenses{i} = vsenses{i}(p);
    end
    
    % 3. For each vertex, make a list recording which outbound edges have been used. These are initially all false.
    vnbseligible = vsenses;
    
    % 4. For each vertex, choose the first unused outbound edge and follow it around a loop until reaching the
    % initial vertex. Keep count of the winding. The winding number should be ±1. Record a polygon if the winding
    % number is 1. For this polygon record its sequence of edges and vertexes.

    polyvxs = cell( numpolys, 1 );
    polyedges = cell( numpolys, 1 );
    polyi = 0;
    boundaryvxs = [];
    MAXITERS = numvxs;
    for vi=1:numvxs
        vvi = find( vnbseligible{vi}, 1 );
        if isempty(vvi)
%             polys{end+1} = polyedges;
            continue;
        end
        
        pes = [];
        pvs = [];
        currentv = vi;
        niters = 0;
        while true && (niters < MAXITERS)
            
            niters = niters+1;
            vnbseligible{currentv}(vvi) = false;
            nextedge = vedges{currentv}(vvi);
            whichevi = 1 + vsenses{currentv}(vvi);
            nextv = edges( nextedge, whichevi );
            pvs(end+1) = nextv;
            pes(end+1) = nextedge;
            if nextv==vi
                polyedgevecs = vxs( pvs( [2:end 1] ), : ) - vxs( pvs, : );
                edirs = atan2( polyedgevecs(:,2), polyedgevecs(:,1) );
                edirdiffs = mod( edirs( [2:end 1] ) - edirs, 2*pi );
                edirdiffs(edirdiffs >= pi) = edirdiffs(edirdiffs >= pi) - 2*pi;
                windingnumber = round( sum( edirdiffs )/(2*pi) );
                if windingnumber > 0
                    polyi = polyi+1;
                    polyvxs{polyi} = pvs;
                    polyedges{polyi} = pes;
                else
                    boundaryvxs = pvs;
                end
                break;
            end
            % Find currentedge in edges of nextv
            [nextce,nextcei] = find( nextedge==vedges{nextv}, 1 );
            if isempty( nextce )
                % Error.
                fprintf( 1, 'Failed to find edge %d (%d %d) from %d as incident edge of vertex %d.\n', ...
                    nextedge, edges(nextedge,:), currentv, nextv );
                xxxx = 1;
                error( mfilename() );
            end
            if vnbs{nextv}(nextcei) ~= currentv
                % Error.
                fprintf( 1, 'Edge and nb lists inconsistent at vertex %d, reached from %d.\n', ...
                    nextv, currentv );
                xxxx = 1;
                error( mfilename() );
            end
            vvi = nextcei-1;
            if vvi==0
                vvi = length(vedges{nextv});
            end
            currentv = nextv;
        end
        if niters >= MAXITERS
            fprintf( 2, 'Too many iterations (%d) when searching for polygon from vertex %d edge %d.\n', ...
                MAXITERS, vi, vvi );
            xxxx = 1;
            error( mfilename() );
        end
    end
    
    noisescale = 0.5 * max( 0, min(xdelta,ydelta - max(yoffsets(:))));
    vxsnoise = s.noise * noisescale * 2 * (rand( numvxs, 2 )-0.5);
    vxsnoise( boundaryvxs, : ) = 0;
    vxs = vxs + vxsnoise;
    
    vxs = vxs + s.bbox([1 3]);
    
    
    
    if s.plot
        [f,ax] = getFigure();
        plotpts( vxs, 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 20, 'Parent', ax );
        plotlines( edges, vxs, 'Marker', 'none', 'LineWidth', 1, 'LineStyle', '-', 'Parent', ax );
        axis( ax, 'equal' );
        axis( ax, [-1 bboxsize(1)+1 -1 bboxsize(2)+1] );
    end
end
