function nzimage( A, blockx, blocky, f )
%nzimage( A, blockx, blocky, f )
%   Produce a greyscale image showing the non-zero elements of A.  Each
%   pixel of im corresponds to a blockx*blocky tile of A, and its greyscale
%   level represents the proportion of non-zero elements in that tile.
%   f is a figure to plot into.

    if nargin < 2
        blockx = 1;
    end

    if nargin < 3
        blocky = 1;
    end

    if (blockx==1) && (blocky==1)
        if nargin >= 4
            figure(f);
        end
        image( repmat(A==0,[1,1,3]) );
        axis square
        return;
    end
            
    sx = size(A,1);
    sy = size(A,2);
    nx = floor(sx/blockx);
    ny = floor(sy/blocky);
    tilesize = blockx*blocky;
    ibase = 0;
    im = zeros( nx, ny );
    for i=1:nx
        jbase = 0;
        for j=1:ny
            im(i,j) = sum( sum( A( (ibase+1):(ibase+blockx), (jbase+1):(jbase+blockx) ) ~= 0 ) );
            jbase = jbase+blocky;
        end
        ibase = ibase+blockx;
    end
    im = im/tilesize;
    
    if nargin >= 4
        figure(f);
    end
    image( repmat(1-im/max(max(im)),[1,1,3]) );
    axis square
end
