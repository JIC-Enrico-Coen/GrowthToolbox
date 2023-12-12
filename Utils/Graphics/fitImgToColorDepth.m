function img = fitImgToColorDepth( img, numchannels )
%img = fitImgToColorDepth( img, numchannels )
%   Convert an image to have a given number of channels, which must be 1
%   (grayscale) 2, (grayscale+alpha), 3 (rgb), or 4 (rgb+alpha).
%
%   IMG may be of any numeric or logical class, and the result will have
%   the same class.
%
%   When IMG already has the requested number of channels, this procedure
%   is very fast.
%
%   See also: fitToColorDepth

    numimgchannels = size(img,3);
    if numimgchannels==numchannels
        % No conversion required.
        return;
    end
    
    switch numimgchannels*10 + numchannels
        case 12
            % Add an opaque alpha channel.
            img(:,:,2) = 1;
        case 13
            % Convert grayscale to rgb.
            img = repmat( img, 1, 1, 3 );
        case 14
            % Convert grayscale to rgb and add an opaque alpha channel.
            img = repmat( img, 1, 1, 3 );
            img(:,:,4) = 1;
        case 21
            % Drop the alpha channel.
            img = img(:,:,1);
        case 23
            % Drop the alpha channel and convert grayscale to rgb.
            img = img(:,:,1);
            img = repmat( img, 1, 1, 3 );
        case 24
            % Convert grayscale to rgb and preserve the alpha channel.
            alph = img(:,:,2);
            img = repmat( img(:,:,1), 1, 1, 3 );
            img(:,:,4) = alph;
        case 31
            % Convert from rgb to grayscale.
            img = mean( img, 3 );
        case 32
            % Convert from rgb to grayscale and add an opaque alpha channel.
            img = mean( img, 3 );
            img(:,:,2) = ones( size(img,1), size(img,2) );
        case 34
            % Add an opaque alpha channel.
            img(:,:,4) = 1;
        case 41
            % Drop the alpha channel and convert rgb to grayscale.
            img = mean( img(:,:,1:3), 3 );
        case 42
            % Preserve the alpha channel and convert rgb to grayscale.
            alph = img(:,:,4);
            img = mean( img(:,1:3), 2 );
            img(:,:,2) = alph;
        case 43
            % Drop the alpha channel.
            img = img(:,:,1:3);
        otherwise
            error( 'Number of channels must be 1, 2, 3, or 4: image has %d, depth has %d.', numimgchannels, numchannels );
    end
end
