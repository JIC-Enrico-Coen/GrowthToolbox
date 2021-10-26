function m = matRot( rotAxis, rotAmount )
%m = matRot( rotAxis, rotAmount )
%   Calculate the rotation matrix that rotates about the given axis by the
%   given amount in radians.  The axis must be a unit vector.
%   Formula cribbed from Wikipedia.

    x = rotAxis(1);  y = rotAxis(2);  z = rotAxis(3);
    c = cos(rotAmount);  s = sin(rotAmount);  C = 1-c;
    xs = x*s; ys = y*s; zs = z*s;
    xC = x*C; yC = y*C; zC = z*C;
    xyC = x*yC; yzC = y*zC; zxC = z*xC;
    m = [ [ x*xC+c, xyC-zs, zxC+ys ]; ...
          [ xyC+zs, y*yC+c, yzC-xs ]; ...
          [ zxC-ys, yzC+xs, z*zC+c ] ];
end

