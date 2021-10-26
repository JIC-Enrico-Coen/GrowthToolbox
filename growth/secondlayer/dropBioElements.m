function secondlayer = dropBioElements( secondlayer, cellsToDelete, edgesToDelete, vertexesToDelete )
%secondlayer = dropBioElements( secondlayer, cellsToDelete, edgesToDelete, vertexesToDelete )
%   FOR INTERNAL USE ONLY
%   For every field of secondlayer listed in setGlobals.m as storing a
%   value per cell, edge, or vertex, all rows not indexed by cellsToDelete,
%   edgesToDelete, or vertexesToDelete respectively are deleted.  This does
%   not perform any reindexing of the remaining data, which is presumed to
%   have been done already.  It makes no validity check that the retained
%   data does not reference any of the discarded data.
%
%   cellsToDelete, edgesToDelete, and vertexesToDelete can be either lists
%   of indexes or boolean maps.  All must be supplied, and all will be
%   applied.  To indicate that nothing of some type should be deleted,
%   supply an empty list.  This will be faster than supplying an all-false
%   map.
%
%   A field which is empty will be unaltered.  A field which contains data
%   for a single cell, edge, or vertex is presumed to be a value to be
%   applied to all, however many, and will also be left unaltered.
%
%   See also: keepBioElements, keepFEElements, dropFEElements.

    global gPerBioCellFields gPerBioEdgeFields gPerBioVertexFields

    if ~isempty(cellsToDelete)
        for i = 1:length(gPerBioCellFields)
            fn = gPerBioCellFields{i};
            x = secondlayer.(fn);
            if size(x,1) > 1
                x(cellsToDelete,:) = [];
                secondlayer.(fn) = x;
            end
        end
    end
    
    if ~isempty(edgesToDelete)
        for i = 1:length(gPerBioEdgeFields)
            fn = gPerBioCellFields{i};
            x = secondlayer.(fn);
            if size(x,1) > 1
                x(edgesToDelete,:) = [];
                secondlayer.(fn) = x;
            end
        end
    end

    if ~isempty(vertexesToDelete)
        for i = 1:length(gPerBioVertexFields)
            fn = gPerBioCellFields{i};
            x = secondlayer.(fn);
            if size(x,1) > 1
                x(vertexesToDelete,:) = [];
                secondlayer.(fn) = x;
            end
        end
    end
end

