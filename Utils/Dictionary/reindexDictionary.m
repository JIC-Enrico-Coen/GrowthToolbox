function reindex = reindexDictionary( ni1, in1, ni2, in2 )
%reindex = reindexDictionary( ni1, in1, ni2, in2 )
%   ni1 and in1 are the mappings between names and indexes for a
%   dictionary.  ni2 and in2 are the same for another dictionary.
%   This procedure returns information for use in reindexing data whose
%   indexes are appropriate to the first dictionary, so that they will be
%   appropriate for the second.
%
%   In GFtbox, this is used to update various parts of the mesh structure
%   when morphogens or cell factors are renamed, added, or deleted.
%
%   To transform an array foo whose second dimension is indexed by the first
%   dictionary, do this:
%   	foo(:,reindex.perm) = [ foo(:,reindex.retained), zeros( size(foo,1), reindex.numextra ) ];
%       if reindex.numnew < reindex.numold
%           foo(:,reindex.deleted) = [];
%       end


    newtoold = zeros(1,length(in2));
    for newindex=1:length(in2)
        try
            oldindex = ni1.(in2{newindex});
        catch
            oldindex = 0;
        end
        newtoold(newindex) = oldindex;
    end
    if (length(newtoold)==length(in1)) && all( newtoold==(1:length(in1)) )
        % No change.
        reindex = [];
        return;
    end
    
    oldtonew = zeros(1,length(in1));
    for oldindex=1:length(in1)
        try
            newindex = ni2.(in1{oldindex});
        catch
            newindex = 0;
        end
        oldtonew(oldindex) = newindex;
    end
    
    
    numold = length(in1);
    numnew = length(in2);
    deleted = (numnew+1):numold;
    retained = oldtonew ~= 0;
    numRetained = sum(retained);
    numextra = numnew - numRetained;
    extra = find( newtoold==0 );
    perm( 1:numRetained ) = oldtonew(retained);
    perm( (numRetained+1):(numRetained+numextra) ) = extra;
    
    reindex = struct( ...
                'perm', perm, ...
                'retained', retained, ...
                'deleted', deleted, ...
                'numold', numold, ...
                'numnew', numnew, ...
                'numextra', numextra ...
              );
end
