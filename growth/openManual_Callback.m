function openManual_Callback(hObject, eventdata)
%openManual_Callback(hObject, eventdata)
%   Callback for the Help/Open Manual menu item.
%   Open the PDF manual.

    try
        toolboxdir = GFtboxDir();
        open( fullfile( toolboxdir, 'docs', 'gftbox.pdf' ) );
    catch e %#ok<NASGU>
        queryDialog( 1, 'Manual not found', 'The manual cannot be found.' )
    end
end
