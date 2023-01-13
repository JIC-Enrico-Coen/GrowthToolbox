function h = histogramWeighted( ax, values, weights, varargin )
    [bincounts,binedges,bins] = histcounts(values,varargin{:});
    histlengths = zeros( 1, length(bincounts) );
    for i=1:length(values)
        b = bins(i);
        histlengths(b) = histlengths(b) + weights(i);
    end
    h = histogram( ax, 'BinEdges', binedges, 'BinCounts', histlengths );
end
