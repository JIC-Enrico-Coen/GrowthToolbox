function cd = getCameraDistance( ax )
    if ~ishghandle(ax)
        cd = 0;
        return;
    end
    
    cp = getCameraParams( ax );
    cd = norm( cp.CameraTarget - cp.CameraPosition );
end
