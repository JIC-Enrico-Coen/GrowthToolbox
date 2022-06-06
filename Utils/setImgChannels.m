function img = setImgChannels( img, numchannels )
%img = setImgChannels( img, numchannels )
%   Force IMG to have the given number of channels.
%   Images of 1 to 4 channels are interpreted thus:
%   1: Greyscale.
%   2: Greyscale and alpha.
%   3: RGB.
%   4: RGB and alpha.
%   Later channels, if present, are not interpreted.

    curchannels = size( img, 3 );
    
    if curchannels==0
        img = ones( size(img,1), size(img,2), numchannels );
        return;
    end

    if (curchannels < numchannels) && (curchannels >= 4)
        img(:,:,(curchannels+1):numchannels) = 1;
        return;
    end
    
    if (curchannels > numchannels) && (numchannels >= 4)
        img = img(:,:,1:numchannels);
        return;
    end
    
    extrachannels = 0;
    if (curchannels < numchannels) && (numchannels > 4)
        extrachannels = numchannels-4;
        numchannels = 4;
    end
    
    if (curchannels > numchannels) && (curchannels > 4)
        img = img(:,:,1:4);
        curchannels = 4;
    end
    
    % At this point, curchannels and numchannels are both <= 4.
    
    switch curchannels*10 + numchannels
        case 11
            % Nothing.
        case 12
            img(:,:,2) = 1; % Add opaque alpha channel.
        case 13
            img = repmat( img, 1, 1, 3 ); % Replicate grayscale to colour channels.
        case 14
            img = repmat( img, 1, 1, 3 ); % Replicate grayscale to colour channels.
            img(:,:,4) = 1; % Add opaque alpha channel.
        case 21
            img = img(:,:,1); % Drop alpha channel.
        case 22
            % Nothing.
        case 23
            img = repmat( img(:,:,1), 1, 1, 3 ); % Drop alpha and replicate grayscale to colour channels.
        case 24
            img(:,:,4) = img(:,:,2); % Copy alpha to channel 4.
            img(:,:,[2 3]) = repmat( img(:,:,1), 1, 1, 2 ); % Replicate grayscale to colour channels.
        case 31
            img = rgb2lightness( img ); % Transform colour channels to greyscale.
        case 32
            img = rgb2lightness( img ); % Transform colour channels to greyscale.
            img(:,:,2) = 1; % Add opaque alpha channel.
        case 33
            % Nothing.
        case 34
            img(:,:,4) = 1; % Add opaque alpha channel.
        case 41
            img = mean( img(:,:,1:3), 3 ); % Drop alpha and average colour channels to make greyscale.
        case 42
            img(:,:,1) = rgb2lightness( img(:,:,1:3) ); % Transform colour channels to greyscale.
            img(:,:,2) = img(:,:,4); % Copy alpha to channel 2.
            img(:,:,[3 4]) = []; % Drop later channels.
        case 43
            img = img(:,:,1:3); % Drop alpha channel.
        case 44
            % Nothing.
    end
    if extrachannels > 0
        img(:,:,(end+1):(end+extrachannels)) = 1;
    end
end
