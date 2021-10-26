function m = zeroOutputs( m, numElements )
%m = zeroOutputs(m)
%   Fill in the outputs structure with zeros.
%   See also: calculateOutputs.
    m.outputs.specifiedstrain.A = zeros( numElements, 6 );
    m.outputs.specifiedstrain.B = zeros( numElements, 6 );
    m.outputs.actualstrain.A = zeros( numElements, 6 );
    m.outputs.actualstrain.B = zeros( numElements, 6 );
    m.outputs.residualstrain.A = zeros( numElements, 6 );
    m.outputs.residualstrain.B = zeros( numElements, 6 );
    m.outputs.rotations = zeros( numElements, 3 );
end
