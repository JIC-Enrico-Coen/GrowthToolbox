function writeVRMLViewpoints( fid, cameraparams, scale, centre )
    if ~isempty( cameraparams )
        viewtarget = cameraparams.CameraTarget * scale - centre;
        viewangle = deg2rad( cameraparams.CameraViewAngle );
        viewpos = cameraparams.CameraPosition * scale - centre;
        writeVRMLViewpoint( fid, viewangle, viewpos, viewtarget, cameraparams.CameraUpVector, 'Default' );
        viewdistance = norm(viewpos);
        viewoffsets = [0 0 1; 1 0 0; 0 1 0; 0 0 -1; -1 0 0; 0 -1 0] * viewdistance;
        viewup = [0 1 0; 0 0 1; 0 0 1; 0 1 0; 0 0 1; 0 0 1] * viewdistance;
        viewdescs = { 'From top', 'From front', 'From right', 'From bottom', 'From back', 'From left' };
        for i=1:size(viewoffsets,1)
            writeVRMLViewpoint( fid, viewangle, viewtarget+viewoffsets(i,:), viewtarget, viewup(i,:), viewdescs{i} );
        end
    end
end

function writeVRMLViewpoint( fid, viewangle, viewpos, viewtarget, viewup, viewdesc )
    r = rotateFrameToFrame( [0 0 -1;0 1 0], [viewtarget-viewpos; viewup] );
    aa = vrrotmat2vec( r' );
    fprintf( fid, ...
            [ 'Viewpoint {\n', ...
              '  fieldOfView %g\n', ...
              '  position %g %g %g\n', ...
              '  orientation %g %g %g %g\n', ...
              '  description "%s"\n', ...
              '  jump TRUE\n', ...
              '}\n\n' ], viewangle, viewpos, aa, viewdesc );
end

