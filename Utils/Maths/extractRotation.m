function [q,err] = extractRotation( q, tol )
%q = extractRotation( q, tol )
% Find the rotational component of a polar decomposition of q.
% See http://www.cs.wisc.edu/graphics/Courses/838-s2002/Papers/polar-decomp.pdf
%     http://tog.acm.org/resources/GraphicsGems/gemsiv/polar_decomp/Decompose.c
%     http://eprints.ma.man.ac.uk/340/01/covered/MIMS_ep2006_161.pdf
% If the determinant of q is negative, the decomposition will be a
% combination of rotation and reflection.
% The tolerance defaults to 1e-3.

    if nargin < 2
        tol = 1e-3;
    end
    id = eye(size(q,1));
    id = id(:);
    err = max(abs(q(:)-id)); % abs(det(q))-1;
    maxiters = 10;
    niters = 0;
    while (abs(err) > tol) && (niters < maxiters)
        qi = inv(q);
        q1 = max(abs(q(:)));
        qinf = sum(abs(q(:)));
        qi1 = max(abs(qi(:)));
        qiinf = sum(abs(qi(:)));
        gamma = (qi1*qiinf/(q1*qinf))^0.25;
        % q = (q*gamma+inv(q)'/gamma)/2;
        q = (q*gamma+qi'/gamma)/2;
        err = abs(det(q))-1;
        niters = niters+1;
    end
  % err
  % niters
end
