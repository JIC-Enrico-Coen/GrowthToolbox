function m = leaf_resetview( m )
%m = leaf_resetview( m )
%   Centre the mesh in the view and zoom it to fill the view.
%
%   Options: None.

    if isempty(m)
        return;
    end
    if isempty( m.pictures )
        return;
    end
    
    bboxAxisRange = unionBbox( meshbbox( m, true, 0.2 ), visibleBbox( m.pictures(1) ) );
    m.plotdefaults.matlabViewParams = autozoomcentre( m.plotdefaults.matlabViewParams, bboxAxisRange, true, true );
    m.plotdefaults.ourViewParams = ourViewParamsFromCameraParams( m.plotdefaults.matlabViewParams );
    saveStaticPart( m );
    setViewFromMesh( m );
end
