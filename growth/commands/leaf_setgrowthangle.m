function m = leaf_setgrowthangle( m, varargin )
%m = leaf_setgrowthangle( m, ... )
%
%   Set the angle at which the principal directions of growth are rotated
%   relative to the polariser gradient.  By default this is zero, i.e. the
%   growth specified by KAPAR and KBPAR is parallel to the gradient, that
%   specified by KAPER and KBPER is perpendicular to the gradient within
%   the surface, and that specified by KNOR is perpendicular to the
%   surface.
%
%   This procedure allows the PAR and PER growth directions to be rotated
%   within the surface, by a specified angle relative to the gradient.  The
%   direction of KNOR is unaffected.
%
%   The direction of rotation for a positive angle is defined by the
%   right-hand rule applied to the surface normal.  The surface normal is
%   directed from the A side of the mesh towards the B side.  If you
%   imagine this vector grasped by the fist of the right hand, with the
%   thumb extended along it, then the direction the fingers curl around the
%   vector is the direction of positive rotation.  In the GUI, you can
%   determine which are the A and B sides by turning on the display of FE
%   edges and observing which side of the mesh they are drawn as thicker
%   lines.  That side is the side selected by the "Decor" "A" and "B" radio
%   buttons.
%
%   The angle can be set differently on the two sides of the mesh.
%
%   Options:
%
%   'anglePerVertex'    A single value, or a vector of values, one for
%       every vertex of the finite element mesh.
%
%   'anglePerVertexB'   Like anglePerVertex, but specifying the angle on
%       the B side of the mesh.  When this is specified, anglePerVertex
%       applies only to the A side.  When it is not, anglePerVertex is
%       applied to both sides.
%
%   'anglePerFE'    A single value, or a vector of values, one for
%       every element of the finite element mesh.
%
%   'anglePerFEB'   Like anglePerFE, but specifying the angle on
%       the B side of the mesh.  When this is specified, anglePerFE
%       applies only to the A side.  When it is not, anglePerFE is
%       applied to both sides.
%
%   'radians'   True if the angles are given in radians, false if they are
%       given in degrees (the default).
%
%   Either the per-vertex or the per-FE values should be specified, but not
%   both.  If both are given, only the per-vertex values will be used.
%
%   Example:
%       m = leaf_setgrowthangle( m, 'anglePerVertex', 0.3, 'radians', true );
%           Sets the angle to 0.3 radians everywhere on both sides.
%
%   Topics: Growth.

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, ...
        'anglePerVertex', [], 'anglePerVertexB', [], ...
        'anglePerFE', [], 'anglePerFEB', [], ...
        'radians', false );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'anglePerVertex', 'anglePerVertexB', 'anglePerFE', 'anglePerFEB', 'radians' );
    if ~ok, return; end

    numvxs = size(m.nodes,1);
    numFEs = size(m.tricellvxs,1);
    if numel(s.anglePerVertex)==1
        s.anglePerVertex = zeros(numvxs,1) + s.anglePerVertex;
    end
    if numel(s.anglePerVertexB)==1
        s.anglePerVertexB = zeros(numvxs,1) + s.anglePerVertexB;
    end
    if numel(s.anglePerFE)==1
        s.anglePerFE = zeros(numFEs,1) + s.anglePerFE;
    end
    if numel(s.anglePerFEB)==1
        s.anglePerFEB = zeros(numFEs,1) + s.anglePerFEB;
    end
    
    if isempty( s.anglePerVertex ) && ~isempty( s.anglePerVertexB )
        s.anglePerVertex = s.anglePerVertexB;
        s.anglePerVertexB = [];
    end
    
    if isempty( s.anglePerFE ) && ~isempty( s.anglePerFEB )
        s.anglePerFE = s.anglePerFEB;
        s.anglePerFEB = [];
    end
    
    if ~isempty( s.anglePerVertex )
        s.anglePerFE = [];
        s.anglePerFEB = [];
    end
    if (~isempty( s.anglePerVertex ) && all( s.anglePerVertex==0 ) && all( s.anglePerVertexB==0 )) ...
            || (~isempty( s.anglePerFE ) && all( s.anglePerFE==0 ) && all( s.anglePerFEB==0 ))
        m.growthanglepervertex = [];
        %m.growthanglepervertexB = [];
        m.growthangleperFE = [];
        %m.growthangleperFEB = [];
    else
        if s.radians
            factor = 1;
        else
            factor = pi/180;
        end
        m.growthanglepervertex = [s.anglePerVertex(:), s.anglePerVertexB(:)] * factor;
        %m.growthanglepervertexB = s.anglePerVertexB(:) * factor;
        m.growthangleperFE = [s.anglePerFE(:), s.anglePerFEB(:)] * factor;
        %m.growthangleperFEB = s.anglePerFEB(:) * factor;
    end
end
