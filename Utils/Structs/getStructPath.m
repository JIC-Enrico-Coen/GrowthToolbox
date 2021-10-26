function s = getStructPath( s, path )
    fields = splitString( '\.', path );
    for i=1:length(fields)
        s = s.(fields{i});
    end
end
