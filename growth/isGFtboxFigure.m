function isgf = isGFtboxFigure( f )
%isgf = isGFtboxFigure( f )
%   Return true if f is a handle to a GFTbox window.

    isgf = false;
    
    if ~ishghandle(f)
        return;
    end
    
    isgf = strcmp( get(f,'Tag'), 'GFTwindow' );
    
%     gd = guidata(f);
%     
%     isgf = isfield( gd, 'GFTwindow' );
%     
%     ad = getappdata(f);
%     if ~isfield( ad, 'UsedByGUIData_m' )
%         return;
%     end
%     
%     if ~isfield( ad.UsedByGUIData_m, 'GFTwindow' )
%         return;
%     end
%     
%     isgf = true;
end