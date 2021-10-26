function c = structFromFile( filename )
%c = structFromFile( filename )
%   Read the given file, and parse each line into a token followed by a
%   string.  Use the token as a field name and the string as the
%   corresponding value.  The token will be forced to be a valid Matlab
%   field name by replacing all non-alphanumerics by underscores, and if
%   the result begins with a digit, prefixing 'F_'.
%
%   If a token occurs multiple times, the values will be stored as a cell
%   array.
%
%   Blank lines and lines beginning with a # are ignored.
%   If the file cannot be read, an empty struct is returned.

    c = struct();
    fid = fopen( filename );
    if fid==-1, return; end
    while true
        s = fgetl( fid );
        if (length(s)==1) && (s==-1)
            break;
        end
        s = regexprep( s, '^\s+', '' );
        s = regexprep( s, '\s+$', '' );
        if isempty(s), continue; end
        if s(1)=='#', continue; end
        tokens = regexp( s, '^([^\s]+)\s+(.*)$', 'tokens' );
        if length(tokens) ~= 1, continue; end
        tokens = tokens{1};
        if length(tokens) ~= 2, continue; end
        field = tokens{1};
        field = regexprep( field, '[^A-Za-z0-9_]', '_' );
        if ~isletter(field(1))
            field = [ 'F_', field ];
        end
        value = tokens{2};
        if isfield( c, field )
            if iscell( c.(field) )
                x = c.(field);
                x{end+1} = value;
                c.(field) = x;
            else
                c.(field) = { c.(field), value };
            end
        else
            c.(field) = value;
        end
    end
    fclose(fid);
end
