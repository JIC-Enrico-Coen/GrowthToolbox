function pts = splitEllipticalArc( a, b, theta1, theta2, ndivs )
%pts = splitEllipticalArc( a, b, theta1, theta2, ndivs )

% Divide the requested arc into octants.
% Pick an appropriate series of points for each octant.
% Rescale for the required number of points.

    swapends = theta1 > theta2;
    if swapends
        temp = theta1;
        theta1 = theta2;
        theta2 = temp;
    end
    
    swapaxes = a > b;
    if swapaxes
        temp = a;
        a = b;
        b = temp;
    end
    
    octanttype = [1 0 0 1 1 0 0 1];
        
    
    revs1 = floor( theta1/(2*pi) );
    theta1 = theta1 - revs1;
    theta2 = theta2 - revs1;
    
    octangle = pi/4;
    
    firstoctant = floor(theta1/octangle);
    lastoctant = ceil(theta2/octangle);
    numoctants = lastoctant-firstoctant;
    octends = [ theta1, octangle*((firstoctant+1):(lastoctant-1)), theta2 ];
    if numoctants==1
        octangles = theta2-theta1;
    else
        octangles = [ octends(2)-theta1, octangle+zeros(1,lastoctant-firstoctant-1), theta2-octends(end-1) ];
    end
    numapproxsegs = max( ndivs*4, ((theta2-theta1)/octangle)*10 );
    segsperoctangle = ceil( (numapproxsegs * octangles)/(theta2-theta1) );
    
    pts1 = placeOctant( octpts( octends(1), octends(2), octanttype( mod(firstoctant,8)+1 ), segsperoctangle(1) ), firstoctant );
    if numoctants > 1
%         pts1 = pts1(1:(end-1),:);
        pts2 = placeOctant( octpts( octends(end-1), octends(end), octanttype( mod(lastoctant,8)+1 ), segsperoctangle(end) ), lastoctant-1 );
    end
    if numoctants > 2
        y = linspace( 0, sqrt(0.5), segsperoctangle(2) )';
        x = sqrt(1-y.^2);
        xy = [x y];
        pts4 = cell( numoctants-2, 1 );
        for i=1:(numoctants-2)
            pts3 = placeOctant( xy, firstoctant+i );
            pts4{i} = pts3; % (1:(end-1),:);
        end
    end
    switch numoctants
        case 1
            pts = pts1;
        case 2
            pts = [pts1; pts2];
        otherwise
            pts = [pts1; cell2mat(pts4); pts2];
    end
    
    if swapends
        pts = pts( end:-1:1, : );
    end
    if swapaxes
        pts = pts(:,[2 1]);
    end
    pts(:,1) = pts(:,1)*a;
    pts(:,2) = pts(:,2)*b;
end

function pts = placeOctant( pts, octant )
    switch mod(octant,8)
        case 0
            % No change.
        case 1
            pts = pts(end:-1:1,[2 1]);
        case 2
            pts = [pts(:,2) -pts(:,1)];
        case 3
            pts = [-pts(end:-1:1,2) pts(end:-1:1,1)];
        case 4
            pts = -pts;
        case 5
            pts = [-pts(end:-1:1,2) -pts(end:-1:1,1)];
        case 6
            pts = [-pts(:,2) pts(:,1)];
        case 7
            pts = [pts(end:-1:1,1) -pts(end:-1:1,2)];
    end
end


function pts = octpts( theta1, theta2, octanttype, ndivs )
    if octanttype
        y = linspace( sin(theta1), sin(theta2), ndivs+1 )';
        x = sqrt(1-y.^2);
    else
        x = linspace( cos(theta1), cos(theta2), ndivs+1 )';
        y = sqrt(1-x.^2);
    end
    pts = [x y];
end
