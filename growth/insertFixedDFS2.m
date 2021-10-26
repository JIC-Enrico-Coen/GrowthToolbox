function M = insertFixedDFS2( M, renumber, numfulldfs, stitchDFs, oppositePairs, stitchPairs )
%M = insertFixedDFS2( M, renumber, numfulldfs, stitchDFs )
%    M is a matrix indexed by reduced degrees of freedom.
%    Insert zeros into M so that it is indexed by the full degrees of
%    freedom.

% WARNING: not updated to use stitchDFs, oppositePairs, or stitchPairs.

    if ~isempty(renumber)
        result = sparse( numfulldfs, numfulldfs );
        result( renumber, renumber ) = M;
        M = result;
    end
end
