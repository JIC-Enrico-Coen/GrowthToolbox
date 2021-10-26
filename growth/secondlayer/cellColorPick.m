function cellColorPick()
%cellColorPick()
%   Callback for the cellular color pickers in the Cell Factors panel.

    [hObject,tag,fig,handles,panelfig,panelhandles] = getGFtboxFigFromGuiObject();
    if isempty(hObject)
        return;
    end
    if isempty(handles.mesh)
        return;
    end
    
    c = bgColorPick( hObject, 'Cell color' );
    if length(c) ~= 3
        return;
    end
    
    cellmgenName = getMenuSelectedLabel(handles.displayedCellMgenMenu);
    selectedValueIndex = name2Index( handles.mesh.secondlayer.valuedict, cellmgenName );
    if selectedValueIndex > size( handles.mesh.secondlayer.cellvalues, 2 )
        return;
    end
    
    % Set the positive or negative colour for the selected factor to c.
    
    switch tag
        case 'poscolorchooser'
            handles.mesh.secondlayer.cellcolorinfo(selectedValueIndex).pos = c(:)';
        case 'negcolorchooser'
            handles.mesh.secondlayer.cellcolorinfo(selectedValueIndex).neg = c(:)';
        case 'edgecolorchooser'
            handles.mesh.secondlayer.cellcolorinfo(selectedValueIndex).edgecolor = c(:)';
    end
    guidata( handles.output, handles );
    
    % If the bio layer is nonempty and the factor is currently being
    % plotted, then schedule a replot.
    
    needReplot = handles.mesh.plotdefaults.drawsecondlayer ...
                 && hasNonemptySecondLayer( handles.mesh );
    if needReplot
        currentplotted = handles.mesh.plotdefaults.cellbodyvalue;
        if ischar(currentplotted)
            currentplotted = {currentplotted};
        end
        needReplot = ~isempty( intersect( currentplotted, cellmgenName ) );
    end
    if needReplot
        % Need to cause a replot.
        notifyPlotChange( handles );
    end
end
