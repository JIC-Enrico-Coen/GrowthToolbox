function hh = myquiver3(p,v,normals,headsize,headratio,fore,aft,varargin)
%h = MYQUIVER3(p,v,normals,headsize,headratio,fore,aft,varargin)
%   3-D quiver plot.
%   This differs from the standard quiver3 in the following ways:
%   1.  The origins and velocities are given as row vectors, or matrices of
%   the same. 
%   2.  It takes an additional argument NORMALS, which should follow the
%   velocity argument.  The arrowheads will be drawn in a plane perpendicular
%   to the corresponding normal vector.  If NORMALS is empty or absent,
%   suitable values will be chosen automatically.  A single normal can be
%   given, or one per arrow.  The normals must be unit vectors.
%   3.  It takes an argument HEADSIZE specifying the size of the
%   arrowheads as a proportion of the size of the shaft.  The handle
%   returned by quiver3 has a MaxHeadSize attribute, but I find there
%   appears to be a maximum size that it allows, irrespective of the value
%   requested.
%   4.  It takes an argument HEADRATIO, specifying the ratio of half-width
%   to length of the arrowhead.
%   5.  It takes additional arguments FORE and AFT.  The part of the arrow
%   in front of P is FORE*V, the part behind is -AFT*V
%   6.  If takes any number of further arguments, which will be passed as
%   parameters to the calls of lineMulticolor() that draw the components of
%   the arrows.
%   7.  It does not return a quiver object.  Instead, it returns an array
%   of handles to line objects.
%
%   If p has size N*3*K and v has size N*3*L, then each set of L velocities
%   will be plotted at each point in the set of K positions. 

  % fprintf( 1, 'myquiver3\n' );

    
    narginchk(2,inf);
    
    if (size(p,3) > 1) || (size(v,3) > 1)
        pointSetSize = size(p,3);
        arrowSetSize = size(v,3);
        p = repmat( p, 1, 1, 1, arrowSetSize );
        p = permute( p, [2 1 3 4] );
        p = reshape( p, 3, [] )';
        v = repmat( v, 1, 1, 1, pointSetSize );
        v = permute( v, [2 1 4 3] );
        v = reshape( v, 3, [] )';
    end
    
    numarrows = size(p,1);
    if numarrows==0
        hh = [];
        return;
    end
    
    if (nargin < 3) || isempty(normals)
        normals = findPerpVector( v );
    elseif size(normals,1)==1
        normals = repmat( normals, numarrows, 1 );
    end
    if (nargin < 4) || isempty(headsize), headsize = 0.5; end
    if (nargin < 5) || isempty(headratio), headratio = 0.6; end
    if (nargin < 6) || isempty(fore), fore = 1; end
    if (nargin < 7) || isempty(aft), aft = 1; end

    ends = p+fore*v;
    starts = p-aft*v;
    edgeindexes = repmat((1:numarrows)',1,2);
    
    if (headsize ~= 0) && (headratio ~= 0)
        headlength = headsize*(fore+aft);
        barbstart = ends - v*headlength;
        barboffset = cross( v, normals, 2 )*(headlength*headratio);  % Depends on normals being unit vectors.
        starts = reshape( [ starts, barbstart+barboffset, barbstart-barboffset ]', 3, [] )';
        startIndexes1 = edgeindexes(:,1) + numarrows;
        startIndexes2 = startIndexes1 + numarrows;
        edgeindexes = [ reshape( [edgeindexes(:,1), startIndexes1, startIndexes2], [], 1 ), ...
                        reshape( repmat( edgeindexes(:,2)', 3, 1 ), [], 1 ) ];
    end
    
    colorarg = [];
    colorindexarg = [];
    for i=1:2:length(varargin)
        if strcmp( varargin{i}, 'Color' )
            colorarg = i+1;
        end
        if strcmp( varargin{i}, 'ColorIndex' )
            colorindexarg = i+1;
        end
    end
    if (headsize ~= 0) && (headratio ~= 0)
        if ~isempty( colorindexarg )
            c = varargin{colorindexarg};
            if size(c,1) > 1
                varargin{colorindexarg} = reshape( repmat( c(:)', 3, 1 ), [], 1 );
            end
        elseif ~isempty( colorarg )
            c = varargin{colorarg};
            if size(c,1) > 1
                varargin{colorarg} = reshape( repmat( c', 3, 1 ), 3, [] )';
            end
        end
    end
    
    hh = plotIndexedLines( edgeindexes, starts, ends, varargin{:} );
end
