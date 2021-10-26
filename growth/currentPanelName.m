function panelname = currentPanelName( handles )
    panelnames = fieldnames(handles.panels);
    for i=1:length(panelnames)
        panelname = panelnames{i};
        panelhandlename = strcat( panelname, 'panel' );
        if strcmp( get( handles.(panelhandlename), 'Visible' ), 'on' );
            return;
        end
    end
end
