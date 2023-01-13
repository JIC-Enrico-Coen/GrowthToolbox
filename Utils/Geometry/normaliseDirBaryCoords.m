function dbc = normaliseDirBaryCoords( dbc, tol )
%dbc = normaliseDirBaryCoords( dbc, tol )
%   DBC is a matrix in which each row is a set of directional barycentric
%   coordinates for a simplex.
%
%   This procedure normalises the coordinates so that they sum to zero and
%   have norm 1.
%
%   Any coordinate whose absolute value is less than TOL times the maximum
%   absolute value of the coordinates is replaced by zero. The default
%   value is 1e-7, obtained either by omitting the TOL argument or passing
%   []. To have no snapping to zero, set TOL to be 0.

    if (nargin < 2) || isempty(tol)
        tol = 1e-7;
    end
    dbc( abs(dbc) < tol*max(abs(dbc),[],2) ) = 0;
    dbc = dbc - mean( dbc, 2 );
    dbc = dbc ./ sqrt(sum(dbc.^2,2));
end
