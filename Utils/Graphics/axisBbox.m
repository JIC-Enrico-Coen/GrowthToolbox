function bbox = axisBbox( ax )
    if ~ishghandle(ax)
        bbox = [];
    else
        bbox = [ ax.XLim', ax.YLim', ax.ZLim' ];
    end
end