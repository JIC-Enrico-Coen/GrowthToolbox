function [values,components,frames,selectedCpts] = getMeshTensorValues( m, oq, oa, cf )
%[values,components,frames,selectedCpts] = getMeshTensorValues( m, oq, oa, cf )
%   Calculate the tensor values specified by oq (name of an output
%   quantity), oa (set of axes), and cf (cell frames).
%
%   If the mesh has N elements, the sizes of the results are:
%
%   values: N*1
%   components: N*3
%   frames: 3*3*N
%   selectedCpts: 1*1
%
%   The columns of frames(:,:,i) are the principal axes of the i'th tensor.

%     values = zeros( size(cf,3), 1 );
    values = zeros( getNumberOfFEs(m), 1 );
    oq = regexprep( oq, 'growth', 'strain' );
    oq = regexprep( oq, 'resultant', 'actual' );
    xx = regexp( oq, '^(?<type>actual|specified|residual)(?<quantity>strain|stress|relativeanisotropy|anisotropy|bend|rotation)(?<rate>rate|)(?<side>A|B|)$', 'names' );
    if isempty(xx)
        % Error -- oq should always match that expression.
        return;
    end
    
    isrelaniso = strcmp( xx.quantity, 'relativeanisotropy' );
    isaniso = isrelaniso | strcmp( xx.quantity, 'anisotropy' );
    isstress = strcmp( xx.quantity, 'stress' );
    israte = strcmp( xx.rate, 'rate' );
    isbend = strcmp( xx.quantity, 'bend' );
    if isbend
        % Bend is inherently a quantity that depends on both sides,
        % therefore any specification of a single side is ignored.
        xx.side = '';
    end
    
    outputfield = [ xx.type 'strain' xx.side ];
    
    
    if ~isfield( m.outputs, outputfield )
        % Data to be plotted is not present.
        return;
    end
    polAligned = true; % ~isaniso && (strcmp(oa,'parallel') || strcmp(oa,'perpendicular') || strcmp(oa,'normal') || strcmp(oa,'areal'));
    [components,frames] = getCpts( m.outputs.(outputfield), isbend, xx.side, polAligned );
    if ~israte && (m.globalProps.timestep > 0)
        components = components*m.globalProps.timestep;
    end
    if isstress  % TESTING!! In production this should be "if isstress".
        components = components .* m.cellbulkmodulus;
    end
    selectedCpts = [];
    if isaniso
        values = components(:,1) - components(:,2);
        if isrelaniso
            magnitudes = sum( abs( components(:,[1 2]) ), 2 );
            values = values ./ magnitudes;
            values(isnan(values)) = 0;
        end
    else
        switch oa
            case {'','total'}
                selectedCpts = 1:size(components,2);
                values = sum( components(:,selectedCpts), 2 );
            case 'areal'
                selectedCpts = [1 2];
                values = sum( components(:,selectedCpts), 2 );
            case 'parallel'
                selectedCpts = 1;
                values = components(:,selectedCpts);
            case 'major+'
                values = max( components(:,[1 2]), [], 2 );
            case 'major'
                [values,selectedCpts] = max( abs(components(:,[1 2])), [], 2 );
            case 'perpendicular'
                selectedCpts = 2;
                values = components(:,selectedCpts);
            case 'minor+'
                selectedCpts = 2;
                values = components(:,selectedCpts);
            case 'minor'
                [values,selectedCpts] = min( abs(components(:,[1 2])), [], 2 );
            case 'normal'
                selectedCpts = 3;
                values = sum( components(:,selectedCpts), 2 );
        end
    end
    
    function [components,frames] = getCpts( tensors, bend, tensorside, polAligned )
        if bend
            if isstruct(tensors)
                tensors = (tensors.A-tensors.B)/2;
            else
                % Volumetric mesh.  No such thing as bend, so return zeros.
                tensors = zeros(size(tensors));
            end
        elseif isstruct(tensors)
            switch tensorside
                case 'A'
                    tensors = tensors.A;
                case 'B'
                    tensors = tensors.B;
                otherwise
                    tensors = (tensors.A+tensors.B)/2;
            end
        end
        fn_cellFramesField = ['cellFrames', tensorside];
        if polAligned
            [components,frames] = tensorsToComponents( tensors, m.(fn_cellFramesField) );
        else
            [components,frames] = tensorsToComponents( tensors );
        end
    end
end
 
