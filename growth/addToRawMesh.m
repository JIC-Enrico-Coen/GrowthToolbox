function rawmesh = addToRawMesh( rawmesh, filename, formats )
    fid = fopen(filename,'r');
    if fid==-1
        fprintf( 1, 'Cannot read from file %s.\n', filename );
        return;
    end
    fprintf( 1, 'Reading file %s.\n', filename );
    linenum = 0;
    fileextension = regexp( filename, '\.([^./\\]*)$', 'tokens' );
    if size(fileextension,1)==0
        fileextension = filename;
    end
    fileextension = fileextension{1}{1};
    fileextension = regexprep( fileextension, '[^A-Za-z0-9_]', '_' );
    fileextension = regexprep( fileextension, '^[0-9_]*', '' );
    if isempty(fileextension)
        fileextension = 'UNKNOWN';
    end
    
    while 1
        s = fgetl( fid );
        if s==-1, break; end
        linenum = linenum+1;
        s = regexprep(s, '^\s*', ''); % Strip leading space.
        s = regexprep(s, '#.*', ''); % Strip comments.
        s = regexprep(s, '\s*$', ''); % Strip trailing space.
        if isempty(s), continue; end % Ignore empty lines.
        [c,s] = strtok( s );
        if regexp( c, '^[0-9]+$' ) == 1
          % fprintf( 1, 'First token on line %d is a number %s, using file extension %s as field name.\n    %s\n', ...
          %     linenum, c, fileextension, s );
            s = [ c, ' ', s ];
            c = fileextension;
        else
            if isempty(regexp( c, '^[_a-zA-Z][-_a-zA-Z0-9]*$', 'once' ))
                fprintf( 1, 'Invalid token "%s" on line %d of file %s: line ignored.\n', ...
                    c, linenum, filename );
                continue;
            end
            c = regexprep( c, '-', '_' );
        end
        
        switch c
            case 'f'
                data = obj_f_parse( s );
            otherwise
                if isfield(formats,c)
                    format = formats.(c);
                else
                    format = '%f';
                end
                data = sscanf( s, format )';
        end
        if ~isfield( rawmesh, c )
            rawmesh.(c) = data;
          % fprintf( 1, 'New field name "%s", %d parameters.\n', c, length(data) );
        else
            expectedLength = size(rawmesh.(c),2);
            if length(data) > expectedLength
                fprintf( 1, ...
                'Warning: ignoring %d extra numbers in line %d, type %s, of file %s.\n    %s\n', ...
                    length(data) - expectedLength, ...
                    linenum, ...
                    c, ...
                    filename, ...
                    s );
                data = data(1:expectedLength);
            elseif length(data) < expectedLength
                fprintf( 1, ...
                    'Warning: zeroing %d missing numbers in line %d, type %s, of file %s.    %s\n\n', ...
                    expectedLength - length(data), ...
                    linenum, ...
                    c, ...
                    filename, ...
                    s );
            end
            rawmesh.(c)(size(rawmesh.(c),1)+1,:) = data;
        end
    end
    status = fclose(fid);
    if status ~= 0
        fprintf( 1, '%s: error when closing file %s.\n', mfilename(), filename );
    end
end

function vertexes = obj_f_parse( line )
% Parse the body of an OBJ line for an "f" field.  This should consist of
% a number of fields, each beginning with an unsigned integer.  A field in
% gneral can consist of up to three unsigned integers separated by "/", but
% we are only interested in the first integer and do not verify the rest of
% the field for syntactic correctness.

    tt = regexp( line, '([0-9]+)[^ ]*', 'tokens' );
    vertexes = zeros(1,length(tt));
    for i=1:length(tt)
        vertexes(i) = sscanf( tt{i}{1}, '%d' );
    end
end
