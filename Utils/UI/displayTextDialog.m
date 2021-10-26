function displayTextDialog( title, msg )
%displayTextDialog( title, msg )
%   Present a modal dialog displaying some text to the user.
%   TITLE will be used as the title of the dialog and MSG is a string
%   that will appear within the dialog.  The user may hit return or escape
%   to dismiss the dialog.

    initvals = struct( 'figure', title, 'msg', msg );
    performRSSSdialogFromFile( 'displayTextDialog.txt', initvals, [], @setDefaultGUIColors ); % @(h)setGFtboxColourScheme( h, handles ) );
end
