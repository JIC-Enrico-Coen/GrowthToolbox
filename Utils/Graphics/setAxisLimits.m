function setAxisLimits( ax, bbox )
    ax.XLim = bbox(:,1)';
    ax.YLim = bbox(:,2)';
    ax.ZLim = bbox(:,3)';
end