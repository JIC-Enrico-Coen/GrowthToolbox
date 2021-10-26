function roleindex = setrole( roleindex, keys, indexes )
% roleindex = setrole( roleindex, keys, indexes )
%
%   roleindex is a struct mapping keys to values.
%   keys is a cell array of fields, which may or may not exist in
%   roleindex.
%   indexes is a list of non-negative integers, one for each key.
%
%   Where indexes is zero, the corresponding field of roleindex, if it
%   exists, will be removed.  Otherwise, that field will be created if
%   necessary and set to that value.
%
%   If the same key appears multiple times in the arguments, only the last
%   occurrence will be effective.

    for i=1:length(keys)
        key = upper( keys{i} );
        index = indexes(i);
        if index==0
            roleindex = safermfield( roleindex, key );
        else
            roleindex.(key) = index;
        end
    end
end
