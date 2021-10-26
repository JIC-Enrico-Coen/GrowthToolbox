function [gi,roles] = growthIndexes( m )
%gi = growthIndexes( m )
%   Return the indexes of all morphogens that specify growth rates.
%
%   If ROLES is requested, the list of corresponding role names is also
%   returned.
%
%   Valid for all types of mesh.

    roles = {'KAPAR','KAPER','KBPAR','KBPER','KNOR','KPAR','KPAR2'};
    gi = FindMorphogenRole( m, roles );
    valid = gi ~= 0;
    gi = gi(valid);
    if nargout > 1
        roles = roles(valid);
    end
end
