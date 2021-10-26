function s = printOptions( fid, options )
%printModelOptions( m )
%printModelOptions( fid, m )
%   Print the current model options to the given stream (by default the
%   console).

    if nargin==1
        options = fid;
        fid = 1;
    end
    
    havefile = fid >= 0;
    if nargout > 0
        s = '';
    else
        s = -1;
    end
    
    if isempty( options )
        if havefile
            fprintf( fid, '    None.\n' );
        end
    else
        fns = fieldnames( options );
        for i=1:length(fns)
            fn = fns{i};
            v = getOption( options, fn );
            if ischar( v )
                s = sfprintf( s, fid, '    %s: ''%s''\n', fn, v );
            elseif islogical( v )
                s = sfprintf( s, fid, '    %s: %s\n', fn, boolchar(v,'true','false') );
            else
                s = sfprintf( s, fid, '    %s:', fn );
                s = sfprintf( s, fid, ' %g', v );
                s = sfwrite( s, fid, newline );
            end
        end
    end
end

function s = sfprintf( s, fid, varargin )
    if ischar(s)
        s = [s sprintf( varargin{:} )];
    end
    if fid >= 0
        fprintf( fid, varargin{:} );
    end
end

function s = sfwrite( s, fid, str )
    if ischar(s)
        s = [s str];
    end
    if fid >= 0
        fwrite( fid, str );
    end
end