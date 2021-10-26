function [ok, arg, args] = getTypedArg( msg, type, args, default )
    if isempty( args )
        if nargin >= 4
            ok = 1;
            arg = default;
        else
            ok = 0;
            arg = 0;
            fprintf( 1, '%s: Missing argument. Command ignored.\n', msg );
        end
    else
        arg = args{1};
        ok = isType(arg,type);
        if ok
            args = {args{2:end}};
        else
            fprintf( 1, '%s: %s argument expected, %s found.  Command ignored.\n', msg, stringsToString(type), class(arg) );
        end
    end
end

function s = stringsToString( ss )
    if iscell(ss)
        s = [ '{', ss{1} ];
        for i=2:length(ss)
            s = [ s, ',', ss{i} ];
        end
        s = [ s, '}' ];
    else
        s = ss;
    end
end


