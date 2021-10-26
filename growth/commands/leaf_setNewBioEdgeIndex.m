function m = leaf_setNewBioEdgeIndex( m, index )
%m = leaf_setNewBioEdgeIndex( m, index )
%   Set the index that all subsequently created cellular edges will have.
%   This is a dynamic property, i.e. it is stored separately for each saved
%   mesh, not a single value for a whole project.
%
%   See also: leaf_setBioEdgeIndexedProperties

    m.secondlayer.newedgeindex = index;
end
