function [m,delinfo] = renumberMesh3D( m, varargin )
%[m,delinfo] = renumberMesh3D( m, ... )
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
    
    delinfo = [];
    [s1,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    deletiontypes = { 'fevx', 'fe', 'feedge', 'cellvx', 'celledge', 'cell', 'mgen', 'cellmgen' };
    datamodes = { 'dellist', 'delmap', 'keeplist', 'keepmap' };
    datatypes = { 'int32', 'logical', 'int32', 'logical' };
    anywork = false;
    havework = struct();
    for i=1:length(deletiontypes)
        h = false;
        for j=1:length(datamodes)
            fn = [ deletiontypes{i} datamodes{j} ];
            if isfield( s1, fn )
                delinfo.(deletiontypes{i}).(datamodes{j}) = s1.(fn);
                h = h || ~isempty(s1.(fn));
                s1 = rmfield( s1, fn );
            else
                delinfo.(deletiontypes{i}).(datamodes{j}) = zeros( 0, 1, datatypes{j} );
            end
            
            delinfo.(deletiontypes{i}).(datamodes{j}) = cast( delinfo.(deletiontypes{i}).(datamodes{j}), datatypes{j} );
        end
        havework.(deletiontypes{i}) = h;
        anywork = anywork || h;
        delinfo.(deletiontypes{i}).remap = zeros(0,1,'int32');
        
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
        delinfo = [];
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
            delinfo.(deltype) = unifyDelData( numitems.(deltype), delinfo.(deltype) );
        end
    end
    
    full3d = isVolumetricMesh( m );
    
    if full3d
        fevxs = int32( m.FEsets.fevxs );
        feedges = int32( m.FEconnectivity.feedges );
    else
        fevxs = int32( m.tricellvxs );
        feedges = int32( m.celledges );
    end
    
    % Reconcile fevx, feedge, and fe data.  Vertexes, edges, and FEs are
    % retained only if they are retained by all sets of data.
    havefe = ~isempty( delinfo.fe.dellist );
    havefevx = ~isempty( delinfo.fevx.dellist );
    if havefe
        if havefevx
            delinfo.fe.keepmap = delinfo.fe.keepmap & all( delinfo.fevx.keepmap( fevxs ), 2 );
            delinfo.fe = unifyDelData( numitems.fe, delinfo.fe, 'keepmap' );
            
            usedvxs = unique( fevxs( delinfo.fe.keepmap, : ) );
            usedmap = false( size( delinfo.fevx.keepmap ) );
            usedmap(usedvxs) = true;
            delinfo.fevx.keepmap = delinfo.fevx.keepmap & usedmap;
            delinfo.fevx = unifyDelData( numitems.fevx, delinfo.fevx, 'keepmap' );
        else
            delinfo.fevx.keeplist = unique( fevxs( delinfo.fe.keepmap, : ) );
            delinfo.fevx = unifyDelData( numitems.fevx, delinfo.fevx, 'keeplist' );
            havefevx = true;
        end
    elseif havefevx
        delinfo.fe.keepmap = all( delinfo.fevx.keepmap( fevxs ), 2 );
        delinfo.fe = unifyDelData( numitems.fe, delinfo.fe, 'keepmap' );
        havefe = true;
    end
    
    usededges = unique( feedges( delinfo.fe.keepmap, : ) );
    delinfo.feedge.keeplist = usededges;
    delinfo.feedge = unifyDelData( numitems.feedge, delinfo.feedge, 'keeplist' );
    
    havecell = ~isempty( delinfo.cell.dellist );
    havecellvx = ~isempty( delinfo.cellvx.dellist );

    % Reconcile fe and cell data.  A cell vertex is retained only if it
    % lies in a retained FE.
    if havefe && hasNonemptySecondLayer( m )
        newcellvxkeepmap = delinfo.fe.keepmap( m.secondlayer.vxFEMcell );
        if havecellvx
            delinfo.cellvx.keepmap = delinfo.cellvx.keepmap & newcellvxkeepmap;
        else
            delinfo.cellvx.keepmap = newcellvxkeepmap;
            havecellvx = true;
        end
        delinfo.cellvx = unifyDelData( numitems.cellvx, delinfo.cellvx, 'keepmap' );
    end
    
    % Reconcile cellvx and cell data.  Cell vertexes and cells are retained
    % only if they are retained by both sets of data. Create also celledge
    % data.
    if havecell
        if havecellvx
            extracellkeepmap = false( getNumberOfCells( m ), 1 );
            allcellvxs = { m.secondlayer.cells.vxs };
            for i=1:length( m.secondlayer.cells )
                extracellkeepmap(i) = all( delinfo.cellvx.keepmap( allcellvxs{i}.vxs ) );
            end
            delinfo.cell.keepmap = delinfo.cell.keepmap & extracellkeepmap;
            delinfo.cell = unifyDelData( numitems.cell, delinfo.cell, 'keepmap' );
            
            usedvxs = unique( [ m.secondlayer.cells(delinfo.cell.keepmap).vxs ] );
            usedmap = false( size( delinfo.cellvx.keepmap ) );
            usedmap(usedvxs) = true;
            delinfo.cellvx.keepmap = delinfo.cellvx.keepmap & usedmap;
            delinfo.cellvx = unifyDelData( numitems.cellvx, delinfo.cellvx, 'keepmap' );
        else
            delinfo.cellvx.keeplist = unique( [ m.secondlayer.cells(delinfo.cell.keepmap).vxs ] );
            delinfo.cellvx = unifyDelData( numitems.cellvx, delinfo.cellvx, 'keeplist' );
        end
    elseif havecellvx
        delinfo.cell.keepmap = false( getNumberOfCells( m ), 1 );
        allcellvxs = { m.secondlayer.cells.vxs };
        for i=1:length( m.secondlayer.cells )
            delinfo.cell.keepmap(i) = all( delinfo.cellvx.keepmap( allcellvxs{i} ) );
        end
        delinfo.cell = unifyDelData( numitems.cell, delinfo.cell, 'keepmap' );
        
        % Duplicates a chhunk of code from above -- bad!
        % By deleting all the dells that include deleted vertexes, some
        % non-deleted vertexes may no longer belong to any cell, and should
        % also be deleted. These vertexes must be found and added to
        % delinfo.cellvx.
        usedvxs = unique( [ m.secondlayer.cells(delinfo.cell.keepmap).vxs ] );
        usedmap = false( size( delinfo.cellvx.keepmap ) );
        usedmap(usedvxs) = true;
        delinfo.cellvx.keepmap = delinfo.cellvx.keepmap & usedmap;
        delinfo.cellvx = unifyDelData( numitems.cellvx, delinfo.cellvx, 'keepmap' );
    end
    
    % A celledge is retained only if both of its vertexes are retained
    delinfo.celledge.keepmap = all( delinfo.cellvx.keepmap( m.secondlayer.edges(:,[1 2]) ), 2 );
    delinfo.celledge = unifyDelData( numitems.celledge, delinfo.celledge, 'keepmap' );
    
    % Recompute our idea of what we are doing.
    havefevx = ~isempty( delinfo.fe.dellist );
    havefe = ~isempty( delinfo.fevx.dellist );
    havecellvx = ~isempty( delinfo.cell.dellist );
    havecell = ~isempty( delinfo.cellvx.dellist );
    
    if ~full3d && havefevx
        delinfo.prismvx.keeplist = delinfo.fevx.keeplist*2;
        delinfo.prismvx.keeplist = reshape( [ delinfo.prismvx.keeplist-1; delinfo.prismvx.keeplist ], [], 1 );
        delinfo.prismvx = unifyDelData( numitems.fevx*2, delinfo.prismvx, 'keeplist' );
    end
    
    fns = fieldnames(delinfo);
    for i=1:length(fns)
        fn = fns{i};
        delinfo.(fn) = makeremapper( delinfo.(fn) );
    end
    
%     okbeforedeletion = consistentMeshDelInfo( m, delinfo, false )
    
    for i=1:size(gFIELDTYPES,1)
        fn = gFIELDTYPES{i,1};
        % fn is the name of a deep field of m. If it is absent or empty, do
        % nothing.
        
        v = getDeepField( m, fn );
        if isempty( v )
%             fprintf( 1, 'Deep field %s not found.\n', fn );
            xxxx = 1;
            continue;
        end
        
        dimtypes = gFIELDTYPES{i,2};
        % dimtypes lists the types of the dimensions of the array.
        if ischar( dimtypes )
            dimtypes = { dimtypes };
        end
        
        if ~isempty( dimtypes )
            if strcmp( dimtypes{1}, '{' )
                endcellargs = find( strcmp( dimtypes(2:end), '}' ), 1 );
                cellcontentstypes = dimtypes( (endcellargs+1):end );
                dimtypes = dimtypes( 2:(endcellargs-1) );
            else
                cellcontentstypes = {};
            end
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
            if ~isfield( delinfo, dimtype )
                continue;
            end
            reindexer = delinfo.(dimtype);
            if isempty(reindexer.keepmap)
                continue;
            end
            changed = true;
            whichcase = j+10*vdims;
            switch whichcase
                case 11
                    v = reshape( v(reindexer.keepmap), [], 1 );
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
            
%             if iscell(v) && ~isempty( cellcontentstypes )
%                 for ci=1:numel(v)
%                     v{ci} = reindex1( v{ci}, reindexer );
%                 end
%             end
        end
        
        % Remap the values.
        if ~isempty( valuetype )
            haszero = valuetype(1)=='z';
            if haszero
                valuetype(1) = [];
            end
            if isfield( delinfo, valuetype )
                if strcmp(valuetype,'prismvx') && full3d
                    valuetype = 'fevx';
                end
                reindexer = delinfo.(valuetype);
                if ~isempty(reindexer.keepmap)
                    changed = true;
                    if haszero
                        v(v>0) = reindexer.remap(v(v>0));
                    else
                        v = reindexer.remap(v);
                    end
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
        m.secondlayer.cells(i).vxs = reshape( delinfo.('cellvx').remap( m.secondlayer.cells(i).vxs ), 1, [] );
        m.secondlayer.cells(i).edges = reshape( delinfo.('celledge').remap( m.secondlayer.cells(i).edges ), 1, [] );
%         m.secondlayer.cells(i).edges = int32([]); % s.('celledge').remap( m.secondlayer.cells(i).edges );
    end
    sl = m.secondlayer;
    newedges1 = delinfo.('cellvx').remap( m.secondlayer.edges(:,[1 2]) );
    newedges2 = m.secondlayer.edges(:,[3 4]);
    newedges2(newedges2~=0) = delinfo.('cell').remap( newedges2(newedges2~=0) );
    reverseedges = newedges2(:,1)==0;
    m.secondlayer.edges = [ newedges1, newedges2 ];
    m.secondlayer.edges(reverseedges,:) = m.secondlayer.edges(reverseedges,[2 1 4 3]);
%     m.secondlayer = makeSecondLayerEdgeData( m.secondlayer );
    
    if full3d
        m.FEconnectivity = connectivity3D( m );
    else
        [m.edgeends,m.celledges,m.edgecells,~] = connectivityTriMesh(size(m.nodes,1),m.tricellvxs);
        m = makeVertexConnections( m );
    end
    
    [m,ok] = invokeIFcallback( m, 'Renumber', delinfo );
    
%     okafterdeletion = consistentMeshDelInfo( m, delinfo, true )
end

function v = reindex1( v, reindexer )
end

function dd = unifyDelData( n, dd, fn )
% dd has four fields: dellist, delmap, keeplist, and keepmap.
% At most one should be nonempty.  The other fields will be computed
% from that one.

    if ~isfield( dd, 'dellist' )
        dd.dellist = zeros(0,1,'int32');
    end
    if ~isfield( dd, 'delmap' )
        dd.delmap = zeros(0,1,'logical');
    end
    if ~isfield( dd, 'keeplist' )
        dd.keeplist = zeros(0,1,'int32');
    end
    if ~isfield( dd, 'keepmap' )
        dd.keepmap = zeros(0,1,'logical');
    end
    if ~isfield( dd, 'remap' )
        dd.remap = zeros(0,1,'int32');
    end
    
    if nargin < 3
        if ~isempty( dd.keepmap )
            fn = 'keepmap';
        elseif ~isempty( dd.keeplist )
            fn = 'keeplist';
        elseif ~isempty( dd.delmap )
            fn = 'delmap';
        elseif ~isempty( dd.dellist )
            fn = 'dellist';
        else
            return;
        end
    end
    
    switch fn
        case 'keepmap'
            dd.keeplist = int32( find( dd.keepmap ) );
            dd.delmap = ~dd.keepmap;
            dd.dellist = int32( find( dd.delmap ) );
        case 'keeplist'
            dd.keepmap = false(n,1);
            dd.keepmap(dd.keeplist) = true;
            dd.delmap = ~dd.keepmap;
            dd.dellist = int32( find( dd.delmap ) );
        case 'delmap'
            dd.keepmap = ~dd.delmap;
            dd.keeplist = int32( find( dd.keepmap ) );
            dd.dellist = int32( find( dd.delmap ) );
        case 'dellist'
            dd.keepmap = true(n,1);
            dd.keepmap(dd.dellist) = false;
            dd.delmap = ~dd.keepmap;
            dd.keeplist = int32( find( dd.keepmap ) );
    end

end

function reindexer = makeremapper( reindexer )
    if ~isempty(reindexer.keepmap)
        reindexer.remap = zeros( size(reindexer.keepmap), 'int32' );
        reindexer.remap(reindexer.keepmap) = int32(1:sum(reindexer.keepmap))';
    end
end


    
