function dir = streamlineGlobalDirection( m, s )
%dir = streamlineGlobalDirection( m, s )
%   Calculate the streamline's global dirwection from its barycentric
%   direction and the coordinates of the vertexes of its final element.

    dir = s.directionbc * m.nodes( m.tricellvxs(s.vxcellindex(end),:), : );
    dir = dir/norm(dir);
end
