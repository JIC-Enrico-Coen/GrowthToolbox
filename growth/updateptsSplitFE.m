function [fes,bcs] = updateptsSplitFE( fes, bcs, splitinfo )
%[fes,bcs] = updateptsSplitFE( fes, bcs, splitinfo )
%   The positions of a set of points on the surface are defined by the finite
%   element they lie in, and their barycentric coordinates within the
%   element.  When a finite element is split by splitalledges, each point
%   lying within it must be assigned to one of the descendant
%   finite elements, and its barycentric coordinates with respect to that
%   cell computed.  That is done by this function.
%
%   splitinfo is an array built by splitalledges.  It contains one row for
%   every finite element vertex, with six elements [ ci1, ci2, ci3, nc1,
%   nc2, nc3 ].  ci1, ci2, and ci3 are the indexes within the cell of the
%   edges of that cell that were split.  If only two edges were split, ci3
%   is zero, and if only one edge, ci2 is also zero.  nc1, nc2, and nc3 are
%   the indexes of the new cells.  If only two edges were split, nc3 is
%   zero, and if only one edge, nc2 is also zero.  The edges and cells are
%   listed in a canonical order, for which see how they are computed in
%   splitalledges.

    numpts = length( fes );
    for p=1:numpts
        fe = fes(p);
        if splitinfo(fe,1) > 0 % If not, the element was not split and there is nothing to do.
            [newbc,newci] = splitbc( bcs(p,:), fe, splitinfo(fe,:) );
            if newci==0
                error('updateptsSplitFE');
            end
            bcs( p, : ) = newbc;
            fes( p ) = newci;
        end
    end
end
