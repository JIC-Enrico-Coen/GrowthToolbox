function v2p = makeperp( v1, v2 )
%v2p = makeperp( v1, v2 )
%   Construct the vector v2p which is orthogonal to v1 and in the same plane
%   as v2 and v1.

    v2p = v2 - v1*dot(v2,v1)/dot(v1,v1);
end
