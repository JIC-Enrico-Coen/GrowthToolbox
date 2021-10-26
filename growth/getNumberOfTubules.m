function n = getNumberOfTubules( m )
    if isempty( m.tubules )
        n = 0;
    else
        n = length( m.tubules.tracks );
    end
end