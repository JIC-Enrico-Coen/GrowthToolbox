function m = leaf_rotate( m, varargin )
%m = leaf_rotate( m, type1, rot1, type2, rot2, ... )
%   Rotate the mesh about the given axes.  The rotations are performed in
%   the order they are given: the order matters.  Each type argument is one
%   of 'M', 'X', 'Y', or 'Z' (case is ignored).  For a type 'M', the
%   following rotation should be a 3*3 rotation matrix.  For 'X', 'Y', or
%   'Z' it should be an angle in degrees.  Any sequence of rotations can be
%   given.
%
%   See also: leaf_rotatexyz.
%
%   Topics: Mesh editing.

    if isempty(m), return; end
    if nargin < 2
        return;
    end
    rotation = eye(3);
    for i=2:2:length(varargin)
        axis = lower(varargin{i-1});
        if strcmp(axis,'m')
            rot3 = varargin{i};
        else
            angle = varargin{i} * pi/180;
            c = cos(angle);
            s = sin(angle);
            rot2 = [[c -s];[s c]];
            rot3 = eye(3);
            switch axis
                case 'x'
                    rot3([2 3],[2 3]) = rot2;
                case 'y'
                    rot3([3 1],[3 1]) = rot2;
                case 'z'
                    rot3([1 2],[1 2]) = rot2;
                otherwise
                    fprintf( 1, '%s: invalid axis ''%s''. Rotation not performed.\n', ...
                        mfilename(), axis );
            end
        end
        rotation = rot3*rotation;
    end
    m = rotatemesh( m, rotation );
end
