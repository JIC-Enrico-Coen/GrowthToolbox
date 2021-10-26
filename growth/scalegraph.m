function mesh = scalegraph(mesh,scale)
%MESH = SCALEGRAPH(MESH,SCALE)  Scale a mesh by a real number.
    mesh.nodes = mesh.nodes * scale;
    mesh.prismnodes = mesh.prismnodes * scale;
end
