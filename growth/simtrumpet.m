function [allr, allz, tt] = simtrumpet( len, diam, maxg )
%fn_arclen( maxs )
%   Simulated trumpet growth.

    if nargin < 1
        len = 2;
    end
    if nargin < 2
        diam = 2;
    end
    if nargin < 3
        maxg = 1;
    end
    radius = diam/2;
    maxiter = 30;
    figure(1);
    axis( [0 len 0 len] );
    axis equal
    allr = zeros( 0, maxiter+1 );
    allz = zeros( 0, maxiter+1 );
    tt = zeros(0,1);
    done = false;
    for j=0:100
        t = 0.0214*j;
        tg = t*maxg;
        y = zeros( 1, maxiter+1 );
        x = zeros( 1, maxiter+1 );
        x(1) = 0;
        y(1) = trumpet(0,tg,radius);
        ds = len/maxiter;
        limit = maxiter+1;
        for i=1:maxiter
            s = i*ds;
            y(i+1) = trumpet(s/len,tg,radius);
            dy = y(i+1)-y(i);
            dx = sqrt(ds^2-dy^2);
            x(i+1) = x(i) + dx;
            if imag(dx) ~= 0
                limit = i;
                fprintf( 1, 'Growth terminated at time %f.\n', t );
                done = true;
                break;
            end
        end
        if done, break; end
        allr( j+1, : ) = y;
        allz( j+1, : ) = x;
        tt( j+1, 1 ) = t;
        figure(1);
        plotconic( gca, x(1:limit), y(1:limit), 20, 'LineStyle', 'none' );
%         plot(y(1:limit),x(1:limit),'-');
%         hold on
%         plot(-y(1:limit),x(1:limit),'-');
%         hold off
        axis equal
        axis( [-radius-len radius+len -radius-len radius+len 0 len] );
      % xmax = x(limit)
        drawnow;
    end
    figure(2);
    surf( allr, repmat(tt,1,maxiter+1), allz );
    view(0,0);
    axis equal
end

function y = trumpet( s, gt, radius )
    y = radius*exp(gt*s);
end

