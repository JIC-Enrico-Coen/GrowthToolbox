function setInteractionModeFromGUI( handles )
    toolName = currentPanelName( handles );
%   fprintf( 1, 'setInteractionModeFromGUI %s\n', toolName );
    switch toolName
        case 'editor'
            mouseeditmodeMenu_Callback(handles.mouseeditmodeMenu, [], handles);
        case 'morphdist'
            if ~isempty(handles.mesh)
                morphEditMode = [ 'morph', ...
                    getMenuSelectedLabel( handles.morpheditmodemenu ) ];
                mgenIndex = getDisplayedMgenIndex( handles );
                handles = establishInteractionMode( handles, ...
                    mgenIndex, ...
                    getDoubleFromDialog( handles.paintamount ) );
                c = averageConductivity( handles.mesh, mgenIndex );
                setDoubleInTextItem( handles.conductivityText, c );
                setDoubleInTextItem( handles.absorptionText, ...
                    mean(handles.mesh.mgen_absorption(:,mgenIndex)) );
                guidata( handles.output, handles );
            end
        case 'runsim'
            simulationMouseModeMenu_Callback(handles.simulationMouseModeMenu, [], handles);
        case 'bio1' % Cells panel
            %handles.mesh = establishInteractionMode( handles.mesh, '' );
            mouseCellModeMenu_Callback(handles.mouseCellModeMenu, [], handles);
        case 'bio2' % OBSOLETE
            handles = establishInteractionMode( handles );
            guidata( handles.output, handles );
        otherwise
            handles = establishInteractionMode( handles );
            guidata( handles.output, handles );
    end
end
