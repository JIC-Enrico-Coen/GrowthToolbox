function img = imgForceSize( img, sz, backgroundColor )
%img2 = imgForceSize( img, sz, backgroundColor )
%   Force the given image to have the given size, by either cropping it or
%   extending it. When it is extended, the extra pixels have
%   BACKGROUNDCOLOR, which defaults to white, and opaque if IMG has an
%   alpha channel.
%
%   If BACKGROUNDCOLOR is 'mean', then it is set to the mean of all pixels
%   in the original image. If it is 'border', then it is set to the mean of
%   all pixels on the edge of the original image. If it is 'extend', then
%   the pixels at the edges of the image will be replicated when the image
%   has to be extended.
%
%   SZ can have either 2 or 3 elements. If it has three elements, the
%   number of channels of the image will be forced to have that value,
%   which must be either 1 (grayscale) 2, (grayscale+alpha), 3 (rgb), or 4
%   (rgb+alpha).

    if all(size(img)==sz)
        return;
    end

    if nargin < 3
        backgroundColor = [1 1 1];
    end
    imgclass = class( img );
    img2 = img;
    if length(sz) >= 3
        img2 = fitImgToColorDepth( img2, sz(3) );
        img2 = convertImageType( img2, imgclass );
    end
    imgsz = size( img2 );
    extendEdges = false;
    switch backgroundColor
        case 'mean'
            backgroundColor = mean( mean( img2, 1, 'native' ), 2, 'native' );
        case 'border'
            if isempty(img2)
                backgroundColor = [1 1 1];
            elseif (imgsz(1) <= 2) || (imgsz(2) <= 2)
                backgroundColor = mean( mean( img2, 1, 'native' ), 2, 'native' );
            else
                e1 = reshape( img2(1:(end-1),1,:), imgsz(1)-1, imgsz(3) );
                e2 = reshape( img2(end, 1:(end-1),:), imgsz(2)-1, imgsz(3) );
                e3 = reshape( img2(2:end,end,:), imgsz(1)-1, imgsz(3) );
                e4 = reshape( img2(1,2:end,:), imgsz(2)-1, imgsz(3) );
                backgroundColor = mean( [e1;e2;e3;e4], 1, 'native' );
            end
            backgroundColor = reshape( backgroundColor, 1, 1, imgsz(3) );
        case 'extend'
            extendEdges = true;
        otherwise
            backgroundColor = reshape( fitToColorDepth( backgroundColor, imgsz(3) ), 1, 1, [] );
            backgroundColor = convertImageType( backgroundColor, imgclass );
    end
    
    extraPixels = imgsz([1 2]) - sz([1 2]);
    loPixels = floor( abs(extraPixels)/2 );
    hiPixels = abs(extraPixels) - loPixels;
    
    switch sign( extraPixels(1) )
        case 0
            % Nothing to do.
        case -1
            % Imgs is smaller. Pad out.
            if extendEdges
                lopad = repmat( img2(1,:,:), loPixels(1), 1, 1 );
                hipad = repmat( img2(end,:,:), hiPixels(1), 1, 1 );
            else
                lopad = repmat( backgroundColor, loPixels(1), imgsz(2), 1 );
                hipad = repmat( backgroundColor, hiPixels(1), imgsz(2), 1 );
            end
            img2 = [ lopad; img2; hipad ];
        case 1
            % Img is larger. Crop.
            img2 = img2( (loPixels(1)+1):(imgsz(1)-hiPixels(1)), :, : );
    end
    
    switch sign( extraPixels(2) )
        case 0
            % Nothing to do.
        case -1
            % Imgs is smaller. Pad out.
            if extendEdges
                lopad = repmat( img2(:,1,:), 1, loPixels(2), 1 );
                hipad = repmat( img2(:,end,:), 1, hiPixels(2), 1 );
            else
                lopad = repmat( backgroundColor, size(img2,1), loPixels(2), 1 );
                hipad = repmat( backgroundColor, size(img2,1), hiPixels(2), 1 );
            end
            img2 = [ lopad, img2, hipad ];
        case 1
            % Img is larger. Crop.
            img2 = img2( :, (loPixels(2)+1):(imgsz(2)-hiPixels(2)), : );
    end
    
    img = img2;
end

