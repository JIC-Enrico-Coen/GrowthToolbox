function [totlen, lengths] = getTubuleLengths( m )
    numTubules = getNumberOfTubules(m);
    if numTubules==0
        lengths = [];
        totlen = 0;
    else
        if nargout==1
            totlen = sum( [m.tubules.tracks.segmentlengths] );
        else
            lengths = zeros(1,numTubules);
            for i=1:numTubules
                lengths(i) = sum( [m.tubules.tracks(i).segmentlengths] );
            end
            totlen = sum(lengths);
        end
    end
end