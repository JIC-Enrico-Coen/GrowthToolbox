function useNewFEs( use )
%useNewFEs( use )
%   USE is a boolean, to say whether computations on foliate meshes should
%   be carried out with the legacy FEs, or with the new implementation of
%   the same type of FEs (i.e. first-order pentahedra for elasticity and
%   first-order triangles for diffusion).  Both methods should carry out
%   identical computations, up to rounding error resulting from the
%   computations being reordered.
%
%   This sets two global variables, which immediately affect all
%   computations performed on legacy meshes, for the remainder of the
%   Matlab session.

    global gUSENEWFES_ELAST gUSENEWFES_DIFFUSE
    gUSENEWFES_ELAST = use;
    gUSENEWFES_DIFFUSE = use;
end
