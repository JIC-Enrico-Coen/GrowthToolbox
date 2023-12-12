function [result,m] = validmesh(m,verbose,fatalerrors,warningsareerrors)
%RESULT = VALIDMESH(M,VERBOSE,ALLERRORS)  Determines whether the mesh is valid.
%  All the connectivity information is checked for consistency.
%  Triangles with very small angles are detected.
%  The morphogen array must be the right size.
%  If VERBOSE is true (default false), messages will be printed to the
%  command window in case of flaws.
%  If FATALERRORS is true (default false) then warnings will be treated as
%  errors.
%  If ALLERRORS is true (default false) then warnings will be treated as
%  errors.
%  RESULT will be FALSE if the mesh has fatal errors in it.

if isempty(m), result = 0; return; end

if (nargin < 2) || isempty(verbose)
    verbose = false;
end
if (nargin < 3) || isempty(fatalerrors)
    fatalerrors = false;
end
if (nargin < 4) || isempty(warningsareerrors)
    warningsareerrors = false;
end

errorseverity = [0 0 0];
if fatalerrors
    errorseverity(3) = 2;
end
if warningsareerrors
    errorseverity(1) = errorseverity(2);
end

result = true;
if isfield( m, 'globalProps' ) ...
        && isfield( m.globalProps, 'validateMesh' ) ...
        && ~m.globalProps.validateMesh
    return;
end

timedFprintf( 1, 'Checking mesh validity.\n' );


full3d = usesNewFEs( m );
numnodes = getNumberOfVertexes(m);
if full3d
    numallnodes = numnodes;
else
    numallnodes = numnodes*2;
end
numedges = getNumberOfEdges( m );
numelements = getNumberOfFEs(m);
cptsPerTensor = getComponentsPerSymmetricTensor();

setGlobals();
global gDYNAMICFIELDS gSTATICFIELDS gHYBRIDFIELDS gUNSAVEDFIELDS gTRANSIENTFIELDS
global gFOLIATEONLYFIELDS gVOLUMETRICONLYFIELDS
[ok,missingfields,extrafields] = checkFields( m, ...
    [ gDYNAMICFIELDS gSTATICFIELDS gHYBRIDFIELDS gUNSAVEDFIELDS ], ...
    gTRANSIENTFIELDS);
if full3d
    missingfields = setdiff( missingfields, gFOLIATEONLYFIELDS );
else
    missingfields = setdiff( missingfields, gVOLUMETRICONLYFIELDS );
end
if ~isempty(missingfields)
    complain2( errorseverity(1), 'Mesh has missing fields:' );
    for ci=1:length(missingfields)
        fprintf( 1, '    %s\n', missingfields{ci} );
    end
end
if ~isempty(extrafields)
    complain2( errorseverity(1), 'Mesh has extra fields:' );
    for ci=1:length(extrafields)
        fprintf( 1, '\n    %s', extrafields{ci} );
    end
    fprintf( 1, '\n' );
end

if ~checknumel( m, 'celldata', numelements )
    result = 0;
end

if full3d
    havefields = isfield( m.FEconnectivity, { 'allfevxs'
                                 'nzallfevxs'
                                 'numfevxs'
                                 'fetypes'
                                 'feedges'
                                 'fefaces'
                                 'faces'
                                 'facefes'
                                 'facefeparity'
                                 'facefefaces'
                                 'facefevxs'
                                 'numfacevxs'
                                 'faceedges'
                                 'edgefaces'
                                 'faceloctype'
                                 'edgeends'
                                 'edgeloctype'
                                 'vertexloctype' } );
    if ~all(havefields)
        m.FEconnectivity = connectivity3D( m );
    end
    [ok,errs] = checkConnectivityNewMesh( m );
else
    [ok,m] = checkConnectivityOldMesh( m );
end

% The angles of each FEM element should not be very small or very close to
% 180 degrees.
ANGLE_THRESHOLD = m.globalProps.mincellangle/4;  % 4 is a fudge factor.
if full3d
    timedFprintf( 1, 'Checking angle quality for general FEs is not yet supported.\n' );
else
    alltriangles = permute( reshape( m.nodes( m.tricellvxs', : ), 3, [], 3 ), [1 3 2] );
    allAngles = trianglesAngles( alltriangles );
    badAngles = allAngles < ANGLE_THRESHOLD;
    if any(badAngles(:))
        complain2( errorseverity(1), ...
            'There are %d very small angles (below %f radians), smallest is %.3g radians.', ...
            sum(badAngles(:)), ANGLE_THRESHOLD, min(abs(allAngles(:))) );
        if false
            for ci=1:nf
                if any( badAngles(:,ci) )
                    fprintf( 1, 'Cell %d has angles [%f %f %f], threshold %f.\n', ...
                        ci, allAngles(:,ci), ANGLE_THRESHOLD );
                    fprintf( 1, '    %8f   %8f   %8f\n', alltriangles(1,:,ci) );
                    fprintf( 1, '    %8f   %8f   %8f\n', alltriangles(2,:,ci) );
                    fprintf( 1, '    %8f   %8f   %8f\n', alltriangles(3,:,ci) );
                end
            end
        end
    end
end

% The morphogens must be defined per vertex.
if isfield(m,'morphogens') && (size(m.morphogens,1) ~= numnodes)
    result = 0;
    complain2( errorseverity(1), ...
        'Morphogens are defined for %d nodes, but the mesh has %d nodes.', ...
        size(m.morphogens,1), numnodes );
    delta = size(m.morphogens,1) - numnodes;
    if delta > 0
        m.morphogens = m.morphogens( 1:numnodes, 1:size( m.morphogens, 2 ) );
    else
        m.morphogens = [ m.morphogens ; zeros( -delta, size( m.morphogens, 2 ) ) ];
    end
end

% Check that cellstiffness is the right size.
cssize = size(m.cellstiffness);
if length(cssize) < 3
    cssize((end+1):3) = 1;
end
if ~samesize(cssize, [cptsPerTensor cptsPerTensor numelements])
    complain2( errorseverity(1), ...
        'cellstiffness has size [%d %d %d], expected [%d %d %d]\n', ...
        cssize(1), cssize(2), cssize(3), cptsPerTensor, cptsPerTensor, numelements );
    if all(cssize([1 2])==[cptsPerTensor cptsPerTensor])
        if cssize(3) > numelements
            m.cellstiffness = m.cellstiffness(:,:,1:numelements);
        else
            m.cellstiffness(:,:,(end+1):numelements) = ...
                repmat( sum( m.cellstiffness, 3 )/cssize(3), [1, 1, numelements-cssize(3)] );
        end
    else
        ok = false;
    end
end

if isfield( m, 'sharpvxs' ) && ~isempty( m.sharpvxs ) && ~samesize(size(m.sharpvxs), [numnodes 1])
    complain2( errorseverity(1), ...
        'sharpvxs has size [%d %d], expected [%d %d]\n', ...
        size(m.sharpvxs,1), size(m.sharpvxs,2), numnodes, 1 );
    if size(m.sharpvxs,1) > numnodes
        m.sharpvxs = m.sharpvxs(1:numnodes,1);
    else
        m.sharpvxs((end+1):numnodes,1) = false;
    end
end

% Disabled for the moment. 2022-01-25
if false && isfield( m, 'sharpedges' ) && ~isempty( m.sharpedges ) && ~samesize(size(m.sharpedges), [numedges 1])
    complain2( errorseverity(1), ...
        'sharpedges has size [%d %d], expected [%d %d]\n', ...
        size(m.sharpedges,1), size(m.sharpedges,2), numedges, 1 );
    if size(m.sharpedges,1) > numedges
        m.sharpedges = m.sharpedges(1:numedges);
    else
        m.sharpedges((end+1):numedges) = false;
    end
end


    
% Check that cellbulkmodulus is the right size.
cbmsize = length(m.cellbulkmodulus);
if cbmsize ~= numelements
    complain2( errorseverity(1), ...
        'cellbulkmodulus has size %d, expected %d\n', ...
        cbmsize, numelements );
    if cbmsize > numelements
        m.cellbulkmodulus = m.cellbulkmodulus(1:numelements);
    else
        m.cellbulkmodulus(:,:,(end+1):numelements) = sum( m.cellbulkmodulus )/numelements;
    end
end
    
% Check that cellpoisson is the right size.
cpsize = length(m.cellpoisson);
if cpsize ~= numelements
    complain2( errorseverity(1), ...
        'cellpoisson has size %d, expected %d\n', ...
        cpsize, numelements );
    if cpsize > numelements
        m.cellpoisson = m.cellbulkmodulus(1:numelements);
    else
        m.cellpoisson(:,:,(end+1):numelements) = sum( m.cellpoisson )/numelements;
    end
end

% Check that no two vertexes are in the same place.
    if false % No, don't bother.
        if verbose
            mul2 = 1.1234;
            mul3 = pi;
            vxhash = m.nodes(:,1) + mul2*m.nodes(:,2) + mul3*m.nodes(:,3);
            [vxsort,sortperm] = sort(vxhash);
            comparevxs = find( vxsort(1:(end-1)) == vxsort(2:end) );
            for i=1:length(comparevxs)-1
                vx1 = sortperm(comparevxs(i));
                vx2 = sortperm(comparevxs(i+1));
                fprintf( 1, 'Vertexes %d and %d appear to be in the same place:\n', ...
                    vx1, vx2 );
                fprintf( 1, '    [%.3f,%.3f,%.3f]    [%.3f,%.3f,%.3f]\n', ...
                    m.nodes(vx1,:), m.nodes(vx2,:) );
            end
        end
    end
    
% If the prism nodes are valid, check there are the right number.
    if m.globalProps.prismnodesvalid && ~isVolumetricMesh(m)
        if size(m.prismnodes,1) ~= size(m.nodes,1)*2
            result = 0;
            complain2( errorseverity(2), ...
                'Wrong number of prism nodes: %d, expected twice %d.', ...
                size(m.prismnodes,1), size(m.nodes,1) );
        end
    end
    
    
    if (~isempty(m.displacements)) && ~checkheight( m, 'displacements', getTotalNumberOfVertexes(m) )
        result = 0;
    end
    if (~isempty(m.effectiveGrowthTensor)) && ~checkheight( m, 'effectiveGrowthTensor', getNumberOfFEs( m ) )
        m.effectiveGrowthTensor = procrustesHeight( m.effectiveGrowthTensor, getNumberOfFEs( m ), 0 );
        result = 0;
    end
    if ~isempty( m.directGrowthTensors ) ...
            && ~checksize( [numelements,cptsPerTensor], size(m.directGrowthTensors), 'directGrowthTensors' )
     result = 0;
    end

  
    if ~checkheight( m, 'fixedDFmap', numallnodes )
        result = 0;
    end
    
% Validate the edge/cell chains.
  % ok = validateChains(m);
  % result = result && ok;
    
% Validate the seams
    if isVolumetricMesh(m)
        % For volumetric meshes, seams will be reimplemented.  This has not
        % yet been done.
    elseif length(m.seams) ~= size(m.edgeends,1)
        complain2( errorseverity(1), ...
            'Seams bitmap has %d elements but there are %d edges.', ...
            length(m.seams), size(m.edgeends,1) );
    end
    
% Validate the second layer.
    badvxFEMcell = find( ...
        (m.secondlayer.vxFEMcell > numelements)...
        | (m.secondlayer.vxFEMcell <= 0) );
    if ~isempty(badvxFEMcell)
        result = 0;
        complain2( errorseverity(2), ...
            '%d invalid values found in secondlayer.vxFEMcell.', ...
            length(badvxFEMcell) );
        fprintf( 1, ' %d', badvxFEMcell );
        fprintf( 1, '\n' );
        fprintf( 1, ' %d', m.secondlayer.vxFEMcell(badvxFEMcell) );
        fprintf( 1, '\n' );
    end

    [ok,m.secondlayer] = checkclonesvalid( m.secondlayer );
% ok = validateLineage( m ) && ok;  % DOESN'T WORK BECAUSE SOME
% LINEAGE DATA ISN'T BEING UPDATED PROPERLY.
    
% Check that there is the right amount of other 3D data.
    if ~full3d
        result = checksize( numelements, length(m.cellareas), 'cellareas' ) && result;
        result = checksize( numelements, size(m.unitcellnormals,1), 'unitcellnormals' ) && result;
        numedges = size(m.edgeends,1);
        result = checksize( numedges, length(m.currentbendangle), 'currentbendangle' ) && result;
        result = checksize( numedges, length(m.initialbendangle), 'initialbendangle' ) && result;
        if isfield( m, 'vertexnormals' ) && ~isempty( m.vertexnormals )
            if full3d
                complain2( errorseverity(1), ...
                    'vertexnormals should not exist in foliate meshes' );
                m.vertexnormals = [];
            else
                result = checksize( size(m.nodes), size(m.vertexnormals), 'vertexnormals' ) && result;
                if ~result
                    m.vertexnormals = [];
                end
            end
        end
    end
    if ~isempty(m.displacements)
        result = checksize( numallnodes, size(m.displacements,1), 'displacements' ) && result;
    end
    % Check that m.conductivity is the right size.
    if length(m.conductivity) ~= size(m.morphogens,2)
        complain2( errorseverity(1), ...
            'conductivity has length %d, expected %d\n', ...
            length(m.conductivity), size(m.morphogens,2) );
    else
        % Check that each member of m.conductivity is the right size.
        for ci=1:length(m.conductivity)
            nDpar = length(m.conductivity(ci).Dpar);
            nDper = length(m.conductivity(ci).Dper);
            if (nDpar > 1) && (nDpar ~= numelements)
                if nDpar==numnodes
                    m.conductivity(ci).Dpar = perVertextoperFE( m, m.conductivity(ci).Dpar );
                    complain2( errorseverity(1), ...
                        'Dpar %d was per-vertex, converted to per-element\n', ci );
                else
                    complain2( errorseverity(1), ...
                        'Dpar %d has length %d, expected %d\n', ...
                        ci, nDpar, numelements );
                end
            end
            if (nDper > 1) && (nDper ~= numelements)
                if nDper==numnodes
                    m.conductivity(ci).Dper = perVertextoperFE( m, m.conductivity(ci).Dper );
                    complain2( errorseverity(1), ...
                        'Dper %d was per-vertex, converted to per-element\n', ci );
                else
                    complain2( errorseverity(1), ...
                        'Dper %d has length %d, expected %d\n', ...
                        ci, nDper, numelements );
                end
            end
        end
    end
    

    numpol = size(m.gradpolgrowth,3);
    okpol = true;
    okpol = checksize( [numelements,3,numpol], size(m.gradpolgrowth), 'gradpolgrowth' ) && okpol;
    if full3d
        okpol = checksize( size(m.FEsets(1).fevxs), size(m.polfreeze), 'polfreeze' ) && okpol;
    else
        okpol = checksize( [numelements,3,numpol], size(m.polfreeze), 'polfreeze' ) && okpol;
        okpol = checksize( [numelements,3,numpol], size(m.polfreezebc), 'polfreezebc' ) && okpol;
    end
    okpol = checksize( [numelements,numpol], size(m.polfrozen), 'polfrozen' ) && okpol;
    if size(m.polsetfrozen,1) > 1
        okpol = checksize( [numelements,numpol], size(m.polsetfrozen), 'polsetfrozen' ) && okpol;
    end
    if ~okpol
        complain2( errorseverity(1), 'Polariser gradient errors fixed.' );
        m = calcPolGrad( m );
        result = false;
    end
    
    if ~isempty( m.growthanglepervertex )
        result = checksize( numnodes, size(m.growthanglepervertex,1), 'growthanglepervertex' ) && result;
    end
    if ~isempty( m.growthangleperFE )
        result = checksize( numelements, size(m.growthangleperFE,1), 'growthangleperFE' ) && result;
    end
    if ~isempty( m.decorFEs )
        if length(m.decorFEs) ~= size(m.decorBCs,1)
            complain2( errorseverity(1), ...
                'length(m.decorFEs) = %d but size(m.decorBCs,1) = %d.', ...
                length(m.decorFEs), size(m.decorBCs,1) );
            m.decorFEs = [];
            m.decorBCs = [];
        end
        if any(m.decorFEs > numelements)
            complain2( errorseverity(1), ...
                '%d values in m.decorFEs refer to non-existent FEs.', sum(m.decorFEs > numelements) );
            m.decorFEs = [];
            m.decorBCs = [];
        end
        if any(m.decorFEs < 1)
            complain2( errorseverity(1), ...
                '%d values in m.decorFEs refer to invalid FEs.', sum(m.decorFEs < 1) );
            m.decorFEs = [];
            m.decorBCs = [];
        end
    end

% Check the per-morphogen data.
    numMorphogens = size( m.morphogens, 2 );
    global gPerMgenDefaults
    fns = fieldnames( gPerMgenDefaults );
    for ci=1:length(fns)
        fn = fns{ci};
        numfound = size(m.(fn),2);
        if numfound > numMorphogens
            complain2( errorseverity(1), ...
                '%d extra columns found in %s.', ...
                numfound - numMorphogens, fn );
            x = m.(fn);
            m.(fn) = x(:,1:numMorphogens);
        elseif numfound < numMorphogens
            complain2( errorseverity(1), ...
                '%d missing columns found in %s.', ...
                numMorphogens - numfound, fn );
            m.(fn) = [ m.(fn), ...
                       repmat( gPerMgenDefaults.(fn), 1, numMorphogens - numfound ) ];
        end
    end
    
    numIndexedMgens = length(m.mgenIndexToName);
    if numIndexedMgens < numMorphogens
        % Well, fuck.
        complain2( errorseverity(1), ...
            '%d unnamed morphogens found in mgenIndexToName.', ...
            numMorphogens - numIndexedMgens );
        for ci=(numIndexedMgens+1):numMorphogens
            m.mgenIndexToName{ci} = sprintf( 'UNK_%03d', ci );
        end
        m.mgenNameToIndex = invertNameArray( m.mgenIndexToName );
    elseif numIndexedMgens > numMorphogens
        complain2( errorseverity(1), ...
            '%d extra morphogens names in mgenIndexToName.', ...
            numIndexedMgens - numMorphogens );
        m.mgenIndexToName = m.mgenIndexToName( 1:numMorphogens );
        m.mgenNameToIndex = invertNameArray( m.mgenIndexToName );
    end
    m.mgenNameToIndex = invertNameArray( m.mgenIndexToName );
    
    [oks,errfields] = validStreamline( m );
    if ~all(oks)
        complain2( errorseverity(1), ...
            '%d streamlines had errors.', ...
            sum(~oks) );
        fprintf( 1, 'These fields contained errors:\n   ' );
        fprintf( 1, ' %s', errfields{:} );
        fprintf( 1, '\n' );
%         ok = false;
    end
    
    timedFprintf( 1, 'Finished mesh validity check.\n' );
end

