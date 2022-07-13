function inertia = pointMassInertias( pos, m )
%inertia = pointMassInertias( pos, m )
%   Calculate the inertia tensor of a set of point masses at POS of mass M,
%   relative to the origin. POS is N*3, and M is N*1.
%
%   The result is 3*3*N.
%
%   See also: pointMassInertia.


    if nargin < 2
        m = 1;
    end
    
    % This method is much faster than writing out a loop, but it might be
    % slower for a single mass, hence a separate procedure to handle
    % multiple masses.
    pos1 = permute( pos, [2 3 1] ); 
    pos2 = permute( pos, [3 2 1] ); 
    inertia = shiftdim(m,-2) .* (shiftdim(sum(pos.^2,2),-2) .* eye(3) - pos1 .* pos2);
end
