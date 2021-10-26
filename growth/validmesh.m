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
if fatalerrors
    complainer = @error;
else
    complainer = @warning;
end
if warningsareerrors
    whiner = @error;
elseif verbose
    whiner = @warning;
else
    whiner = @donothing;
end
    
result = true;
if isfield( m, 'globalProps' ) ...
        && isfield( m.globalProps, 'validateMesh' ) ...
        && ~m.globalProps.validateMesh
    return;
end

fprintf( 1, '%s: Checking mesh validity.\n', datestring() );


full3d = usesNewFEs( m );
numnodes = getNumberOfVertexes(m);
if full3d
    numallnodes = numnodes;
else
    numallnodes = numnodes*2;
end
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
    complainer( 'Mesh has missing fields:' );
    for ci=1:length(missingfields)
        fprintf( 1, '\n    %s', missingfields{ci} );
    end
    fprintf( 1, '\n' );
end
if ~isempty(extrafields)
    complainer( 'Mesh has extra fields:' );
    for ci=1:length(extrafields)
        fprintf( 1, '\n    %s', extrafields{ci} );
    end
    fprintf( 1, '\n' );
end

if ~checknumel( m, 'celldata', numelements, complainer )
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
    [ok,errs] = checkConnectivityNewMesh( m, verbose );
else
    [ok,m] = checkConnectivityOldMesh( m, verbose );
end

% The angles of each FEM element should not be very small or very close to
% 180 degrees.
ANGLE_THRESHOLD = m.globalProps.mincellangle/4;  % 4 is a fudge factor.
if full3d
    fprintf( 1, '%s: Checking angle quality for general FEs is not yet supported.\n', mfilename() );
else
    alltriangles = permute( reshape( m.nodes( m.tricellvxs', : ), 3, [], 3 ), [1 3 2] );
    allAngles = trianglesAngles( alltriangles );
    badAngles = allAngles < ANGLE_THRESHOLD;
    if any(badAngles(:))
        complainer( 'validmesh:poorcells', ...
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
    complainer( 'validmesh:badgrowth', ...
        'Morphogens are defined for %d nodes, but the mesh has %d nodes.\n', ...
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
    complainer( 'validmesh:badcellstiffness', ...
        'cellstiffness has size [%d %d %d], expected [%d %d %d]\n', ...
        cssize(1), cssize(2), cssize(3), cptsPerTensor, cptsPerTensor, numelements );
    complainer( 'validmesh:badcellstiffness', ...
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
    
% Check that cellbulkmodulus is the right size.
cbmsize = length(m.cellbulkmodulus);
if cbmsize ~= numelements
    complainer( 'validmesh:badcellbulkmodulus', ...
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
    complainer( 'validmesh:badcellpoisson', ...
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
    if m.globalProps.prismnodesvalid
        if size(m.prismnodes,1) ~= size(m.nodes,1)*2
            result = 0;
            complainer( 'validmesh:badprisms', ...
                'Wrong number of prism nodes: %d, expected twice %d.', ...
                size(m.prismnodes,1), size(m.nodes,1) );
        end
    end
    
    
    if (~isempty(m.displacements)) && ~checkheight( m, 'displacements', getTotalNumberOfVertexes(m), complainer )
        result = 0;
    end
    if (~isempty(m.effectiveGrowthTensor)) && ~checkheight( m, 'effectiveGrowthTensor', getNumberOfFEs( m ), complainer )
        m.effectiveGrowthTensor = procrustesHeight( m.effectiveGrowthTensor, getNumberOfFEs( m ), 0 );
        result = 0;
    end
    if ~isempty( m.directGrowthTensors ) ...
            && ~checksize( [numelements,cptsPerTensor], size(m.directGrowthTensors), 'directGrowthTensors', complainer )
     result = 0;
    end

  
    if ~checkheight( m, 'fixedDFmap', numallnodes, complainer )
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
        whiner( 'validmesh:badseams', ...
            'Seams bitmap has %d elements but there are %d edges.', ...
            length(m.seams), size(m.edgeends,1) );
    end
    
% Validate the second layer.
badvxFEMcell = find( ...
    (m.secondlayer.vxFEMcell > numelements)...
    | (m.secondlayer.vxFEMcell <= 0) );
if ~isempty(badvxFEMcell)
    result = 0;
    complainer( 'validmesh:badvxFEMcell', ...
        '%d invalid values found in secondlayer.vxFEMcell:', ...
        length(badvxFEMcell) );
    fprintf( 1, ' %d', badvxFEMcell );
    fprintf( 1, '\n' );
    fprintf( 1, ' %d', m.secondlayer.vxFEMcell(badvxFEMcell) );
    fprintf( 1, '\n' );
end
[ok,m.secondlayer] = checkclonesvalid( m.secondlayer );
% ok = validateLineage( m ) && ok;  % DOESN'T FUCKING WORK BECAUSE SOME
% LINEAGE DATA ISN'T BEING UPDATED PROPERLY.
    
% Check that there is the right amount of other 3D data.
    if ~full3d
        result = checksize( numelements, length(m.cellareas), 'cellareas', complainer ) && result;
        result = checksize( numelements, size(m.unitcellnormals,1), 'unitcellnormals', complainer ) && result;
        numedges = size(m.edgeends,1);
        result = checksize( numedges, length(m.currentbendangle), 'currentbendangle', complainer ) && result;
        result = checksize( numedges, length(m.initialbendangle), 'initialbendangle', complainer ) && result;
        if isfield( m, 'vertexnormals' ) && ~isempty( m.vertexnormals )
            if full3d
                complainer( 'vertexnormals should not exist in foliate meshes' );
                m.vertexnormals = [];
            else
                result = checksize( size(m.nodes), size(m.vertexnormals), 'vertexnormals', complainer ) && result;
                if ~result
                    m.vertexnormals = [];
                end
            end
        end
    end
    if ~isempty(m.displacements)
        result = checksize( numallnodes, size(m.displacements,1), 'displacements', complainer ) && result;
    end
    % Check that m.conductivity is the right size.
    if length(m.conductivity) ~= size(m.morphogens,2)
        complainer( 'validmesh:badconductivity', ...
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
                    complainer( 'validmesh:vxconductivity', ...
                        'Dpar %d was per-vertex, converted to per-element\n', ci );
                else
                    complainer( 'validmesh:badconductivity', ...
                        'Dpar %d has length %d, expected %d\n', ...
                        ci, nDpar, numelements );
                end
            end
            if (nDper > 1) && (nDper ~= numelements)
                if nDper==numnodes
                    m.conductivity(ci).Dper = perVertextoperFE( m, m.conductivity(ci).Dper );
                    complainer( 'validmesh:vxconductivity', ...
                        'Dper %d was per-vertex, converted to per-element\n', ci );
                else
                    complainer( 'validmesh:badconductivity', ...
                        'Dper %d has length %d, expected %d\n', ...
                        ci, nDper, numelements );
                end
            end
        end
    end
    

    numpol = size(m.gradpolgrowth,3);
    okpol = true;
    okpol = checksize( [numelements,3,numpol], size(m.gradpolgrowth), 'gradpolgrowth', complainer ) && okpol;
    if full3d
        okpol = checksize( size(m.FEsets(1).fevxs), size(m.polfreeze), 'polfreeze', complainer ) && okpol;
    else
        okpol = checksize( [numelements,3,numpol], size(m.polfreeze), 'polfreeze', complainer ) && okpol;
        okpol = checksize( [numelements,3,numpol], size(m.polfreezebc), 'polfreezebc', complainer ) && okpol;
    end
    okpol = checksize( [numelements,numpol], size(m.polfrozen), 'polfrozen', complainer ) && okpol;
    if size(m.polsetfrozen,1) > 1
        okpol = checksize( [numelements,numpol], size(m.polsetfrozen), 'polsetfrozen', complainer ) && okpol;
    end
    if ~okpol
        complainer( 'validmesh:badpolgrad', 'Polariser gradient errors fixed.\n' );
        m = calcPolGrad( m );
        result = false;
    end
    
    if ~isempty( m.growthanglepervertex )
        result = checksize( numnodes, size(m.growthanglepervertex,1), 'growthanglepervertex', complainer ) && result;
    end
    if ~isempty( m.growthangleperFE )
        result = checksize( numelements, size(m.growthangleperFE,1), 'growthangleperFE', complainer ) && result;
    end
    if ~isempty( m.decorFEs )
        if length(m.decorFEs) ~= size(m.decorBCs,1)
            complainer( 'validmesh:baddecorpts', ...
                'length(m.decorFEs) = %d but size(m.decorBCs,1) = %d.\n', ...
                length(m.decorFEs), size(m.decorBCs,1) );
            m.decorFEs = [];
            m.decorBCs = [];
        end
        if any(m.decorFEs > numelements)
            complainer( 'validmesh:invalid decor FEs:' );
            m.decorFEs(m.decorFEs > numelements);
        end
        if any(m.decorFEs < 1)
            complainer( 'validmesh:invalid decor FEs:' );
            m.decorFEs(m.decorFEs < 5);
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
            complainer( ['validmesh:bad',fn], ...
                '%d extra columns found in %s:', ...
                numfound - numMorphogens, fn );
            x = m.(fn);
            m.(fn) = x(:,1:numMorphogens);
        elseif numfound < numMorphogens
            complainer( ['validmesh:bad',fn], ...
                '%d missing columns found in %s:', ...
                numMorphogens - numfound, fn );
            m.(fn) = [ m.(fn), ...
                       repmat( gPerMgenDefaults.(fn), 1, numMorphogens - numfound ) ];
        end
    end
    
    numIndexedMgens = length(m.mgenIndexToName);
    if numIndexedMgens < numMorphogens
        % Well, fuck.
        complainer( 'validmesh:badmorphogennames', ...
            '%d unnamed morphogens found in mgenIndexToName:', ...
            numMorphogens - numIndexedMgens );
        for ci=(numIndexedMgens+1):numMorphogens
            m.mgenIndexToName{ci} = sprintf( 'UNK_%03d', ci );
        end
        m.mgenNameToIndex = invertNameArray( m.mgenIndexToName );
    elseif numIndexedMgens > numMorphogens
        complainer( 'validmesh:badmorphogennames', ...
            '%d extra morphogens names in mgenIndexToName:', ...
            numIndexedMgens - numMorphogens );
        m.mgenIndexToName = m.mgenIndexToName( 1:numMorphogens );
        m.mgenNameToIndex = invertNameArray( m.mgenIndexToName );
    end
    m.mgenNameToIndex = invertNameArray( m.mgenIndexToName );
    
    
    fprintf( 1, '%s: Finished mesh validity check.\n', datestring() );
end

