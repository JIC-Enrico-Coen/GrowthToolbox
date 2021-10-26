function [ ci1, bc1 ] = findBaryPoint( mesh, ci, bc )
%[ ci1, bc1 ] = findBaryPoint( mesh, ci, bc )
%   Given barycentric coordinates bc in cell ci, with one or more negative
%   values, find a point in a neighbouring cell which most closely
%   approximates the given point.
% UNFINISHED.

    if all(bc >= 0)
        ci1 = ci;
        bc1 = bc;
    end
    bi = find(bc<0);