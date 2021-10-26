function w = randperp( v )
%w = randperp( v )
%   Return a random unit vector perpendicular to the unit vector v.
%   v may be an N*3 matrix of row vectors, in which case an N*3 matrix will
%   be returned, of a random perpendicular to each row of v.

    v1 = findperp( v );
    v2 = cross( v1, v, 2 );
    theta = pi*2*rand(size(v,1),1);
    w = zeros(size(v));
    for i=1:size(v,1)
        w(i,:) = cos(theta(i))*v1(i,:) + sin(theta(i))*v2(i,:);
    end
end
