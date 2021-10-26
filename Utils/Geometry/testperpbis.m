function testperpbis( n, v )
    starttic = tic;
    for i=1:n
        perpBisIntersect( v );
    end
    toc(starttic);
    starttic = tic;
    for i=1:n
        perpBisIntersect1( v );
    end
    toc(starttic);
    perpBisIntersect( v )
    perpBisIntersect1( v )
end