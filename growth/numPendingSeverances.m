function n = numPendingSeverances( m )
    n = 0;
    for i=1:length(m.tubules.tracks)
        n = n + length( m.tubules.tracks(i).status.severance );
    end
end
