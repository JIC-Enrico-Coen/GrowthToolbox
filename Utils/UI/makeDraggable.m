function makeDraggable( hObject, min_frac, min_pixels )
%makeDraggable( hObject )
%makeDraggable( hObject, min_frac, min_pixels )
%   This makes the gui item hObject draggable in its parent.  min_frac is
%   the fraction of the object's bounding box in each direction that must
%   remain visible, and min_pixels is similarly the minimum number of
%   pixels that must remain visible.  During dragging, the object will
%   always be positioned such that both criteria are satisfied.
%
%   Note that some Matlab gui items draw outside
%   of the rectangle specified by their 'Position' property (e.g. the axis
%   labels are drawn outside the graphic area of an axes object), and some
%   container objects (e.g. panels) overlay part of their content area with
%   their own furniture.  This procedure ignores that messiness. In these
%   cases the amount actually visible may be a little less than that
%   specified.
%
%   If min_frac and min_pixels are not supplied, they default to 0 and 40.
%   If you really want dragging to be unrestricted, set both parameters to
%   -Inf.  This allows the item to be dragged completely out of view, and
%   therefore impossible to click on again.  This will usually not be what
%   you want.

    set( hObject, 'ButtonDownFcn', @draggableItemButtonDown_Callback );
    set( hObject, 'Enable', 'inactive' );
    if nargin==3
        setUserdataFields( hObject, 'minVisFraction', min_frac, 'minVisPixels', min_pixels );
    end
end
