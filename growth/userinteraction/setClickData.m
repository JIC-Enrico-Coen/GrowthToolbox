function setClickData( clickData, ax )
%setClickData( clickData )
%   Install the click data into ax, or if ax is not supplied, into
%   clickData.axes.

    if nargin < 2
        ax = clickData.axes;
    end
    setUserdataFields( ax, 'clickData', clickData );
end
