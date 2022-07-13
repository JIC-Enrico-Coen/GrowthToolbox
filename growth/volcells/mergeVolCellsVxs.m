function newvolcells = mergeVolCellsVxs( volcells, tol, transitive )
%newvolcells = mergeVolCellsVxs( volcells, tol, transitive )
%   Merge vertexes of a volumetric mesh that are closer than TOL.
%
%   INCOMPLETE, WORK SUSPENDED UNTIL I ACTUALLY NEED THIS.

    newvolcells = volcells;
    [newvolcells.vxs3d,remap_vxs] = mergenodesprox( volcells.vxs3d, tol, transitive );
    
    % We want to replace every group of vertexes by their mean. Don't we
    % already have something to do this?
    % Yes, see sumArray, minArray, maxArray, averageArray,
    % weightedAverageArray. But these only allow for one-dimensional
    % values. Hence averageArrayRows() below.
    
    [newvolcells.vxs3d,vxnumreps] = averageArrayRows( remap_vxs, volcells.vxs3d );
    
    newvolcells.edgevxs = sort( remap_vxs( newvolcells.edgevxs ), 2 );
    [newvolcells.edgevxs,~,remap_edges] = unique( newvolcells.edgevxs, 'rows', 'stable' );
    
    % Some edges may be so short that their ends are merged. These edges
    % must be eliminated.
    zeroEdges = newvolcells.edgevxs(:,1)==newvolcells.edgevxs(:,2);
    
    for fi=1:length( newvolcells.facevxs )
        newvolcells.facevxs{fi} = remap_vxs( newvolcells.facevxs{fi} );
        newvolcells.faceedges{fi} = remap_edges( newvolcells.faceedges{fi} );
        zeroEdgesThisFace = zeroEdges( newvolcells.faceedges{fi} );
        newvolcells.facevxs{fi}( zeroEdgesThisFace ) = [];
        newvolcells.faceedges{fi}( zeroEdgesThisFace ) = [];
    end
    
    % Faces reduced to two or fewer edges must be eliminated.
    
    % Now detect duplicate faces. This is tricky. Duplicates are faces with
    % the same vertex list in either the same or opposite order, but the
    % lists can start anywhere. We also have to correct the polyfacesigns
    % in all volumes that include the merged faces.
    
    % If two faces get merged, this may affect volumes in complicated
    % ways.
    
    
    
    
    % Now detect duplicate volumes. These are volumes consisting of the
    % same faces in any order.
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
    n = zeros(shape,'int32');
    for i=1:numel(indexes)
        ii = indexes(i);
        a(ii,:) = a(ii,:) + values(i,:);
        n(ii) = n(ii) + 1;
    end
    nz = n ~= 0;
    a(nz,:) = a(nz,:)./double(n(nz));
end
