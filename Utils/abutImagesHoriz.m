function img = abutImagesHoriz( varargin )
%img = abutImagesHoriz( imgs, background )
%img = abutImagesHoriz( img1, img2, background )
%img = abutImagesHoriz( img1, img2, ..., background )

%   The images are abutted horizontally.  When images need to be padded
%   out, the provided background color is used.
%
%   The images may be supplied as separate arguments, or as a single cell
%   array.

    if nargin < 2
        complain( '%s: At least two arguments required, %d given.', mfilename(), nargin );
        return;
    end
    background = varargin{end};
    if nargin==2
        if isnumeric( varargin{1} )
            % Just one image, nothing to do.
            img = varargin{1};
            return;
        end
        imgs = varargin{1};
    else
        imgs = varargin(1:(end-1));
    end
    
    numimgs = numel(imgs);
    for i=1:numimgs
        if ischar( imgs{i} )
            imgs{i} = imread( imgs{i} );
        end
    end

    imgheight = zeros(1,numimgs);
    for i=1:numimgs
        imgheight(i) = size(imgs{i}, 1);
    end
    height = max( imgheight );
    if isempty(background)
        background = [1 1 1];
    end
    background = convertColorMode( background, class(imgs{1}) );
    for i=1:numimgs
        imgs{i} = padImageTo( imgs{i}, height, 0, background );
    end
    img = cell2mat( imgs );


%     height = max( size(img1,1), size(img2,1) );
%     background = convertColorMode( background, class(img1) );
%     img1 = padImageTo( img1, height, 0, background );
%     img2 = padImageTo( img2, height, 0, background );
%     img = [ img1, img2 ];
end

function img = padImageTo( img, x, y, background )
    numchannels = size(img,3);
    x1 = size(img,1);
    if x > x1
        for i=1:numchannels
            img((x1+1):x,:,i) = background(i);
        end
    end
    y1 = size(img,2);
    if y > y1
        for i=1:numchannels
            img(:,(y1+1):y,i) = background(i);
        end
    end
end
