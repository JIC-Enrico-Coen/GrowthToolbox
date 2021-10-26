function m = completesecondlayer( m, olddata )
%m = completesecondlayer( m )
%   This takes a mesh having a second layer containing only the components
%       cells(:).vxs(:)
%       vxFEMcell(:)
%       vxBaryCoords(:,1:3)
%       cell3dcoords(:,1:3)
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

    numbiocells = length(m.secondlayer.cells);
    numbiovxs = size(m.secondlayer.cell3dcoords,1);
    numnewcells = numbiocells - olddata.numcells;
    numnewvxs = numbiovxs - olddata.numvxs;
    if ~isfield( m.secondlayer, 'vxFEMcell' ) || isempty( m.secondlayer.vxFEMcell )
        m.secondlayer.vxFEMcell = extendArray1( m.secondlayer.vxFEMcell, numnewvxs, 0 );
        m.secondlayer.vxBaryCoords = extendArray1( m.secondlayer.vxBaryCoords, numnewvxs, 0 );
%         m.secondlayer.vxFEMcell = zeros( numbiovxs, 1 );
%         m.secondlayer.vxBaryCoords = zeros( numbiovxs, 3 );
        for i=1:numbiovxs
            [ ci, bc, ~, ~ ] = findFE( m, m.secondlayer.cell3dcoords(i,:) );
            m.secondlayer.vxFEMcell(i) = ci;
            m.secondlayer.vxBaryCoords(i,:) = bc;
        end
        m.secondlayer.cell3dcoords = baryToGlobalCoords( m.secondlayer.vxFEMcell, m.secondlayer.vxBaryCoords, m.FEnodes, m.FEsets.fevxs );
    end
    
    if ~isfield( m.secondlayer, 'valuedict' )
        m.secondlayer.valuedict = struct( 'name2IndexMap', struct(), 'index2NameMap', [], 'case', -1 );
        m.secondlayer.valuedict.index2NameMap = {};
    end
    m.secondlayer.cellvalues = extendArray12( m.secondlayer.cellvalues, [ numnewcells, length( m.secondlayer.valuedict.index2NameMap ) ], 0 );
%     if size(m.secondlayer.cellvalues,1) < numbiocells
%         m.secondlayer.cellvalues = ...
%             [ m.secondlayer.cellvalues; ...
%               zeros(numbiocells-size(m.secondlayer.cellvalues,1), size(m.secondlayer.cellvalues,2) ) ];
%     end
%     if isfield( m.secondlayer, 'valuedict' )
%         m.secondlayer.cellvalues = zeros( numbiocells, length( m.secondlayer.valuedict.index2NameMap ) );
%     else
%         m.secondlayer.valuedict = struct( 'name2IndexMap', struct(), 'index2NameMap', [], 'case', -1 );
%         m.secondlayer.valuedict.index2NameMap = {};
%         m.secondlayer.cellvalues = zeros( numbiocells, 0 );
%     end

    m.secondlayer = makeSecondLayerEdgeData( m.secondlayer );
    m = setSplitThreshold( m, 1.05 );
    m.secondlayer.jiggleAmount = 0;
    m.secondlayer.edgepropertyindex = ones( size(m.secondlayer.edges,1), 1, 'int32' );
    m.secondlayer.interiorborder = false( size(m.secondlayer.edges,1), 1 );
    m.secondlayer.generation = zeros( size(m.secondlayer.edges,1), 1, 'int32' );
    if ~isfield( m.secondlayer,'cloneindex') || isempty( m.secondlayer.cloneindex )
        m.secondlayer.cloneindex = ones( length( m.secondlayer.cells ), 1 );
    end
    m.secondlayer.cellpolarity = zeros( length( m.secondlayer.cells ), 3 );
    if ~isfield( m.secondlayer,'side' ) || isempty( m.secondlayer.side )
        m.secondlayer.side = true(numbiocells,1);
    end
    m = calcBioACellAreas( m );
    m.secondlayer.areamultiple = ones(numbiocells,1);
    if numbiocells == 0
        m.secondlayer.celltargetarea = zeros(0,1);
        m.secondlayer.averagetargetarea = 0;
    else
        m.secondlayer.celltargetarea = m.secondlayer.areamultiple * ...
            (sum(m.secondlayer.cellarea)/numbiocells);
        m.secondlayer.averagetargetarea = ...
            sum(m.secondlayer.celltargetarea)/length(m.secondlayer.celltargetarea);
    end
    
    m = initialiseCellIDData( m );
    
    numnewedges = size(m.secondlayer.edges,1) - olddata.numedges;
    m.secondlayer = extendCellIndexing( m.secondlayer, numnewcells, numnewedges, numnewvxs );
    
    m.secondlayer.visible.cells = extendArray12( m.secondlayer.visible.cells, [numnewcells,1], true );
    
    [ok,m.secondlayer] = checkclonesvalid( m.secondlayer );
    if ~ok
        % Delete the second layer?
        fprintf( 1, 'Second layer creation failed.\n' );
      % mesh = rmfield( mesh, 'm.secondlayer' );
    end
end
