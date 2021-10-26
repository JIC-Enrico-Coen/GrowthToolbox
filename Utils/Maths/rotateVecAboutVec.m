function v = rotateVecAboutVec( v, a, theta )
%v = rotateVecAboutvec( v, a, theta )
%   Rotate the 3D vector v about the axis a by angle theta.  a is assumed
%   to be a unit vector.  v and a must be row vectors.  v and a can also be
%   N*3 matrices, and theta an N-element vector: each vector will be
%   rotated about the corresponding axis by the corresponding angle.

    if all(theta==0)
        return;
    end
    nv = size(v,1);
    na = size(a,1);
    nt = numel(theta);
    if (na==1) && (nt==1)
        c = cos(theta);
        s = sin(theta);
        t = 1-c;
        xs = a(1)*s;
        ys = a(2)*s;
        zs = a(3)*s;
        r = (t * a') * a + [c, zs, -ys; -zs, c, xs; ys, -xs, c];
        % r is the rotation matrix for rotating about axis a by angle
        % theta, applied by postmultiplying a row vector.
        v = v * r;
    else
        if na==1
            a = repmat( a, nv, 1 );
        end
        if nt==1
            theta = theta+zeros(nv,1);
        end
        c = cos(theta);
        s = sin(theta);
        t = 1-c;
        c = reshape( c, 1, 1, [] );
        xs = reshape( a(:,1).*s, 1, 1, [] );
        ys = reshape( a(:,2).*s, 1, 1, [] );
        zs = reshape( a(:,3).*s, 1, 1, [] );
        m2 = [c, zs, -ys; -zs, c, xs; ys, -xs, c];
        m1 = repmat( permute( a .* repmat(t,1,3), [2, 3, 1] ), 1, 3, 1 ) .* repmat( permute( a, [3, 2, 1] ), 3, 1, 1 );
        r = m1 + m2;
        % r is the set of rotation matrices.
        
        % Now multiply each row of v by the corresponding slice (along the 3rd index) of r.
%         v1 = permute( v, [2 3 1] );
%         v2 = repmat( v1, [1 3 1] );
%         v3 = v2 .* r;
%         v4 = sum( v3, 1 );
%         v = permute( v4, [3 2 1] );
        v = permute( sum( repmat( permute( v, [2 3 1] ), [1 3 1] ) .* r, 1 ), [3 2 1] );
        
        % An explicit loop takes at least 10 times longer.
%         for i=1:nv
%             v(i,:) = v(i,:) * r(:,:,i);
%         end
    end
end
