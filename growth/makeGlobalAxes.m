function axes = makeGlobalAxes( localAngle, xiV, etaV, zetaV )
%axes = makeThDiffGlobalTensor( localAngle, xiV, etaV, zetaV )
%    Construct the set of axes resulting from rotating xiV and etaV about
%    zetaV by localAngle.  xiV, etaV, and zetaV are assumed to be unit
%    column vectors.
    c = cos(localAngle);
    s = sin(localAngle);
    princAxis1 = xiV*c + etaV*s;
    princAxis2 = xiV*(-s) + etaV+c;
    axes = [ princAxis1, princAxis2, zetaV ];
end
