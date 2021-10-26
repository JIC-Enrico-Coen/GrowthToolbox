function c = unescapechars( c )
    for i=1:numel(c)
        switch c(i)
            case 'a'
                c(i) = char(7);
            case 'b'
                c(i) = char(8);
            case 'f'
                c(i) = char(12);
            case 'n'
                c(i) = char(10);
            case 'r'
                c(i) = char(13);
            case 't'
                c(i) = char(9);
            case 'v'
                c(i) = char(11);
        end
    end
end

