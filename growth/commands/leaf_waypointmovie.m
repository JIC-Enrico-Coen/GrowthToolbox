function [m,ok] = leaf_waypointmovie( m, varargin )
%   Generate a movie from the currently stored waypoints in m.
%   The options are the same as for leaf_movie.
%
%   See also leaf_movie, leaf_addwaypoint, leaf_clearwaypoints.
%
%   Topics: Movies/Waypoints.

    if isempty( m.moviescripts )
        complain( 'The mesh contains no movies.' );
        return;
    end
    
    if( m.movieselected < 1) || (m.movieselected > length(m.moviescripts))
        % Say nothing, silently correct the value.
        m.moviescripts = 1;
    end
    
    themovie = m.moviescripts(m.movieselected);
    if length(themovie.waypoints) < 2
        complain( 'The selected movie script must have at least two waypoints.' );
        return;
    end
    
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    ok = checkcommandargs( mfilename(), s, 'only', ...
        'mode', 'filename', 'moviedir', 'fps', 'compression', ...
        'quality', 'keyframe', 'colormap', 'videoname' );
    if ~ok, return; end
    
    s = defaultfields( s, ...
        'fps', 0, ...
        'compression', 'Motion JPEG AVI', ...
        'quality', 75, ...
        'keyframe', 5 );
    s.fps = double(s.fps);  % Because it generates a bad movie file if
                            % it's an integer type.

    % Close any existing movie.
    m = leaf_movie( m, 0 );
    
    % Sort the waypoints by time.
    [t_unused,ti] = sort( [themovie.waypoints.simtime] );
    waypoints = themovie.waypoints(ti);
    
    % Put m into the state of the first waypoint.
    pics = m.pictures;
    [m,ok] = leaf_reload( m, waypoints(1).simtime, 'rewrite', false );
    if ~ok
        complain( 'Cannot load first waypoint at time %f.  Movie not generated.', ...
            waypoints(1).simtime );
        return;
    end
    m.pictures = pics;
    m = leaf_plot( m, waypoints(1).plotoptions );
    % Start recording a movie.
    if s.fps==0
        s.fps = themovie.framerate;
    end
    [m,ok] = leaf_movie( m, s );
    if ~ok
        % Movie was not started, for whatever reason.
        return;
    end
    curframe = 1;
    for i=2:length(waypoints)
        waypoint = waypoints(i);
        timediff = waypoint.simtime - waypoints(i-1).simtime;
        if (waypoint.numframes > 0) && (timediff > 0)
            m.globalProps.timestep = timediff/waypoint.numframes;
        end
        TOL = 1e-8;
        if waypoint.crossfade && (timediff < TOL) ...
            && samecamera( waypoints(i-1).plotoptions.ourViewParams, ...
                                        waypoint.plotoptions.ourViewParams )
            [m,img0] = getmovieframe( m, waypoints(i-1).plotoptions );
            [m,img1] = getmovieframe( m, waypoint.plotoptions );
            for fi=1:waypoint.numframes
                img = interpolateImages( img0, img1, fi/waypoint.numframes );
                m = recordframe( m, img );
            end
        else
            for fi=1:waypoint.numframes
                if timediff > 0
                    [m,ok] = leaf_iterate( m, 1, 'plot', 0 );
                    if ~ok
                        m = closeMovie( m );
                        clearstopbutton( m );
                        return;
                    end
                end
                if waypoint.crossfade
                    fraction = fi/waypoint.numframes;
                else
                    fraction = double( fi==waypoint.numframes );
                end
                [m,img] = getmovieframe( m, ...
                    waypoints(i-1).plotoptions, waypoint.plotoptions, fraction );
                % add frame to movie
                curframe = curframe+1;
                fprintf( 1, '%s: Recording frame %d: %d in segment %d-%d.\n', ...
                    mfilename(), curframe, fi, i-1, i );
                m = recordframe( m, img );
            end
        end
    end
    % Close the movie.
    m = closeMovie( m );
    clearstopbutton( m );


function m = closeMovie( m )
    m = leaf_movie( m, 0 );
    m.waypoints = waypoints;
end
end

function same = samemesh( wp0, wp1 )
    if ~(wp0.doclip || wp1.doclip)
        same = true;
    elseif wp0.doclip ~= wp1.doclip
        same = false;
    else
        same = false;
        % ******** Need to compare all the clipping parameters.
    end
end

function same = samecamera( ocp0, ocp1 )
    tol = 1e-8;
    same = (abs(ocp0.azimuth-ocp1.azimuth) < tol) ...
        && (abs(ocp0.elevation-ocp1.elevation) < tol) ...
        && (abs(ocp0.roll-ocp1.roll) < tol) ...
        && (abs(ocp0.fov-ocp1.fov) < tol) ...
        && (max(abs(ocp0.pan-ocp1.pan)) < tol) ...
        && (abs(ocp0.targetdistance-ocp1.targetdistance) < tol) ...
        && (abs(ocp0.camdistance-ocp1.camdistance) < tol);
end

function [m,img] = getmovieframe( m, p0, p1, fraction )
% If only m is given, grab a frame from m.
% If m and p0 are given, grab a frame using p0 as the plotting options.
% If all params are given, grab a frame with p0, grab a frame with p1, and
% mix the two according to fraction.  (Detect fraction==0 or 1 as special
% cases.)

    switch nargin
        case 1
            [m,ok,img] = leaf_snapshot( m, '-', 'hires', m.plotdefaults.hiresmovies );
        case 2
            m = leaf_plot( m, p0 );
            [m,ok,img] = leaf_snapshot( m, '-', 'hires', m.plotdefaults.hiresmovies );
        case 4
            if fraction==0
                [m,ok,img] = leaf_snapshot( m, '-', 'hires', m.plotdefaults.hiresmovies );
            elseif fraction==1
                m = leaf_plot( m, p1 );
                [m,ok,img] = leaf_snapshot( m, '-', 'hires', m.plotdefaults.hiresmovies );
            else
                p0f = mixplotoptions( p0, p1, fraction );
                p1f = mixplotoptions( p1, p0, 1-fraction );
                m = leaf_plot( m, p0f );
                [m,ok,img0] = leaf_snapshot( m, '-', 'hires', m.plotdefaults.hiresmovies );
                m = leaf_plot( m, p1f );
                img1 = leaf_snapshot( m, '-', 'hires', m.plotdefaults.hiresmovies );
                [m,ok,img1] = interpolateImages( img0, img1, fraction );
              % img.colormap = po_interp( img0.colormap, img1.colormap, fraction );
            end
    end
end

function img = interpolateImages( img0, img1, fraction )
    img.cdata = img0.cdata*(1-fraction) + img1.cdata*fraction;
    img.colormap = img0.colormap;
end

