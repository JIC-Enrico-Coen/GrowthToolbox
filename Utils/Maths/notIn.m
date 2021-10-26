function b = notIn( n, a )
    b = true(1,n);
    b(a) = false;
    b = find(b);
end

