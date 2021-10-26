function m = leaf_setsecondlayerparams( m, varargin )
%m = leaf_setsecondlayerparams( m, varargin )
%
%   Set various general properties of the second layer.  If the second
%   layer does not exist an empty second layer will be created, and the
%   properties set here will be the defaults for any subsequently created
%   nonempty second layer.
%
%   If m already has a second layer, this procedure does not affect the
%   colours of existing cells, only the colours that may be chosen by
%   subsequent recolouring operations.
%
%   Options:
%       colors: An N*3 array of RGB values.  These are the colours
%               available for colouring cells.  The special value 'default'
%               will use the array [ [0.1 0.9 0.1]; [0.9 0.1 0.1] ].
%               N should be 2.  "Ordinary" cells will be coloured with the
%               first colour, while "shocked" cells will be coloured with
%               the second colour.
%       colorvariation: A real number between 0 and 1.  When a colour for a
%               cell is selected from the colour table, this amount of
%               random variation will be applied to the value selected from
%               colors.  A suitable value is 0.1, to give a subtle
%               variation in colour between neighbouring cells.
%
%   Topics: Bio layer.

    if isempty(m), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'colors', [], 'colorvariation', [] );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'colors', 'colorvariation' );
    if ~ok, m = []; return; end

    m.globalProps.colors = s.colors;
    m.globalProps.colorvariation = s.colorvariation;
    m.globalProps.colorparams = ...
        makesecondlayercolorparams( s.colors, s.colorvariation );
end
