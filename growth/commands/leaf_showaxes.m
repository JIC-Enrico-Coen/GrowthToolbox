function m = leaf_showaxes( m, varargin )
%m = leaf_showaxes( m, axeson )
%
%   Make the axes visible or invisible, according as AXESON is true or false.
%
%   Topics: Plotting.

    if isempty(m), return; end
    if length( varargin ) ~= 1
        fprintf( 1, '%s: One argument required, %d supplied.\n', ...
            mfilename(), length( varargin ) );
        return;
    end
    if varargin{1}
        axeson = true;
    else
        axeson = false;
    end
    axisVisString = boolchar( axeson, 'on', 'off' );
    for i=1:length(m.pictures)
%         h = guidata( m.pictures(i) );
%         axis( h.picture, axisVisString );
        theaxes = m.pictures(i);
        axis( theaxes, axisVisString );
        set( get(theaxes,'XLabel'), 'Visible', axisVisString );
        set( get(theaxes,'YLabel'), 'Visible', axisVisString );
        set( get(theaxes,'ZLabel'), 'Visible', axisVisString );
    end
    m.plotdefaults.axisVisible = axeson;
end

