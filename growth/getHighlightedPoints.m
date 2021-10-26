function highlightedpts = getHighlightedPoints( ax, emptyIsAll )
    if nargin < 2
        emptyIsAll = false;
    end
    gd = guidata( ax );
    highlightedpts = gd.mesh.selection.highlightedVxList;
    if emptyIsAll && isempty( highlightedpts )
        highlightedpts = true( getNumberOfVertexes(gd.mesh), 1 );
    end
end
