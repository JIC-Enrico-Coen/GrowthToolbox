function gfe = resultantDirectedGrowthPerFE( m, dir, type, fes )
%gfe = resultantDirectedGrowthPerFE( m, dir, type, fes )
%   Calculate the projections of various growth tensors of a mesh M onto a
%   specified direction.
%
%   DIR is a 3-element vector specifying a direction.  It must be non-zero
%   but need not be normalised.
%
%   TYPE is either 'actual', 'specified', or 'residual'.  Anything else
%   makes this procedure return an empty array.
%
%   FES specifies which finite element the growth is to be computed for.
%   By default it is all of them.
%
%   The result is a column vector of growth rates, one per finite element
%   asked for.
%
%   See also: projectTensorsToDirections.

    switch type
        case { 'actual', 'specified', 'residual' }
            fn = [ type 'strain' ];
            numvals = size(m.outputs.(fn).A,1);
            if nargin < 4
                fes = 1:numvals;
            end
            gfe = (projectTensorsToDirection( dir, m.outputs.(fn).A( fes, : ) ) ...
                  + projectTensorsToDirection( dir, m.outputs.(fn).B( fes, : ) )) * 0.5;
        otherwise
            gfe = [];
    end
end

