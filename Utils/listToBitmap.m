function b = listToBitmap( l, len )
    if islogical(l)
        b = l;
    else
        b = false( len, 1 );
        b(l) = true;
    end
end
