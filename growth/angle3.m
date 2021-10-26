function theta = angle3( v )
%theta = angle3( v )    v is a 3*3 matrix [A;B;C].  The result is the angle
%    ABC.
    BA = v(1,:) - v(2,:);
    BC = v(3,:) - v(2,:);
    theta = vecangle( BA, BC );
end

