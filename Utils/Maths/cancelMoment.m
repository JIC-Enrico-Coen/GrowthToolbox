function [w,d] = cancelMoment( u, d, cancelDrift, rotAxis )
%[w,d] = cancelMoment( u, d, cancelDrift, rotAxis )
%   d is a set of velocities of particles at positions u.
%   Calculate the angular velocity w about the centroid of u that will
%   cancel out the moment of the velocities d.  The revised values of d are
%   returned.
%
%   If cancelDrift is true (default is false), then d will also be
%   translated to make its average zero.  cancelDrift may also be a triple
%   of booleans, one for each axis, in which case drift will be cancelled
%   on the axes for which it is true.
%
%   If rotAxis is provided and nonempty, it specifies a single axis to
%   eliminate rotation about.
%
%   The moment of velocities (assuming the centroid is zero) is sum_i u_i
%   cross d_i.

    if nargin < 3
        cancelDrift = [false false false];
    elseif numel(cancelDrift)==1
        cancelDrift = [cancelDrift cancelDrift cancelDrift];
    end
    
    if nargin < 4
        rotAxis = [];
    end
    
    % Remove all drift from u.  Note that u is not returned, so the
    % original values that this was called with are unaffected.
    c = sum(u,1)/size(u,1);
    u = u - repmat(c,size(u,1),1);
    
    if isempty(rotAxis)
        % Total the cross product of each position and velocity.
        ucrossd = sum( cross(u,d,2), 1 );
        
        % For each pair of coordinates, calculate the sum of the product of
        % that pair of position coordinates.
        uu1 = sum( u(:,1).*u(:,1) );
        uu2 = sum( u(:,2).*u(:,2) );
        uu3 = sum( u(:,3).*u(:,3) );
        u1u2 = sum( u(:,1).*u(:,2) );
        u1u3 = sum( u(:,1).*u(:,3) );
        u2u3 = sum( u(:,2).*u(:,3) );
        u2u1 = u1u2; % sum( u(:,2).*u(:,1) );
        u3u1 = u1u3; % sum( u(:,3).*u(:,1) );
        u3u2 = u2u3; % sum( u(:,3).*u(:,2) );
        
        M = [ uu2+uu3, -u2u1, -u3u1; ...
              -u1u2, uu3+uu1, -u3u2; ...
              -u1u3, -u2u3, uu1+uu2 ];
        w = ucrossd / M;
    else
        [x,y] = othersOf3( rotAxis );
        
        % Total the cross product of each position and velocity in the
        % required axis plane.
        ucrossd = sum( u(:,x) .* d(:,y) - u(:,y) .* d(:,x) );
        
        % Calculate the required cancelling rotation.
        w = [0 0 0];
        w(rotAxis) = ucrossd/sum(sum(u(:,[x y]).^2,2));
    end
    bigw = repmat( w, size(u,1), 1 );
    d = d - cross( bigw, u, 2 );
    if all( cancelDrift )
        d = d - repmat( sum(d,1)/size(d,1), size(d,1), 1 );
    else
        for i=1:3
            if cancelDrift(i)
                d(:,i) = d(:,i) - sum(d(:,i))/size(d,1);
            end
        end
    end
    
    % test.
    % We should have u X (d - wXu) = 0
%     bigw = repmat( w, size(u,1), 1 );
%     test = sum( cross( u, d, 2 ), 1 )
%     uXwXu = sum( cross( cross( u, bigw, 2 ), u, 2 ), 1 )
%     wM = w*M
end
