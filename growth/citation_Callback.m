function citation_Callback(hObject, eventdata)
%citation_Callback(hObject, eventdata)
%   Display a citation of our papers.

    citerecords = readCitationFile( 'GFtbox_citations.txt' );
    ud = get( hObject, 'UserData' );
    citetext = makeCitations( citerecords, ud.bibtex );
    textdisplayDlg('theText', citetext, 'title', 'Citations', 'size', [700,600] );
end

