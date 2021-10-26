function m = ypiecequadpos( r, rt, xw, yw, nx, ny )
%v = ypiecequadpos( u, v )
%   Calculate the 3D position of a point on the basic quadilateral, of
%   which 12 copies form the basic y-shaped junction of three tubes.

% The quad is bounded by four curved sides, and parameterised by u and v
% varying from 0 to 1:
%   v=0: y = rb + a*x^2
%           a = 
% The parameters defining the shape are:
%   r: radius of tubes.
%   rt: radius to centre of tube-end
%   rb: radius from centre to between-tube saddle points.

    s3 = sqrt(3);
    centreheight = rt*2;
    outerradius = rt*s3 - r;
    rb = centreheight - outerradius;
    
    m1 = makerectmesh( 1, 1, [0,0,0], nx, ny );
    m1.nodes(:,[1 2]) = m1.nodes(:,[1 2]) + 0.5;
    [x,y,z] = interp( 1-m1.nodes(:,1), m1.nodes(:,2) );
    m1.nodes = [x,y,z];
    
    m2 = makerectmesh( 1, 1, [0,0,0], nx, ny );
    m2.nodes(:,[1 2]) = m2.nodes(:,[1 2]) + 0.5;
    [x,y,z] = interp( m2.nodes(:,1), m2.nodes(:,2) );
    m2.nodes = [-x,y,z];
    
    c3 = cos(pi*2/3);
    s3 = sin(pi*2/3);
    rotthird = [ c3 s3 0; -s3 c3 0; 0 0 1];
    
    m3 = m1;
    m3.nodes = m3.nodes * rotthird;
    
    m4 = m2;
    m4.nodes = m4.nodes * rotthird;
    
    m5 = m3;
    m5.nodes = m5.nodes * rotthird;
    
    m6 = m4;
    m6.nodes = m6.nodes * rotthird;
    
    ms = [m1 m2 m3 m4 m5 m6];
    ms2 = ms;
    roty = diag([-1,1,-1]);
    for i=1:length(ms2)
        ms2(i).nodes = ms2(i).nodes * roty;
    end
    ms = [ ms, ms2 ];
    
    [m,ren2] = stitchmeshes( m1, m2, m1.borders.xmax, m2.borders.xmin );
    
    [m,ren3] = stitchmeshes( m, m3, ren2(m2.borders.ymax), m3.borders.ymax(end:-1:1) );
    [m,ren4] = stitchmeshes( m, m4, ren3(m3.borders.xmax), m4.borders.xmin );
    [m,ren5] = stitchmeshes( m, m5, ren4(m4.borders.ymax), m5.borders.ymax(end:-1:1) );
    [m,ren6] = stitchmeshes( m, m6, ...
                            [ ren5(m5.borders.xmax)'; m1.borders.ymax(1:(end-1)) ], ...
                            [ m6.borders.xmin; m6.borders.ymax(end:-1:2) ] );
    j12 = [ m1.borders.ymin; ren2(m2.borders.ymin(2:end))' ];
    j34 = [ ren3(m3.borders.ymin)'; ren4(m4.borders.ymin(2:end))' ];
    j56 = [ ren5(m5.borders.ymin)'; ren6(m6.borders.ymin(2:end))' ];
    mx = m;
    mx.nodes = mx.nodes * roty;
    
    m = stitchmeshes( m, mx, ...
                      [ j12; j34; j56 ], ...
                      [ j12(end:-1:1); j56(end:-1:1); j34(end:-1:1) ] );
                    
    
    
    
    figure(1);
    clf;
    hold on
    x = reshape( m.nodes(m.tricellvxs',1), 3, [] );
    y = reshape( m.nodes(m.tricellvxs',2), 3, [] );
    z = reshape( m.nodes(m.tricellvxs',3), 3, [] );
    fill3( x, y, z, ...
           rand(3,size(m.tricellvxs,1)) );
    axis equal
    hold off
    
%     xmin = m.borders.xmin'
%     xmax = m.borders.xmax'
%     ymin = m.borders.ymin'
%     ymax = m.borders.ymax'
    return;
    x = m.nodes(:,1);
    y = m.nodes(:,2);
    z = m.nodes(:,3);
    plot1();
    
    pts = [x(:),y(:),z(:)];
    
    function plot1()
        surf(x,y,z);
    end

    function plot4()
        surf(x,y,z);
        surf(-x,y,z);
        surf(x,y,-z);
        surf(-x,y,-z);
    end

    function plot12()
        plot4();
        x1 = (-x + y*s3)/2;
        y1 = (-x*s3 + -y)/2;
        x = x1;
        y = y1;
        plot4();
        x1 = (-x + y*s3)/2;
        y1 = (-x*s3 + -y)/2;
        x = x1;
        y = y1;
        plot4();
    end

    function [x,y,z] = v0( u )
        z = zeros(size(u));
        theta = u*(pi/6);
        x = outerradius*sin(theta);
        y = centreheight - outerradius*cos(theta);
    end

    function [x,y,z] = v1( u )
        z = r*ones(size(u));
        x = u*(rt*s3*0.5);
        y = u*(rt*0.5);
    end

    function [x,y,z] = u0( v )
        x = zeros(size(v));
        theta = v*(pi/2);
        y = rb*sin(theta);
        z = r*cos(theta);
    end

    function [x,y,z] = u1( v )
        theta = v*(pi/2);
        ctheta = cos(theta);
        x = rt*s3/2 - (r/2)*ctheta;
        y = rt/2 + (r*s3/2)*ctheta;
        z = r*sin(theta);
    end

    function [x,y,z] = interp( u, v )
        [v0ux,v0uy,v0uz] = v0(u);
        [v1ux,v1uy,v1uz] = v1(u);
        h = sqrt( (v0ux-v1ux).^2 + (v0uy-v1uy).^2 );
        inclination = atan2( v0uy-v1uy, v1ux-v0ux );
        thv = v*(pi/2);
        cthv = cos(thv);
        sthv = sin(thv);
        z = r*sthv;
        y = v1uy + (h.*sin(inclination)).*cthv;
        x = v1ux - (h.*cos(inclination)).*cthv;
    end
end
