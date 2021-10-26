function rotmatrix = eulerRotation( eulerangles, euleraxes, mode )
%rotmatrix = eulerRotation( eulerangles, euleraxes, mode )
%   Calculate the rotation matrix corresponding to the given Euler angles.
%   Any number of Euler angles can be given.  The same number of axis names
%   must also be given in the string EULERAXES, each element of which is
%   'X', 'Y', or 'Z' (case is ignored).
%
%   Normally, the rotations are all composed in the global frame.
%   eulerRotation( eulerangles, euleraxes, 'local' ) will compose each
%   rotation in the frame of reference rotated by all the preceding
%   rotations.  This is equivalent to applying the rotations all in the
%   global frame and in the reverse order.
%
%   The resulting matrix is suitable for applying to column vectors: given
%   a column vector V, the result of rotating V by the result is
%   ROTMATRIX*V.  If you require a matrix R which can be applied to a row
%   vector V by V*R, take the transpose of ROTMATRIX.

    if numel(eulerangles)==0
        rotmatrix = eye(3);
    else
        rotmatrix = eulerComponent( eulerangles(1), euleraxes(1) );
        globalFrame = (nargin < 3) || ~strcmp(mode,'local');
        for i=2:numel(eulerangles)
            a = eulerangles(i);
            if a ~= 0
                mat1 = eulerComponent( a, euleraxes(i) );
                if globalFrame
                    rotmatrix = mat1*rotmatrix;
                else
                    rotmatrix = rotmatrix*mat1;
                end
            end
        end
    end
end

function em = eulerComponent( angle, ax )
    c = cos(angle);
    s = sin(angle);
    switch lower(ax)
        case 'x'
            em = [ [ 1, 0, 0 ]; [ 0, c, -s ]; [ 0, s, c ] ];
        case 'y'
            em = [ [ c, 0, s ]; [ 0, 1, 0 ]; [ -s, 0, c ] ];
        case 'z'
            em = [ [ c, -s, 0 ]; [ s, c, 0 ]; [ 0, 0, 1 ] ];
        otherwise
            em = eye(3);
    end
end
