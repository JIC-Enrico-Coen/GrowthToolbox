function m = renumberMesh3D( m, varargin )
%m = renumberMesh3D( m, ... )
% For volumetric meshes only.
%
% This is a general routine for deleting vertexes, finite elements,
% cell vertexes, cells, morphogens, or cell factors.
%
% The procedure assumes that no alteration to m has yet been done. The
% arguments specify the items to be deleted or retained, using alternating
% option-name/option-value arguments.
%
% Each option name is a combination of the sort of thing to be deleted and
% the type of information specifying the set of things to delete.
%
% The sort is one of:
%   'fe': finite elements
%   'fevx: vertexes of finite elements
%   'cell': biological cells
%   'cellvx': vertexes of cells
%   'celledge': edges of cells  (NOT SUPPORTED)
%   'mgen': morphogens
%   'cellmgen': cell factors
%
% The information type is one of:
%   'keepmap': an N*1 vector of booleans, one for each of the existing
%       items, which is true for the items to be retained and false for the
%       items to be deleted.
%   'keeplist': A list of the indexes of the items to be retained.
%   'delmap': Like keepmap, but true for deleted items and false for
%       retained ones.
%   'dellist': A list of the indexes of the items to be deleted.
%
% A option name is the concatenation of any sort of thing with any
% information type, e.g. 'fevxkeepmap'.
%
% For a given sort of thing to be deleted, only one information type should
% be specified. If more than one is given, only the first (in the order
% they are listed above) will be used.
%
% Certain consistency requirements are automatically imposed.
% 1.  A vertex is retained if the fevx information retains it and it
%     is a vertex of at least one retained finite element.
% 2.  A finite element is retained if the fe information retains it and all
%     its vertexes are retained.
% 3.  Cells and cell vertexes are handled similarly.
% 4.  A cell vertex will be deleted (and hence all cells containing it) if
%     it lies in a finite element that is deleted.
%
% The purpose of this procedure is to perform the required deletions and
% reindexings of all relevant fields of m so as to keep the whole structure
% consistent.
%
% This has currently been tested for volumetric meshes only, but it will
% eventually be used for foliate meshes also.

    global gFIELDTYPES
    % gFIELDTYPES holds data on the types of the various array fields of m.
    
    [s1,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    deletiontypes = { 'fevx', 'fe', 'cellvx', 'celledge', 'cell', 'mgen', 'cellmgen' };
    datamodes = { 'dellist', 'delmap', 'keeplist', 'keepmap' };
    anywork = false;
    havework = struct();
    for i=1:length(deletiontypes)
        h = false;
        for j=1:length(datamodes)
            fn = [ deletiontypes{i} datamodes{j} ];
            if isfield( s1, fn )
                s.(deletiontypes{i}).(datamodes{j}) = s1.(fn);
                h = h || ~isempty(s1.(fn));
                s1 = rmfield( s1, fn );
            else
                s.(deletiontypes{i}).(datamodes{j}) = [];
            end
        end
        havework.(deletiontypes{i}) = h;
        anywork = anywork || h;
    end
    remainingFields = fieldnames(s1);
    if ~isempty(remainingFields)
        fprintf( 1, 'Unrecognised arguments supplied to command "%s":\nRemaining fields ignored:\n', ...
            mfilename() );
        for i=1:length(remainingFields)
            fprintf( 1, '     %s\n', remainingFields{i} );
        end
    end
    
    if ~anywork
        return;
    end
    
    numitems = struct();
    for i=1:length(deletiontypes)
        deltype = deletiontypes{i};
        switch deltype
            case 'fevx'
                numitems.(deltype) = getNumberOfVertexes( m );
            case 'fe'
                numitems.(deltype) = getNumberOfFEs( m );
            case 'feedge'
                numitems.(deltype) = getNumberOfEdges( m );
            case 'cell'
                numitems.(deltype) = getNumberOfCells( m );
            case 'cellvx'
                numitems.(deltype) = getNumberOfCellvertexes( m );
            case 'mgen'
                numitems.(deltype) = getNumberOfMorphogens( m );
            case 'cellmgen'
                numitems.(deltype) = getNumberOfCellFactors( m );
            case 'celledge'
                numitems.(deltype) = getNumberOfCellEdges( m );
        end
    end
    
    for i=1:length(deletiontypes)
        deltype = deletiontypes{i};
        if havework.(deltype)
            s.(deltype) = unifyDelData( numitems.(deltype), s.(deltype) );
        end
    end
    
    full3d = isVolumetricMesh( m );
    
    if full3d
        fevxs = m.FEsets.fevxs;
    else
        fevxs = m.tricellvxs;
    end
    
    % Reconcile fevx and fe data.  Vertexes and FEs are retained only if
    % they are retained by both sets of data.
    havefe = ~isempty( s.fe.dellist );
    havefevx = ~isempty( s.fevx.dellist );
    if havefe
        if havefevx
            s.fe.keepmap = s.fe.keepmap & all( s.fevx.keepmap( fevxs ), 2 );
            s.fe.keeplist = [];
            s.fe.dellist = [];
            s.fe = unifyDelData( numitems.fe, s.fe );
            
            usedvxs = unique( fevxs( s.fe.keepmap, : ) );
            usedmap = false( size( s.fevx.keepmap ) );
            usedmap(usedvxs) = true;
            s.fevx.keepmap = s.fevx.keepmap & usedmap;
            s.fevx.keeplist = [];
            s.fevx.dellist = [];
            s.fevx = unifyDelData( numitems.fevx, s.fevx );
        else
            s.fevx.keeplist = unique( fevxs( s.fe.keepmap, : ) );
            s.fevx = unifyDelData( numitems.fevx, s.fevx );
            havefevx = true;
        end
    elseif havefevx
        s.fe.keepmap = all( s.fevx.keepmap( fevxs ), 2 );
        s.fe.keeplist = [];
        s.fe.dellist = [];
        s.fe = unifyDelData( numitems.fe, s.fe );
        havefe = true;
    end
    
    havecell = ~isempty( s.cell.dellist );
    havecellvx = ~isempty( s.cellvx.dellist );

    % Reconcile fe and cell data.  A cell vertex is retained only if it
    % lies in a retained FE.
    if havefe && hasNonemptySecondLayer( m )
        newcellvxkeepmap = s.fe.keepmap( m.secondlayer.vxFEMcell );
        if havecellvx
            s.cellvx.keepmap = s.cellvx.keepmap & newcellvxkeepmap;
        else
            s.cellvx.keepmap = newcellvxkeepmap;
            havecellvx = true;
        end
        s.cell.keeplist = [];
        s.cell.dellist = [];
        s.cell = unifyDelData( numitems.cellvx, s.cellvx );
    end
    
    % Reconcile cellvx and cell data.  Cell vertexes and cells are retained
    % only if they are retained by both sets of data. Create also celledge
    % data.
    if havecell
        if havecellvx
            extracellkeepmap = false( getNumberOfCells( m ), 1 );
            allcellvxs = { m.secondlayer.cells.vxs };
            for i=1:length( m.secondlayer.cells )
                extracellkeepmap(i) = all( s.cellvx.keepmap( allcellvxs{i}.vxs ) );
            end
            s.cell.keepmap = s.cell.keepmap & extracellkeepmap;
            s.cell.keeplist = [];
            s.cell.dellist = [];
            s.cell = unifyDelData( numitems.cellvx, s.cellvx );
            
            usedvxs = unique( [ m.secondlayer.cells(s.cell.keepmap).vxs ] );
            usedmap = false( size( s.cellvx.keepmap ) );
            usedmap(usedvxs) = true;
            s.cellvx.keepmap = s.cellvx.keepmap & usedmap;
            s.cellvx.keeplist = [];
            s.cellvx.dellist = [];
            s.cellvx = unifyDelData( numitems.cellvx, s.cellvx );
        else
            s.cellvx.keeplist = unique( [ m.secondlayer.cells(s.cell.keepmap).vxs ] );
            s.cellvx = unifyDelData( numitems.cellvx, s.cellvx );
        end
    elseif havecellvx
        s.cell.keepmap = false( getNumberOfCells( m ), 1 );
        allcellvxs = { m.secondlayer.cells.vxs };
        for i=1:length( m.secondlayer.cells )
            s.cell.keepmap(i) = all( s.cellvx.keepmap( allcellvxs{i} ) );
        end
        s.cell.keeplist = [];
        s.cell.dellist = [];
        s.cell = unifyDelData( numitems.cell, s.cell );
    end
    
    % A celledge is retained only if both of its vertexes are retained
    s.celledge.keepmap = all( s.cellvx.keepmap( m.secondlayer.edges(:,[1 2]) ), 2 );
    s.celledge = unifyDelData( numitems.celledge, s.celledge );
    
    % Recompute our idea of what we are doing.
    havefevx = ~isempty( s.fe.dellist );
    havefe = ~isempty( s.fevx.dellist );
    havecellvx = ~isempty( s.cell.dellist );
    havecell = ~isempty( s.cellvx.dellist );
    
    if ~full3d && havefevx
        s.prismvx.keeplist = s.fevx.keeplist*2;
        s.prismvx.keeplist = reshape( [ s.prismvx.keeplist-1; s.prismvx.keeplist ], [], 1 );
        s.prismvx = unifyDelData( numitems.fevx*2, s.prismvx );
    end
    
    fns = fieldnames(s);
    for i=1:length(fns)
        fn = fns{i};
        s.(fn) = makeremapper( s.(fn) );
    end
    
    for i=1:size(gFIELDTYPES,1)
        fn = gFIELDTYPES{i,1};
        % fn is the name of a field of m. If it is absent or empty, do
        % nothing.
        
        if strcmp( fn, 'cellstiffness' )
            xxxx = 1;
        end
        
        v = getDeepField( m, fn );
        if isempty( v )
            fprintf( 1, 'Deep field %s not found.\n', fn );
            xxxx = 1;
            continue;
        end
        
        dimtypes = gFIELDTYPES{i,2};
        % dimtypes lists the types of the dimensions of the array.
        if ischar( dimtypes )
            dimtypes = { dimtypes };
        end
        
        valuetype = gFIELDTYPES{i,3};
        % valuetype is the type of the values stored in the array.
        
%         meshtype = gFIELDTYPES{i,4};
        % meshtype specifies whether the field is to be found only in
        % volumetric meshes, only in foliate meshes, or in all meshes.
        
        vdims = length(size(v));
        changed = false;
%         fprintf( 1, 'Reindexing field %s.\n', fn );
        if strcmp( fn, 'secondlayer.vxFEMcell' )
            xxxx = 1;
        end
        
        % Reindex every applicable dimension.
        for j=1:length(dimtypes)
            dimtype = dimtypes{j};
            if strcmp(dimtype,'prismvx') && full3d
                dimtype = 'fevx';
            end
            if ~isfield( s, dimtype )
                continue;
            end
            reindexer = s.(dimtype);
            if isempty(reindexer.keepmap)
                continue;
            end
            changed = true;
            whichcase = j+10*vdims;
            switch whichcase
                case 11
                    v = v(reindexer.keepmap);
                case 21
                    v = v(reindexer.keepmap,:);
                case 22
                    v = v(:,reindexer.keepmap);
                case 31
                    v = v(reindexer.keepmap,:,:);
                case 32
                    v = v(:,reindexer.keepmap,:);
                case 33
                    v = v(:,:,reindexer.keepmap);
                otherwise
                    % Not handled.
                    error( '%s: unexpected case %d.', mfilename(), whichcase );
            end
        end
        
        % Remap the values.
        if ~isempty( valuetype )
            haszero = valuetype(1)=='z';
            if haszero
                valuetype(1) = [];
            end
            if strcmp(valuetype,'prismvx') && full3d
                valuetype = 'fevx';
            end
            if ~isfield(s,  valuetype )
                continue;
            end
            reindexer = s.(valuetype);
            if ~isempty(reindexer.keepmap)
                changed = true;
                if haszero
                    v(v>0) = reindexer.remap(v(v>0));
                else
                    v = reindexer.remap(v);
                end
            end
        end
        
        % Install updated version.
        if changed
            m = setDeepField( m, v, fn );
        end
    end
    
    % Some fields are not handled by the generic method above.
    % m.secondlayer.cells is a struct array with fields 'vxs' and 'edges',
    % which must be renumbered.
    for i=1:length( m.secondlayer.cells )
        m.secondlayer.cells(i).vxs = s.('cellvx').remap( m.secondlayer.cells(i).vxs );
        m.secondlayer.cells(i).edges = []; % s.('celledge').remap( m.secondlayer.cells(i).vxs );
    end
    % m = completesecondlayer( m );
    m.secondlayer = makeSecondLayerEdgeData( m.secondlayer );
    
    if full3d
        m.FEconnectivity = connectivity3D( m );
    else
        [m.edgeends,m.celledges,m.edgecells,~] = connectivityTriMesh(size(m.nodes,1),m.tricellvxs);
        m = makeVertexConnections( m );
    end
end

function dd = unifyDelData( n, dd )
% dd has three fields: dellist, delmap, keeplist, and keepmap.
% At most one should be nonempty.  The other two fields will be computed
% from that one.

    if ~isfield( dd, 'dellist' )
        dd.dellist = [];
    end
    if ~isfield( dd, 'delmap' )
        dd.delmap = [];
    end
    if ~isfield( dd, 'keeplist' )
        dd.keeplist = [];
    end
    if ~isfield( dd, 'keepmap' )
        dd.keepmap = [];
    end

    if ~isempty( dd.keepmap )
        dd.keeplist = find( dd.keepmap );
        dd.delmap = ~dd.keepmap;
        dd.dellist = find( dd.delmap );
    elseif ~isempty( dd.keeplist )
        dd.keepmap = false(n,1);
        dd.keepmap(dd.keeplist) = true;
        dd.delmap = ~dd.keepmap;
        dd.dellist = find( dd.delmap );
    elseif ~isempty( dd.delmap )
        dd.keepmap = ~dd.delmap;
        dd.keeplist = find( dd.keepmap );
        dd.dellist = find( dd.delmap );
    elseif ~isempty( dd.dellist )
        dd.keepmap = true(n,1);
        dd.keepmap(dd.dellist) = false;
        dd.delmap = ~dd.keepmap;
        dd.keeplist = find( dd.keepmap );
    end
end

function reindexer = makeremapper( reindexer )
    if ~isempty(reindexer.keepmap)
        reindexer.remap = zeros( size(reindexer.keepmap) );
        reindexer.remap(reindexer.keepmap) = (1:sum(reindexer.keepmap))';
    end
end


    
