function setaxisrangeFromDialog( h )
    autoScale = get( h.autoScale, 'Value' );
    if autoScale
        axisrange = [];
    else
        axisrange = axisrangeFromDialog( h );
    end
  % if ~isempty(axisrange)
        attemptCommand( h, false, false, ...
            'plotoptions', ...
            'axisRange', axisrange, ...
            'autoScale', autoScale, ...
            'autocentre', autoScale );
  % end
end
