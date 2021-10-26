function vvlayer = addVVmgen( vvlayer, varargin )
%vvlayer = addVVmgen( vvlayer, name1, name2, ... )
%   Add VV morphogens.  If a morphogen already exists of a given name, a
%   new one will not be created.

    newmgens = setdiff( varargin, vvlayer.mgendict.indexToName );
    curNumMgens = length( vvlayer.mgendict.indexToName );
    vvlayer.mgendict.indexToName = { vvlayer.mgendict.indexToName{:}, newmgens{:} };
    
    for i=1:length(newmgens)
        vvlayer.mgendict.nameToIndex.(newmgens{i}) = curNumMgens+i;
    end
    vvlayer.mgens = [ vvlayer.mgens, zeros( size(vvlayer.mgens,1), length(newmgens) ) ];
    vvlayer.mgenC = [ vvlayer.mgenC, zeros( size(vvlayer.mgenC,1), length(newmgens) ) ];
    vvlayer.mgenW = [ vvlayer.mgenW, zeros( size(vvlayer.mgenW,1), length(newmgens) ) ];
    vvlayer.mgenM = [ vvlayer.mgenM, zeros( size(vvlayer.mgenM,1), length(newmgens) ) ];
end

