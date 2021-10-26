function colorinfo = calcColorinfoMap( range, colorinfo, varargin )
%colorinfo = calcColorinfoMap( range, colorinfo, ... )
%   Given a colorinfo struct and a range of values, set up the
%   colormap, issplit, and range fields of colorinfo.  colorinfo can also
%   be a single name, in which case the whole colorinfo struct is built.
%
%   The optional arguments specify values for any of the fields of
%   colorinfo. Do not try to set the 'issplit' field here: this field is
%   determined by the name of the color scale (true for splitmono and split
%   rainbow', false for all others).
%
%   If colorinfo is 'custom' or 'indexed', then the optional arguments must
%   include 'colormap'. For 'indexed', the 'colormap' argument can be a single
%   integer, specifying the number of indexed colours, which will begin
%   with white, followed by saturated bright hues starting from red and
%   going through yellow, green, blue, and purple.
%
%   If colorinfo is omitted or empty, a rainbow scale will be chosen.
%
%   If there is already a colormap, colorinfo is not updated unless
%   autorange is true and range is different from the current range.
%
%   If autorange is false, the resulting colormap will cover only that part
%   of the scale specified by range.
%
%   The colorinfo struct consists of these fields:
%       mode:  A string naming a color scale. This is one of the
%           following:
%               rainbow: a scale from blue (low) to green, yellow, orange,
%                   and red (high).
%               splitrainbow: A split scale whose positive half goes from
%                   white (zero) to blue, then follows with the rainbow
%                   scale. The negative half goes from white (zero) to
%                   purple (negative).
%               monochrome: A scale from white (low) to pos (high).
%               splitmono: A split scale whose positive half is as for
%                   monochrome (beginning at zero), and whose negative half
%                   goes from white (zero) to neg (negative).
%               custom: A non-split scale with a user-specified color map.
%               indexed: A scale mapping integer values to a list of
%                   colors.
%       issplit:    A boolean specifying whether positive and negative
%           values are mapped to separate halves of the scale, both
%           beginning with white.
%       range:      A pair of numbers, representing the values of the ends
%           of the color map.
%       autorange:  A boolean.  If true, then when a set of values is
%           to be translated to colours, colorinfo.range is set to the
%           range of values presented. If false, colorinfo.range remains
%           fixed and colormap is computed to cover just the range of
%           values presented.
%       colormap: an N*3 list of colors.
%       pos, neg:  These are the colors that will be used for the
%           ends of a monochrome or splitmono scale.
%       edgecolor: a single color, to be used for the edges of patches.

    if nargin < 1
        range = [];
    end

    if (nargin < 2) || isempty(colorinfo)
        colorinfo = 'rainbow';
    end

    suppliedcolorinfo = safemakestruct( varargin );
    if ischar( colorinfo )
        suppliedcolorinfo.mode = colorinfo;
        colorinfo = suppliedcolorinfo;
        colorinfo = defaultFromStruct( colorinfo, ...
                        struct( 'issplit', false, ...
                                'colors', [], ...
                                'range', [], ...
                                'pos', [1 0 0], ...
                                'neg', [0 0 1], ...
                                'autorange', true, ...
                                'edgecolor', [0.2 0.2 0.2], ...
                                'falsecolorscaling', 1 ) );
    else
        colorinfo = setFromStruct( colorinfo, suppliedcolorinfo );
    end
    
    useGivenRange = colorinfo.autorange && ~isempty(range);
    
    if isempty( colorinfo.colors ) || (colorinfo.autorange && any( range ~= colorinfo.range ))
        switch( colorinfo.mode )
            case { 'splitmono', 'posneg' }
                colorinfo.issplit = true;
                if useGivenRange
                    colorinfo.range = range;
                else
                    colorinfo.range = [-1 1];
                end
                colorinfo.colors = posnegMap( colorinfo.range, [1 1 1;colorinfo.neg], [1 1 1;colorinfo.pos] );
            case { 'monochrome', 'minmax' }
                colorinfo.issplit = false;
                if useGivenRange
                    colorinfo.range = range;
                else
                    colorinfo.range = [0 1];
                end
                colorinfo.colors = posnegMap( colorinfo.range, [1 1 1;colorinfo.neg], [1 1 1;colorinfo.pos] );
            case 'rainbow'
                colorinfo.issplit = false;
                if useGivenRange
                    colorinfo.range = range;
                else
                    colorinfo.range = [0 1];
                end
                [colorinfo.colors,~] = rainbowMap( colorinfo.range, false );
            case 'splitrainbow'
                colorinfo.issplit = true;
                if useGivenRange
                    colorinfo.range = range;
                else
                    colorinfo.range = [-1 1];
                end
                [colorinfo.colors,~] = rainbowMap( colorinfo.range, true );
            case 'custom'
                colorinfo.issplit = false;
                if (nargin < 3) || isempty(colors)
                if useGivenRange
                    colorinfo.range = range;
                else
                    colorinfo.range = [0 1];
                end
                    colorinfo.colors = [1 1 1];
                else
                    colorinfo.colors = colors;
                end
            case 'indexed'
                colorinfo.issplit = false;
                colorinfo.autorange = false;
                makecolormap = true;
                if isempty( colorinfo.colors )
                    maxindex = 12;
                elseif numel(colorinfo.colors)==1
                    maxindex = colorinfo.colors;
                else
                    makecolormap = false;
                    maxindex = size( colorinfo.colors, 1 )-1;
                end
                colorinfo.range = int32( [0 maxindex] );
                if makecolormap
                    hues = linspace( 0, 1, maxindex+1 )';
                    hues(end) = [];
                    colorinfo.colors = [ 1 1 1; hsv2rgb( [ hues, ones( length(hues), 2 ) ] ) ];
                end
        end
    end
end
