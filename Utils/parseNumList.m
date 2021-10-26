function [list,ok,msg] = parseNumList( s )
    list = [];
    ok = false;
    msg = '';
    s = regexprep( s, '\s*:\s*', ':' );
    s = regexprep( s, '\s+', ' ' );
    s = regexprep( s, ',', ' ' );
    s = regexprep( s, '^\s+', '' );
    s = regexprep( s, '\s+$', '' );
    if regexp( s, '[^-+ 0-9.:eE]', 'start', 'once' )
        msg = 'List must contain numbers, colons, comma, and spaces only.';
        return;
    end
    tokens = splitString( ' ', s );
    for i=1:length(tokens)
        t = tokens{i};
        parts = splitString( ':', t );
        if length(parts)==1
            [x,ok1] = string2num( parts{1} );
            if ~ok1
                msg = ['Not a number: ', parts{1} ];
                return;
            end
            list(length(list)+1) = x;
        elseif length(parts)==2
            [x1,ok1] = string2num( parts{1} );
            x2 = 1;
            [x3,ok3] = string2num( parts{2} );
            if ~ok1 || ~ok3
                msg = numerr( [ok1,ok3], parts );
                return;
            end
            list = [ list, x1:x2:x3 ];
        elseif length(parts)==3
            [x1,ok1] = string2num( parts{1} );
            [x2,ok2] = string2num( parts{2} );
            [x3,ok3] = string2num( parts{3} );
            if ~ok1 || ~ok2 || ~ok3
                msg = numerr( [ok1,ok2,ok3], parts );
                return;
            end
            list = [ list, x1:x2:x3 ];
        else
            return;
        end
    end
    ok = true;
end

function msg = numerr( oks, strs )
    for i=1:length(oks)
        if ~oks(i)
            msg = ['Not a number: ', strs{i} ];
            return;
        end
    end
    msg = '';
end
