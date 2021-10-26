function h = displayHelpFile( helpname )
    whereami = fileparts(mfilename('fullpath'));
    toolboxdirectory = fileparts(whereami);
    helpdir = fullfile( toolboxdirectory, 'Help' );
    fullhelpname = fullfile( helpdir, [helpname, '.txt'] );
    missingMessage = [ 'No help available for topic ''', helpname, '''.' ];
    h = displayFileInDlg( fullhelpname, missingMessage, helpname );
end
