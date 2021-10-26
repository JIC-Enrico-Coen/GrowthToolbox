function newstruct = readstruct( filepath, filename )
%newstruct = readstruct( filepath, filename )
%   Read a Matlab struct from a file.
%   A .stc file stores a Matlab struct in textual form.  Each field of the
%   struct is printed, together with the dimensions of its value, on a line
%   of its own.  It is followed on subsequent lines by the value of the
%   field.  (If the field contains a single, numeric value, then that value
%   is printed on the same line as the field name.)  If the field is itself
%   a struct (or struct array) this continues recursively.

    newstruct = [];
    fullname = fullfile( filepath, filename );
    [fid,msg] = fopen( fullname, 'rt' );
    if fid == -1
        fprintf( 1, 'Cannot read file %s. (%s)\n', fullname, msg );
        return;
    end

    while 1
        s = fgetl(fid);
        if isempty(s), continue; end
        if ~ischar(s), break; end
        if s(1)=='.'
            % New field.
            tokens = splitString( '  *', s );
            type = tokens{2};
            if strcmp( type, 'struct' )
                % Ignore.
            elseif exist( type, 'class' )
                % Ignore.
            else
                fieldpath = tokens{1};
                fmt = typeFormat( type );
                if length(tokens) < 3
                    sz = [1 1];
                else
                    sz = decodeSize( tokens{3}, 'x' )';
                end
                allzero = (length(tokens) >= 4) && strcmp( tokens{4}, 'zero' );
                len = prod(sz);
                if (len==1) && ~allzero && (length(tokens) >= 4)
                    v = cast( tokens{4}, type );
                elseif allzero
                    v = cast( zeros(sz), type );
                else
                    cols = sz(length(sz));
                    rows = prod(sz(1:(end-1)));
                    needcast = strcmp( type, 'logical' ) || strcmp( type, 'char' );
                    if needcast
                        type1 = 'int16';
                    else
                        type1 = type;
                    end
                    if strcmp(type1,'cell')
                        v = cell( sz );
                    else
                        v2 = zeros( rows, cols, type1 );
                        for i=1:rows
                            s = fgetl(fid);
                            if ~ischar(s)
                                fprintf( 1, 'Field %s should have %d rows, %d found.\n ', ...
                                    fieldpath, rows, i-1 );
                                break;
                            end
                            if strcmp(type,'char')
                                v1 = s;
                                if (length(v1) == sz(2)-1) && (v1(length(v1)) ~= char(10))
                                    v1(length(v1)+1) = char(10);
                                end
                            else
                                v1 = strread( s, fmt, -1 );
                            end
                            if length(v1) ~= sz(2)
                                fprintf( 1, 'Value of %s should have %d columns, %d found.\n ', ...
                                    fieldpath, cols, length(v1) );
                                break;
                            else
                                v2(i,:) = v1;
                            end
                        end
                        if needcast
                            v2 = cast(v2,type);
                        end
                        v = reshape( v2, sz );
                    end
                end
                newstruct = setfieldbystring( newstruct, fieldpath, v );
            end
        else
            % Ignore other lines.
        end
    end
    
    fclose(fid);
end

function f = typeFormat( t )
    switch t
        case 'double', f = '%f';
        case 'single', f = '%f';
        case 'logical', f = '%d';
        case 'char', f = '%c';
        case 'cell', f = '';
        case 'struct', f = '';
        case 'function_handle', f = '%f';
        case 'int8', f = '%d';
        case 'uint8', f = '%d';
        case 'int16', f = '%d';
        case 'uint16', f = '%d';
        case 'int32', f = '%d';
        case 'uint32', f = '%d';
        case 'int64', f = '%d';
        case 'uint64', f = '%d';
        otherwise, f = '';
    end
end

function sz = decodeSize( s, c )
    ss = regexprep( s, c, ' ' );
    sz = sscanf( ss, '%d' );
end

function newstruct = setfieldbystring( newstruct, fieldpath, v )
%newstruct = setfieldbystring( newstruct, fieldpath, v )
%   Set the component of newstruct specified by fieldpath to the value v.
%   We do this in one line with eval(), but for security we first check
%   that fieldpath really is a component description.
%   It must consist of a series of fields separated by '.'.  Each field
%   must be an identifier formed from letters and underscores, optionally
%   followed by a series of positive integers separated by commas,
%   enclosed in round brackets.

    fields = splitString( '\.', fieldpath );
    for i=1:length(fields)
        f = fields{i};
        si = regexp( f, '\(.*\)$', 'once', 'start' );
        subscripts = '';
        if ~isempty(si)
            subscripts = f( si+1 : length(f)-1 );
            f = f( 1 : si-1 );
        end
        if ~regexp( f, '^[a-zA-Z_][a-zA-Z_]*$', 'once' )
            fprintf( 1, 'Invalid field name "%s".\n', f );
            return;
        end
        if ~isempty(subscripts) && ~regexp( subscripts, '^[1-9][,0-9]*$', 'once' )
            fprintf( 1, 'Invalid subscripts ("%s").\n', subscripts );
            return;
        end
    end
    
    eval( ['newstruct', fieldpath, ' = v;'] );
end

