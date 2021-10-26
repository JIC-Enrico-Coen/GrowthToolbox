function h = displayFileInDlg( filename, missingMessage, title )
    h = [];
    fid = fopen( filename, 'r' );
    if fid==-1
        if isempty(missingMessage)
            return;
        end
        text = missingMessage;
    else
        text = cell(0,1);
        i = 0;
        currentline = '';
        while true
            line = fgetl(fid);
            if (length(line)==1) && (line==-1)
                if ~isempty(currentline)
                    i = i+1;
                    text{i} = currentline;
                end
                break;
            end
            if (isempty(currentline) && ~isempty(text)) || isempty(line) || (line(1)==' ')
                i = i+1;
                text{i} = currentline;
                currentline = '';
            end
            if isempty(currentline)
                currentline = line;
            else
                currentline = [currentline, ' ', line ];
            end
        end
        fclose(fid);
    end
    h = displayTextInDlg( title, text );
%     h = openfig('textdisplayDlg','new','invisible');
%     hd = guihandles(h);
%     set( hd.thetext, 'String', text );
%     setGUIColors( h, [0.4 0.8 0.4], [0.9 1 0.9] );
%     set( h, 'Visible', 'on', 'Name', title );
end
