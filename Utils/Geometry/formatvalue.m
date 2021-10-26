function s = formatvalue( varargin )
    if nargin > 1
        s = '{ ';
    else
        s = '';
    end
    for i=1:length(varargin)
        v = varargin{i};
        if isstruct(v)
            fprintf( 1, 'formatvalue cannot format structs\n' );
            v
            continue
        elseif ischar(v)
            s1 = ['''' v ''''];
        elseif iscell(v)
            s1 = formatvalue( v{:} );
        elseif length(v) > 1
            if islogical(v)
                s1 = '[';
                for i=1:length(v)
                    s1 = [s1 ' ' boolchar(v, 'true', 'false' )];
                end
                s1 = [s1 ' ]'];
            elseif all(v==round(v))
                s1 = [ '[' sprintf( ' %d', v ) ' ]' ];
            else
                s1 = [ '[' sprintf( ' %f', v ) ' ]' ];
            end
        elseif islogical(v)
            s1 = boolchar( v, 'true', 'false' );
        elseif v==round(v)
            s1 = sprintf( '%d', v );
        else
            s1 = sprintf( '%f', v );
        end
        if isempty(s)
            s = s1;
        elseif i==1
            s = [ s s1 ];
        else
            s = [ s ', ' s1 ];
        end
    end
    if nargin > 1
        s = [s ' }'];
    end
end
