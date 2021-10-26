function m = meshUpdateAllStreamlineStatus( m, dt )
%m = meshUpdateAllStreamlineStatus( m, dt )
%   Update the behaviour of all streamlines of m according to their
%   transition probabilities. dt defaults to m.globalProps.timestep.
%
%   NOT USED.

    if nargin < 2
        dt = m.globalProps.timestep;
    end

    for i=1:length( m.tubules.tracks )
        m.tubules.tracks(i) = updatestreamlinestatus( m.tubules.tracks(i), dt );
    end
end