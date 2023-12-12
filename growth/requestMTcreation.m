function grantednum = requestMTcreation( m, requestednum )
%grantednum = requestMTcreation( m, requestednum )
%   If there is a request to create some number of new microtubules, this
%   procedure returns the number that will actually be created.
%
%   The number of microtubules is limited by a ceiling on the mean density
%   of growing heads.

    if isempty( m.tubules ) || (requestednum==0)
        grantednum = 0;
    else
        if isempty( m.tubules.tracks )
            numheads = 0;
        else
            statuses = [m.tubules.tracks.status];
            numheads = sum( [statuses.head] >= 0 );
        end
        max_mts = m.tubules.tubuleparams.max_growing_mt_per_area * sum(m.cellareas);
        grantednum = attemptCreation( max_mts, numheads, requestednum );
    end
end