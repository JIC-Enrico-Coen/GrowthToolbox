function y = calcdistrib( distrib, x )
    i = binsearchupper( distrib(:,1), x ) - 1;
    if i < 1, i = 1; end
    dx = x - distrib(i,1);
    y = distrib(i,3) + distrib(i,2)*dx + distrib(i,4)*dx*dx;
end
