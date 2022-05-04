function [relmap,classes] = transitiveClosure( rel, mode )
%rel = transitiveClosure( rel, mode )
%   Find the closure of a binary relation under transitivity, symmetry,
%   reflexiveness, or any combination of these.
%
%   The binary relation is specified either as an N*N boolean matrix or an
%   N*2 list of pairs.
%
%   The MODE argument specifies which of the three properties is to be
%   produced. It is a string (case independent). If it contains an 's', the
%   relation is to be symmetric, if an 'r', it is to be reflexive, and if a
%   't', it is to be made transitive. The default is 'rst'.
%
%   When MODE is 'rst', the CLASSES result maps each value to the index of
%   its equivalence class. Otherwise, CLASSES is empty.

    if nargin < 2
        mode = 'rst';
    else
        mode = lower(mode);
    end
    refl = any( mode=='r' );
    sym = any( mode=='s' );
    trans = any( mode=='t' );

    reindex = ~islogical( rel );
    if islogical( rel )
        relmap = rel;
    else
        ris = unique(rel(:));
        n = length(ris);
        maxval = max(ris);
        invris = zeros( maxval, 1 );
        invris(ris) = (1:n);
        relmap = false( n, n );
        ri1 = invris(rel(:,1));
        ri2 = invris(rel(:,2));
        relmap( sub2ind( [n n], ri1, ri2 ) ) = true;
    end

    n = size(relmap,1);
    if sym
        relmap = relmap | relmap';
    end
    if refl
        relmap = relmap | eye(n,'logical');
    end
    if trans
        while true
            relmap2 = logical( relmap^2 ) | relmap;
            if all(relmap2(:) == relmap(:))
                break;
            end
            relmap = relmap2;
        end
    end
    
    if reindex
        relmap2 = false( maxval, maxval );
        relmap2(ris,ris) = relmap;
        relmap = relmap2;
        if refl
            relmap = relmap | eye(maxval,'logical');
        end
    end
    if refl && sym && trans
        [~,~,classes] = unique( relmap, 'rows', 'stable' );
    else
        classes = [];
    end
end
