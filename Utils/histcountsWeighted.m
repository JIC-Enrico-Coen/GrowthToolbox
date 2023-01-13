function [histlengths,binedges,bins] = histcountsWeighted( values, weights, varargin )
    [bincounts,binedges,bins] = histcounts(values,varargin{:});
    histlengths = zeros( 1, length(bincounts) );
    for i=1:length(values)
        b = bins(i);
        histlengths(b) = histlengths(b) + weights(i);
    end
end
