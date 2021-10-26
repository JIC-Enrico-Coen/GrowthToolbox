function selectCurrentTool( handles )
    toolButton = get( handles.toolSelect, 'SelectedObject' );
    toolName = get( toolButton, 'Tag' );
    selectPanel( handles, toolName );
    setInteractionModeFromGUI( handles );
end
