function [ci,bc,pt] = hitmesh( m, hitLine )
%ci = hitmesh( m, hitLine )
%   Return the element of m that is first intersected by the hitline, 0 if
%   there is no such cell.
%
%   This is rather slow: it tests every element of m for intersection.
%   There are more efficient ways of doing this, but they're not worth the
%   effort of programming.

    numcells = size( m.tricellvxs, 1 );
    hitVector = hitLine(2,:) - hitLine(1,:);
    hits = zeros( [], 8 );
    nearhit = [];
    numhits = 0;
    bestbcmin = -0.2;
    for i=1:numcells
        [bc,pt] = findHitBC( m, i, hitLine, false, m.plotdefaults.thick );
        updatebest( bc(1,:), pt(1,:) );
        if m.plotdefaults.thick
            updatebest( bc(2,:), pt(2,:) );
        end
    end
    if isempty(hits)
        besthit = nearhit;
    else
        hits = sortrows( hits );
        besthit = hits(1,:);
    end
    if isempty(besthit)
        ci = 0;
        bc = [0 0 0];
        pt = [0 0 0];
    else
        ci = besthit(2);
        bc = normaliseBaryCoords( besthit(3:5) );
        pt = besthit(6:8);
    end
    
    function updatebest( bc, pt )
        bcmin = min(bc);
        if bcmin >= 0
            numhits = numhits+1;
            hits(numhits,:) = [ dot(pt,hitVector), i, bc, pt ];
            nearhit = [];
            bestbcmin = 0;
        elseif bcmin > bestbcmin
            bestbcmin = bcmin;
            nearhit = [ dot(pt,hitVector), i, bc, pt ];
            fprintf( 1, '%s: nearhit, bc [ %f, %f, %f ]\n', mfilename(), bc );
        end
    end
end
