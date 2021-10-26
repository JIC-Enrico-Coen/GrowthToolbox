function m = storeCodeRevInfo( m )
    [coderev,codedate] = GFtboxRevision();
    if m.globalProps.coderevision > coderev
        fprintf( 1, [ 'This model was last edited with a more recent version of GFtbox (%d)\n', ...
                      'than the one you are running (%d).\n' ], ...
                 m.globalProps.coderevision, coderev );
    else
        m.globalProps.coderevision = coderev;
        m.globalProps.coderevisiondate = simplifyDate( codedate );
    end
end

function d = simplifyDate( d )
    d = regexprep( d, 'T', ' ' );
    d = regexprep( d, 'Z', '' );
end
