function [m,ok_debug] = leaf_deleteElements( m, elements )
%m = leaf_deleteElements( m, elements )
%   Delete a specified set of finite elements of m.
%   ELEMENTS can be either a list of indexes of the the elements to be
%   deleted, or a boolean map that is true for the elements to be deleted.

    m = deleteFEs( m, elements );
    m = restoreManifoldSurface( m );
    ok_debug = validmesh( m );
end
