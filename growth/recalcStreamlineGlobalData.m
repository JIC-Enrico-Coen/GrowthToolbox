function m = recalcStreamlineGlobalData( m )
    if isempty( m.tubules )
        return;
    end
    
    ss = m.tubules.tracks;
    
    for i=1:length(m.tubules.tracks)
        aa = m.tricellvxs(ss(i).vxcellindex,:)';
        bb = reshape( m.nodes( aa, : ), 3, [], 3 );
        m.tubules.tracks(i).globalcoords = permute( sum( ss(i).barycoords .* permute( bb, [2 1 3] ), 2 ), [1 3 2] );
        m.tubules.tracks(i).directionglobal = streamlineGlobalDirection( m, m.tubules.tracks(i) );
    end
end
