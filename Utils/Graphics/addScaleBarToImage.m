function img = addScaleBarToImage( img, width, height, margin, scalebarcolour )
%img = addScaleBarToImage( img, width, height, margin, scalebarcolour )
%   Add a scale bar to the bottom left corner of an image, of a specified
%   height and width, with a specified margin above it separating it from
%   the image content.
%
%   The content is defined to be all pixels whose colour is not the same as
%   the bottom left pixel.
%
%   The scale bar is black unless otherwise specified.  If the image needs
%   to be padded to make room for the scale bar, the extra pixels are
%   the same colour as the bottom left pixel.

    width = round(width);
    height = round(height);
    margin = round(margin);
    backgroundcolor = img(end,1,:);
    if nargin < 5
        scalebarcolour = zeros(1,1,size(img,3));
    end
    scalebarcolour = convertColorMode( scalebarcolour, class(img) );
    scalebarcolour = reshape( scalebarcolour, 1, 1, numel(scalebarcolour) );
    

    scalebarpart = img( (end-height-margin+1):end, 1:width, : );
    backgroundlines = all( all( scalebarpart==repmat( backgroundcolor, height+margin, width ), 3 ), 2 );
    extralines = find( ~backgroundlines, 1, 'last' );
    if ~isempty(extralines)
        img( (end+1):(end+extralines), :, : ) = repmat( backgroundcolor, extralines, size(img,2) );
    end
    
    img( (end-height+1):end, 1:width, : ) = repmat( scalebarcolour, height, width );
end
