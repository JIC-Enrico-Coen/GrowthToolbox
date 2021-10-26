function [par,per] = splitVector( v, n )
%[par,per] = splitVector( v, n )
%   Split a row vector r into its components parallel and perpendicular to
%   the row vector n.  r and n can be N*3 matrices.
    par = dot( v, n, 2 );
    per = v - n .* repmat( par, 1, 3 );
end
