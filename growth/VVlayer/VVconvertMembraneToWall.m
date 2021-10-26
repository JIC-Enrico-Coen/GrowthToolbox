function vvmgen1 = VVconvertMembraneToWall( vvlayer, vvmgen )
%vvmgen1 = VVconvertMembraneToWall( vvlayer, vvmgen )
%   vvmgen is a membrane morphogen.
%   vvmgen1 is a wall morphogen, whose value at each wall vertex
%   is the sum of those at the adjacent (one or two) membrane vertexes.

    vvmgen1 = zeros(size(vvlayer.mgenW,1),1);
    for i=1:length(vvmgen)
        wi = vvlayer.edgeWM(i,1);
        mi = vvlayer.edgeWM(i,2);
        vvmgen1(wi) = vvmgen1(wi) + vvmgen(mi);
    end
end
