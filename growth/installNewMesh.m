function handles = installNewMesh( handles, m )
%handles = installNewMesh( handles, m )
%   Install a new, fully constructed mesh into the handles.
%   m is copied to handles.mesh.
%   Various other cross-references between the mesh, the handles, and the
%   GUI are set up.
%
%   This routine assumes that the simulation is not running.

    if isempty( m ), return; end
    if isempty( handles ), return; end
    handles = stopMovie( handles );
    setVisualRunMode( handles, 'idle' );
    cla( handles.picture );
  % resetView( handles.picture );
    handles.mesh = m;
    handles.mesh.pictures = handles.picture;
    handles.boingNeeded = 0;
    modelcoderev = handles.mesh.globalProps.coderevision;
    if modelcoderev > handles.GFtboxRevision
        fprintf( 1, 'Toolbox version is %d, model was last modified by version %d.\n', ...
            handles.GFtboxRevision, modelcoderev );
        handles.runColors.readyColor = handles.runColors.warningColor;
    else
        handles.runColors.readyColor = handles.runColors.okColor;
    end
  % setRunning( handles, 0 );
    setToolboxName( handles );
    updateGUIFromMesh( handles );
    setFlag( handles, 'plotFlag' );
    setInteractionModeFromGUI( handles );
    handles = guidata( handles.output );
    if isfield( handles, 'stopButton' )
        handles.mesh.stopButton = handles.stopButton;
    else
        handles.mesh.stopButton = [];
    end
    handles.autoScale.UserData = [];
%     leaf_plotview( m, ...
%         'azimuth', m.globalProps.defaultazimuth, ...
%         'elevation', m.globalProps.defaultelevation, ...
%         'roll', m.globalProps.defaultroll );
    handles = GUIPlotMesh( handles );
    setViewFromMesh( handles.mesh );
    enableMenus( handles );
    handles = remakeStageMenu( handles );
    handles = updateRecentProjects( handles );
    drawThumbnail( handles );
end
