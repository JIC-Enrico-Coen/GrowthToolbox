function ok = images2movie( filename, imagespec, varargin )
%ok = images2movie( filename, imagespec, ... )
%   Make a movie from a sequence of images.
%
%   FILENAME is the name of the output file. If no file extension is
%       given, the extension implied by the 'profile' option will be used,
%       and if there is no profile option, '.avi'. If animated GIF output
%       is required, the '.gif' extension must be supplied and no profile
%       option given. If the filename is empty, then the movie file will
%       be created in the same directory as the first image file, and its
%       name will be that of the directory, suffixed if necessary with a
%       number to avoid overwriting any existing file. If a filename is
%       explicitly given, an existing file of that name will be
%       overwritten without warning. If the filename is '?', the user will
%       be asked to choose a file.
%
%   IMAGESPEC specifies the set of images to make the movie from.  There
%       are several forms it can take:
%       1.  A cell array of images as returned by imread().
%       2.  A cell array of filenames, in the order in which they are to be
%       written to the movie.
%       3.  A single string, which may contain wildcards, specifying a set
%       of files, the same set that would be reported by supplying it to
%       the Matlab function dir(). They will be written in the same order
%       as they are reported by dir(), i.e. alphabetical.
%       4.  The result of calling ls(), i.e. a two-dimensional character
%       array in which each row is a filename, padded out if necessary with
%       trailing spaces (which will be ignored).
%
%   Further named options:
%
%   'loopcount'  An integer, by default Inf. For GIF output only. This
%       specifies how often the movie should loop, with zero = play once,
%       1 = play twice, etc. Inf means loop indefinitely.
%
%   'framerate'  A positive number, default 10. Specifies the frame rate of
%       the movie. This can be a fractional number.
%
%   'profile'  For AVI output only. A string indicating the video format.
%       This will be passed to the Matlab function VideoWriter, which will
%       set various formatting and compression properties of the movie.
%       The default is 'MPEG-4'. This format is most likely to play
%       on the widest range of platforms. Note that there is no guarantee
%       that a movie created in some particular format can be played even
%       on the machine where it was created.
%
%   All of the images must be the same size, and have the same number of
%   channels and bits per channel. If there is an alpha channel it will be
%   ignored. The movie will always have 3 channels, RGB.
%
%   The result is a boolean to indicate success or failure. In the case of
%   failure, a movie file may or may not have been created, and if created,
%   may be invalid or incomplete.
%
%   See also: movie2images
    
    ok = false;
    if ischar(imagespec)
        d = fileparts(imagespec);
        zz = dir(imagespec);
        images = { zz(:).name };
        if ~isempty(d)
            for i = 1:length(images)
                images{i} = fullfile( d, images{i} );
            end
        end
    else
        images = imagespec;
    end
    makegif = ~isempty( regexp( filename, '\.gif$', 'once' ) );
    if isempty(images)
        fprintf( 1, 'No images selected.\n' );
        return;
    end
    options = struct( varargin{:} );
    options = defaultfields( options, ...
        'loopcount', Inf, 'framerate', 10, 'profile', 'MPEG-4' );
    
    try
        if makegif
            for i = 1:numel(images)
                img = rectifyImageType( images{i} );
                [colorindexes,cmap] = rgb2ind(img,256,'nodither');
                if i == 1
                    imwrite( colorindexes, cmap, filename, 'gif', 'WriteMode','overwrite','Loopcount',options.loopcount, 'DelayTime', 1/options.framerate );
                else
                    imwrite( colorindexes, cmap, filename, 'gif', 'WriteMode','append', 'DelayTime', 1/options.framerate);
                end
            end
        else
            if isempty(options.profile)
                vidObj = VideoWriter(filename);
            else
                vidObj = VideoWriter(filename,options.profile);
            end
            set( vidObj, 'FrameRate', options.framerate );
            open(vidObj);
            for i = 1:length(images)
                img = rectifyImageType( images{i} );
                frame = im2frame( img );
                writeVideo(vidObj,frame);
            end
            ok = true;
        end
    catch e
        ok = false;
        fprintf( 1, 'WARNING: The requested movie may not have been created. Reason:\n    %s\n    (Error code %s)\n', e.message, e.identifier );
    end
    if ok && ~makegif
        try
            close(vidObj);
        catch e
            ok = false;
            fprintf( 1, 'WARNING: The requested movie may not have been created. Reason:\n    %s\n    (Error code %s)\n', e.message, e.identifier );
        end
    end
end

function img = rectifyImageType( img )
    if ischar(img)
        fprintf( 1, 'Reading image %s.\n', img );
        img = imread(img);
    end
    img = convertImageType( img, 'double' );
    img = ensure3channels( img );
end

function img = ensure3channels( img )
    if size(img,3) <= 2
        % Convert grayscale to RGB. The first channel is taken to be the
        % grayscale values. The second channel, if present, is assumed to
        % be an alpha channel, and is ignored.
        img = repmat( img(:,:,1), 1, 1, 3 );
    elseif size(img,3) > 3
        img = img(:,:,1:3);
    end
end