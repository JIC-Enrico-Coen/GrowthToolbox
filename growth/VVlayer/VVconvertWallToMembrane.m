function vvmgen1 = VVconvertWallToMembrane( vvlayer, vvmgen )
%vvmgen1 = VVconvertWallToMembrane( vvlayer, vvmgen )
%   vvmgen is a wall morphogen.
%   vvmgen1 is a membrane morphogen, whose value at each membrane vertex
%   is equal to that at the adjacent wall vertex.

    vvmgen1 = zeros(size(vvlayer.mgenM,1),1);
    vvmgen1(vvlayer.edgeWM(:,2)) = vvmgen( vvlayer.edgeWM(:,1) );
end
