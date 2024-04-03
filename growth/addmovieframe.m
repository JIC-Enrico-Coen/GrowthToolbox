function movieobj = addmovieframe( movieobj, frame, bgcolor )
%movieobj = addmovieframe( movieobj )
%   Add a frame to a movie object created by VideoWriter.
%
%   If the movie already has at least one frame written to it, and hence
%   has a defined and unchangeable height and width, then force the new
%   frame to be that height and width, using BGCOLOR for any required
%   padding. Otherwise, pad the frame to have even height and width,
%   because odd height or width is incompatible with some movie formats.
%   Matlab will happily write the file, but some players may have trouble
%   reading it. Transcoders may choke when converting such a file, evebn if
%   it is valid in itself, to a format that requires even height and
%   width.

    if nargin < 3
        bgcolor = [1 1 1];
    end
    if isa( movieobj, 'VideoWriter' )
        if ~isstruct( frame )
            frame = struct( 'cdata', frame, 'colormap', [] );
        end
        if isempty( movieobj.Height )
            % The frame must have even width and height.
            imgsize = size( frame.cdata );
            imgsize = imgsize([1 2]);
            requiredSize = ceil( imgsize/2 ) * 2;
        else
            % The new frame must be the same size as the movie frames
            % already recorded.
            requiredSize = [movieobj.Height, movieobj.Width];
        end
        frame = trimframe( frame.cdata, requiredSize, bgcolor );
        writeVideo( movieobj, frame );
    else
        movieobj = [];
    end
end
