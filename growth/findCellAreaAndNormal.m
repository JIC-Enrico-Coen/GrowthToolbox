function [a,n] = findCellAreaAndNormal( m, ci )
%[a,n] = findCellAreaAndNormal( m, ci )
%   Compute the normal vector and area of finite element ci of mesh m.  We
%   do these together, since this is faster than computing them separately.

    [a,n] = findAreaAndNormal( m.nodes( m.tricellvxs( ci, : ), : ) );
end
