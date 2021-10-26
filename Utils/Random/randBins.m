function r = randBins( binsizes, numpts, uniformise )
%r = randBins( binsizes, numpts, uniformise )
%   Select a random number of points from each of the bins, in proportion
%   to their size.  The result is a list, in random order, of which bin
%   each point falls in.
%
%   If uniformise is true (the default is false) then each bin is
%   guaranteed to have n members, where n is one of the two integers on
%   either side of its expected number of members.
%
%   If the binsizes are all zero, they are taken to be all 1. Only their
%   relative sizes matter,

%   There might be a more efficient way to do this, taking time proportional
%   to the number of bins and independent of the number of points.

    if nargin < 3
        uniformise = false;
    end
    if (numpts <= 0) || isempty(binsizes)
        r = [];
    elseif uniformise
        r1 = randBinCounts( binsizes, numpts, uniformise );
        r = binCountsToBinList( r1 );
    else
        binsizes = max( binsizes,0);
        if all(binsizes == 0)
            binsizes(:) = 1;
        end
        cumbins = vecsums( binsizes );
        cumbins = cumbins/cumbins(length(cumbins));
        v = rand( 1, numpts );
        r = binsearchupper( cumbins, v );
    end
    r = int32(r(:));
end

function bl = binCountsToBinList( bc )
    bl = zeros( sum( bc ), 1 );
    bli = 0;
    for i=1:length(bc)
        bl( (bli+1):(bli+bc(i)) ) = i;
        bli = bli + bc(i);
    end
    bl = bl( randperm( length(bl) ) );
end
