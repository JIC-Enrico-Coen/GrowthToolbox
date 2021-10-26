function drawThumbnail( handles )
    imagedata = [];
    thumbfile = '';
  % fprintf( 1, 'drawThumbnail\n' );
    if isfield(handles,'mesh') && ~isempty(handles.mesh)
        modeldir = getModelDir( handles.mesh );
        if ~isempty( modeldir )
            thumbfile = fullfile( modeldir, 'GPT_thumbnail.png' );
            try
                % fprintf( 1, 'drawThumbnail: looking for thumbnail in %s\n', thumbfile );
                imagedata = imread( thumbfile );
                % fprintf( 1, 'drawThumbnail: found project thumbnail\n' );
            catch e %#ok<NASGU>
            end
        end
    end
    if isempty( imagedata )
        thumbfile = fullfile( GFtboxDir(), 'GPT_defaulticon.png' );
        try
            imagedata = imread( thumbfile );
            % fprintf( 1, 'drawThumbnail: using default thumbnail\n' );
        catch e %#ok<NASGU>
        end
    end
    cla( handles.thumbnailAxes );
    thpos = get( handles.thumbnailAxes, 'Position' );
    if ~isempty( imagedata )
        imagedata = rescaleimage( imagedata, thpos(3), thpos(4) );
      % fprintf( 1, 'drawThumbnail: drawing thumbnail from %s\n', thumbfile );
        image( imagedata, 'Parent', handles.thumbnailAxes );
    end
    set( handles.thumbnailAxes, 'Visible', 'off' );
    xwidth = size( imagedata, 1 );
    ywidth = size( imagedata, 2 );
    line( [1;xwidth;xwidth;1;1], [1;1;ywidth;ywidth;1], [1;1;1;1;1], ...
          'Parent', handles.thumbnailAxes, 'Color', 'k', 'Linewidth', 1 );
end
