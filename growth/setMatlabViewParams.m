function m = setMatlabViewParams( m, matlabViewParams )
    m.plotdefaults.matlabViewParams = matlabViewParams;
    m.plotdefaults.ourViewParams = ourViewParamsFromCameraParams( m.plotdefaults.matlabViewParams );
    setViewFromMesh( m );
end
