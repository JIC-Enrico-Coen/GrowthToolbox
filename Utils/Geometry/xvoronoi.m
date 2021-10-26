function [vxx,vy] = xvoronoi(varargin)
%XVORONOI Modified Voronoi diagram.
%   By RK, based on Matlab's VORONOI.
%
%   VORONOI(X,Y) plots the Voronoi diagram for the points X,Y. Lines-to-
%   infinity are approximated with an arbitrarily distant endpoint.
%
%   VORONOI(X,Y,TRI) uses the triangulation TRI instead of 
%   computing it via DELAUNAY. 
%
%   VORONOI(X,Y,OPTIONS) specifies a cell array of strings to be used as
%   options in Qhull via DELAUNAY.
%   If OPTIONS is [], the default DELAUNAY options will be used.
%   If OPTIONS is {''}, no options will be used, not even the default.
%
%   VORONOI(AX,...) plots into AX instead of GCA.
%
%   H = VORONOI(...,'LineSpec') plots the diagram with color and linestyle
%   specified and returns handles to the line objects created in H.
%
%   [VX,VY] = VORONOI(...) returns the vertices of the Voronoi edges in VX 
%   and VY so that plot(VX,VY,'-',X,Y,'.') creates the Voronoi diagram.  
%   The lines-to-infinity are the last columns of VX and VY.  To 
%   ensure the lines-to-infinity do not affect the settings of the axis 
%   limits, use the commands:
%
%       h = plot(VX,VY,'-',X,Y,'.');
%       set(h(1:end-1),'xliminclude','off','yliminclude','off')
%
%   For the topology of the voronoi diagram, i.e. the vertices for
%   each voronoi cell, use the function VORONOIN as follows: 
%
%         [V,C] = VORONOIN([X(:) Y(:)])
%
%   See also VORONOIN, DELAUNAY, CONVHULL.

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.15.4.9 $  $Date: 2005/06/09 04:40:51 $

[cax,args,nargs] = axescheck(varargin{:});
narginchk(2,4);

x = args{1}(:);
y = args{2}(:);

if nargs == 2,
    tri = delaunay(x,y);
    ls = '';
else 
    arg3 = args{3};
    if nargs == 3,
        ls = '';
    else
        arg4 = args{4};
        ls = arg4;
    end 
    if isempty(arg3),
        tri = delaunay(x,y);
    elseif ischar(arg3),
        tri = delaunay(x,y); 
        ls = arg3;
    elseif iscellstr(arg3),
        tri = delaunay(x,y,arg3);
    else
        tri = arg3;
    end
end

% re-orient the triangles so that they are all clockwise
xt = x(tri); 
yt = y(tri);
%Because of the way indexing works, the shape of xt is the same as the
%shape of tri, EXCEPT when tri is a single row, in which case xt can be a
%column vector instead of a row vector.
if size(xt,2) == 1 
    xt = xt';
    yt = yt';
end
ot = xt(:,1).*(yt(:,2)-yt(:,3)) + ...
    xt(:,2).*(yt(:,3)-yt(:,1)) + ...
    xt(:,3).*(yt(:,1)-yt(:,2));
bt = find(ot<0);
tri(bt,[1 2]) = tri(bt,[2 1]);

% Compute centers of triangles
% c = circle(tri,x,y);
% Compute centroids of triangles
c = centroids(tri,x,y);

% Create matrix T where i and j are endpoints of edge of triangle T(i,j)
n = numel(x);
t = repmat((1:size(tri,1))',1,3);
T = sparse(tri,tri(:,[3 1 2]),t,n,n); 

% i and j are endpoints of internal edge in triangle E(i,j)
E = (T & T').*T; 
% i and j are endpoints of external edge in triangle F(i,j)
F = xor(T, T').*T;

% v and vv are triangles that share an edge
[i,j,v] = find(triu(E));
[i,j,vv] = find(triu(E'));

% Internal edges
vx = [c(v,1) c(vv,1)]';
vy = [c(v,2) c(vv,2)]';

%%% Compute lines-to-infinity
% i and j are endpoints of the edges of triangles in z
[i,j,z] = find(F);
% Counter-clockwise components of lines between endpoints
dx = x(j) - x(i);
dy = y(j) - y(i);

% Calculate scaling factor for length of line-to-infinity
% Distance across range of data
rx = max(x)-min(x); 
ry = max(y)-min(y);
% Distance from vertex to center of data
cx = (max(x)+min(x))/2 - c(z,1); 
cy = (max(y)+min(y))/2 - c(z,2);
% Sum of these two distances
nm = sqrt(rx.*rx + ry.*ry) + sqrt(cx.*cx + cy.*cy);
% Compute scaling factor
scale = nm./sqrt((dx.*dx+dy.*dy));
    
% Lines from voronoi vertex to "infinite" endpoint
% We know it's in correct direction because compononents are CCW
ex = [c(z,1) c(z,1)-dy.*scale]';
ey = [c(z,2) c(z,2)+dx.*scale]';
% Combine with internal edges
vx = [vx ex];
vy = [vy ey];

if nargout<2
    % Plot diagram
    if isempty(cax)
        % If no current axes, create one
        cax = gca;
    end
    if isempty(ls)
        % Default linespec
        ls = '-';
    end
    [l,c,mp,msg] = colstyle(ls); error(msg) % Extract from linespec
    if isempty(mp)
        % Default markers at points        
        mp = '.';
    end
    if isempty(l)
        % Default linestyle
        l = get(ancestor(cax,'figure'),'defaultaxeslinestyleorder'); 
    end
    if isempty(c), 
        % Default color        
        co = get(ancestor(cax,'figure'),'defaultaxescolororder');
        c = co(1,:);
    end
    % Plot points
    h1 = plot(x,y,'marker',mp,'color',c,'linestyle','none','parent',cax);
    % Plot voronoi lines.  Needs updating to plot lines more efficiently.
    h2 = line(vx,vy,'color',c,'linestyle',l,'parent',cax,...
        'yliminclude','off','xliminclude','off' );
    if nargout==1, vxx = [h1; h2]; end % Return handles
else
    vxx = vx; % Don't plot, just return vertices
end



function c = centroids(tri,x,y)
%CENTROIDS Return centroid and radius for circumcircles
%   C = CENTROIDS(TRI,X,Y) returns a N-by-2 vector containing [xcenter(:)
%   ycenter(:)] for each triangle in TRI.

%   x1 = x(tri(:,1)); x2 = x(tri(:,2)); x3 = x(tri(:,3));
%   y1 = y(tri(:,1)); y2 = y(tri(:,2)); y3 = y(tri(:,3));

    c = [ sum( x(tri(:,:)), 2 ), sum( y(tri(:,:)), 2 ) ]/3;
  % c = [ (x1+x2+x3)/3, (y1+y2+y3)/3 ];


function c = circle(tri,x,y)
%CIRCLE Return center and radius for circumcircles
%   C = CIRCLE(TRI,X,Y) returns a N-by-2 vector containing [xcenter(:)
%   ycenter(:)] for each triangle in TRI.

% Reference: Watson, p32.
x1 = x(tri(:,1)); x2 = x(tri(:,2)); x3 = x(tri(:,3));
y1 = y(tri(:,1)); y2 = y(tri(:,2)); y3 = y(tri(:,3));

% Set equation for center of each circumcircle: 
%    [a11 a12;a21 a22]*[x;y] = [b1;b2] * 0.5;

a11 = x2-x1; a12 = y2-y1;
a21 = x3-x1; a22 = y3-y1;

% Solve the 2-by-2 equation explicitly
idet = a11.*a22 - a21.*a12;

% Add small random displacement to points that are either the same
% or on a line.
d = find(idet == 0);
if ~isempty(d), % Add small random displacement to points
    delta = sqrt(eps);
    x1(d) = x1(d) + delta*(rand(size(d))-0.5);
    x2(d) = x2(d) + delta*(rand(size(d))-0.5);
    x3(d) = x3(d) + delta*(rand(size(d))-0.5);
    y1(d) = y1(d) + delta*(rand(size(d))-0.5);
    y2(d) = y2(d) + delta*(rand(size(d))-0.5);
    y3(d) = y3(d) + delta*(rand(size(d))-0.5);
    a11 = x2-x1; a12 = y2-y1;
    a21 = x3-x1; a22 = y3-y1;
    idet = a11.*a22 - a21.*a12;
end

b1 = a11 .* (x2+x1) + a12 .* (y2+y1);
b2 = a21 .* (x3+x1) + a22 .* (y3+y1);

idet = 0.5 ./ idet;

xcenter = ( a22.*b1 - a12.*b2) .* idet;
ycenter = (-a21.*b1 + a11.*b2) .* idet;

c = [xcenter ycenter];


