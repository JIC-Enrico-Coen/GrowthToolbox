function num = getNumberOfFEs( m )
    if isempty(m)
        num = 0;
    elseif usesNewFEs(m)
        num = 0;
        numTypes = length(m.FEsets);
        for i=1:numTypes
            num = num + size( m.FEsets(i).fevxs, 1 );
        end
    else
        num = size( m.tricellvxs, 1 );
    end
end
