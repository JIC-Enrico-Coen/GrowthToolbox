function secondlayer = keepBioElements( secondlayer, cellsToKeep, edgesToKeep, vertexesToKeep )
%secondlayer = keepBioElements( secondlayer, cellsToKeep, edgesToKeep, vertexesToKeep )
%   FOR INTERNAL USE ONLY
%   For every field of secondlayer listed in setGlobals.m as storing a
%   value per cell, edge, or vertex, all rows not indexed by cellsToKeep,
%   edgesToKeep, or vertexesToKeep respectively are deleted.  This does not
%   perform any reindexing of the remaining data, which is presumed to have
%   been done already.  It makes no validity check that the retained data
%   does not reference any of the discarded data.
%
%   cellsToKeep, edgesToKeep, and vertexesToKeep can be either lists of
%   indexes or boolean maps.  All must be supplied, and all will be
%   applied.  To indicate that everything of some type should be kept,
%   supply the value 0 as the corresponding argument.  This will be faster
%   than supplying a list of all indexes or an all-true map.
%
%   Supplying the empty list for all of these arguments will delete the
%   whole secondlayer.
%
%   A field which is empty will be unaltered.  A field which contains data
%   for a single cell, edge, or vertex is presumed to be a value to be
%   applied to all, however many, and will also be left unaltered.
%
%   See also: dropBioElements, keepFEElements, dropFEElements.

    global gPerBioCellFields gPerBioEdgeFields gPerBioVertexFields

    for i = 1:length(gPerBioCellFields)
        fn = gPerBioCellFields{i};
        if ~isfield( secondlayer, fn )
            continue;
        end
        if strcmp( fn, 'cells' )
            secondlayer.(fn) = secondlayer.(fn)(cellsToKeep);
        else
            x = secondlayer.(fn);
            if size(x,1) > 1
                x = x(cellsToKeep,:);
                secondlayer.(fn) = x;
            elseif (size(x,1) == 1) && (size(x,2) > 1)
                x = x(cellsToKeep);
                secondlayer.(fn) = x;
            end
        end
    end
    secondlayer.visible.cells = secondlayer.visible.cells(cellsToKeep);

    for i = 1:length(gPerBioEdgeFields)
        fn = gPerBioEdgeFields{i};
        if ~isfield( secondlayer, fn )
            continue;
        end
        x = secondlayer.(fn);
        if size(x,1) > 1
            x = x(edgesToKeep,:);
            secondlayer.(fn) = x;
        end
    end

    for i = 1:length(gPerBioVertexFields)
        fn = gPerBioVertexFields{i};
        if ~isfield( secondlayer, fn )
            continue;
        end
        x = secondlayer.(fn);
        if size(x,1) > 1
            x = x(vertexesToKeep,:);
            secondlayer.(fn) = x;
        elseif size(x,2)==length(vertexesToKeep)
            x = x(:,vertexesToKeep);
            secondlayer.(fn) = x;
        end
    end
end

