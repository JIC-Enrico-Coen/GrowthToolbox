function is = suffixStringToItemString( ts )
    is = regexprep( ts, '[mM]', '-' );
    is = regexprep( is, '[dD]', '.' );
    is = realStringToItemString( is );
end
