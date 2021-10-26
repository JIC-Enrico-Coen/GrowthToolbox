function r = randBinCounts( binsizes, numpts, uniformise )
%r = randBinCounts( binsizes, numpts, uniformise )
%   Select a random number of points from each of the bins, in proportion
%   to their size.  The result is an array the same shape as binsizes,
%   containing the number of points that fell into each bin.
%
%   If uniformise is true (the default is false) then each bin is
%   guaranteed to have n members, where n is one of the two integers on
%   either side of its expected number of members.
%
%   If the binsizes are all zero, they are taken to be all 1. Only their
%   relative sizes matter,

    if nargin < 3
        uniformise = false;
    end
    binsizes = max( binsizes,0);
    if all(binsizes == 0)
        binsizes(:) = 1;
    end
    if (numpts <= 0) || isempty(binsizes)
        r = zeros( 1, length(binsizes) );
    elseif uniformise
        totsize = sum( binsizes );
        expectedcounts = binsizes*(numpts/totsize);
        floorcounts = floor(expectedcounts);
        fraccounts = expectedcounts - floorcounts;
        totfloor = sum(floorcounts);
        rmdr = numpts - totfloor;
        r1 = randBinCounts( fraccounts, rmdr, false );
        r = floorcounts(:) + r1(:);
    else
        cumbins = vecsums( binsizes );
        cumbins = cumbins/cumbins(end);
        v = rand( 1, numpts );
        r = zeros( 1, length(binsizes) );
        for i=1:numpts
            n = binsearchupper( cumbins, v(i) );
            r(n) = r(n)+1;
        end
    end
    r = reshape( r, size(binsizes) );
end
