function unionData = updateSpreadsheet( spreadsheetFile, newdata )
%unionData = updateSpreadsheet( spreadsheetFile, newdata )
%
% SPREADSHEETFILE is the name of an Excel spreadsheet that was written by
% Matlab. When read in, it is assumed to yield a cell array in the same
% format as those handled by MERGESPREADSHEETDATA. NEWDATA is a cell array
% of the same form. The two sets of data are united with
% MERGESPREADSHEETDATA. The result is returned, and it may also be written
% to the spreadsheet file, overwriting its previous contents.
%
% If the spreadsheet does not exist, it will be created with the contents
% of NEWDATA.
%
% See also: mergeSpreadsheetData

    if exist( spreadsheetFile, 'file' )
        olddata = readcell( spreadsheetFile );
        for i=1:numel(olddata)
            if isa( olddata{i}, 'missing' )
                olddata{i} = '';
            end
        end
        unionData = mergeSpreadsheetData( olddata, newdata );
    else
        unionData = newdata;
    end
    
    if exist( spreadsheetFile, 'file' )
        [filepath,basename,ext] = fileparts( spreadsheetFile );
        spreadsheetFileBackup = fullfile( filepath, [basename, '-BAK', ext] );
        [ok,msg,msgid] = copyfile( spreadsheetFile, spreadsheetFileBackup );
        if ~ok
            timedFprintf( 'Cannot back up spreadsheet %d.\n  Reason: %s:%s\n', spreadsheetFile, msgid, msg );
        end
    else
        ok = true;
    end
    
    if ok
        writecell( unionData, spreadsheetFile, 'FileType', 'spreadsheet', 'WriteMode', 'inplace' );
    end
end