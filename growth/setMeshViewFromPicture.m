function m = setMeshViewFromPicture( m, p )
    if nargin < 2
        p = m.pictures(1);
    end
    gd = guidata( p );
    camparams = getCameraParams( gd.picture );
    if isfield( gd, 'stereooffset' )
        camparams = offsetCameraParams( camparams, -gd.stereooffset );
    end
    m.plotdefaults.matlabViewParams = camparams;
    m.plotdefaults.ourViewParams = ...
        ourViewParamsFromCameraParams( m.plotdefaults.matlabViewParams );
    setViewFromMesh( m, p );
end
