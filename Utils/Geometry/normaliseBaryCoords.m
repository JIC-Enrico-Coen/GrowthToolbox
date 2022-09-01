function bc = normaliseBaryCoords( bc )
%bc = normaliseBaryCoords( bc )
%   bc is a matrix in which each row is a set of barycentric coordinates
%   for a simplex. This presupposes that the sum of each row is 1.
%   This procedure normalises the coordinates so that they all lie in the
%   range of 0 to 1, while preserving the property of summing to 1.

    dims = size(bc,2);
    nonpos = bc <= 0;
    numnonpos = sum( nonpos, 2 );
    FOO = false;
    if FOO
        for i=1:size(bc,1)
            nonpos1 = nonpos(i,:); 
            numnonpos1 = numnonpos(i);
            if numnonpos1==dims-1
                bc(i,:) = double( ~nonpos1 );
            elseif numnonpos1 > 0
                bc = bc(i,:) - min(bc(i,:));
                bc(i,:) = bc/sum(bc);
            end
        end
    else
        FOO1 = false;
        if FOO1
            % Benchmarked 9 times as fast as alternative FOO1==false
            % for large sets of bcs. However, it uses a different
            % normalisation method that gives different results. This
            % formula might be preferable, but we shall need to look at the
            % places where it is used before deciding to switch.
            bc = max(bc,0);
            bc = bc ./ sum(bc,2);
        else
            % Benchmarked twice as fast as the alternative FOO==true for
            % large sets of bcs, and gives the same results.
            if dims > 3
                forceedge = numnonpos==2;
                bc( forceedge & (bc < 0) ) = 0;
            end
            forcecorner = numnonpos == dims-1;
            needscorrection = (numnonpos > 0) & ~forcecorner;
            bc(needscorrection,:) = bc(needscorrection,:) - min(bc(needscorrection,:),[],2);
            bc(needscorrection,:) = bc(needscorrection,:) ./ sum( bc(needscorrection,:), 2 );
            bc(forcecorner > 0,:) = double( ~nonpos(forcecorner > 0,:) );
        end
        xxxx = 1;
    end
end
