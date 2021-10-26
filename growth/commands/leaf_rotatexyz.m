function m = leaf_rotatexyz( m, varargin )
%m = leaf_rotatexyz( m, varargin )
%   Rotate the coordinates of the leaf: x becomes y, y becomes z, and z
%   becomes z.  If the argument -1 is given, the opposite rotation is
%   performed.
%
%   Equivalent GUI operation: clicking on the "Rotate xyz" button in the
%   "Mesh editor" panel.
%
%   See also: leaf_rotate.
%
%   Topics: Mesh editing.

    if isempty(m), return; end
    if isempty(varargin)
        dir = 1;
    elseif varargin{1}
        dir = 1;
    else
        dir = 0;
    end
    m = rotateXYZ( m, dir );
end
