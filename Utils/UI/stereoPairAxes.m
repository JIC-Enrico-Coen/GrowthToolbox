function stereoPairAxes( ax1, ax2, vergence, trackball )
%stereoPairAxes( ax1, ax2, vergence, trackball )
%
%   NEVER USED
%
%   Make the two axes objects into a stereo trackball pair, by storing in
%   the guidata of each a reference to the other and the angle of
%   convergence.  ax1 is assumed to be the left eye view and ax2 the right
%   eye view, in which case vergence should be positive.
%
%   The trackball argument is optional and defaults to false.  If true,
%   trackballButtonDownFcn is installed as the ButtonDownFcn in both axes
%   objects and all their children.  Clicking and dragging on either
%   window will rotate both views together.  If you only want trackball
%   functionality part of the time -- for example, only when the user does
%   a control-click-drag -- then you should not install it here, but
%   call trackballButtonDownFcn from your own ButtonDownFcn when you detect
%   that trackball behaviour is required.

    if nargin < 4
        trackball = false;
    end
    gd1 = guidata( ax1 );
    gd1.stereodata = struct( 'otheraxes', ax2, 'vergence', vergence );
    guidata( ax1, gd1 );
    gd2 = guidata( ax2 );
    gd2.stereodata = struct( 'otheraxes', ax1, 'vergence', -vergence );
    guidata( ax2, gd2 );
    if trackball
        set( ax1, 'ButtonDownFcn', @trackballButtonDownFcn );
        set( get(ax1,'Children'), 'ButtonDownFcn', @trackballButtonDownFcn );
        set( ax2, 'ButtonDownFcn', @trackballButtonDownFcn );
        set( get(ax2,'Children'), 'ButtonDownFcn', @trackballButtonDownFcn );
    end
end
