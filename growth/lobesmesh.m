function m = lobesmesh( nlobes, radius, nrings, rectht, nrows, nbase )
    m = lobemesh( radius, nrings, rectht, nrows, nbase );
    if nlobes <= 1, return; end
    leftBorder = m.borders.left;
    rightBorder = m.borders.right;
    newrightborder = rightBorder;
    m1 = m;
    for i=2:nlobes
        [m,renumber] = stitchmeshes( m1, m, rightBorder, leftBorder );
        newrightborder = renumber(newrightborder);
    end
    m.borders.left = leftBorder;
    m.borders.right = newrightborder;
    m.globalProps.trinodesvalid = true;
end
