function m = completesecondlayer( m, olddata )
%m = completesecondlayer( m )
%   This takes a mesh having a second layer containing only the components
%       cells(:).vxs(:)
%       cell3dcoords(:,1:3)
%       vxFEMcell(:)
%       vxBaryCoords(:,1:3)
%   and calculates or updates all the rest.
%
%   If either vxFEMcell and vxBaryCoords is missing or empty, it will also
%   compute these.  However, if at the point of creating the vertexes one
%   has specific information about which FEs they lie in, it will be faster
%   to use that information rather than the general construction
%   implemented here.
%
%   If olddata is given, it must be a struct with fields oldnumcells,
%   oldnumedges, and oldnumvxs, giving the number of cells, edges, and
%   vertexes that already existed in the mesh prior to adding some new
%   cells.  By default these are taken to be zero.

    if nargin < 2
        olddata = struct( 'numcells', 0, 'numedges', 0, 'numvxs', 0 );
    end
    
    thesecondlayer = m.secondlayer;

    numbiocells = length(thesecondlayer.cells);
    numbiovxs = size(thesecondlayer.cell3dcoords,1);
    numnewcells = numbiocells - olddata.numcells;
    numnewvxs = numbiovxs - olddata.numvxs;
    if ~isfield( thesecondlayer, 'vxFEMcell' ) || isempty( thesecondlayer.vxFEMcell )
        thesecondlayer.vxFEMcell = extendArray1( thesecondlayer.vxFEMcell, numnewvxs, 0 );
        thesecondlayer.vxBaryCoords = extendArray1( thesecondlayer.vxBaryCoords, numnewvxs, 0 );
        for i=1:numbiovxs
            [ ci, bc, ~, ~ ] = findFE( m, thesecondlayer.cell3dcoords(i,:) );
            thesecondlayer.vxFEMcell(i) = ci;
            thesecondlayer.vxBaryCoords(i,:) = bc;
        end
        thesecondlayer.cell3dcoords = baryToGlobalCoords( thesecondlayer.vxFEMcell, thesecondlayer.vxBaryCoords, m.FEnodes, m.FEsets.fevxs );
    end
    
    if ~isfield( thesecondlayer, 'valuedict' )
        thesecondlayer.valuedict = struct( 'name2IndexMap', struct(), 'index2NameMap', [], 'case', -1 );
        thesecondlayer.valuedict.index2NameMap = {};
    end
    thesecondlayer.cellvalues = extendArray12( thesecondlayer.cellvalues, [ numnewcells, length( thesecondlayer.valuedict.index2NameMap ) ], 0 );

    thesecondlayer = makeSecondLayerEdgeData( thesecondlayer );
    m = setSplitThreshold( m, 1.05 );
    thesecondlayer.jiggleAmount = 0;
    thesecondlayer.edgepropertyindex = ones( size(thesecondlayer.edges,1), 1, 'int32' );
    thesecondlayer.interiorborder = false( size(thesecondlayer.edges,1), 1 );
    thesecondlayer.generation = zeros( size(thesecondlayer.edges,1), 1, 'int32' );
    if ~isfield( thesecondlayer,'cloneindex') || isempty( thesecondlayer.cloneindex )
        thesecondlayer.cloneindex = ones( length( thesecondlayer.cells ), 1 );
    end
    thesecondlayer.cellpolarity = zeros( length( thesecondlayer.cells ), 3 );
    if ~isfield( thesecondlayer,'side' ) || isempty( thesecondlayer.side )
        thesecondlayer.side = true(numbiocells,1);
    end
    m.secondlayer = calcBioACellAreas( m.secondlayer );
    thesecondlayer.areamultiple = ones(numbiocells,1);
    if numbiocells == 0
        thesecondlayer.celltargetarea = zeros(0,1);
        thesecondlayer.averagetargetarea = 0;
    else
        thesecondlayer.celltargetarea = thesecondlayer.areamultiple * ...
            (sum(thesecondlayer.cellarea)/numbiocells);
        thesecondlayer.averagetargetarea = ...
            sum(thesecondlayer.celltargetarea)/length(thesecondlayer.celltargetarea);
    end
    
    m = initialiseCellIDData( m );
    
    numnewedges = size(thesecondlayer.edges,1) - olddata.numedges;
    thesecondlayer = extendCellIndexing( thesecondlayer, numnewcells, numnewedges, numnewvxs );
    
    thesecondlayer.visible.cells = logical( extendArray12( thesecondlayer.visible.cells, [numnewcells,1], true ) );
    
    [ok,thesecondlayer] = checkclonesvalid( thesecondlayer );
    if ~ok
        % Delete the second layer?
        fprintf( 1, 'Second layer creation failed.\n' );
      % mesh = rmfield( mesh, 'thesecondlayer' );
    end
    
    m.secondlayer = thesecondlayer;
end
