function s = setStructPath( s, path, value )
    s = setStructPath1( s, value, splitString( '\.', path ) );

    function s = setStructPath1( s, value, fields )
        if isempty(fields)
            s = value;
        else
            fn = fields{1};
            s.(fn) = setStructPath( s(fn), value, fields(2:end) );
        end
    end
end
