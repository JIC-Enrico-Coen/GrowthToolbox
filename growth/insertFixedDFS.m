function v = insertFixedDFS( v, renumber, numfulldfs, ...
    stitchDFs, oppositePairs, stitchPairs, oppMoves, rowsToFix, fixedMoves )
%v = insertFixedDFS( v, renumber, numfulldfs, stitchDFs, oppositePairs, stitchPairs, oppMoves, rowsToFix, fixedMoves, )
%    v is a vector indexed by reduced degrees of freedom.
%    Insert zeros into v so that it is indexed by the full degrees of
%    freedom.
%
%   stitchDFs is a set of sets of dfs.  Each set is represented by a single
%   element of v, and the value of that element is to be replicated to all
%   members of the set.
%
%   oppositePairs is a set of pairs of dfs that are to be given equal and
%   opposite values.  For each pair, the first is listed in v and the
%   second is not.
%
%   stitchPairs is a set of pairs of dfs that are to be given equal values.
%   As such, this duplicates some of the functionality of stitchDFs.
%
%   oppMoves is an amount by which every pair in oppositePairs is to be
%   moved.
%
%   rowsToFix and fixedMoves specify a set of dfs, absent from v, which are
%   to be given the values in fixedMoves.  rowsToFix and fixedMoves musdt
%   be the same length, or fixedMoves must be a single value.
%
%   oppMoves, rowsToFix, fixedMoves are not implemented for
%   insertFixedDFS2, implying that these features cannot be used at all.

    if isempty(v)
        v = zeros( numfulldfs, 1 );
        return;
    end
        
    if ~isempty(renumber)
        result = zeros( numfulldfs, 1 );
        result( renumber ) = v;
        v = result;
    end
    if iscell(stitchDFs)
        for i=1:length(stitchDFs)
            vxs = stitchDFs{i};
            v(vxs(2:end)) = v(vxs(1));
        end
    else
        for i=1:size(stitchDFs,1)
            vxs = stitchDFs(i,:);
            v(vxs(2:end)) = v(vxs(1));
        end
    end
    if ~isempty(stitchPairs)
        v(stitchPairs(:,2)) = v(stitchPairs(:,1));
    end
    if ~isempty(oppositePairs)
        v(oppositePairs(:,2)) = -v(oppositePairs(:,1));
        if ~isempty(oppMoves)
            v(oppositePairs(:,1)) = v(oppositePairs(:,1)) + oppMoves;
            v(oppositePairs(:,2)) = v(oppositePairs(:,2)) + oppMoves;
        end
    end
    if ~isempty( fixedMoves )
        v(rowsToFix) = fixedMoves;
    end
end
