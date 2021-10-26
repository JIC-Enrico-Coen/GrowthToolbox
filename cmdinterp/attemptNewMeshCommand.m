function [h,ok] = attemptNewMeshCommand( h, replaceGeometry, cmd, varargin )
%m = attemptNewMeshCommand( h, replace cmd, varargin )
%   Assumes the simulation is not running.  Executes the specified command
%   cmd(varargin{:}), which creates a new mesh.  If the GUI specifies that
%   a random perturbation should be made, it does so.  If REPLACEGEOMETRY is true,
%   the old mesh is discarded, otherwise as many properties as possible of
%   the old mesh are copied to the new one.
%
%   If successful, it installs the new mesh into h.

    ok = false;
    set(h.GFTwindow,'Pointer','arrow');
    startTic = startTimingGFT( h );
    needInstallNewMesh = isempty(h.mesh);
    m = scriptcommand( h.mesh, cmd, 'new', ~replaceGeometry, varargin{:} );
    if isempty( m ), return; end
    flat = get( h.alwaysFlat, 'Value' );
    m.globalProps.alwaysFlat = flat;
    twoD = get( h.twoD, 'Value' );
    m.globalProps.twoD = twoD;
    if ~isVolumetricMesh(m) && any( m.nodes(:,3) ~= 0 )
        set( h.alwaysFlat, 'Value', 0 );
        m.globalProps.alwaysFlat = false;
        set( h.twoD, 'Value', 0 );
        m.globalProps.twoD = false;
    end
    stopTimingGFT(['leaf_' cmd],startTic);
    if needInstallNewMesh
        h = installNewMesh( h, m );
    else
        h.mesh = m;
    end
    ok = true;
end
