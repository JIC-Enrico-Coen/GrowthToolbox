function m = leaf_stereoparams( m, varargin )
%m = leaf_stereoparams( m, ... )
%   Turn stereo on and off, and change associated parameters.
%   In stereo mode, the mesh is displayed simultaneously in two different
%   windows, from the viewpoints of the left eye and the right eye.  When
%   running from the GUI, the main GUI window shows the left eye view and
%   the second window which appears when stereo is enabled shows the right
%   eye view.  When using a 3D screen that operates by superimposing both
%   screens in the user's view using polarisers to separate the left and
%   right eye views, the two windows should automatically appear to be
%   superimposed on each other.
%
%   When stereo is enabled, all snapshots and movies taken will be recorded
%   in stereo, with the two views composited into a single frame, either
%   side by side or one above the other.
%
%   Options:
%       'enable'    Boolean, turns stereo on or off.
%       'vergence'  The number of degrees each image is rotated.  A
%                   positive value (the usual case) means that the image
%                   view directions are what they would be if the eyes
%                   turned inwards to converge on the real 3D object. (This
%                   value is independent of the actual convergence of the
%                   eyes when viewing the stereo images. A typical 3D
%                   display does not require any convergence of the eyes.)
%       'windowsize'  The size in pixels of both of the windows.  If the
%                   first window already exists, do not supply this
%                   argument: the second window will automatically be sized
%                   so that its picture is the same size as that in the
%                   first.
%       'spacing'   The number of
%                   pixels separating the centres of the two images in the
%                   combined image.  Pass 0 to have the two images abutted.
%                   Pass -1 to specify the screen width or height, as
%                   appropriate to the value of 'direction'.  Any empty
%                   space between the images will be filled with the
%                   current background colour.
%       'direction' A string specifying how the two windows
%                   are placed relative to each other in the
%                   composite frame.  The value is one of these strings:
%                       '-h'  Right-eye window is placed to the left.
%                       '+h'  Right-eye window is placed to the right.
%                       '-v'  Right-eye window is placed below.
%                       '+v'  Right-eye window is placed above.
%                   The initial default is '-h'
%       'imagespacing', 'imagedirection'  Like spacing, but refers to the
%                   spacing between the two halves of snapshots and movie
%                   frames.
%
%   The default for all options is to leave the previous value unchanged.
%   The initial defaults are 'enable' = false, 'vergence' = 2.5 degrees,
%   'spacing' = 0, 'direction = '-h', 'imagespacing' = 0, 'imagedirection =
%   '-h' (which means you have to cross your eyes to fuse the images in
%   snapshots and movies).
%
%   Topics: Movies/Images, Plotting.

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    ok = checkcommandargs( mfilename(), s, 'only', ...
            'enable', 'vergence', 'spacing', 'direction', ...
            'imagespacing', 'imagedirection' );
    if ~ok, return; end
    
    enableChanged = isfield( s, 'enable' ) && (s.enable ~= m.stereoparams.enable);
    vergenceChanged = isfield( s, 'vergence' ) && (s.vergence ~= m.stereoparams.vergence);
    if vergenceChanged
        m.stereoparams.vergence = s.vergence;
        if m.stereoparams.enabled && ~enableChanged
            % Update the vergences of the windows if they exist.
            if length(m.pictures) >= 1
                h = guidata( m.pictures(1) );
                h.stereooffset = m.stereoparams.vergence;
                guidata( m.pictures(1), h );
                % Update the actual view.
            end
            if length(m.pictures) >= 2
                h = guidata( m.pictures(2) );
                h.stereooffset = -m.stereoparams.vergence;
                guidata( m.pictures(2), h );
                % Update the actual view.
            end
        end
    end
    if isfield( s, 'spacing' )
        m.stereoparams.spacing = s.spacing;
    end
    if isfield( s, 'direction' )
        m.stereoparams.direction = s.direction;
    end
    
    if enableChanged
        m.stereoparams.enable = s.enable;
        if m.stereoparams.enable
            % Ensure first window exists.
            if isempty( m.pictures )
                m = leaf_addpicture( m, ...
                    'figure', -1, ...
                    'position', s.windowsize, ...
                    'vergence', s.vergence, ...
                    'eye', 'l' );  % Params?
                if isempty( m.pictures )
                    % Failed to create new window.
                    return;
                end
                h = guidata( m.pictures(1) );
                h.stereooffset = m.stereoparams.vergence;
            end
            % If first window doesn't exist
            %   Create it, with vergence.
            % else if vergenceChanged
            %   Change vergence of first window
            % end
            % Create second window, with vergence.
            % Copy the plot from the first window,
        else
            % Destroy second window and set vergence of first window to
            % zero.
        end
    end
end
