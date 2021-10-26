function tokens = tokeniseString( s )
%tokens = tokeniseString( s )
%   Convert s into a cell array of tokens, splitting it at white space.

    tokstart = 0;
    stringstart = 0;
    escaping = 0;
    curtok = 1;
    tokens = {};
    for i=1:length(s)
        c = s(i);
        if stringstart
            if escaping
                escaping = 0;
            elseif c=='\'
                escaping = 1;
            elseif c==stringstart
                tokens{curtok} = strToToken( s(tokstart:i-1) );
                curtok = curtok+1;
                tokstart = 0;
                stringstart = 0;
            end
        elseif (c=='"') || (c=='''')
            stringstart = c;
            tokstart = i+1;
        elseif c=='#'
            if tokstart==0
                % Comment.  Ignore the rest of the string.
                return;
            elseif stringstart
                % In string.  Do nothing.
            else
                % Comment.  Save the current token and ignore the rest of the string.
                tokens{curtok} = strToToken( s(tokstart:i-1) );
                return;
            end
        else
            isspace = (c==' ') || (c==char(9)) || (c==char(10)) || (c==char(13));
            if isspace
                if tokstart > 0
                    tokens{curtok} = s(tokstart:(i-1));
                    curtok = curtok+1;
                    tokstart = 0;
                end
            elseif tokstart==0
                tokstart = i;
            else
                % Nothing.
            end
        end
    end
    if tokstart > 0
        if stringstart
            tokens{curtok} = strToToken( s(tokstart:end) );
        else
            tokens{curtok} = s(tokstart:end);
        end
    end
end

function token = strToToken( s )
    i = 1;
    j = 1;
    token = [];
    while i <= length(s)
        if s(i)=='\'
            if i==length(s)
                return;
            else
                i = i+1;
                switch s(i)
                    case 's'
                        token(j) = ' ';
                    case 'r'
                        token(j) = char(13);
                    case 'n'
                        token(j) = char(10);
                    case 't'
                        token(j) = char(9);
                    otherwise
                        token(j) = s(i);
                end
                j = j+1;
            end
        else
            token(j) = s(i);
            j = j+1;
        end
        i = i+1;
    end
    token = char(token);
end
