function [cj,bcj] = transferEdgeBC( m, ci, bc )
%[cj,bcj] = transferEdgeBC( m, ci, bc )
%   Given barycentric coordinates bc of a point on an edge of a cell ci of
%   m, find the barycentric coordinates of the same point relative to the
%   cell on the other side of the same edge.  If there is no such cell, cj
%   is returned as zero.

    cei = find(bc==0,1);
    ei = m.celledges(ci,cei);
    celledges = m.edgecells(ei,:);
    cj = celledges(celledges ~= ci);
    if cj==0
        bcj = [];
        return;
    end
    cej = find(m.celledges(cj,:)==ei);
    bcj = [0 0 0];
    cei1 = mod(cei,3)+1;
    cei2 = mod(cei1,3)+1;
    cej1 = mod(cej,3)+1;
    cej2 = mod(cej1,3)+1;
    bcj([cej,cej1,cej2]) = bc([cei,cei2,cei1]);
end