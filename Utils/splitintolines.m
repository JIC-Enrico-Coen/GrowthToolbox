function lines = splitintolines( s )
    lines = regexp( s, '[^\n]*(\n|$)', 'match' );
end
