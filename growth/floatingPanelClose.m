function floatingPanelClose( varargin )
    theDialog = gcbo();
    [h,tag,gfh] = getGFtboxFigFromGuiObject();
    if ishghandle(gfh)
        panelname = regexprep( tag, '_figure$', '' );
        vals = getDialogVals( theDialog );
        ud = get( gfh, 'Userdata' );
        ud.floatingpanels.(panelname) = vals;
        set( gfh, 'Userdata', ud );
    end
    closeDialog( theDialog );
end
