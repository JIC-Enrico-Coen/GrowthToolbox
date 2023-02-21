function [K,f,renumber] = eliminateEquations( K, f, rowsToElim, stitchDFsets, ...
    oppositePairs, stitchPairs, rowsToFix, fixedMoves )
%(K,f] = eliminateEquations( K, f, rowsToElim, stitchDFsets, oppositePairs, stitchPairs, oppMoves )
%
%    For each i in rowsToElim, delete row i of f and row and column i of K.
%
%    For each array in stitchDFsets, impose the constraint that the
%    corresponding set of variables are all equal.
%
%    For each pair [i,j] in oppositePairs, impose the condition that the
%    corresponding variables x and y have the property that x+y=0, i.e.
%    these dfs move by equal and opposite amounts.
%
%    For each pair [i,j] in stitchPairs, impose the condition that the
%    corresponding variables are equal.  If any vertex appears in both
%    oppositePairs and stitchPairs, remove it from stitchPairs and ensure
%    that its partner in stitchPairs appears in oppositePairs.
%
%    rowsToFix and fixedMoves have equal length, and the equations are
%    transformed to impose the condition that the variables for these rows
%    must take these fixed values.
%
%    Overlaps among these are resolved as follows:
%
%   

    if nargin < 4
        stitchDFsets = [];
    end
    if nargin < 5
        oppositePairs = [];
    end
    if nargin < 6
        stitchPairs = [];
    end
    if nargin < 7
        rowsToFix = [];
    end
    if nargin < 8
        fixedMoves = [];
    end
    [oppstitch,osi,osj] = intersect( oppositePairs(:), stitchPairs(:) );
    if ~isempty(oppstitch)
        orows = mod( osi-1, size(oppositePairs,1) ) + 1;
        zeroopp = oppositePairs( orows, : );
        srows = mod( osj-1, size(stitchPairs,1) ) + 1;
        zerostitched = stitchPairs( srows, : );
        oppositePairs( orows, : ) = [];
        stitchPairs( srows, : ) = [];
        rowsToElim = unique( [ rowsToElim(:), zeroopp(:), zerostitched(:) ] );
    end
    if iscell(stitchDFsets)
        for i=1:length(stitchDFsets)
            r = stitchDFsets{i};
            if islogical(r)
                r = find(r);
            end
            nr = 1/length(r);
            K(:,r(1)) = sum( K(:,r), 2 );
            K(r(1),:) = nr * sum( K(r,:), 1 );
            f(r(1)) = nr * sum( f(r) );
            rowsToElim = [ rowsToElim; r(2:end) ];
        end
    else
        for i=1:size(stitchDFsets,1)
            r = stitchDFsets(i,:);
            if islogical(r)
                r = find(r);
            end
            nr = 1/length(r);
            K(:,r(1)) = sum( K(:,r), 2 );
            K(r(1),:) = nr * sum( K(r,:), 1 );
            f(r(1)) = nr * sum( f(r) );
            rowsToElim = [ rowsToElim; r(2:end) ];
        end
    end
    if ~isempty( stitchPairs )
        K(:,stitchPairs(:,1)) = (K(:,stitchPairs(:,1)) + K(:,stitchPairs(:,2)));
        K(stitchPairs(:,1),:) = (K(stitchPairs(:,1),:) + K(stitchPairs(:,2),:))/2;
        f(stitchPairs(:,1)) = (f(stitchPairs(:,1)) + f(stitchPairs(:,2)))/2;
        rowsToElim = [ rowsToElim; stitchPairs(:,2) ];
    end
    if (nargin >= 5) && ~isempty(oppositePairs)
        o1 = oppositePairs(:,1);
        o2 = oppositePairs(:,2);
        K(o1,:) = K(o1,:) - K(o2,:);
        Koppsum = K(o1,o1) + K(o1,o2);
        K(:,o1) = K(:,o1) - K(:,o2);
        f(o1) = f(o1) - f(o2);
%         if ~isempty(oppMoves)
%             f(o1) = f(o1) + Koppsum * oppMoves;
%         end
        rowsToElim = [ rowsToElim; o2 ];
    end
    
    if ~isempty( fixedMoves )
        rowsToElim = [ rowsToElim; rowsToFix ];
        f = f - K(:,rowsToFix) * fixedMoves;
    end

    if isempty(rowsToElim)
        if nargout >= 3
            renumber = [];
        end
    else
        remainingRows = eliminateVals( size(K,1), rowsToElim );
        K = K(remainingRows,remainingRows);
        f = f(remainingRows);
        if nargout >= 3
            renumber = remainingRows;
        end
    end
end
