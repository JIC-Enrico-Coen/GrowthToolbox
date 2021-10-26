function m = splitSecondLayer( m )
%m = splitSecondLayer( m )
%   Split the second layer components where necessary.
%   If m.globalProps.bioAsplitcells, cells larger than a certain size will
%   be split; otherwise, edges longer than a certain amount will be split.

    if m.globalProps.bioAsplitcells
        m = splitSecondLayerCells( m );
    else
        m = splitSecondLayerEdges( m );
    end
end
