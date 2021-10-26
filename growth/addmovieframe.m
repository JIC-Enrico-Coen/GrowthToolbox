function movieobj = addmovieframe( movieobj, frame )
%movieobj = addmovieframe( movieobj )
%   Add a frame to a movie object created by VideoWriter.
    if isa( movieobj, 'VideoWriter' )
        if isstruct( frame )
            writeVideo( movieobj, frame );
        else
            writeVideo( movieobj, struct( 'cdata', frame, 'colormap', [] ) );
        end
    else
        movieobj = [];
    end
end
