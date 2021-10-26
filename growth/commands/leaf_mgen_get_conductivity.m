function c = leaf_mgen_get_conductivity( m, morphogens )
%c = leaf_mgen_get_conductivity( m, morphogens )
%   Return the rate at which a specified morphogen diffuses through the leaf.
%   Arguments:
%   morphogens: The name or index of a morphogen, or a cell array or
%               numeric array of morphogens.
%
%   The result is a struct array with one element for each morphogen
%   requested.  The fields of each struct will be Dpar and Dper, each of
%   which will be either a single number or an array or numbers, one per
%   finite element.  Dper may also be empty.  These are the diffusion
%   constants of the morphogen parallel or perpendicular to the polariser
%   gradient.  A single number imples a constant value over the whole mesh.
%   An empty array for Dper implies that it is everywhere identical to
%   Dpar.  An empty array for Dpar implies that it is everywhere zero.
%
%   Example:
%       c = leaf_mgen_get_conductivity( m, {'foo','bar'} );
%   c will be a struct array of length two.
%
%   Topics: Morphogens.

    if isempty(m), return; end
    if isempty(varargin), return; end
    
    g = FindMorphogenIndex( m, morphogens, mfilename() );
    c = m.conductivity(g);
end
