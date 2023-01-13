function grantednum = requestMTcreation( m, requestednum )
%grantednum = requestMTcreation( m, requestednum )

    if isempty( m.tubules ) || (requestednum==0)
        grantednum = 0;
    else
        if isempty( m.tubules.tracks )
            numheads = 0;
        else
            statuses = [m.tubules.tracks.status];
            numheads = sum( [statuses.head] >= 0 );
        end
        max_mts = m.tubules.tubuleparams.max_mt_per_area * sum(m.cellareas);
        grantednum = attemptCreation( max_mts, numheads, requestednum );
    end
end