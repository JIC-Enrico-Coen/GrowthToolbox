function theunit = defaultScaleBarUnit( pixelwidth, realwidth )
    if realwidth < 0
        realwidth = -realwidth;
    end
    scalerange = 2.51;
    minwidth = min( pixelwidth/scalerange, max( 100, pixelwidth*0.1 ) );
    maxwidth = minwidth*scalerange;
    minunit = minwidth*realwidth/pixelwidth;
    maxunit = maxwidth*realwidth/pixelwidth;
    minl = log10(minunit);
    minlfrac = 10^(minl - floor(minl));
    maxl = log10(maxunit);
    maxpow = floor(maxl);
    maxlfrac = 10^(maxl - maxpow);
    if minlfrac > maxlfrac
        minlfrac = minlfrac/10;
    end
    if (minlfrac <= 1) && (maxlfrac >= 1)
        theunit = 10^maxpow;
    elseif (minlfrac <= 2) && (maxlfrac >= 2)
        theunit = 2*10^maxpow;
    elseif (minlfrac <= 5) && (maxlfrac >= 5)
        theunit = 5*10^maxpow;
    else
        theunit = NaN;
    end
  % theunitpixels = theunit*pixelwidth/realwidth;
end
