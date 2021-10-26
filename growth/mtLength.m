function [totMTlen,mtLengths] = mtLength( m )
%len = mtLength( m )
%   Calculate the total length of all the microtubules of m.

    numtubules = length( m.tubules.tracks );
    mtLengths = zeros( numtubules, 1 );
    for i=1:numtubules
        mtLengths(i) = sum( m.tubules.tracks(i).segmentlengths );
    end
    totMTlen = sum(mtLengths);
end
