function side = planeSide( n, a, pts )
%side = planeSide( n, a, pts )
%   The column vector N and the real number A define a plane by the equation
%   N*X==A.  Set SIDE to an array of booleans of length size(p,1), in which
%   each element is truee iff the corresponding row of p satisfies
%   N*P(i,:) >= A.

    numpts = size(pts,1);
    side = false( numpts, 1 );
    for i=1:numpts
        side(i) = pts(i,:)*n >= a;
    end
end
