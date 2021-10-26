function m = leaf_setmorphogenrole( m, varargin )
% m = leaf_setmorphogenrole( m, role1, morphogen1, role2, morphogen2, ... )
%
%   Use morphogen1 for role1, morphogen2 for role2, etc.
%   Currently valid roles are:
%
%   KAPAR:  The growth rate in the principal direction of growth on the A
%           side.  (Surface meshes only.)
%   KAPER:  The growth rate perpendicular to the principal direction of
%           growth on the A side.  (Surface meshes only.)
%   KBPAR:  The growth rate in the principal direction of growth on the B
%           side.  (Surface meshes only.)
%   KBPER:  The growth rate perpendicular to the principal direction of
%           growth on the B side.  (Surface meshes only.)
%   POLARISER: The morphogen whose gradient defines the principal direction
%           of growth.  (Surface meshes only.)
%   KPAR:   The growth rate in the first principal direction of growth.
%           (Volumetric meshes only.) 
%   KPAR2:  The growth rate in the second principal direction of growth.
%           (Volumetric meshes only.) 
%   POL:    The morphogen whose gradient defines the first principal
%           direction of growth. (Volumetric meshes only.)
%   POL2:   The morphogen whose gradient defines the second principal
%           direction of growth. (Volumetric meshes only.)
%   KNOR:   For surface meshes, the growth rate perpendicular to the
%           surface.  For volumetric meshes, the growth rate perpendicular
%           to both the principal directions.
%   STRAINRET: The amount of strain retention. (Surface and volumetric
%           meshes.)
%   ARREST: The morphogen that arrests cell division in the biological
%           layer.  (Surface meshes only.)
%
%   If zero is specified for a morphogen, or the name of a morphogen that
%   does not exist, then the corresponding role will be removed.
%
%   If the same role appears multiple times in the arguments, only the last
%   occurrence will be effective.
%
%   Role names are arbitrary, but are primarily intended to be roles that
%   GFtbox knows about.

    roles = varargin(1:2:(end-1));
    mgenIndexes = FindMorphogenIndex2( m, varargin(2:2:end) );
    m.roleNameToMgenIndex = setrole( m.roleNameToMgenIndex, roles, mgenIndexes );
end
