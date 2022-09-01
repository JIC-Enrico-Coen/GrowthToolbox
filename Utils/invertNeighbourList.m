function BtoA = invertNeighbourList( AtoB, numB )
%BtoA = invertNeighbourList( AtoB, numB )
%   Given a cell array indexed by an entity A, each member of which
%   contains indexes of type B, return a cell array indexes by B, in which
%   each member is a list of the A's that reference it. If numB is
%   supplied, this is the total number of B's. If not, the total number
%   will be taken to be the largest value occurring in AtoB.

    if isempty( AtoB )
        indexclass = 'uint32';
    else
        indexclass = class( AtoB{1} );
    end
    numA = length(AtoB);
    if nargin < 2
        numB = 0;
        for ci=1:numA
            numB = max( numB, max( AtoB{ci}(:) ) );
        end
    end
    
    BperA = zeros( numA, 1, 'uint32' );
    for ci=1:numA
        BperA(ci) = length(AtoB{ci});
    end
    
    BA = zeros( sum(BperA), 2, indexclass );
    vfi = 0;
    for Ai=1:numA
        Bs = AtoB{Ai};
        nfs = length(Bs);
        BA( (vfi+1):(vfi+nfs), 1 ) = Bs;
        BA( (vfi+1):(vfi+nfs), 2 ) = Ai;
        vfi = vfi+nfs;
    end
    BA = sortrows( BA );
    
    [starts,ends] = runends( BA(:,1) );
    BtoA = cell( numB, 1 );
    for i=1:length(starts)
        BtoA{ BA(starts(i),1) } = BA( starts(i):ends(i), 2 );
    end
end
