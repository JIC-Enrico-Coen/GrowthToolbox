function h = displayTextInDlg( title, s )
    h = openfig('textdisplayDlg','new','invisible');
    hd = guihandles(h);
    set( hd.thetext, 'String', s );
    setGUIColors( h, [0.4 0.8 0.4], [0.9 1 0.9] );
    set( h, 'Visible', 'on', 'Name', title );
end
