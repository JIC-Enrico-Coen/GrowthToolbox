function [m,ok] = leaf_teardrop( m, varargin )
%[m,ok] = leaf_teardrop( m, ... )
%
%   Make a flat mesh whose shape is an equilateral trapezium with a
%   semicircle attached to each of the parallel sides. The axis of symmetry
%   is the Y axis.
%
%   Options:
%
%   Default values are defined for all of these, so you can just give the
%   command m = leaf_teardrop([]) and get something sensible.
%
%   'length'    The length of the trapezium along the Y axis, i.e. the
%               distance between its parallel sides. Default 8.
%
%   'width1', 'width2'  The lengths of the two parallel sides. 'width1'
%               specifies the one with the smaller value of Y. Default 4
%               and 1.
%
%   'rings'     The number of concentric rings of elements in the larger of
%               the two semicircles. The smaller one will have the number
%               of rings scaled down in proportion to its size. Twice this
%               is also the number of finite elements across the width of
%               the trapezium at each end. If a pair of values is given,
%               these specify the number of rigs for the two semicircles
%               separately, overriding the automatic scaling. Default 4.
%
%               A potential disadvantage of the automatic scaling is that
%               the number of elements in each row of the trapezium will
%               decrease from the larger end to the smaller, and this means
%               that although the overall shape is symmetric, the division
%               into finite elements will not be. If it is important that
%               the decomposition be symmetric, give a pair of identical
%               values.
%
%   'circumpts' The number of elements around both of the semicircles
%               combined. Use 0 to have a suitable value be chosen
%               calculated from 'rings'. Default 0.
%
%   'centre'    The centre of the bounding box of the trapezium. Default
%               [0 0 0].
%
%   'lengthdivs'    The number of finite elements along the length of the
%               trapezium. Default 16.
%
%   'thickness' The thickness of the mesh in the Z direction. Default 1.
%
%   'layers'    The number of layers of finite elements stacked in the Z
%               direction. Default 1 (and better left that way, as
%               multi-layer meshes have not been tested in a long time).
%
%   'generalFE' Ignore. By default false, and setting it to true is not
%               implemented.
%
%   See also:
%           LEAF_CIRCLE, LEAF_CYLINDER, LEAF_ICOSAHEDRON, LEAF_LOBES,
%           LEAF_ONECELL, LEAF_RECTANGLE, LEAF_SNAPDRAGON, LEAF_BOX, etc.
%
%   Topics: Mesh creation.

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    s = defaultfields( s, 'length', 8, 'width1', 4, 'width2', 1, 'rings', 4, 'circumpts', 0, ...
        'centre', [0 0 0], 'lengthdivs', 16, 'layers', 0, 'thickness', 0, 'generalFE', false );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'length', 'width1', 'width2', 'rings', 'circumpts', ...
        'centre', 'lengthdivs', 'layers', 'thickness', 'generalFE' );
    if ~ok, return; end
    [ok,handles,m,savedstate] = prepareForGUIInteraction( m );
    if ~ok, return; end
    savedstate.replot = true;
    savedstate.install = true;
    
    % Make a rectangle mesh of dimensions [ length, width1, thickness ].
    
    if length(s.rings)==1
        widths = [ s.width1 s.width2 ];
        [~,maxwi] = max( widths );
        minwi = 3-maxwi;
        rings(maxwi) = s.rings;
        rings(minwi) = ceil( s.rings * (widths(minwi)/widths(maxwi)) );
    else
        rings = s.rings([1 2]);
    end
    newm_rect = makerectmesh( s.width1, s.length, s.centre, [rings(1)*2 rings(2)*2], s.lengthdivs, [s.width2/s.width1 1] );
    newm_semi1 = newcirclemesh( [ s.width1, s.width1, 0 ], s.circumpts, rings(1), [0 0 0], 0, 0, false, 0.5, 0 );
    newm_semi2 = newcirclemesh( [ s.width2, s.width2, 0 ], s.circumpts, rings(2), [0 0 0], 0, 0, false, 0.5, 0 );
    centre1 = s.centre - [ 0, s.length/2, 0 ];
    centre2 = s.centre + [ 0, s.length/2, 0 ];
    
    newm_semi1.nodes = -newm_semi1.nodes + centre1;
    newm_semi2.nodes = newm_semi2.nodes + centre2;
    
    if false
        % Testing
        [~,ax] = getFigure();
        plotbaremesh( newm_rect, ax );
        hold on
        plotbaremesh( newm_semi1, ax );
        plotbaremesh( newm_semi2, ax );
        hold off
        axis equal
    end
    
    newm = unionmesh( newm_rect, newm_semi1, newm_semi2 );
    [newm1.nodes,retained,remap] = mergenodesprox( newm.nodes, 1e-6 );
    newm1.tricellvxs = remap( newm.tricellvxs );
    
    m = setmeshfromnodes( newm1, m, s.layers, s.thickness );
    m.meshparams = s;
    m.meshparams.randomness = 0;
    m.meshparams.type = regexprep( mfilename(), '^leaf_', '' );
    
    m = concludeGUIInteraction( handles, m, savedstate );
    xxxx = 1;
end
