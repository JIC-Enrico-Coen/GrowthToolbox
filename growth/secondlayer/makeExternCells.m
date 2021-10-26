function [m,vxerrs] = makeExternCells( m, vertexdata, celldata )
%m = makeExternCells( m, vertexdata, celldata, add )
%   Create the biological layer from vertexdata, an N*3 array giving the
%   three-dimensional positions of all the vertexes, and celldata, a cell
%   array, each member of which is the list of vertex indexes for one cell.
%   If add is true then the cells will be added to any existing biological
%   layer, otherwise they will replace it.

    numoldvxs = length( m.secondlayer.vxFEMcell );
    numoldedges = size( m.secondlayer.edges, 1 );
    numoldcells = length( m.secondlayer.cells );
    if size(vertexdata,2)==2
        vertexdata(:,3) = 0;
    end
    numvxs = size(vertexdata,1);
    numcells = length(celldata);
    vci = zeros( numvxs, 1 );
    vbc = zeros( numvxs, 3 );
    bcerr = zeros( numvxs, 1 );
    abserr = zeros( numvxs, 1 );
    validcells = false( 1, length(celldata) );
    for i=1:numcells
        len = length(celldata{i});
        if len >= 3
            validcells(i) = len==length(unique(celldata{i}));
        end
    end
    celldata = celldata(validcells);
    numcells = length(celldata);
    fprintf( 1, '%s: Locating %d vertexes.\n', mfilename(), numvxs );
    mindist = 10 * max( max(m.nodes,[],1)-min(m.nodes,[],1) )/sqrt(getNumberOfFEs(m));
    tic;
    hint = [];
    for i=1:numvxs
        [ vci(i), vbc(i,:), bcerr(i), abserr(i) ] = findFE( m, vertexdata(i,:), 'hint', hint, 'mindist', mindist );
        if vci(i)==0
            [ vci(i), vbc(i,:), bcerr(i), abserr(i) ] = findFE( m, vertexdata(i,:), 'hint', hint );
        end
        hint = vci(i);
        if mod(i,100)==0
            fprintf( 1, '%s: Located %d vertexes.\n', mfilename(), i );
            toc;tic;
        end
    end
    toc;

    totedges = 0;
    for i=1:numcells
        totedges = totedges + length( celldata{i} );
    end
    edgeends = zeros( totedges, 2 );
    e = 0;
    for i=1:numcells
        c = celldata{i};
        c = c(:);
        edgeends( (e+1):(e+length(c)), : ) = [ c(:), c([2:end 1]) ];
        e = e + length(c);
    end
    revs = edgeends(:,1) > edgeends(:,2);
    edgeends(revs,:) = edgeends(revs,[2 1]);
    [edgeends,ei1,ei2] = unique( edgeends, 'rows', 'first' );
    numedges = size( edgeends, 1 );
    
    edgedata = [ edgeends + numoldvxs, zeros( numedges, 2 ) ];
    e = 0;
    for i=1:numcells
        c = celldata{i};
        for j=1:length(c)
            theedge = ei2(e+j);
            if edgedata(theedge,3)==0
                edgedata(theedge,3) = i + numoldcells;
            else
                edgedata(theedge,4) = i + numoldcells;
            end
        end
        e = e + length(c);
    end

    m.secondlayer.edges = [ m.secondlayer.edges; edgedata ];
    m.secondlayer.vxFEMcell = [ m.secondlayer.vxFEMcell; vci];
    m.secondlayer.vxBaryCoords = [ m.secondlayer.vxBaryCoords; vbc ];
    new3dcoords = findCloneVxCoords( m, (numoldvxs+1):(numoldvxs+numvxs) );
    vxerrs = vertexdata - new3dcoords;
    m.secondlayer.cell3dcoords = [ m.secondlayer.cell3dcoords; new3dcoords ];
    e = 0;
    for i=1:numcells
        c = celldata{i};
        m.secondlayer.cells(numoldcells+i).edges = numoldedges + ei2( (e+1):(e+length(c)) )';
        e = e + length(c);
        m.secondlayer.cells(numoldcells+i).vxs = numoldvxs + c;
    end
    [m.secondlayer,numfixed] = fixbioedgehandedness( m.secondlayer );
end
