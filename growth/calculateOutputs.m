function m = calculateOutputs( m )
%m = calculateOutputs( m )
%   Calculate all of the tensors for specified/actual/residual growth on
%   the A/B sides, and the rotations.  This creates the following
%   components of m:
%
%     m.outputs.specifiedstrain.A
%     m.outputs.specifiedstrain.B
%     m.outputs.actualstrain.A
%     m.outputs.actualstrain.B
%     m.outputs.residualstrain.A
%     m.outputs.residualstrain.B
%     m.outputs.rotation
%
%   Each of these is a per-FE quantity.  If there are N finite elements,
%   then the tensor fields are N*6 and the rotations field is N*3.  These
%   are all rates of growth or rotation, not absolute amounts.
%
%   Take the average of an A and a B quantity to get the value for the
%   midplane; take half of B-A to get the bending component.
%
%   To convert tensors to principal components, write for example:
%       [amounts,frames] = tensorsToComponents( m.outputs.actualstrain.A );
%   amounts will then be the principal components of actual growth on the
%   A side, listed in descending order.  If you want them listed in the
%   order parallel, perpendicular, and normal, replace the second line by:
%       [amounts,frames] = tensorsToComponents( m.outputs.actualstrain.A, m.cellFrames );
%
%   To resolve rotation vectors into rotation about the normal vector and
%   the remainder, write:
%
%       [inplane,outofplane] = splitVector( m.outputs.rotations, m.unitcellnormals );
%
%   inplane will be a column of scalars, the rotation rates around the
%   normal vectors, and outofplane will be an N*3 matrix of vectors in the
%   planes of the respective finite elements.
%
%   To convert any per-element quantity to a per-vertex quantity, call:
%
%       perVxQuantity = perFEtoperVertex( m, perFEquantity );
%
%   The per-element quantity can be an N*K matrix, where N is the number of
%   finite elements.  perVxQuantity will then be M*K where M is the number
%   of vertices.

    V = getNumVxsPerFE(m);
    T = getComponentsPerSymmetricTensor();
    Q = getNumQuadPointsPerFE(m);
    F = getNumberOfFEs(m);
    allgrowthtensors = zeros( T, V, F );
    if m.globalProps.useGrowthTensors
        allgrowthtensors = allgrowthtensors + ...
            reshape( ...
                repmat( [m.celldata.cellThermExpGlobalTensor], ...
                        V/size(m.celldata(1).cellThermExpGlobalTensor,2), 1 ),...
                        T, V, F );
        if ~isempty(m.directGrowthTensors)
            allgrowthtensors = allgrowthtensors + reshape( repmat( m.directGrowthTensors', V, 1 ), T, V, F );
        end
    end
    haveCelldata = isfield( m, 'celldata' ) && ~isempty(m.celldata) && isfield( m.celldata, 'Gglobal' ) &&  ~isempty(m.celldata(1).Gglobal);
    if m.globalProps.useMorphogens && haveCelldata
        allgrowthtensors = allgrowthtensors + ...
                           permute( ...
                               reshape( [m.celldata.Gglobal], V, T, F), ...
                               [2 1 3] ...
                           );
    end
    
    if usesNewFEs(m)
        m.outputs.specifiedstrain = permute( sum( allgrowthtensors, 2 )/V, [3 1 2] );   % F*T
        m.outputs.actualstrain = averagestrains( 'displacementStrain' );
        m.outputs.residualstrain = averagestrains( 'residualStrain' );
    else
        % A and B sides are only valid for old-style meshes.
        m.outputs.specifiedstrain = struct( 'A', permute( sum( allgrowthtensors(:,1:3,:), 2 )/3, [3 1 2] ), ...
                                            'B', permute( sum( allgrowthtensors(:,4:6,:), 2 )/3, [3 1 2] ) ); 
        [A,B] = split6strains( 'displacementStrain' );
        m.outputs.actualstrain = struct( 'A', A, 'B', B );
        [A,B] = split6strains( 'residualStrain' );
        m.outputs.residualstrain = struct( 'A', A, 'B', B );
    end
    
    % For large meshes, rotations are expensive to compute.  The only thing
    % we use them for is plotting, and only if the drawrotations option is
    % on.  Therefore we do not calculate them here, but in leaf_plot if
    % demanded.
    m.outputs.rotations = getRotations( m, 'total' );
%     m.outputs.rotations = zeros( 0, 3 );

function A = averagestrains( f )
    if haveCelldata
        data = [m.celldata.(f)];
        if isempty(data)
            A = zeros( F, T );
        else
            alltensors = reshape( [m.celldata.(f)], T, Q, F )/m.globalProps.timestep;
            A = permute( sum( alltensors, 2 )/Q, [3 1 2] );
        end
    else
        A = zeros( F, T );
    end
end

function [A,B] = split6strains( f ) % [m.celldata.(f)] is T*(V*F)
    alltensors = reshape( [m.celldata.(f)], T, V, F )/m.globalProps.timestep;
    A = permute( sum( alltensors(:,1:3,:), 2 )/3, [3 1 2] ); 
    B = permute( sum( alltensors(:,4:6,:), 2 )/3, [3 1 2] ); 
end
end

