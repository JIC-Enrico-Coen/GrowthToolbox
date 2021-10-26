function s = convertFieldToNumber( s, fn, fmt, dflt )
%s = convertFieldToNumber( s, fn, fmt, dflt )
%   Convert the field FN of struct S from a string to a number, using the
%   given FMT.  If yhe field is missing or fails to convert, use the
%   default value DFLT.

    if isfield( s, fn )
        [v,n] = sscanf( s.(fn), fmt, 1 );
        if n ~= 1, v = dflt; end
    else
        v = dflt;
    end
    s.(fn) = v;
end
