function s = readWholeFile( fid )
    s = '';
    if ~isnumeric(fid)
        filename = fid;
        fid = fopen(filename, 'r' );
        if fid == -1
            fprintf( 1, 'Cannot read from file %s.\n', filename );
            return;
        end
    end
    if fid == -1
        fprintf( 1, 'Cannot read from file.\n' );
        return;
    end
    i = 0;
    lines = cell(1,100);
    while true
        line = fgets( fid );
        if line == -1
            fclose(fid);
            break;
        end
        i = i+1;
        lines{i} = line;
    end
    s = [ lines{:} ];
end
