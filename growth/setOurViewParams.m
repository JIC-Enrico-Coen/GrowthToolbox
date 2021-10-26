function m = setOurViewParams( m, ourViewParams )
    m.plotdefaults.ourViewParams = ourViewParams;
    m.plotdefaults.matlabViewParams = cameraParamsFromOurViewParams( ourViewParams );
    m = setMatlabViewParams( m, m.plotdefaults.matlabViewParams );
end
