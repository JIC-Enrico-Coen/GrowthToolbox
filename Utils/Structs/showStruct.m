function showStruct( fid, s, prefix, level )
%showStruct( s )
%   Print s, and all of its components recursively.
%   There are assumed to be no arrays involved except at the bottom level.

    if nargin < 3, prefix = ''; end
    if nargin < 4, level = 0; end
    MAX_NUMS = 5;

    is = indent( level );
    fprintf( fid, '%s%s ', is, prefix );
    if isinteger(s)
        showArray( fid, s, '%d' );
    elseif isfloat(s)
        showArray( fid, s, '%g' );
    elseif islogical(s)
        showArray( fid, s, '%d' );
    elseif ischar(s)
        fprintf( fid, 'char(%d) "%s"\n', numel(s), s );
    elseif isjava(s)
        fprintf( fid, 'java %s\n', sizestring(s) );
    elseif isstruct(s)
        fprintf( fid, 'struct %s\n', sizestring(s) );
        n = sort(fieldnames( s ));
        for i=1:length(n)
            fname = n{i};
            if isempty(s)
                is = indent( level+1 );
                fprintf( fid, '%s%s\n', is, fname );
            else
                showStruct( fid, s(1,1).(fname), fname, level+1 );
            end
        end
    elseif numel(s) ~= 1
        fprintf( fid, '%s array %s\n', class(s), sizestring(s) );
    else
        fprintf( fid, '%s\n', class(s) );
    end
    
function showArray( fid, s, fmt )
    fprintf( fid, '%s(%d)', class(s), numel(s) );
    if numel(s) <= MAX_NUMS
        fprintf( fid, [' ' fmt], s );
    else
        fprintf( fid, ' size [' );
        fprintf( fid, ' %d', size(s) );
        fprintf( fid, ' ]' );
    end
    fprintf( fid, '\n' );
end

end

function str = sizestring( s )
    if numel(s)==1
        str = '';
    else
        s = size(s);
        str1 = sprintf( '%d', s(1) );
        str2 = sprintf( 'x%d', s(2:end) );
        str = [str1 str2];
    end
end

function i = indent( level )
    c(1:(level*2)) = ' ';
    i = char(c);
end
