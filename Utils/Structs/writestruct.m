function ok = writestruct( dirname, basename, s )
%writestruct( dirname, basename, s )
%   Write the value of s to the file.  readstruct(dirname, basename) can be
%   used to read it in again.
%   This does not write any Java objects that the value of s may contain.
%   Other than that, the structure read in by readstruct should be
%   identical to the structure written by writestruct.

    ok = true;
    fullfilename = fullfile( dirname, basename );
    [fid,msg] = fopen( fullfilename, 'wt' );
    if fid == -1
        fprintf( 1, 'Cannot write to file %s. (%s) Mesh not saved.\n', fullfilename, msg );
        ok = false;
        return;
    end
    writestructfid( fid, s, '' );
    fclose(fid);
end

function writescalararray( fid, s, fmt )
    sz = size(s);
    s1 = reshape( s, [], sz(length(sz)) );
    if any( any( s1, 1 ), 2 )
        fprintf( fid, '\n' );
        for i=1:size(s1,1)
            fprintf( fid, fmt, s1(i,:) );
            fprintf( fid, '\n' );
        end
    else
        fprintf( fid, ' zero\n' );
    end
end

function writestructfid( fid, s, prefix )
%writestructfid( fid, s, prefix )
%   Does the work of writestruct.

    fprintf( fid, '%s ', prefix );
    fprintf( fid, '%s %s', class(s), sizestring(s) );
    if isinteger(s)
        writescalararray( fid, s, ' %d' );
    elseif isfloat(s)
        writescalararray( fid, s, ' %f' );
    elseif islogical(s)
        writescalararray( fid, s, ' %d' );
    elseif ischar(s)
        writescalararray( fid, s, '%c' );
    elseif iscell(s)
        fprintf( fid, '\n' );
        writecellarray( fid, s, prefix );
    elseif isstruct(s)
        fprintf( fid, '\n' );
        n = fieldnames( s );
        if numel(s) == 1
            for k=1:length(n)
                writestructfid( fid, s.(n{k}), [prefix '.' n{k} ] );
            end
        else
            s1 = reshape(s,numel(s),1);
            l = labels( size(s) );
            for i=1:length(l)
                for k=1:length(n)
                    writestructfid( fid, s1(i).(n{k}), [prefix l(i).s '.' n{k} ] );
                end
            end
        end
    else
        % Nothing.
    end
end

function writecellarray( fid, s, prefix )
    s1 = reshape( s, [], 1 );
    for i=1:length(s1)
        fprintf( fid, '%s{%d}', prefix, i );
        writestructfid( fid, s1{i}, '' );
    end
end


function l = labels( sz )
    c = ones(1,length(sz));
    numl = prod(sz);
    l(numl).s = '';
    for i=1:numl
        s = num2str(c);
        s = regexprep( s, '  *', ',' );
        l(i).s = [ '(', s, ')' ];
        c = increment( c, sz );
    end
end

function c = increment( c, sz )
    i = length(c);
    while 1
        c(i) = c(i)+1;
        if c(i) > sz(i)
            c(i) = 1;
            i = i-1;
            if i == 0
                return;
            end
        else
            return;
        end
    end
end


function str = sizestring( s )
    s = size(s);
    str1 = sprintf( '%d', s(1) );
    str2 = sprintf( 'x%d', s(2:end) );
    str = [str1 str2];
end
