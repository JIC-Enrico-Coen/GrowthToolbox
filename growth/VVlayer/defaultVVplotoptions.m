function vvpo = defaultVVplotoptions( x ) %#ok<INUSD>
%vvpo = defaultVVplotoptions()
%vvpo = defaultVVplotoptions( x )
%
%   Calculate and optionally print the default plotting options for VV
%   layers.
%
%   If no output value is requested, the default options will be printed to
%   the console.  Otherwise, they will be returned as the result and no
%   output will be printed.
%
%   The value is cached in a global variable, so that it is not rebuilt
%   every time.  Recomputation can be forced by passing it a single
%   argument, whose value does not matter.  This is only necessary of this
%   file has been updated since it was last called in the current Matlab
%   session (e.g. if a new version of GFtbox was downloaded).
%
%   Here are the available options.  Option names with suffixes C, W, or M
%   are for properties relation to cell interiors, cell walls, and cell
%   membranes respectively.  Suffixies consisting of a pair of these
%   letters refer to properties of edges connection vertexes of the
%   specified types.
%
%   vertexcolorC, ...M, ...W: the colour to draw a vertex with (when it is
%   not being drawn with a morphogen colour).  The default is dark grey,
%   [0.2 0.2 0.2].
%
%   edgecolorCM, ...MM, ...WW, ...WM: the colour of each type of edge.  The
%   default is light grey, [0.7 0.7 0.7].
%
%   colormap: the scale to use to map plotted values to colours.  The
%   default is Matlab's standard 'jet' scale running from blue to red.
%
%   colormapbounds: a pair of values, which are the values mapped to the
%   bottom and top of the colour scale.  Alternatively, one of the
%   following strings can be specified, to make the bounds dependent on the
%   values to be plotted:
%       'bounds': use the minimum and maximum
%       'posbounds': use the minimum and maximum of the positive values
%       'max':  Use zero and the maximum value.
%   The default is 'bounds'.

    global gDefaultVVPlotOptions;
    if isempty(gDefaultVVPlotOptions) || (nargin > 0)
        dkgrey = [0.2 0.2 0.2];
        ltgrey = [0.7 0.7 0.7];
        jetscale = [ ...            
                 0         0    0.5625
                 0         0    0.6250
                 0         0    0.6875
                 0         0    0.7500
                 0         0    0.8125
                 0         0    0.8750
                 0         0    0.9375
                 0         0    1.0000
                 0    0.0625    1.0000
                 0    0.1250    1.0000
                 0    0.1875    1.0000
                 0    0.2500    1.0000
                 0    0.3125    1.0000
                 0    0.3750    1.0000
                 0    0.4375    1.0000
                 0    0.5000    1.0000
                 0    0.5625    1.0000
                 0    0.6250    1.0000
                 0    0.6875    1.0000
                 0    0.7500    1.0000
                 0    0.8125    1.0000
                 0    0.8750    1.0000
                 0    0.9375    1.0000
                 0    1.0000    1.0000
            0.0625    1.0000    0.9375
            0.1250    1.0000    0.8750
            0.1875    1.0000    0.8125
            0.2500    1.0000    0.7500
            0.3125    1.0000    0.6875
            0.3750    1.0000    0.6250
            0.4375    1.0000    0.5625
            0.5000    1.0000    0.5000
            0.5625    1.0000    0.4375
            0.6250    1.0000    0.3750
            0.6875    1.0000    0.3125
            0.7500    1.0000    0.2500
            0.8125    1.0000    0.1875
            0.8750    1.0000    0.1250
            0.9375    1.0000    0.0625
            1.0000    1.0000         0
            1.0000    0.9375         0
            1.0000    0.8750         0
            1.0000    0.8125         0
            1.0000    0.7500         0
            1.0000    0.6875         0
            1.0000    0.6250         0
            1.0000    0.5625         0
            1.0000    0.5000         0
            1.0000    0.4375         0
            1.0000    0.3750         0
            1.0000    0.3125         0
            1.0000    0.2500         0
            1.0000    0.1875         0
            1.0000    0.1250         0
            1.0000    0.0625         0
            1.0000         0         0
            0.9375         0         0
            0.8750         0         0
            0.8125         0         0
            0.7500         0         0
            0.6875         0         0
            0.6250         0         0
            0.5625         0         0
            0.5000         0         0
        ];
        gDefaultVVPlotOptions = struct( ...
            'plotC', true, ...
            'plotM', true, ...
            'plotW', true, ...
            'vertexcolorC', dkgrey, ...
            'vertexcolorM', dkgrey, ...
            'vertexcolorW', dkgrey, ...
            'edgecolorCM', ltgrey, ...
            'edgecolorMM', ltgrey, ...
            'edgecolorWW', ltgrey, ...
            'edgecolorWM', ltgrey, ...
            'colormap', jetscale, ...
            'colormapbounds', 'max', ...
            'morphogen', 0, ...
            'morphogencolor', [1 0 0], ...
            'layeroffset', 0.4, ...
            'drawvvcellpolarity', true );
    end    

    if nargout==0
        gDefaultVVPlotOptions %#ok<NOPRT>
    else
        vvpo = gDefaultVVPlotOptions;
    end
end
