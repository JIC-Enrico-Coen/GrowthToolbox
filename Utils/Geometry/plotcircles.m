function h = plotcircles( varargin )
    if nargin==0
        return;
    end
    s = struct( varargin{:} );
    s = defaultfields( s, 'centre', [0 0 0], 'radius', [1 1], 'normal', [0 0 1], 'startvec', [1 0 0], ...
        'midangle', '0', 'arc', 2*pi, 'arrowsize', 0.5, 'arrowratio', 0.5, 'resolution', 24, 'minangle', 0, 'minradius', 0 );
    params = { 'centre', 'radius', 'normal', 'startvec', ...
               'midangle', 'arc', 'arrowsize', 'arrowratio', 'resolution', 'minangle', 'minradius' };
    lengths = zeros( 1, length(params) );
    for i=1:length(params)
        fn = params{i};
        lengths(i) = size( s.(fn), 1 );
    end
    n = max(lengths);
    if (n > 1) && any(lengths==1)
        for i=1:length(params)
            if lengths(i)==1
                fn = params{i};
                sz = [ n ones(1,length(size(s.(fn)))-1) ];
                s.(fn) = repmat( s.(fn), sz );
            end
        end
    end
    if size(s.radius,2)==1
        s.radius = [ s.radius, s.radius ];
    end
    
    otherargs = rmfield( s, params );
    fns = fieldnames(otherargs);
    otherargsarray = cell( 1, 2*length(fns) );
    for i=1:length(fns)
        otherargsarray([2*i-1,2*i]) = { fns{i}, s.(fns{i}) };
    end

    drawnarcs = ((s.radius(:,1) > s.minradius) | (s.radius(:,2) > s.minradius)) & (abs(s.arc) > s.minangle);
    drawnheads = s.arrowsize > 0;
    stepsperarc = ceil(s.resolution.*abs(s.arc)/(2*pi));
    numpts = sum( stepsperarc(drawnarcs) ) + 2*sum(drawnarcs) + 4*sum(drawnheads);
    layers = size(s.centre,3);
    allpoints = zeros(numpts*layers,3);
    ai = 0;
    
    for j=1:layers
        for i=1:n
            if ~drawnarcs(i)
                continue;
            end
            angdiff = s.arc(i);
            sense = sign(angdiff);
            a1 = s.midangle(i) - angdiff/2;
            a2 = a1 + angdiff;
            steps = stepsperarc(i); % ceil(s.resolution(i)*abs(angdiff)/(2*pi));
            theta = linspace( a1, a2, steps+1 );
            xx = cos(theta)*s.radius(i,1);
            yy = sin(theta)*s.radius(i,2);
            zz = zeros(size(xx));
            basepoints = [ [xx(:), yy(:), zz(:)]; ...
                           [NaN NaN NaN] ];
            if drawnheads(i)
                realarrowsize = s.arrowsize(i) .* max( s.radius(i,1), s.radius(i,2) );
                arrowoffset1 = realarrowsize*[s.arrowratio(i), -sense];
                arrowoffset2 = arrowoffset1;
                arrowoffset2(1) = -arrowoffset2(1);
                barbangledelta = sense*atan(s.arrowsize(i))/2;
                barbrot = theta(end)-barbangledelta;
                cb = cos(barbrot);
                sb = sin(barbrot);
                barbs = [ [arrowoffset1;arrowoffset2]*[cb sb;-sb cb], [0;0] ] + repmat([xx(end),yy(end),zz(end)],2,1);
                basepoints((end+1):(end+4),:) = [ barbs(1,:); ...
                                                  [xx(end),yy(end),zz(end)]; ...
                                                  barbs(2,:); ...
                                                  [NaN NaN NaN] ];
            end
            [yaxis,zaxis,xaxis] = makeframe( s.normal(i,:), s.startvec(i,:) );
            rotmat = [xaxis;yaxis;zaxis];
            points = basepoints*rotmat + repmat( s.centre(i,:,j), size(basepoints,1), 1 );
            ai1 = ai + size(points,1);
            allpoints( (ai+1):ai1, : ) = points;
            ai = ai1;
        end
    end
    h = plotpts( allpoints, otherargsarray{:} );
end




