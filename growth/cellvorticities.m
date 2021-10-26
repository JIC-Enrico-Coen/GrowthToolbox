function cv = cellvorticities( m )
%cv = cellvorticities( m )      NOT CURRENTLY USED
%   DEPENDS ON vorticity(), WHICH IS UNTESTED.
    cv = zeros( size(m.tricellvxs,1), 3 );
    for i=1:size(m.tricellvxs,1)
        ni = m.tricellvxs(i,:);
        pi1 = ni*2;  pi = [ pi1-1; pi1 ];
        cv(i,:) = vorticity( m.prismnodes(pi,:), m.displacements(pi,:) )/m.globalProps.timestep;
    end
end
