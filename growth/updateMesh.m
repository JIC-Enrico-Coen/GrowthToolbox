function handles = updateMesh( handles, m, varargin )
%handles = updateMesh( handles, m, ... )
%   Install an update to the mesh into the handles.  Handles is assumed to
%   already have a previous version of the mesh, of which m is some updated
%   version.  m is therefore assumed to be already consistent with handles,
%   e.g. m.pictures is equal to handles.picture, m and handles.mesh belong
%   to the same project, etc.  If a movie is in progress, it is not
%   halted.
%
%   Options:
%
%   'replot'    If true, the new mesh will be plotted.  The default is
%               false.
%
%   This routine assumes that the simulation is not running.

    if isempty( m ), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'replot', false );
    ok = checkcommandargs( mfilename(), s, 'exact', 'replot' );
    if ~ok, return; end

    handles.mesh = m;
    guidata( handles.output, handles )
    updateGUIFromMesh( handles );
    setInteractionModeFromGUI( handles );
    if s.replot
        setFlag( handles, 'plotFlag' );
        handles = guidata( handles.output );
        handles = GUIPlotMesh( handles );
        setViewFromMesh( handles.mesh );
    end
end
