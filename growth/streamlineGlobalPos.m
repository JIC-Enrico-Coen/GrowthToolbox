function p = streamlineGlobalPos( m, s, pi )
    if nargin < 3
        pi = 1:length(s.vxcellindex);
    end
    p = zeros( length(pi), 3 );
    for i=1:length(pi)
        p(i,:) = s.barycoords(pi(i),:) * m.nodes( m.tricellvxs(s.vxcellindex(pi(i)),:), : );
    end
end
