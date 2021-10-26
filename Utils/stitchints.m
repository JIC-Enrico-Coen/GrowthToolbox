function r = stitchints( n, s )
    r = 1:n;
    z = true(1,n);
    r(s(:,1)) = r(s(:,2));
    z(s(:,1)) = false;
    j = 0;
    for i=1:n
        if z(i)
            j = j+1;
            r(i) = j;
        end
    end
end
