function inertia = pointMassInertia( pos, m )
%inertia = pointMassInertia( pos, m )
%   Calculate the inertia tensor of a point mass at POS of mass M, relative
%   to the origin.
%
%   See also: pointMassInertias.

    if nargin < 2
        m = 1;
    end
    inertia = m * (sum(pos.^2) * eye(3) - pos' * pos);
end
