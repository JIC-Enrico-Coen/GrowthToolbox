function m = leaf_perturbz( m, varargin )
%m = leaf_perturbz( m, z, ... )
%   For volumetric meshes, add a random vector to each vertex.
%   For surface meshes, add a random perturbation to the Z coordinate of
%   every vertex.
%
%   The random values are identically uniformly distrubted with mean zero.
%
%   Arguments:
%       A number z, the amplitude of the random displacement.  The
%       displacement components will be randomly chosen from the interval
%       -z/2 ... z/2.
%
%   Options:
%
%       'absolute':   A boolean.  If true, then the displacements will be
%                     interpreted as absolute values.  If false (the
%                     default), for surface meshes they will be interpreted
%                     as proportions of the thickness at each point.
%                     For volumetric meshes they will be interpreted as
%                     proportions of the minimum diameter of the bounding
%                     box.
%
%       'smoothing':  An integer.  The number of times the perturbation of
%                     each vertex will be averaged with its neighbours.
%                     Default 0.  This is not yet implemented for
%                     volumetric meshes.
%
%   Example:
%       m = leaf_perturbz( m, 0.5, 'absolute', true, 'smoothing', 2 )
%
%   Equivalent GUI operation: the "Random Z" button on the "Mesh editor"
%   panel. The amount of random deformation is specified by the value in
%   the upper of the two text boxes to the right of the button.  In the
%   GUI, 'absolute' is always assumed to be false.
%
%   Topics: Mesh editing.

    if isempty(m), return; end
    [ok1, amount, args] = getTypedArg( mfilename(), {'numeric'}, varargin );
    if ~ok1, return; end
    [s,ok] = safemakestruct( mfilename(), args );
    if ~ok, return; end
    s = defaultfields( s, 'absolute', false, 'smoothing', 0 );
    ok = checkcommandargs( mfilename(), s, 'exact', 'absolute', 'smoothing' );
    if ~ok, return; end

    m = perturbz( m, amount, s.absolute, s.smoothing );
    m.meshparams.randomness = amount;
end

