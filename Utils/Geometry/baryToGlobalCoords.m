function gc = baryToGlobalCoords( cells, bcs, nodes, simplexes )
%gc = baryToGlobalCoords( cells, bcs, nodes, triangles )
%   Convert barycentric coordinates to global coordinates.
%   NODES is an N*D matrix containing the global coordinates of a set of N
%   points in D dimensions.
%   TRIANGLES is an M*K matrix containing the indexes of nodes of a set of
%   simplexes.  K will typically be 3 (triangles) or 4 (tetrahedra).
%   CELLS is a C*1 or 1*C vector of indexes of triangles.
%   BCS is a C*K array of barycentric coordinates.  bcs(i,:) is the
%   barycentric coordinates of a point in the triangle cells(i).
%   The result is a C*D array of global coordinates of all the given
%   points.
%
%   See also GLOBALTOBARYCOORDS.
%
%   Timing tests:
%       3.2 microseconds per point, for 100 points.
%       4 microseconds per point for 10 points.
%       20 microseconds per point for 1 point.

    spacedims = size(nodes,2);
    if isempty( cells )
        gc = zeros(0,spacedims);
        return;
    end
    vxspercell = size(simplexes,2);
    cellVxs = simplexes( cells, : );
    foo = permute( reshape( nodes( cellVxs', : ), vxspercell, [], spacedims ), [2 1 3] );
    gc = zeros( length(cells), spacedims );
    for ii=1:spacedims
        % Not much to choose between the two versions.
        gc(:,ii) = dot(foo(:,:,ii),bcs,2);
        %gc(:,ii) = sum(foo(:,:,ii).*bcs,2);
    end
% The following takes substantially longer.
%     for vi=1:length(cells)
%         gc(vi,:) = bcs(vi,:) * nodes( cellVxs( vi, : ), : );
%     end
end
