function m = getDraggedView( m )
%m = getDraggedView( m )
%   Called by the button-up function after a click-drag to change the view.
%   m has its view parameters updated from the picture.

    dragged = false;
    for i=1:length(m.pictures)
        gd = guidata( m.pictures(i) );
        if isfield( gd, 'dragged' ) && gd.dragged
            if ~dragged
                newview = getCameraParams( gd.picture );
                if isfield( gd, 'stereooffset' )
                    newview = offsetCameraParams( newview, -gd.stereooffset );
                end
            end
            dragged = true;
            gd.dragged = false;
            guidata( m.pictures(i), gd );
        end
    end
    if dragged
        m.plotdefaults.matlabViewParams = newview;
        m.plotdefaults.ourViewParams = ...
            ourViewParamsFromCameraParams( m.plotdefaults.matlabViewParams );
    end
end
