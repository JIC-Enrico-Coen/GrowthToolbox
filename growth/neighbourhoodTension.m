function t = neighbourhoodTension( v )
%t = neighbourhoodTension( v )
%   v is an N*2 matrix of row vectors.  If each of these represents a
%   tension acting at a point, calculate the stress tensor resulting from
%   the combination of all of them.

    a = atan2( v(:,2), v(:,1) );
    ca = cos(a);
    sa = sin(a);
    t11 = sum(ca.*ca);
    t22 = length(a) - t11; % sum(sa.*sa);
    t12 = sum(sa.*ca);
    t = [ [t11 t12]; [t12 t22] ];
end

