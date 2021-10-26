function [r,nn] = nextrand_ac( r, n, rows )
% [r,nn] = nextrand_ac( r, n, rows )
%   Generate n sets of random numbers from the random generator r,
%   returning the new state of r and setting nn to the matrix of random
%   numbers.  ROWS is a vector of indexes in the range 1:(order+1) where
%   ORDER is the order of R.  The result is a matrix of size
%   LENGTH(ROWS)*N, containing the N successive values of each of the
%   corresponding elements of r.state.  Row 1 is a sequence of uncorrelated
%   values, row 2 is the first smoothing, and so on.  The default value for
%   ROWS is [order+1], i.e. return just the smoothest sequence.
%
%   I have not yet worked out what values of r.a and r.b will guarantee
%   that each of the successive stages of smoothing has unit standard
%   deviation, except that if r.a(1)^2 + r.b(1)^2 = 1, then r.state(2) will
%   have standard deviation 1.  Further work is to be done on determining
%   the memory of the process, so as to select parameters which will allow
%   generating the "same" process with an arbitrary timestep.
%
%   See also: newwrand1.

    if nargin < 3
        rows = length(r.state);
    else
        rows(rows<0) = length(r.state) + 1 - rows(rows<0);
    end
    nn = zeros(length(rows),n);
    for i=1:n
        r1 = zeros(1,length(r.state));
        r1(1) = randn(1);
        for ri=2:length(r.state)
            ri1 = ri-1;
            r1(ri) = r.state(ri)*r.a(ri1) + r1(ri1)*r.b(ri1);
        end
        r.state = r1;
        nn(:,i) = r.state(rows);
    end
end
