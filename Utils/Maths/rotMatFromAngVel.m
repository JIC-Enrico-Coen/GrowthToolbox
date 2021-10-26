function r = rotMatFromAngVel( angvel, t )
%   angvel is an angular velocity vector.
%   Compute the rotation matrix that represents rotation at that angular
%   velocity for time t (default 1).

    if nargin < 2
        t = 1;
    end
    angspeed = norm(angvel);
    angle = (angspeed*t)/2;
    quat = [ sin(angle)*(angvel/angspeed), cos(angle) ];
    r = quatToMatrix( quat );
end
