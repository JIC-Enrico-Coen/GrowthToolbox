function volcells = delVolcells( volcells, varargin )
%volcells = delVolcells( volcells, ... )
%   The optional arguments specify which vertexes, edges, faces, and
%   volumes to delete or retain. Each option name consists of two parts.
%   The first is the type of thing: 'vx', 'edge', 'face', or 'vol'. The
%   second is how it is specified: 'keepmap', keeplist', delmap', or
%   delllist'. Maps are boolean maps of items to be kept or deleted; lists
%   are lists of such indexes.

    [s1,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    itemtypes = { 'vx', 'edge', 'face', 'vol' };
    datamodes = { 'dellist', 'delmap', 'keeplist', 'keepmap' };
    
    numitems.vx = getNumberOfVolVertexes( volcells );
    numitems.edge = getNumberOfVolEdges( volcells );
    numitems.face = getNumberOfVolFaces( volcells );
    numitems.vol = getNumberOfVolCells( volcells );
    

    anywork = false;
    havework = struct();
    primaryfield = struct();
    for i=1:length(itemtypes)
        s.(itemtypes{i}) = emptyDelinfo( numitems.(itemtypes{i}) );
        h = false;
        for j=1:length(datamodes)
            fn = [ itemtypes{i} datamodes{j} ];
            if isfield( s1, fn )
                s.(itemtypes{i}).(datamodes{j}) = s1.(fn);
                primaryfield.(itemtypes{i}) = (datamodes{j});
                h = h || ~isempty(s1.(fn));
                s1 = rmfield( s1, fn );
            else
%                 s.(itemtypes{i}).(datamodes{j}) = [];
            end
        end
        havework.(itemtypes{i}) = h;
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
    
%     if ~anywork
%         return;
%     end
    
    for i=1:length(itemtypes)
        deltype = itemtypes{i};
        if havework.(deltype)
            s.(deltype) = unifyDelData( s.(deltype).numitems, s.(deltype), primaryfield.(deltype) );
        end
    end
    
    % Delete upwards.
    
    s.edge.delmap = s.edge.delmap | any( s.vx.delmap( volcells.edgevxs ), 2 );
    s.edge = unifyDelData( s.edge.numitems, s.edge, 'delmap' );

    delfacemap = false( length(volcells.facevxs), 1 );
    for fi=1:length(volcells.facevxs)
        delfacemap(fi) = any( s.vx.delmap( volcells.facevxs{fi} ) ) | any( s.edge.delmap( volcells.faceedges{fi} ) );
    end
    s.face.delmap = delfacemap;
    s.face = unifyDelData( s.face.numitems, s.face, 'delmap' );
    
    delvolmap = false( length(volcells.polyfaces), 1 );
    for pi=1:length(volcells.polyfaces)
        delvolmap(pi) = any( s.face.delmap( volcells.polyfaces{pi} ) );
    end
    s.vol.delmap = delvolmap;
    s.vol = unifyDelData( s.vol.numitems, s.vol, 'delmap' );
    
    % Delete downwards.
    keepfacelist = unique( cell2mat( volcells.polyfaces(s.vol.keepmap) ) );
    keepfacemap = false( s.face.numitems, 1 );
    keepfacemap( keepfacelist ) = true;
    s.face.keepmap = s.face.keepmap & keepfacemap;
    s.face = unifyDelData( s.face.numitems, s.face, 'keepmap' );
    
    keepedgelist = unique( cell2mat( volcells.faceedges(s.face.keepmap,:) ) );
    keepedgemap = false( s.edge.numitems, 1 );
    keepedgemap( keepedgelist ) = true;
    s.edge.keepmap = s.edge.keepmap & keepedgemap;
    s.edge = unifyDelData( s.edge.numitems, s.edge, 'keepmap' );
    
    keepvxlist = unique( volcells.edgevxs(s.edge.keepmap,:) );
    keepvxmap = false( s.vx.numitems, 1 );
    keepvxmap( keepvxlist ) = true;
    s.vx.keepmap = s.vx.keepmap & keepvxmap;
    s.vx = unifyDelData( s.vx.numitems, s.vx, 'keepmap' );
    
    renumber = struct();
    for i=1:length(itemtypes)
        f = itemtypes{i};
        renumber.(f) = zeros( numitems.(f), 1, 'uint32' );
        renumber.(f)( s.(f).keepmap, 1 ) = (1:length(s.(f).keeplist))';
    end
    
    % We now have a consistent set of deletions to perform.
    volcells.vxs3d = volcells.vxs3d( s.vx.keepmap, : );
    volcells.vxfe = volcells.vxfe( s.vx.keepmap, : );
    volcells.vxbc = volcells.vxbc( s.vx.keepmap, : );
    volcells.edgevxs = dorenumber( renumber.vx, volcells.edgevxs( s.edge.keepmap, : ) );
    volcells.facevxs = dorenumber( renumber.vx, volcells.facevxs( s.face.keepmap, : ) );
    volcells.faceedges = dorenumber( renumber.edge, volcells.faceedges( s.face.keepmap, : ) );
    volcells.edgefaces = dorenumber( renumber.face, volcells.edgefaces( s.edge.keepmap, : ) );
    volcells.polyfaces = dorenumber( renumber.face, volcells.polyfaces( s.vol.keepmap, : ) );
    volcells.polyfacesigns = volcells.polyfacesigns( s.vol.keepmap, : );
    volcells.atcornervxs = volcells.atcornervxs( s.vx.keepmap, : );
    volcells.onedgevxs = volcells.onedgevxs( s.vx.keepmap, : );
    volcells.surfacevxs = volcells.surfacevxs( s.vx.keepmap, : );
    volcells.surfaceedges = volcells.surfaceedges( s.edge.keepmap, : );
    volcells.surfacefaces = volcells.surfacefaces( s.face.keepmap, : );
    
    validVolcells( volcells )
end

function a = dorenumber( renumberer, a )
    if iscell(a)
        for i=1:numel(a)
            a{i} = renumberer( a{i} );
        end
    else
        a = renumberer(a);
    end
end

function d = emptyDelinfo( n )
    d.delmap = false(n,1);
    d.dellist = [];
    d.keepmap = true(n,1);
    d.keeplist = (1:n)';
    d.numitems = n;
end