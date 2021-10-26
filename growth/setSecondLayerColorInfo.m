function m = setSecondLayerColorInfo( m, colors, colorvariation )
%m = setSecondLayerColorInfo( m, colors, colorvariation )
%   Set the colour range for the second layer.  This information must be
%   stored in m.globalProps, not m.secondlayer, since it needs to exist
%   even when there is no second layer.
%   colors must be either empty (to get the default green/red colours), a
%   single colour (which will be complemented to get the shocked color), or
%   a pair of colours as a 2*3 matrix.
%   colorvariation is a real number, expressing the amount of random
%   variation allowed for cells nominally of the same colour.  The default
%   is 0.1.

    if (nargin < 2) || isempty(colors)
        m.globalProps.colors = [[0.1,1,0.1];[1,0.1,0.1]];
    elseif size(colors,1)==1
        m.globalProps.colors = [ colors; 1-colors ];
    else
        m.globalProps.colors = colors;
    end
    if (nargin < 3) || isempty(colorvariation)
        m.globalProps.colorvariation = 0.1;
    else
        m.globalProps.colorvariation = colorvariation;
    end
    m.globalProps.colorparams = ...
        makesecondlayercolorparams( m.globalProps.colors, m.globalProps.colorvariation );
end
