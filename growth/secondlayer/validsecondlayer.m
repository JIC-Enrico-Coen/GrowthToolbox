function [ok,secondlayer] = validsecondlayer( secondlayer )
%[ok,m] = validsecondlayer( m )
%   Make a complete set of validity checks for the biological layer.
%
%   NEVER USED. See checkclonesvalid.m

    ok = true;
    if isempty(secondlayer)
        return;
    end
    
    % Check connectivity.
    [ok,secondlayer] = checkclonesvalid( secondlayer );
    
    secondlayer.cells = secondlayer.cells(:);
    numcells = numel( secondlayer.cells );
    numedges = size( secondlayer.edges, 1 );
    numvxs = size( secondlayer.vxFEMcell, 1 );
    
    for i=1:length(secondlayer.percellfields)
        checksizeInternal( secondlayer.percellfields{i}, 1, numcells );
    end
    for i=1:length(secondlayer.peredgefields)
        checksizeInternal( secondlayer.peredgefields{i}, 1, numedges );
    end
    for i=1:length(secondlayer.pervertexfields)
        checksizeInternal( secondlayer.pervertexfields{i}, 1, numvxs );
    end
    
    checksizeInternal( 'celldata.genindex', 1, numcells );
    checksizeInternal( 'celldata.parent', 1, numcells );
    checksizeInternal( 'celldata.values', 1, numcells );
    checksizeInternal( 'edgedata.genindex', 1, numedges );
    checksizeInternal( 'edgedata.parent', 1, numedges );
    checksizeInternal( 'edgedata.values', 1, numedges );
    checksizeInternal( 'vxdata.genindex', 1, numvxs );
    checksizeInternal( 'vxdata.parent', 1, numvxs );
    checksizeInternal( 'vxdata.values', 1, numvxs );
    checksizeInternal( 'visible.cells', 1, numcells );
    
    % Check consistency of orientation.
    
    if ok
        ev = cell(numcells,1);
        for i=1:numcells
            vv = secondlayer.cells(i).vxs;
            ev{i} = [vv; vv([2:end 1]); secondlayer.cells(i).edges]';
        end
        eev = cell2mat( ev );
        % Every edge should occur in eev either once or twice. If twice,
        % then in the opposite order.
        eevs = sortrows( eev, 3 );
        pairs = find( eevs(1:(end-1),3)==eevs(2:end,3) );
        okorientation = eevs(pairs,[1 2])==eevs(pairs+1,[2 1]);
        if any( ~okorientation(:) )
            xxxx = 1;
        end
        
        xxxx = 1;
        
    end

    function checksizeInternal( field, dim, expectedsize, data )
        [v,ok1] = getDeepField( secondlayer, field );
        if ok1
            if nargin < 4
                actualsize = size( v, dim );
            else
                actualsize = size( data, dim );
            end
            if actualsize ~= expectedsize
                fprintf( 1, '** Bio layer field %s expected size %d in dimension %d, found size %d.\n', ...
                    field, expectedsize, dim, actualsize );
                ok = false;
            end
        else
            fprintf( 1, '** Bio layer field %s missing.\n', field );
            ok = ok1;
        end
    end
end

%                     cells: [22x1 struct]
%                     edges: [63x4 int32]
%       customcellcolorinfo: [1x1 struct]
%             cellcolorinfo: [0x0 struct]
%     indexededgeproperties: [1x1 struct]
%             percellfields: {1x9 cell}
%             peredgefields: {'edges'  'interiorborder'  'generation'  'edgepropertyindex'}
%           pervertexfields: {'vxFEMcell'  'vxBaryCoords'  'cell3dcoords'}
%                  celldata: [1x1 struct]
%                  edgedata: [1x1 struct]
%                    vxdata: [1x1 struct]
