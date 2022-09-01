function newvolcells = mergeVolCellsVxs( volcells, tol, transitive )
%newvolcells = mergeVolCellsVxs( volcells, tol, transitive )
%   Merge vertexes of a volumetric mesh that are closer than TOL.

    newvolcells = volcells;
    [~,retained_vxs,remap_vxs] = mergenodesprox( volcells.vxs3d, tol, transitive );
    retained_vxs = uint32( retained_vxs );
    remap_vxs = uint32( remap_vxs );
    
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
    zeroEdges = newvolcells.edgevxs(:,1)==newvolcells.edgevxs(:,2);
    retained_edges_map( zeroEdges ) = false;
    remap_edges = uint32( cumsum( retained_edges_map ) );
    remap_edges( zeroEdges ) = 0;
    
    % Remap the face vertex and edge lists.
    zeroFaces = false( length( newvolcells.facevxs ), 1 );
    sortedFaceVxs = cell( length( newvolcells.facevxs ), 1 );
    for fi=1:length( newvolcells.facevxs )
        newvolcells.facevxs{fi} = remap_vxs( newvolcells.facevxs{fi} );
        newvolcells.faceedges{fi} = remap_edges( newvolcells.faceedges{fi} );
        zeroEdgesThisFace = newvolcells.faceedges{fi} == 0;
        newvolcells.facevxs{fi}( zeroEdgesThisFace ) = [];
        newvolcells.faceedges{fi}( zeroEdgesThisFace ) = [];
        zeroFaces(fi) = length( newvolcells.facevxs{fi} ) < 3;
        sortedFaceVxs{fi} = sort( newvolcells.faceedges{fi} )';
    end
    newvolcells.edgevxs = newvolcells.edgevxs( retained_edges_map, : );
    newvolcells.surfaceedges = newvolcells.surfaceedges( retained_edges_map );
    newvolcells.edgefaces = newvolcells.edgefaces( retained_edges_map );


    % Remove deleted faces.
    remap_faces = zeros( length( newvolcells.facevxs ), 1, 'uint32' );
    remap_faces( ~zeroFaces ) = (1:sum(~zeroFaces))';
    % Remove deleted faces from arrays indexed by faces.
    newvolcells.facevxs = newvolcells.facevxs( ~zeroFaces );
    newvolcells.faceedges = newvolcells.faceedges( ~zeroFaces );
    newvolcells.surfacefaces = newvolcells.surfacefaces( ~zeroFaces );
    % Remove deleted faces from any arrays we have defined that are indexed by faces.
    sortedFaceVxs = sortedFaceVxs( ~zeroFaces );

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
    remap_faces2( ~zeroFaces ) = faceremap( remap_faces2( ~zeroFaces ) );
    
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
