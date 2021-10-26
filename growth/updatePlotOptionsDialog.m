function updatePlotOptionsDialog( h, varargin )
    if nargin < 1
        h = gcbo;
    end
    handles = guidata( h );
    if strcmp( get( h, 'Type' ), 'uibuttongroup' )
        h = get( h, 'SelectedObject' );
    end
    tag = get( h, 'Tag' );
    if ~isfield( handles, tag )
        % Either the tag is empty, in which case we are not interested in
        % the item, or the item does not belong to the dialog this procedure
        % expects to be called for.  (The latter case should never happen.)
        return;
    end
    
    tag
    
    switch tag
    end
end
