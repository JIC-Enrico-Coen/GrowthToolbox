function rescaleAxis( ax, values, places )
    valueStrings = cell(length(places),1);
    for i=1:length(places)
        valueStrings{i} = sprintf( '%g', values(i) );
    end
    ax.TickValuesMode = 'manual';
    ax.TickValues = places;
    ax.TickLabels = valueStrings;
end
