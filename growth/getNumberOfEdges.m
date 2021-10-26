function num = getNumberOfEdges( m )
    if isempty(m)
        num = 0;
    elseif usesNewFEs(m)
        if isT4mesh(m)
            num = size(m.FEconnectivity.edgeends,1);
        else
            %  Not implemented.
            num = 0;
        end
    else
        num = size(m.edgeends,1);
    end
end
