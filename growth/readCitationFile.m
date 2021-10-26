function citations = readCitationFile( filename )
    citations = {};
    fid = fopen( filename, 'r' );
    if fid==-1
        return;
    end
    field = '';
    value = '';
    curCitation = [];
    tab = char(9);
    linenum = 0;
    while true
        s = fgetl( fid );
        linenum = linenum+1;
        ended = iseof(s);
        if ~ended
            s = regexprep( s, '[ \t]*$', '' );
        end
        if isempty(s) || ended
            recordCitation();
            if ended
                break;
            else
                continue;
            end
        end
        if (s(1)==' ') || (s(1)==tab)
            if ~isempty(field)
                morevalue = regexprep( s, '^[ \t]*', '' );
                value = [ value ' ' morevalue ];
            end
        else
            tokens = regexp( s, '^([^ \t]+)[ \t]+(.*)$', 'tokens' );
            if isempty(tokens)
                continue;
            end
            tokens = tokens{1};
            if length(tokens) ~= 2
                continue;
            end
            recordField();
            field = tokens{1};
            value = tokens{2};
        end
    end
    fclose( fid );
    
    function recordCitation()
        recordField();
        if ~isempty( curCitation )
            citations{end+1} = curCitation;
            curCitation = [];
        end
    end
    
    function recordField()
        if ~isempty(field)
            curCitation.(field) = value;
            field = '';
            value = '';
        end
    end

end
