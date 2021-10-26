function imagedata = rescaleimage( imagedata, xwidth, ywidth )
%imagedata = rescaleimage( imagedata, xwidth, ywidth )
%   Resample an image to a lower resolution.
%   imagedata should be an X*Y*3 array of uint8.
%
%   This is rather inefficient when xwidth and ywidth are large, and is
%   intended for making small thumbnails of no more than 64 pixels square.
%   xwidth and ywidth must not be larger than the corresponding dimension
%   of imagedata.

    oldxwidth = size( imagedata, 1 );
    oldywidth = size( imagedata, 2 );
    xwidth = round( min( xwidth, oldxwidth ) );
    ywidth = round( min( ywidth, oldywidth ) );
    xscale = oldxwidth/xwidth;
    xlo = 1 + floor((0:(xwidth-1))*xscale);
    xhi = [ xlo(2:end)-1, oldxwidth ];
    yscale = oldywidth/ywidth;
    ylo = 1 + floor((0:(ywidth-1))*yscale);
    yhi = [ ylo(2:end)-1, oldywidth ];
    newcdata = uint8( zeros( [xwidth, ywidth, 3] ) );
    for i=1:xwidth
        for j=1:ywidth
            tile = imagedata( xlo(i):xhi(i), ylo(j):yhi(j), : );
            newcdata(i,j,:) = ...
                uint8( round( sum( sum( double(tile), 1 ), 2 ) ...
                       / ((xhi(i)-xlo(i)+1)*(yhi(j)-ylo(j)+1)) ) );
        end
    end
    imagedata = newcdata;
end
