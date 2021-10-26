function m = leaf_colourA( m, varargin )
%m = leaf_colourA( m )
%   Assign colours to all the cells in the biological layer.  If there is
%   no biological layer, the values of the options are stored in m but the
%   command is otherwise ignored.
%
%   Optional arguments:
%       colors:  The colour of the cells, as a pair of RGB values as a 2*3
%                array.  The first is for the unshocked state and the
%                second for the shocked state.
%       colorvariation:  The amount of variation in the colour of the new
%                cells. Each component of the colour value will be randomly
%                chosen within this ratio of the value set by the 'color'
%                argument.  That is, a value of 0.1 will set each component
%                to between 0.9 and 1.1 times the corresponding component of
%                the specified colour.  (The variation is actually done in
%                HSV rather than RGB space, but the difference is slight.)
%                The default is zero.  A value of 1 or more will give
%                colours scattered over the entire colour space.
%
%   The values of the options are stored in the mesh, and the options
%   default to the stored values.
%
%   Topics: Bio layer.

    if isempty(m), return; end
    if ~hasNonemptySecondLayer( m ), return; end

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'colors', m.globalProps.colors, ...
                          'colorvariation', m.globalProps.colorvariation );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'colors', 'colorvariation' );
    if ~ok, return; end

    NUM_REPS = 50;
    numcells = length( m.secondlayer.cells );
    
    if size(s.colors,1)==1
        s.colors = [ s.colors; 1-s.colors ];
    end
    m.globalProps.colors = s.colors;
    m.globalProps.colorvariation = s.colorvariation;
    m.globalProps.colorparams = ...
        makesecondlayercolorparams( s.colors, s.colorvariation );
    hsv1 = m.globalProps.colorparams(1,[1 2 3]);
    hsv2 = m.globalProps.colorparams(1,[4 5 6]);
    m.secondlayer.cloneindex = ones(numcells,1);
    m.secondlayer.cellcolor = randcolor( numcells, hsv1, hsv2 );
    
    numedges = size( m.secondlayer.edges, 1 );
    min_color_diff = colorDistance( hsv1, hsv2, 'hsv' );
    for i=1:NUM_REPS
        numcollisions = 0;
        for ei=1:numedges
            c2 = m.secondlayer.edges(ei,4);
            if c2 > 0
                c1 = m.secondlayer.edges(ei,3);
                col1 = m.secondlayer.cellcolor(c1,:);
                col2 = m.secondlayer.cellcolor(c2,:);
                cdist = colorDistance(col1,col2);
                if cdist < min_color_diff
                    if rand(1) < 0.5
                        m.secondlayer.cellcolor(c1,:) = randcolor( 1, hsv1, hsv2 );
                    else
                        m.secondlayer.cellcolor(c2,:) = randcolor( 1, hsv1, hsv2 );
                    end
                    numcollisions = numcollisions+1;
                end
            end
        end
        fprintf( 1, 'Randomise colours: iter %d, dist %.3f, %d collisions, diff %.3f.\n', ...
            i, min_color_diff, numcollisions, min_color_diff );
        if numcollisions==0, break; end
        min_color_diff = min_color_diff*0.9;
    end
end
