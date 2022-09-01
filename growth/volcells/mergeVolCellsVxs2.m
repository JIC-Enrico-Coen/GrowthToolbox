function newvolcells = mergeVolCellsVxs2( volcells, tol, transitive )
%newvolcells = mergeVolCellsVxs( volcells, tol, transitive )
%   Merge vertexes of a volumetric mesh that are closer than TOL.

    [~,retained_vxs,remap_vxs] = mergenodesprox( volcells.vxs3d, tol, transitive );
    retained_vxs = uint32( retained_vxs );
    remap_vxs = uint32( remap_vxs );
    
    % Determine which edges should be deleted or merged.
    sortededgevxs = sort( remap_vxs( volcells.edgevxs ), 2 );
    zeroedges = sortededgevxs(:,1)==sortededgevxs(:,2);
    [~,retained_edges,remap_edges] = unique( sortededgevxs, 'rows', 'stable' );
    [retained_edgesA,remap_edgesA] = deleteMore( retained_edges, remap_edges, zeroedges );
    retained_edges = retained_edgesA;
    remap_edges = remap_edgesA;
%     retained_edges = uint32( retained_edges );
%     remap_edges = uint32( remap_edges );
%     
%     retained_edges_map = false( size(volcells.edgevxs,1), 1 );
%     retained_edges_map( retained_edges ) = true;
%     retained_edges_map( zeroedges(remap_edges) ) = false;
%     num_retained_edges = sum( retained_edges_map );
%     remap_edgesA = zeros( size( remap_edges ), 'uint32' );
%     remap_edgesA( retained_edges_map ) = uint32( 1:num_retained_edges );
%     
%     remap_edges = remap_edgesA;
    
    % Determine which faces should be deleted or merged.
    zerofaces = false( length( volcells.facevxs ), 1 );
    sortedFaces = cell( length( volcells.facevxs ), 1 );
    for fi=1:length( volcells.facevxs )
        fedges = remap_edges( volcells.faceedges{fi} );
        fedges = fedges(fedges>0);
        zerofaces(fi) = length( unique( fedges ) ) < 3;
        sortedFaces{fi} = sort( fedges(fedges>0) );
    end
    raggedFaces = cellToRaggedArray( sortedFaces', 0 )';
    [~, retained_faces, remap_faces] = unique( raggedFaces, 'rows', 'stable' );
    [retained_facesA,remap_facesA] = deleteMore( retained_faces, remap_faces, zerofaces );
    retained_faces = retained_facesA;
    remap_faces = remap_facesA;
    
%     retained_faces = uint32( retained_faces );
%     remap_faces = uint32( remap_faces );
%     
%     retained_faces_map = false( size(volcells.facevxs,1), 1 );
%     retained_faces_map( retained_faces ) = true;
%     retained_faces_map( zerofaces(remap_faces) ) = false;
%     retained_faces = find( retained_faces_map );
%     remap_faces( zerofaces ) = 0;
    
    % Determine which volumes should be deleted or merged.
    zerovols = false( length( volcells.polyfaces ), 1 );
    sortedVols = cell( length(volcells.polyfaces), 1 );
    for vi=1:length( volcells.polyfaces )
        pf = volcells.polyfaces{vi};
        pf = remap_faces(pf);
        pf = unique( pf(pf~=0) );
        zerovols(vi) = length(pf) < 4;
        sortedVols{vi} = pf;
    end
    sortedVols = cellToRaggedArray( sortedVols', 0 )';
    [~,retained_vols,remap_vols] = unique( sortedVols, 'rows', 'stable' );
    [retained_volsA,remap_volsA] = deleteMore( retained_vols, remap_vols, zerovols );
    retained_vols = retained_volsA;
    remap_vols = remap_volsA;
    
    if false
        % Eliminate faces that will not be referenced by any volume, edges not
        % referenced by any face, and vertexes not referenced by any edge.
        usedfacesmap = getReferenced( volcells.polyfaces, retained_vols, length(volcells.facevxs) );
        usedfacesmapnew = usedfacesmap( retained_faces, 1 );
        usedfacesnew = retained_faces( usedfacesmapnew, 1 );
        usededgesmap = getReferenced( volcells.faceedges, usedfacesnew, size(volcells.edgevxs,1) );
        usededgesmapnew = usededgesmap( retained_edges, 1 );
        usededgesnew = retained_edges( usededgesmapnew, 1 );
        usedvxsmap = getReferenced( volcells.edgevxs, usededgesnew, size(volcells.vxs3d,1) );
        usedvxsmapnew = usedvxsmap( retained_vxs, 1 );
        usedvxsnew = retained_vxs( usedvxsmapnew, 1 );
        if any( ~usedfacesmapnew )
            % PROBLEM: usedfacesmapnew is the wrong size. We want 
            [retained_facesA,remap_facesA] = deleteMore( retained_faces, remap_faces, zerofaces | remap_faces( ~usedfacesmapnew ) );
            retained_faces = retained_facesA;
            remap_faces = remap_facesA;
        end
        if any( ~usededgesmapnew )
            [retained_edgesA,remap_edgesA] = deleteMore( retained_edges, remap_edges, zeroedges | ~usededgesmapnew );
            retained_edges = retained_edgesA;
            remap_edges = remap_edgesA;
        end
        if any( ~usedvxsmapnew )
            [retained_vxsA,remap_vxsA] = deleteMore( retained_vxs, remap_vxs,  ~usedvxsmapnew );
            retained_vxs = retained_vxsA;
            remap_vxs = remap_vxsA;
        end
    end

    % We now have all the information needed to build newvolcells.
    
    newvolcells.vxs3d = volcells.vxs3d( retained_vxs, : );
    newvolcells.vxfe = volcells.vxfe( retained_vxs );
    newvolcells.vxbc = volcells.vxbc( retained_vxs, : );
    newvolcells.edgevxs = sort( remap_a_to_b( volcells.edgevxs, retained_edges, remap_vxs ), 2 );
    newvolcells.edgefaces = remap_a_to_b( volcells.edgefaces, retained_edges, remap_faces );
    newvolcells.facevxs = volcells.facevxs( retained_faces );
    newvolcells.faceedges = volcells.faceedges( retained_faces );
    for fi=1:length(newvolcells.facevxs)
        if fi==19
            xxxx = 1;
        end
        fedges = remap_edges( newvolcells.faceedges{fi} );
        fvxs = remap_vxs( newvolcells.facevxs{fi} );
        keep = fedges > 0;
        newvolcells.faceedges{fi} = fedges( keep );
        newvolcells.facevxs{fi} = fvxs( keep );
    end
    newvolcells.polyfaces = volcells.polyfaces( retained_vols, 1 );
    newvolcells.polyfacesigns = volcells.polyfacesigns( retained_vols, 1 );
    for pi=1:length(newvolcells.polyfaces)
        pf1 = newvolcells.polyfaces{pi};
        pf2 = remap_faces( pf1 );
        keepfaces = pf2 ~= 0;
        newvolcells.polyfaces{pi,1} = pf2(keepfaces);
        newvolcells.polyfacesigns{pi,1} = newvolcells.polyfacesigns{pi}(keepfaces);
    end
    newvolcells.atcornervxs = volcells.atcornervxs( retained_vxs, 1 );
    newvolcells.onedgevxs = volcells.onedgevxs( retained_vxs, 1 );
    newvolcells.surfacevxs = volcells.surfacevxs( retained_vxs, 1 );
    newvolcells.surfaceedges = volcells.surfaceedges( retained_edges, 1 );
    newvolcells.surfacefaces = volcells.surfacefaces( retained_faces, 1 );
    newvolcells.surfacevolumes = volcells.surfacevolumes( retained_vols, 1 );
    
    
    
    
    
    
    % The surface* fields must be recomputed.
    newvolcells2 = setSurfaceElements( newvolcells );
    newvolcells = newvolcells2;
    
    validVolcells( newvolcells );
    
    xxxx = 1;
    return;
    
%ok              vxs3d: [24×3 double]
%ok            facevxs: {14×1 cell}
%ok          polyfaces: {[14×1 uint32]}
%??      polyfacesigns: {[14×1 logical]}
%ok               vxfe: [24×1 uint32]
%ok               vxbc: [24×4 double]
%ok            edgevxs: [36×2 uint32]
%ok          edgefaces: {36×1 cell}
%ok          faceedges: {14×1 cell}
%ok        atcornervxs: [24×1 logical]
%ok          onedgevxs: [24×1 logical]
%ok         surfacevxs: [24×1 logical]
%ok       surfaceedges: [36×1 logical]
%ok       surfacefaces: [14×1 logical]
%ok     surfacevolumes: 1
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    % Replace every group of vertexes by its mean. averageArray() would do
    % this, but it only allows for one-dimensional values. Hence
    % averageArrayRows() below.
    
    [newvolcells.vxs3d,vxnumreps] = averageArrayRows( remap_vxs, volcells.vxs3d );
    newvolcells.vxfe = newvolcells.vxfe( retained_vxs );
    newvolcells.vxbc = newvolcells.vxbc( retained_vxs, : );
    newvolcells.surfacevxs = newvolcells.surfacevxs( retained_vxs );
    newvolcells.atcornervxs = newvolcells.atcornervxs( retained_vxs );
    newvolcells.onedgevxs = newvolcells.onedgevxs( retained_vxs );

    % Find which edges are now identical and merge them.
    oldedgevxs = newvolcells.edgevxs;
    newvolcells.edgevxs = sort( remap_vxs( newvolcells.edgevxs ), 2 );
    [foo,retained_edges,remap_edges] = unique( newvolcells.edgevxs, 'rows', 'stable' );
    remap_edges = uint32( remap_edges );
    retained_edges = uint32( retained_edges );
    retained_edges_map = false( size(newvolcells.edgevxs,1), 1 );
    retained_edges_map( retained_edges ) = true;
    
    % Some edges may be between merged vertexes. These edges must be
    % eliminated.
    zeroedges = newvolcells.edgevxs(:,1)==newvolcells.edgevxs(:,2);
    retained_edges_map( zeroedges ) = false;
    remap_edges = uint32( cumsum( retained_edges_map ) );
    remap_edges( zeroedges ) = 0;
    
    % Remap the face vertex and edge lists.
    zerofaces = false( length( newvolcells.facevxs ), 1 );
    sortedFaceVxs = cell( length( newvolcells.facevxs ), 1 );
    for fi=1:length( newvolcells.facevxs )
        newvolcells.facevxs{fi} = remap_vxs( newvolcells.facevxs{fi} );
        newvolcells.faceedges{fi} = remap_edges( newvolcells.faceedges{fi} );
        zeroEdgesThisFace = newvolcells.faceedges{fi} == 0;
        newvolcells.facevxs{fi}( zeroEdgesThisFace ) = [];
        newvolcells.faceedges{fi}( zeroEdgesThisFace ) = [];
        zerofaces(fi) = length( newvolcells.facevxs{fi} ) < 3;
        sortedFaceVxs{fi} = sort( newvolcells.faceedges{fi} )';
    end
    newvolcells.edgevxs = newvolcells.edgevxs( retained_edges_map, : );
    newvolcells.surfaceedges = newvolcells.surfaceedges( retained_edges_map );
    newvolcells.edgefaces = newvolcells.edgefaces( retained_edges_map );


    % Remove deleted faces.
    remap_faces = zeros( length( newvolcells.facevxs ), 1, 'uint32' );
    remap_faces( ~zerofaces ) = (1:sum(~zerofaces))';
    % Remove deleted faces from arrays indexed by faces.
    newvolcells.facevxs = newvolcells.facevxs( ~zerofaces );
    newvolcells.faceedges = newvolcells.faceedges( ~zerofaces );
    newvolcells.surfacefaces = newvolcells.surfacefaces( ~zerofaces );
    % Remove deleted faces from any arrays we have defined that are indexed by faces.
    sortedFaceVxs = sortedFaceVxs( ~zerofaces );

    % Find which faces coincide.
    sortedFaceVxs = cellToRaggedArray( sortedFaceVxs, 0 );
    [~,retained_faces,faceremap] = unique( sortedFaceVxs, 'rows', 'stable' );
    retained_faces = uint32( retained_faces );
    faceremap = uint32( faceremap );
    retained_faces_map = false( length( newvolcells.facevxs ), 1 );
    retained_faces_map( retained_faces ) = true;
    
    rotatedFvxs = newvolcells.facevxs;
    for fi=1:length( newvolcells.facevxs )
        % Rotate the vertex and edge lists to start with the vertex of minimal index.
        [~,mini] = min(newvolcells.facevxs{fi});
        rotatedFvxs{fi} = rotatedFvxs{fi}([(mini:end), 1:(mini-1)]);
    end
    % We expect coincident faces to have the same vertexes listed in either
    % the same or opposite order. We have arranged that in rotatedFvxs, all
    % the vertex lists begin with the vertex of minimal index. We shall
    % therefore stipulate that two faces have the same sense if rotatedFvxs
    % also agrees at the second vertex.
    samefacesense = true( length( newvolcells.facevxs ), 1 );
    for fi=1:length( newvolcells.facevxs )
        samefacesense(fi) = retained_faces_map(fi) || (rotatedFvxs{ fi }(2) == rotatedFvxs{ faceremap(fi) }(2));
    end
    % Update remap_faces.
    remap_faces2 = remap_faces;
    remap_faces2( ~zerofaces ) = faceremap( remap_faces2( ~zerofaces ) );
    
    % Renumber all fields that reference faces.
    for vi=1:length( newvolcells.polyfaces )
        pf = newvolcells.polyfaces{vi};
        pf = remap_faces2( pf );
        properfaces = pf ~= 0;
        pf = pf( properfaces );
%         sfs = samefacesense( pf(pf ~= 0) );
        newvolcells.polyfacesigns{vi} = newvolcells.polyfacesigns{vi}( properfaces );
%         newvolcells.polyfacesigns{vi} = newvolcells.polyfacesigns{vi}==sfs;
        newvolcells.polyfaces{vi} = pf;
    end
    for ei=1:length( newvolcells.edgefaces )
        newvolcells.edgefaces{ei} = remap_faces2( newvolcells.edgefaces{ei} );
        newvolcells.edgefaces{ei} = newvolcells.edgefaces{ei}( newvolcells.edgefaces{ei} ~= 0 );
    end
    
    % Reindex all fields indexed by faces.
    newvolcells.facevxs = newvolcells.facevxs( retained_faces );
    newvolcells.faceedges = newvolcells.faceedges( retained_faces );
    newvolcells.surfacefaces = newvolcells.surfacefaces( retained_faces );
    
    
    
    
    % At this point newvolcells should be valid, except possibly for some
    % surface faces being no longer on the surface.
    validVolcells( newvolcells )
    
    % Delete volumes that have fewer than four faces.
    zerovolumes = false( length( newvolcells.polyfaces ), 1 );
    sortedvolfaces = cell( length( newvolcells.polyfaces ), 1 );
    for vi=1:length( newvolcells.polyfaces )
        zerovolumes(vi) = length( newvolcells.polyfaces{vi} ) < 4;
        sortedvolfaces{vi} = sort( newvolcells.polyfaces{vi} );
    end
    sortedvolfaces( zerovolumes ) = [];
    newvolcells.polyfaces( zerovolumes ) = [];
    newvolcells.polyfacesigns( zerovolumes ) = [];
    polyfacearray = cellToRaggedArray( sortedvolfaces', 0 )';
    [~,retainedvols,remapvols] = unique( polyfacearray, 'rows', 'stable' );
    retainedvols = uint32( retainedvols );
    remapvols = uint32( remapvols );
    newvolcells.polyfaces = newvolcells.polyfaces( retainedvols );
    newvolcells.polyfacesigns = newvolcells.polyfacesigns( retainedvols );
    
    % At this point newvolcells should be valid, except possibly for some
    % surface faces being no longer on the surface.
    validVolcells( newvolcells )
    
    % Recompute the surface vertexes.
    newvolcells = setSurfaceElements( newvolcells );
    
     % At this point newvolcells should be valid.
    validVolcells( newvolcells )
end

function [a,n] = averageArrayRows( indexes, values )
%[a,n] = averageArrayRows( indexes, values )
%   Given an N*K array VALUES and an array INDEXES into the first dimension
%   of VALUES, construct an M*K array A such that A(I) = the average of the
%   rows of VALUES for which the corresponding element of INDEXES is I.  K
%   is the maximum value of INDEXES. N is a list of the number of times
%   each index occurred. If an index in the range 1:k does not occur, the
%   corresponding row of A will be all zero.

    shape = [ max(indexes(:)), size(values,2) ];
    a = zeros( shape );
    n = zeros(shape(1),1,'int32');
    for i=1:numel(indexes)
        ii = indexes(i);
        a(ii,:) = a(ii,:) + values(i,:);
        n(ii) = n(ii) + 1;
    end
    nz = n ~= 0;
    a(nz,:) = a(nz,:)./double(n(nz));
end

function a = remap_any_array( a, remap )
    if iscell(a)
        for i=1:numel(a)
            x = remap( a{i} );
            x(x==0) = [];
            a{i} = x;
        end
    else
        a = remap(a);
    end
end

function data = remap_a_to_b( data, remap_a, remap_b )
    if iscell( data )
        data = data( remap_a(remap_a ~= 0), : );
        for i=1:numel(data)
            data{i} = remap_b( data{i} );
            data{i} = data{i}( data{i} ~= 0 );
        end
    else
        data = remap_b( data( remap_a(remap_a ~= 0), : ) );
    end
end

function [retained,remap_retained] = deleteFromRetainedMap( retained, delitems )
    retained_map = false( max(retained), 1 );
    retained_map( retained ) = true;
    retained_map( delitems ) = false;
    retained2 = find( retained_map );
    retained = retained2;
    remap_retained = uint32(1:max(retained))';
    remap_retained = cumsum( retained_map );
end

function [retained,remap] = deleteMore( retained, remap, delitems )
    retained = uint32( retained );
    remap = uint32( remap );
    if ~any(delitems)
        return;
    end
    
    remap2 = remap;
    remap2( delitems ) = 0;
    
    retained2 = retained;
    retained2( delitems(retained2) ) = 0;
    foo = (1:length(retained2))' - cumsum( retained2==0 );
    foo( remap(delitems) ) = 0;
    remap3 = remap2;
    remap3(remap3~=0) = foo( remap3(remap3~=0) );
    retained2( retained2==0 ) = [];
    
    retained = retained2(:);
    remap = remap3(:);
end

function usedmap = getReferenced( referencingarray, usedreferences, num )
    if iscell( referencingarray )
        referencingarray = cell2mat( referencingarray(usedreferences) );
    else
        referencingarray = referencingarray( usedreferences, : );
        referencingarray = referencingarray(:);
    end
    referencingarray = unique( referencingarray );
    usedmap = false( num, 1 );
    usedmap(referencingarray) = true;
end