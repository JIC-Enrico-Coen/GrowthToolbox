function s = realStringToItemString( s )
    s = regexprep( s, '^0*', '' );
    if any(s=='.')
        s = regexprep( s, '0*$', '' );
    end
    s = regexprep( s, '^\.', '0.' );
    s = regexprep( s, '\.$', '' );
    if isempty(s)
        s = '0';
    end
end
