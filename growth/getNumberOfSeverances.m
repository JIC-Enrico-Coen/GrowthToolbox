function numsevs = getNumberOfSeverances( m )
%numsevs = getNumberOfSeverances( m )
%   Count the number of pending microtubule severances.
    
    if isempty( m.tubules ) || isempty( m.tubules.tracks )
        numsevs = 0;
    else
        statuses = [m.tubules.tracks.status];
        sevs = [statuses.severance];
        numsevs = length( sevs );
    end
end
