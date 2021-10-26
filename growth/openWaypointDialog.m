function openWaypointDialog( movies, mi, wpi )
% For testing purposes, MOVIES is a struct array of movies, MI is the index
% of a movie, and wpi is the index of a waypoint of that movie.
% In production, the argument will be a mesh from which the waypoints are
% read, and the indexes will be determined...somehow.

    fig = modelessRSSSdialogFromFile('waypoints.txt');
    state = movies( mi );
    set( fig, 'Userdata', state );
    setWaypointTextItems( fig, state );
end

