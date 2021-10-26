function chains = getIntercellularSpaces( m, visedgemap )
    bordersSpace = visedgemap & any(m.secondlayer.edges(:,[3 4])==-1,2);
    spaceedges = m.secondlayer.edges(bordersSpace,[1 2]);
    if isempty(spaceedges)
        chains = {};
        return;
    end
    chains = makechains2(spaceedges);
end

