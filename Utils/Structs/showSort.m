function showSort( fid, s, prefix, level )
%showSort( s )
%   Show what sort of thing s is, and all of its components recursively.

    if nargin < 3, prefix = ''; end
    if nargin < 4, level = 0; end

    is = '';
    fprintf( fid, '%s%s ', is, prefix );
    if isnumeric(s)
        fprintf( fid, 'numeric %s\n', sizestring(s) );
    elseif islogical(s)
        fprintf( fid, 'logical %s\n', sizestring(s) );
    elseif ischar(s)
        fprintf( fid, 'char %s\n', sizestring(s) );
    elseif isjava(s)
        fprintf( fid, 'java %s\n', sizestring(s) );
    elseif isstruct(s)
        fprintf( fid, 'struct %s\n', sizestring(s) );
        n = fieldnames( s );
        for i=1:length(n)
            fname = n{i};
            showSort( fid, s(1,1).(fname), [prefix '.' fname], level+1 );
        end
    else
        fprintf( fid, '%sunknown %s\n', is, sizestring(s) );
    end
end

function str = sizestring( s )
    s = size(s);
    str1 = sprintf( '%d', s(1) );
    str2 = sprintf( 'x%d', s(2:end) );
    str = [str1 str2];
end
