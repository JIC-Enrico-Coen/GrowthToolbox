function dirbc = streamlineLocalDirection( m, s )
%dirbc = streamlineLocalDirection( m, s )
%   Calculate the streamline's barycentric direction from its global
%   direction and the coordinates of the vertexes of its final element.

    trivxs = m.nodes( m.tricellvxs(s.vxcellindex(end),:), : );
    dirbc = vec2bc( s.directionglobal, trivxs );
end
