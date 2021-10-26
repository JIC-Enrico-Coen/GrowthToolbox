function v = rotVec( v, centre, rotAxis, rotAmount )
%v = rotVec( v, centre, rotAxis, rotAmount )
%   Rotate v about the axis rotAxis passing through centre by rotAmount in
%   radians.
%   v may be a 3-element row vector or an N*3 matrix.

    m = matRot( rotAxis, rotAmount );
    v = (v-centre)*m'+centre;
end

