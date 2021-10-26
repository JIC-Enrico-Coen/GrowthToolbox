function echoCommand( m, cmd, varargin )
    global GF_ECHO
    if (~exist('GF_ECHO','var')) || isempty(GF_ECHO) || (~GF_ECHO)
        return;
    end
    
    fprintf( 1, 'm = %s(', cmd );
    if isempty(m)
        fprintf( 1, ' []' );
    else
        fprintf( 1, ' m' );
    end
    for i=1:length(varargin)
        printArg(varargin{i},true);
    end
    fprintf( 1, ' );\n' );
end

function printArg( a, comma )
    if comma
        fprintf( 1, ', ' );
    end
    if ischar(a)
        fprintf( 1, '''%s''', a );
    elseif iscell(a)
        fprintf( 1, ', {' );
        for i=1:length(a)
            printArg(a{i},i>1);
        end
        fprintf( 1, '}' );
    elseif isnumeric(a)
        if numel(a)==1
            if a==round(a)
                fprintf( 1, '%d', a );
            else
                fprintf( 1, '%f', a );
            end
        else
            if size(a,1)==1
                c = ',';
            else
                c = ';';
            end
            a = reshape(a,1,[]);
            if all(a==round(a))
                fmt = 'd';
            else
                fmt = 'f';
            end
            fprintf( 1, ['[%',fmt], a(1) );
            fprintf( 1, [c,'%',fmt], a(2:numel(a)) );
        end
    end
end
