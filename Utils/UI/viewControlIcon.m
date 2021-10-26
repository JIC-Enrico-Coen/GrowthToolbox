function im = viewControlIcon( type, sz, hl )
    switch type
        case 'zoom'
            im = zoomIcon( sz );
        case 'pan'
            im = panIcon( sz );
        case 'roll'
            im = rollIcon( sz );
        otherwise
            im = emptyIcon( sz );
    end
    if hl
        im = highlight(im);
    end
end

function im = highlight( im )
    sz1 = size(im,1);
    sz2 = size(im,2);
    margin = min( 3, max( 2, floor(min(sz1,sz2)/10) ) );
    im( 1:margin, : ) = 0;
    im( (sz1-margin+1):sz1, : ) = 0;
    im( :, 1:margin ) = 0;
    im( :, (sz2-margin+1):sz2 ) = 0;
end

function im = blur( im, pixels )
    ip = floor(pixels);
    for i=1:ip
        im = blurfrac(im,1);
    end
    if pixels > ip
        im = blurfrac(im,pixels-ip );
    end
    im = 1 - im;
    im(:) = (im/max(im(:)));
    im = 1 - im;
    im(im<1) = 0;
end

function im = blurfrac( im, delta )
    sz1 = size(im,1);
    sz2 = size(im,2);
    imL = im( [2:sz1, 1], : );
    imR = im( [sz1, 1:(sz1-1)], : );
    imU = im( :, [2:sz2, 1] );
    imD = im( :, [sz2, 1:(sz2-1)] );
    im = (1-delta/2)*im + (delta/8)*(imL+imR+imU+imD);
end

function im = emptyIcon( sz )
    im = ones( sz, sz );
end

function im = rollIcon( sz )
    im = ones( sz, sz );
    mid = round(sz/2);
    radius = round(sz/4);
    steps = radius*10;
    for t=1:steps
        theta = (pi*2*t)/steps;
        x = round(radius*cos(theta));
        y = round(radius*sin(theta));
        im(mid+x,mid+y) = 0;
    end
    headsize = ceil(sz/8);
    diag = round(radius/sqrt(2));
    p1 = mid-diag;
    p2 = mid+diag;
    headrange = 0:(headsize-1);
    im( p1, p1-headrange ) = 0;  % NW outside
  % im( p1+headrange, p1 ) = 0;  % NW inside
    im( p1-headrange, p2 ) = 0;  % NE outside
  % im( p1, p2-headrange ) = 0;  % NE inside
    im( p2, p2+headrange ) = 0;  % SE outside
  % im( p2-headrange, p2 ) = 0;  % SE inside
    im( p2+headrange, p1 ) = 0;  % SW outside
  % im( p2, p1+headrange ) = 0;  % SW inside
    headsize = ceil( headsize/sqrt(2) );
    for i=1:(headsize-1)
        im( mid-radius-i, mid-i ) = 0;
        im( mid+radius+i, mid+i ) = 0;
        im( mid+i, mid-radius-i ) = 0;
        im( mid-i, mid+radius+i ) = 0;
    end
%{
    for i=1:(headsize-1)
        im( [mid-radius-i,mid-radius+i], mid-i ) = 0;
        im( [mid+radius-i,mid+radius+i], mid+i ) = 0;
        im( mid+i, [mid-radius-i,mid-radius+i] ) = 0;
        im( mid-i, [mid+radius-i,mid+radius+i] ) = 0;
    end
%}
end

function im = panIcon( sz )
    im = ones( sz, sz );
    mid = round(sz/2);
    im(mid,2:(sz-1)) = 0;
    im(2:(sz-1),mid) = 0;
    headsize = round(sz/6);
    for i=2:headsize
        j = sz-i+1;
        sides = [mid-i+1,mid+i-1];
        im( sides, [i+1,j-1] ) = 0;
        im( [i+1,j-1], sides ) = 0;
    end
end

function im = zoomIcon( sz )
    im = emptyIcon( sz );
    margin = round(sz/3);
    mn = margin;
    mx = sz-margin+1;
    im( [mn,mx], mn:mx ) = 0;
    im( mn:mx, [mn,mx] ) = 0;
    for i=1:(mn-1)
        j = sz-i+1;
        im( [i,j], [i,j] ) = 0;
    end
end

