function vvmgen1 = VVgetOtherSide( m, vvmgen )
%vvmgen1 = VVgetOtherSide( m, vvmgen )
%   vvmgen is a membrane morphogen.
%   Where membrane vertexes i and j are on opposite sides of a wall,
%   vvmgen1 has those two values swapped.
%   Where membrane vertex i is at a border, so has no counterpart on the
%   other side, vvmgen1(i) is zero.

    vvmgen1 = zeros(size(vvmgen));
    vvmgen1( m.secondlayer.vvlayer.edgeMWM ) = vvmgen( m.secondlayer.vvlayer.edgeMWM(:,[2 1]) );
end
