function [newbc,newci] = splitbc( oldbc, ci, splitinfo )
%newbc = splitbc( oldbc, splitinfo )
%   When a finite element is split, any points within it that were defined
%   by their barycentric coordinates must have those coordinates recomputed,
%   and the descendant cell containing the point must be found.  That is
%   done by this function.
%
%   ci is the cell that was split.  splitinfo is an array of six elements
%   [ nc1, nc2, nc3, ci1, ci2, ci3 ].  ci1, ci2, and ci3 are the indexes
%   within the cell of the edges with those that were split coming first.
%   nc1, nc2, and nc3 are the indexes of the new cells.  If only two edges were
%   split, nc3 is zero or -1, and if only one edge, nc2 is also zero.  The edges
%   and cells are listed in a canonical order, for which see the code here,
%   or look at how splitinfo is computed in splitalledges.m.

    newbc = [0 0 0];
    oldbc = oldbc(splitinfo(4:6));
    if splitinfo(2)==0
        % One side of the cell was split.
        nc1 = splitinfo(1);
        [newbc,newci] = split1( oldbc, ci, nc1 );
    elseif splitinfo(3) <= 0
        nc1 = splitinfo(1);
        nc2 = splitinfo(2);
        if splitinfo(3)==0
            [newbc,newci] = split1( oldbc, ci, nc1 );
            if newci==nc1
                [newbc,newci] = split1( newbc([2 1 3]), newci, nc2 );
                if newci==nc1
                    newbc = newbc([1 3 2]);
                else
                    newbc = newbc([2 1 3]);
                end
            end
        else
            [newbc([2 1 3]),newci] = split1( oldbc([2 1 3]), ci, nc1 );
            if newci==nc1
                [newbc,newci] = split1( newbc, newci, nc2 );
            end
        end
    else
        nc1 = splitinfo(1);
        nc2 = splitinfo(2);
        nc3 = splitinfo(3);
        if oldbc(1) >= 0.5
%             newbc(1) = oldbc(1)*2 - 1;
%             newbc([2,3]) = oldbc([2,3])*2;
            newbc = oldbc*2 - [1 0 0];
            newci = nc1;
        elseif oldbc(2) >= 0.5
%             newbc(1) = oldbc(2)*2 - 1;
%             newbc([2,3]) = oldbc([3,1])*2;
            newbc = oldbc([2 3 1])*2 - [1 0 0];
            newci = nc2;
        elseif oldbc(3) >= 0.5
%             newbc(1) = oldbc(3)*2 - 1;
%             newbc([2,3]) = oldbc([1,2])*2;
            newbc = oldbc([3 1 2])*2 - [1 0 0];
            newci = nc3;
        else
            newbc = 1 - oldbc*2;
            newci = ci;
        end
    end
    if newci==0
        error('splitbc');
    end
    
    if abs(sum(newbc)-sum(oldbc)) > 0.01
        xxxx = 1;
    end
end

function [newbc,newci] = split1( oldbc, ci, nc1 )
    newbc(1) = oldbc(1);
    if oldbc(2) >= oldbc(3)
        newbc([2,3]) = [ oldbc(2)-oldbc(3), oldbc(3)*2 ];
        newci = ci;
        oldToNew = [ 1  0 0;
                     0  1 0;
                     0 -1 2 ];
        newToOld = [ 1 0 0;
                     0 1 0;
                     0 1/2 1/2 ];
    else
        newbc([2,3]) = [ oldbc(2)*2, oldbc(3)-oldbc(2) ];
        newci = nc1;
        oldToNew = [ 1 0 0;
                     0 2 -1;
                     0 0 1 ];
        newToOld = [ 1 0 0;
                     0 1/2 1/2;
                     0 0 1 ];
    end
end
