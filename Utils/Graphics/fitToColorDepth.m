function color = fitToColorDepth( color, numchannels )
%color = fitToColorDepth( color, depth )
%   Convert a color or set of colors to have a given number of channels,
%   which must be 1 (grayscale) 2, (grayscale+alpha), 3 (rgb), or 4
%   (rgb+alpha).
%
%   COLOR must be an N*C array, one row for each of N colors, having C
%   channels.
%
%   COLOR may be of any numeric or logical class, and the result will have
%   the same class.
%
%   When COLOR already has the requested number of channels, this procedure
%   is very fast.
%
%   See also: fitImgToColorDepth

    numcolorchannels = size(color,2);
    if numcolorchannels==numchannels
        % No conversion required.
        return;
    end
    
    switch numcolorchannels*10 + numchannels
        case 12
            % Add an opaque alpha channel.
            color(:,2) = 1;
        case 13
            % Convert grayscale to rgb.
            color = repmat( color, 1, 3 );
        case 14
            % Convert grayscale to rgb and add an opaque alpha channel.
            color = repmat( color, 1, 3 );
            color(:,4) = 1;
        case 21
            % Drop the alpha channel.
            color = color(:,1);
        case 23
            % Drop the alpha channel and convert grayscale to rgb.
            color = color(:,1);
            color = repmat( color, 1, 3 );
        case 24
            % Convert grayscale to rgb and preserve the alpha channel.
            color = [ repmat( color(:,1), 1, 3 ), color(:,2) ];
        case 31
            % Convert rgb to grayscale.
            color = mean( color, 2 );
        case 32
            % Convert rgb to grayscale and add an opaque alpha channel.
            color = [ mean( color, 2 ), ones( size(color,1), 1 ) ];
        case 34
            % Add an opaque alpha channel.
            color(:,4) = 1;
        case 41
            % Drop the alpha channel and convert rgb to grayscale.
            color = mean( color(:,1:3), 2 );
        case 42
             % Preserve the alpha channel and convert rgb to grayscale.
             color = [ mean( color(:,1:3), 2 ), color(:,4) ];
        case 43
            % Drop the alpha channel.
            color = color(:,1:3);
        otherwise
            error( 'Number of channels must be 1, 2, 3, or 4: color has %d, depth has %d.', numcolorchannels, numchannels );
    end
end