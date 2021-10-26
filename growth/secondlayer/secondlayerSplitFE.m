function secondlayer = secondlayerSplitFE( secondlayer, splitinfo )
%secondlayer = secondlayerSplitFE( secondlayer, splitinfo )
%   The positions of second layer vertexes are defined by the finite
%   element they lie in, and their barycentric coordinates within the
%   element.  When a finite element is split by splitalledges, each second
%   layer vertex lying within it must be assigned to one of the descendant
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

    [secondlayer.vxFEMcell, secondlayer.vxBaryCoords] = ...
        updateptsSplitFE( secondlayer.vxFEMcell, secondlayer.vxBaryCoords, splitinfo );
    return;
    
%     numpts = length( secondlayer.vxFEMcell );
%     affectedVxs = splitinfo(secondlayer.vxFEMcell,1) > 0;
%     for p=1:numpts
%         fe = secondlayer.vxFEMcell(p);
%       % if splitinfo(fe,1) > 0
%         if affectedVxs(p)
%             [newbc,newci] = splitbc( secondlayer.vxBaryCoords( p, : ), ...
%                 fe, ...
%                 splitinfo(fe,:) );
%             if newci==0
%                 error('secondlayerSplitFE');
%             end
%             secondlayer.vxBaryCoords( p, : ) = newbc;
%             secondlayer.vxFEMcell( p ) = newci;
%         end
%     end
end
