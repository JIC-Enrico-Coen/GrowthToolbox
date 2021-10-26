function [menutag,menuHandle] = currentMouseMenu( handles )
    panelname = currentPanelName( handles );
    switch panelname
        case 'editor'
            menutag = 'mouseeditmodeMenu';
        case 'morphdist'
            menutag = 'morpheditmodemenu';
        case 'bio1'
            menutag = 'mouseCellModeMenu';
        case 'runsim'
            menutag = 'simulationMouseModeMenu';
        otherwise
            menutag = '';
    end
    if isempty( menutag )
        menuHandle = [];
    else
        menuHandle = handles.(menutag);
    end
end
