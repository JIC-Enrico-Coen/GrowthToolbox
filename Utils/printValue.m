function printValue( fid, v, indent )
%printStruct( fid, s )
%   Print the struct s to the stream fid.

    if nargin < 3
        indent = 0;
    end
    indentstring = repmat( '    ', 1, indent );
    newln = char(10);

    if isempty(v)
        fwrite( fid, ' (empty)' );
    elseif islogical(v)
        for i=1:length(v)
            fprintf( fid, ' %s', boolchar(v(i),'true','false') );
        end
    elseif isinteger(v)
        fprintf( fid, ' %d', v );
    elseif isnumeric(v)
        fprintf( fid, ' %g', v );
    elseif ischar(v)
        fprintf( fid, ' ''%s''', v );
    elseif iscell(v)
        fwrite( fid, ' {' );
        fprintf( fid, ' %g', v{:} );
        fwrite( fid, ' }' );
    elseif isstruct(v)
        if nargin >= 3
            fwrite( fid, newln );
        end
        fns = fieldnames(v);
        nfns = length(fns);
        for si = 1:length(v)
            for i=1:nfns
                fn = fns{i};
                v1 = v(si).(fn);
                fprintf( fid, '%s%s:', indentstring, fn );
                printValue( fid, v1, indent+1 );
                if ~isstruct(v1)
                    fwrite( fid, newln );
                end
            end
        end
    else
        fprintf( fid, 'class:%s', class(v) );
    end
    
    if (nargin < 3) && ~isstruct(v)
        fwrite( fid, newln );
    end
end
