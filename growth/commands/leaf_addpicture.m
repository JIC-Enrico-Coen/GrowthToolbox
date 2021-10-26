function m = leaf_addpicture( m, varargin )
%m = leaf_addpicture( m, ... )
%   Create a new picture window to plot the mesh in.  This is primarily
%   intended for plotting the mesh in multiple windows simultaneously.
%
%   Options:
%       'figure'    A handle to a window.  The previous contents of the
%                   window will be erased.
%       'position'  An array [x y w h] specifying the position and size of the
%                   window relative to the bottom left corner of the screen.
%                   x is horizontal from the left, y is vertical from the
%                   bottom, w is the width and h is the height, all in pixels.
%       'relpos'    A similar array, but this time measured relative to the
%                   bottom left corner of the previous picture, if there is
%                   one, otherwise the bottom left corner of the screen.
%       Only one of position or relpos may be supplied.
%       w and h can be omitted from relpos, in which case the size defaults
%       to the size of the existing window, if any, otherwise the default
%       size for a new window.
%       x and y can be omitted from position, in which case the new window
%       is centred on the screen.
%       If both position and relpos are omitted, a window of default size
%       and position is created.
%       'vergence'  A number in degrees, default 0.  The view direction of
%                   the figure is offset by this amount, so that the eye
%                   seeing the figure sees it as if the eye was turned
%                   towards the centre line by this angle.
%       'eye'       'l' or 'r', to specify which eye this is for.
%       If no eye is specified, vergence defaults to zero.  If
%       vergence is specified, an eye must also be specified.
%       'properties'   A structure containing any other attribute of the
%                   figure that should be set.
%
%   Topics: Plotting, Stereo.

    if isempty(m), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, ...
            'figure', -1, ...
            'position', [1200 1200], ...
            'relpos', [], ...
            'vergence', 0, ...
            'eye', '', ...
            'properties', [], ...
            'uicontrols', true );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'figure', 'position', 'relpos', 'vergence', 'eye', 'properties', 'uicontrols' );
    if ~ok, return; end
    if (~isempty(s.position)) && (~isempty(s.relpos))
        fprintf( 1, '%s: Cannot supply both position and relpos. relpos ignored.\n', ...
            mfilename() );
        s = rmfield( s, 'relpos' );
    end
    if (s.vergence ~= 0) && isempty(s.eye)
        fprintf( 1, '%s: Must specify an eye when vergence is non-zero.  Vergence ignored.\n', ...
            mfilename() );
        s.vergence = 0;
    end
    
    if isempty( m.pictures ) && isempty( s.position )
        s.position = s.relpos;
        s.relpos = [];
    end

    if length(s.position)==2
        try
            screenpos = get( 0, 'MonitorPositions' );
        catch
            screenpos = get( 0, 'Position' );
        end
        s.position = [ (screenpos([3 4])-s.position)/2, s.position ];
    end
    
    if ~isempty( s.relpos ) && ~isempty( m.pictures )
        pos = get( m.pictures(end), 'Position' );
        s.position([1 2]) = s.relpos([1 2]) + pos([1 2]);
        if length(s.relpos)==4
            s.position([3 4]) = s.relpos([3 4]);
        else
            s.position([3 4]) = pos([3 4]);
        end
    end
    
    switch s.eye
        case 'l'
            stereooffset = -s.vergence;
        case 'r'
            stereooffset = s.vergence;
        otherwise
            stereooffset = 0;
    end
        
    theaxes = makeCanvasPicture( mfilename(), ...
        'figure', s.figure, ...
        'fpos', s.position, ...
        'stereooffset', stereooffset, ...
        'properties', s.properties, ...
        'uicontrols', s.uicontrols );
    if ishandle( theaxes )
        if isempty(m.pictures) || ~ishghandle( m.pictures )
            m.pictures = theaxes;
        else
            m.pictures(end+1) = theaxes;
        end
    end
    for i=1:length(m.pictures)
        h = guidata( m.pictures(i) );
        h.siblings = m.pictures;
        guidata( m.pictures(i), h );
    end
end
