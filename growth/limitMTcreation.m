function ease_of_creation = limitMTcreation( m )
%ease_of_creation = limitMTcreation( m )
    if isempty( m.tubules )
        ease_of_creation = 0;
    elseif isempty( m.tubules.tracks )
        ease_of_creation = 1;
    else
        statuses = [m.tubules.tracks.status];
        numheads = sum( [statuses.head] >= 0 );
        max_mts = m.tubules.tubuleparams.max_mt_per_area * sum(m.cellareas);
        ease_of_creation = max( 0, 1 - numheads/max_mts );
    end
end