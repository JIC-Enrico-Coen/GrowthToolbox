function [m,ok] = leaf_addwaypoint( m, varargin )
%   Add a waypoint to m.  A waypoint stores the current plotting options,
%   the simulated time, and the options given to this procedure.  The
%   waypoints are states of the mesh that form keyframes for a movie.  Once
%   all of the desired waypoints have been created, a movie can be
%   generated by leaf_waypointmovie which begins at the first waypoint
%   continues through all of them to the last.  Between waypoints
%   iterations of the simulation can be performed, the viewpoint smoothly
%   changed, plotting options can change, the plotting options themselves
%   can be smoothly interpolated between waypoints.
%
%   OPTIONS:
%
%   'name'      A name for the waypoint.  This is optional, and is only used
%               in the dialog for editing the waypoint list.
%   'frames'    The number of frames to be generated from the previous
%               waypoint to the current one, including the current but not
%               the previous.  If simulated time has elapsed since the ;ast
%               waypoint, the simulation step will be adjusted to fit.
%   'timestep'  You can spcify this instead of the number of frames, if
%               some simulated time has elapsed since the last waypoint.
%   'spin'      The number of revolutions of spin that should be performed
%               in the interval since the last waypoint.
%   'tilt'      The number of cycles of up and down tilting of the
%               viewpoint that should be performed in the interval since
%               the last waypoint.
%   'crossfade' Whether the non-interpolable plotting options should be
%               cross-faded in this segment of the movie, or be applied
%               only on the last frame.
%
%   See also leaf_waypointmovie, leaf_clearwaypoints.
%
%   Topics: Movies/Waypoints.

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'name', '', 'numframes', [], 'timestep', [], ...
            'spin', 0, 'tilt', 0, 'crossfade', 0 );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
            'name', 'frames', 'timestep', 'spin', 'tilt', 'crossfade' );
    if ~ok, return; end
    if isempty( m.waypoints )
        [m,ok] = leaf_savestage( m );
        if ~ok, return; end
        s.numframes = 0;
    elseif isempty( s.numframes )
        if isempty( s.timestep )
            s.timestep = m.globalProps.timestep;
        end
        timediff = m.globalDynamicProps.currenttime - m.waypoints(end).simtime;
        s.numframes = max( 1, round( timediff/s.timestep ) );
    end
    wp = rmfield( s, 'timestep' );
    wp.simtime = m.globalDynamicProps.currenttime;
    wp.plotoptions = m.plotdefaults;
    if isempty( m.waypoints )
        m.waypoints = wp;
    else
        m.waypoints(end+1) = wp;
    end
end
