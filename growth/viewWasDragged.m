function dragged = viewWasDragged( m )
%dragged = viewWasDragged( m )
%   Discover if the view was changed by dragging in any of m's pictures.
%   If so return true, and set all the drag flags to false.

    dragged = false;
    for i=1:length(m.pictures)
        gd = guidata( m.pictures(i) );
        if isfield( gd, 'dragged' ) && gd.dragged
            dragged = true;
            gd.dragged = false;
            guidata( m.pictures(i), gd );
        end
    end
end
