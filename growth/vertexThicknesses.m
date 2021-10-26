function vt = vertexThicknesses( m )
%vt = vertexThicknesses( m )
%   Calculate the thickness of m at every vertex.  The result is an N*1
%   array, where N is the number of vertexes of the finite element mesh.
%
%   SEE ALSO: setVertexThicknesses

    vt = sqrt(sum( (m.prismnodes(2:2:end,:) - m.prismnodes(1:2:end,:)).^2, 2 ));
end
