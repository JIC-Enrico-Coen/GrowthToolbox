function [m,ok_debug,delinfo] = leaf_deleteElements( m, elements )
%[m,ok_debug,delinfo] = leaf_deleteElements( m, elements )
%   Delete a specified set of finite elements of m.
%   ELEMENTS can be either a list of indexes of the the elements to be
%   deleted, or a boolean map that is true for the elements to be deleted.
%
%   See also: leaf_deletenodes

    [m,delinfo] = deleteFEs( m, elements );
    if isVolumetricMesh( m )
        m = restoreManifoldSurface( m );
    end
    ok_debug = validmesh( m );
end
