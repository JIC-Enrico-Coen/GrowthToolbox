function img = abutImagesVert( varargin )
%img = abutImagesVert( imgs )
%img = abutImagesVert( img1, ... )
%img = abutImagesVert( imgs, background )
%img = abutImagesVert( img1, ..., background )
%
%   The images are abutted vertically.  When images need to be padded
%   out, the provided background color is used. The background value must
%   be a 1*N array where N  is in the range 1..4.
%
%   The images may be supplied as separate arguments, or as a single cell
%   array.
%
%   If the images contain different numbers of channels, they will be
%   converted to the maximum number of channels for any of them. Thus
%   grayscale images may be converted to RGB, alpha channels may be added,
%   etc.

    if nargin < 1
        img = [];
        return;
    end
    if numel(varargin{end})==3
        background = varargin{end};
        imgs = varargin(1:(end-1))';
    else
        background = [];
        imgs = varargin';
    end
    if length(imgs)==1
        if isnumeric( imgs{1} )
            % Just one image, nothing to do.
            img = imgs{1};
            return;
        end
        imgs = imgs{1};
    end
    okimgs = false( 1, length(imgs) );
    for ii=1:length(imgs)
        okimgs(ii) = ~isempty( imgs{ii} );
    end
    imgs = imgs( okimgs );
    if length(imgs)==1
        img = imgs;
        return;
    end
    
    numimgs = numel(imgs);
    emptyimgs = false(1,numimgs);
    numchannels = zeros(1,numimgs);
    for i=1:numimgs
        if ischar( imgs{i} )
            imgs{i} = imread( imgs{i} );
        end
        emptyimgs(i) = isempty(imgs{i});
        numchannels(i) = size(imgs{i},3);
    end
    imgs(emptyimgs) = [];
    numchannels(emptyimgs) = [];
    
    maxchan = max( numchannels );
    for i=1:numimgs
        imgs{i} = setImgChannels( imgs{i}, maxchan );
    end
    if isempty(background)
        background = ones(1,1,maxchan);
    else
        if ischar(background)
            background = convertColorMode( background, 'double' );
        end
        background = reshape( background, 1, 1, [] );
    end

    imgwidth = zeros(1,numimgs);
    for i=1:numimgs
        imgwidth(i) = size(imgs{i}, 2);
    end
    width = max( imgwidth );
    background = convertColorMode( background, class(imgs{1}) );
    for i=1:numimgs
        imgs{i} = padImageTo( imgs{i}, 0, width, background );
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
    background( (end+1):numchannels ) = 1;
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
