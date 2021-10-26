function bcs = ringbc( bc, r, n )
%bcs = ringbc( bc, r, n )
%   Return the barycentric coordinates of an n-gon centred on bc with
%   radius r.

    bcs = ones(n,1)*bc + deltabc( (1:n)'*(2*pi/n) ) * r;
end

function dbc = deltabc( angle )
    dbc = [ cos(angle-pi/6), -sin(angle), cos(angle-5*pi/6) ];
end
