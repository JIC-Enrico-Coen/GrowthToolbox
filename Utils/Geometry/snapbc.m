function bc = snapbc( bc, tol )
%bc = snapbc( bc, tol )
%   BC is an N*3 collection of barycentric coordinates, and TOL is a small
%   non-negative number.  Set any coordinate of BC that is within TOL of 0
%   or 1 to 0 or 1 respectively.

    bc( abs(bc) < tol ) = 0;
    bc( abs(bc-1) < tol ) = 1;
    bc = bc/sum(bc);
end
