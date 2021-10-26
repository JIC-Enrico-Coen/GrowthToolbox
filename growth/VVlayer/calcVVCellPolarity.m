function vvlayer = calcVVCellPolarity( vvlayer, mvals, flat )
    numcells = size( vvlayer.vvptsC, 1 );
    if flat
        dims = [1 2];
    else
        dims = [1 2 3];
    end
    for i=1:numcells
        mvxs = vvlayer.cellM{i};
        pts = vvlayer.vvptsM( mvxs, dims );
        cmvals = mvals( mvxs );
        vvlayer.cellpolarity(i,dims) = averageGradient( pts, cmvals );
    end
end
