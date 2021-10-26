function frame = getGFtboxImage( m, picture, withColorbar, hires, magnification, antialias )
%frame = getGFtboxImage( m, picture, withColorbar, hires, magnification, antialias )
%   Get an image of the mesh.  picture is the axes object that will be
%   recorded and defaults to the image in the GFtbox window.  WITHCOLORBAR
%   is a boolean to specify whether the colorbar should also be imaged.  If
%   so, it will be butted to the right of the main image.
%   hires, magnification, antialias specify those properties of the
%   requested image, and default to the corresponding plotting options of
%   m.
%
%   If there is an error in acquiring the main image, [] is returned.
%
%   If there is an error in acquiring the colorbar image, the main image
%   will be returned without a colorbar added.

    if (nargin < 2) || isempty(picture)
        picture = m.pictures;
    end
    if nargin < 3
        withColorbar = false;
    end

    if isempty(m) || isempty( picture ) || ~ishandle( picture(1) )
        frame = [];
        return;
    end
    picture = picture(1);
    
    if (nargin < 4) || ~hires
        frame = mygetframe( picture );
        if isempty(frame)
            % Something went wrong.  It has already been reported.
            return;
        end
        frame = frame.cdata;
        if withColorbar
            h = guidata( picture );
            if isfield( h, 'colorbar' )
                frame2 = mygetframe( h.colorbar );
                if ~isempty(frame2)
                    frame = abutImagesHoriz( frame, frame2.cdata, get( picture, 'Color' ) );
                end
            end
        end
    else
        frame = gethiresimage( m, magnification, antialias );
    end
end
