function numsevs = getNumberOfSeverances( m )
%numsevs = getNumberOfSeverances( m )
%   Count the number of pending microtubule severances.
    
    if isempty( m.tubules ) || isempty( m.tubules.tracks )
        numsevs = 0;
    else
        numsevs = 0;
        for ti=1:length(m.tubules.tracks)
             numsevs = numsevs + length( m.tubules.tracks(ti).status.severance );
        end
            
%         statuses = [m.tubules.tracks.status];
%         sevs = [statuses.severance];
%         numsevs = length( sevs );
    end
end
