function m = lobemesh( radius, nrings, rectht, nrows, nbase, ncirc )
%m = LOBEMESH(radius, nrings, rectht, nrows, nbase )
%   Make a mesh in the shape of a semicircle atop a
%   rectangle.  RADIUS is the radius of the semicircle.  RECTHT is the
%   height of the rectangle.  NRINGS is the number of rings of triangles
%   the semicircle is divided into.  NROWS is the number of rows of
%   triangles in the rectangle.  NBASE is half the number of edges the base
%   of the rectangle is divided into.  By default this is NRINGS.
%
%   The bottom edge of the lobe consists of the last 2n+1 nodes.
%
%   The nodes on the right edge are the nth node, and nrows nodes at
%   intervals of 2nrings+1, ending at the last node.
%
%   The resulting mesh contains only the following components:
%   nodes, tricellvxs, globalProps.trinodesvalid,
%   globalProps.prismnodesvalid, and borders.{bottom,left,right}.

    if (nargin < 4) || isempty(nrows) || (nrows==0)
        nrows = ceil(nrings*rectht/radius);
    end
    if (nargin < 5) || isempty(nbase) || (nbase==0)
        nbase = nrings;
    end
    
    rectmeshL = makerectmesh( [ -radius, 0 ], [ -rectht, 0 ], [0,0,0], [nbase, nrings], nrows );
    rectmeshR = makerectmesh( [ 0, radius ], [ -rectht, 0 ], [0,0,0], [nbase, nrings], nrows );
    stitchL = find( rectmeshL.nodes(:,1)==0 );
    stitchR = find( rectmeshR.nodes(:,1)==0 );
    rectmesh = stitchmeshes( rectmeshL, rectmeshR, stitchL, stitchR );
  % rectmesh = makerectmesh( [ -radius, radius ], [ -rectht, 0 ], [nbase, nrings*2], nrows );
    if numel(ncirc) <= 1
        innercirc = 3;
    else
        innercirc = ncirc(1);
        ncirc = ncirc(2);
    end
    if innercirc==0
        innercirc = 3;
    end
    if ncirc==0
        ncirc = innercirc*nrings;
    end
    innercirc = max( innercirc, 2 );
    ncirc = max( ncirc, 2 );
    circmesh = newcirclemesh( [2*radius 2*radius 0], ncirc+1, nrings, [0,0,0], 0, ...
                              innercirc+1, 0, 0.5, 0 );
    rectmeshtop = find( rectmesh.nodes(:,2) >= -rectht/(2*nrows) );
    [ignore,renumber] = sort( rectmesh.nodes(rectmeshtop,1) );
    rectmeshtop = rectmeshtop(renumber);
    circmeshfoot = find( circmesh.nodes(:,2) <= 0.1*radius/nrings );
    [ignore,renumber] = sort( circmesh.nodes(circmeshfoot,1) );
    circmeshfoot = circmeshfoot(renumber);
    m = stitchmeshes( rectmesh, circmesh, rectmeshtop, circmeshfoot );

    m.globalProps.trinodesvalid = true;
    m.globalProps.prismnodesvalid = false;
    
    maxx = radius*(1 + cos(pi/ncirc))/2;
    rectmeshleft = find( m.nodes(:,1) <= -maxx );
    [ignore,renumber] = sort( m.nodes(rectmeshleft,2) );
    rectmeshleft = rectmeshleft(renumber);
    rectmeshright = find( m.nodes(:,1) >= maxx );
    [ignore,renumber] = sort( m.nodes(rectmeshright,2) );
    rectmeshright = rectmeshright(renumber);
    miny = -rectht*(1 - 1/(2*nrows));
    rectmeshbottom = find( m.nodes(:,2) <= miny );
    [ignore,renumber] = sort( m.nodes(rectmeshbottom,1) );
    rectmeshbottom = rectmeshbottom(renumber);
    
  % lobemesh_rectmeshleft = rectmeshleft'
  % lobemesh_rectmeshright = rectmeshright'
  % lobemesh_rectmeshbottom = rectmeshbottom'

    
    m.borders.bottom = rectmeshbottom;
    m.borders.right = rectmeshright;
    m.borders.left = rectmeshleft;
end

function rpi = rectpointindex( n, xi, yi )
    rpi = xi + n + 1 + (n+n+1)*(yi-1);
end

function pti = pointIndex(n,nps,i,j,k)
    pti = (i-1)*nps + j + (k-1)*(n+n-k)/2;
end

function fi = cellIndex(fps,nps,i,j,k,f)
    fi = (i-1)*fps + j*(j-1)/2 + k + f*nps;
end

