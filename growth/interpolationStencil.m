function [ns,wts] = interpolationStencil( m, c, bc )
%[ns,wts] = interpolationStencil( m, c, bc )
%   Given a cell C and barycentric coordinates BC in C, determine the 
%   corresponding point on the subdivision surface, in terms of a set of
%   nodes of M and weights.
%   Not fully implemented: this returns the flat subdivision scheme and
%   needs to be revised to use the butterfly.
%
%   NOT USED.

    ns = m.tricellvxs(c,:);
    ws = bc;
    
    [wts,pis,pos] = butterfly3( m, ci, [b1 b2 b3], tension );
end
