function m = addToSecondLayer( m, newvxs, newcells )
%m = addToSecondLayer( m, newvxs, newcells )
%   NEWVXS is a set of positions of cellular vertexes. NEWCELLS is a cell
%   array of tuples of indexes into NEWVXS. Add these to the existing
%   m.secondlayer.

    numoldvxs = getNumberOfCellvertexes(m);
    numoldcells = getNumberOfCells(m);
    numoldedges = getNumberOfCellEdges(m);
    numnewvxs = size(newvxs,1);
    numnewcells = length(newcells);
    newvxindexes = (numoldvxs+1):(numoldvxs+numnewvxs);
    newcellindexes = (numoldcells+1):(numoldcells+numnewcells);
    
    newcellstruct = struct([]);
    for i=numnewcells:-1:1
        newcellstruct(i).vxs = newcells{i};
    end
    
    celledges = cell( numnewcells, 1 );
    numvxs = zeros( numnewcells, 1 );
    for i=1:numnewcells
        cvxs = newcellstruct(i).vxs;
        celledges{i} = [ reshape( cvxs, [], 1 ), reshape( cvxs([2:end 1]), [], 1 ) ];
        numvxs(i) = length( cvxs );
    end
    celledgesmat = cell2mat( celledges );
    celledgesmat = sort( celledgesmat, 2 );
    [ucelledges,~,ic] = unique( celledgesmat, 'rows', 'stable' );
    cumnumvxs = [0; cumsum( numvxs ) ];
    numnewedges = size(ucelledges,1);
    for i=1:numnewcells
        newcellstruct(i).edges = ic( (cumnumvxs(i)+1):cumnumvxs(i+1) )';
    end
    
    newvxindexes = (numoldvxs+1):(numoldvxs+numnewvxs);
    newedgeindexes = (numoldedges+1):(numoldedges+numnewedges);
    newcellindexes = (numoldcells+1):(numoldcells+numnewcells);

    [ newvxFEMcell, newvxBaryCoords, bcerr, abserr ] = findFE( m, newvxs );
    newsecondlayer = struct( 'cells', newcellstruct, 'vxFEMcell', newvxFEMcell );
    newsecondlayer = makeSecondLayerEdgeData( newsecondlayer );
    xxxx = 1;
    
    
    newvxscorrected = baryToGlobalCoords( newvxFEMcell, newvxBaryCoords, m.FEnodes, m.FEsets.fevxs );
    m.secondlayer.cell3dcoords = [ m.secondlayer.cell3dcoords; newvxscorrected ];
    for i=1:numnewcells
        newcellstruct(i).vxs = numoldvxs + newcellstruct(i).vxs;
        newcellstruct(i).edges = numoldedges + newcellstruct(i).edges;
    end
    m.secondlayer.cells(newcellindexes) = newcellstruct;
    m.secondlayer.vxFEMcell = [ m.secondlayer.vxFEMcell; newvxFEMcell ];
    m.secondlayer.vxBaryCoords = [ m.secondlayer.vxBaryCoords; newvxBaryCoords ];
    newsecondlayer.edges(:,[1 2]) = newsecondlayer.edges(:,[1 2]) + numoldvxs;
    newsecondlayer.edges(:,3) = newsecondlayer.edges(:,3) + numoldcells;
    nz4 = newsecondlayer.edges(:,4) > 0;
    newsecondlayer.edges(nz4,4) = newsecondlayer.edges(nz4,4) + numoldcells;
    m.secondlayer.edges = [ m.secondlayer.edges; newsecondlayer.edges ];
    
    m.secondlayer.side( newcellindexes, : ) = 1;
    m.secondlayer.generation( newcellindexes, : ) = 1;
    m.secondlayer.edgepropertyindex( newedgeindexes, : ) = 1;
    maxcellid = m.secondlayer.celldata.genmaxindex;
    m.secondlayer.cellid( newcellindexes, : ) = maxcellid + (1:numnewcells);
    m.secondlayer.cellparent( newcellindexes, : ) = 0;
    m.secondlayer.cellidtoindex( newcellindexes, : ) = newcellindexes;
    m.secondlayer.cellidtotime( newcellindexes, : ) = m.globalDynamicProps.currenttime;
    m.secondlayer.celldata.genindex( newcellindexes ) = maxcellid + (1:numnewcells);
    m.secondlayer.celldata.genmaxindex = maxcellid+numnewcells;
    m.secondlayer.celldata.parent( newcellindexes ) = 0;
    m.secondlayer.celldata.values( newcellindexes, : ) = 0;
    m.secondlayer.cellarea = [ m.secondlayer.cellarea; zeros( numnewcells, 1 ) ];
    for i=1:numnewcells
        m.secondlayer.cellarea( numoldcells + i ) = polyarea3( m.secondlayer.cell3dcoords( newcellstruct(i).vxs, : ) );
    end
    newtargetarea = max( m.secondlayer.celltargetarea );
    if isempty(newtargetarea)
        newtargetarea = mean( m.secondlayer.cellarea );
    end
    m.secondlayer.celltargetarea( newcellindexes ) = newtargetarea;
    maxvxid = m.secondlayer.vxdata.genmaxindex;
    m.secondlayer.vxdata.genindex( newvxindexes ) = maxvxid + (1:numnewvxs);
    m.secondlayer.vxdata.genmaxindex = maxvxid+numnewvxs;
    m.secondlayer.vxdata.parent( newvxindexes ) = 0;
    m.secondlayer.vxdata.values( newvxindexes, : ) = 0;

    m.secondlayer.areamultiple( newcellindexes, : ) = 1;
%              interiorborder: [1216×1 logical]
%                    edgedata: [1×1 struct]
%             surfaceVertexes: [25988×1 logical]
%                     auxdata: [1×1 struct]
    if isfield( m.secondlayer.visible, 'cells' )
        m.secondlayer.visible.cells( newcellindexes, : ) = true;
    end
    
    m.secondlayer.cloneindex( newcellindexes, : ) = 0;
    m.secondlayer.cellpolarity( newcellindexes, : ) = 0;
    m.secondlayer.cellcolor( newcellindexes, : ) = 1;
    m.secondlayer.cellvalues( newcellindexes, : ) = 0;
    
    addToSecondLayerOK = validmesh(m)
end
