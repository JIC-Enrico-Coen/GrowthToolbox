function testtok( filename )
    testtokD( filename );
end

function testtokD( filename )
    s = readsyntax( 'xx' );
  % showStruct( 1, s );
    v = execcmds( filename, s, [], 0 )
end

function testtokC( filename )
    s = readsyntax( 'xx' );
    showStruct( 1, s );
end

function testtokB( filename )
    ts = opentokenlinestream( filename );
    if isempty(ts)
        fprintf( 1, 'Cannot open file "%s".\n', filename );
    else
        while 1
            [ts,toks] = readtokenline( ts );
            if ~isempty(toks)
                fprintf( 1, 'Line %d contains %d tokens.\n', ts.curline, length(toks) );
                for i=1:length(toks)
                    fprintf( 1, '[%s] ', toks{i} );
                end
                fprintf( 1, '\n' );
            else
                break;
            end
        end
    end
end

function testtokA( filename )
    ts = opentokenstream( filename );
    if ts.fid == -1
        fprintf( 1, 'Cannot open file "%s".\n', filename );
    else
        ts = dumptokens( ts );
    end
    ts = putback( ts, 'asdasds' );
    dumptokens( ts );
end

function ts = dumptokens( ts )
    numtokens = 0;
    while 1
        [ts,t] = readtoken( ts );
        if t
            numtokens = numtokens+1;
            fprintf( 1, 'Token %d line %d "%s"\n', numtokens, ts.curline, t );
        else
            fprintf( 1, '%d tokens read.\n', numtokens );
            return;
        end
    end
end
    
