
function m = upgradeVeryOldMesh( m )
%m = upgradeVeryOldMesh( m )
%   Bring the mesh up to version 0.

    if isempty(m), return; end
    
    resetGlobals();
    global gGlobalProps;
    global gDefaultPlotOptions;
    global gOLD_NUMRESERVEDMGENS;
    
    OLD_PPMorphogenNames = upper( { ...
        'kpar', 'kperp', 'polariser', ...
        'bpar', 'bperp', 'NOTUSED', ...
        'arrest', 'strainret', 'thickness' } );

    global gOLD_K_PAR gOLD_K_PER gOLD_BEND_PAR gOLD_BEND_PER gOLD_BEND_POL gOLD_STRAINRET;

    gOLD_K_PAR = 1; 
    gOLD_K_PER = 2;
    gOLD_BEND_PAR = 4;
    gOLD_BEND_PER = 5;
    gOLD_BEND_POL = 6;
    gOLD_STRAINRET = 8;
    gOLD_NUMRESERVEDMGENS = 9;
    
    % Add all the new fields of globalProps.
    m.globalProps = defaultFromStruct( m.globalProps, gGlobalProps );
 
% 2008 May 27
    if ~isfield( m, 'absKvector' )
        if isfield( m.globalProps, 'timescaling' );
            timescale = m.globalProps.timescaling;
        else
            timescale = 1;
        end
        m.absKvector = m.Kvector*(m.globalProps.lengthscale^2)/timescale;
    end
    m = safermfield( m, 'Kvector' );
    
    if strcmp( m.globalProps.timeunitname, 'time unit' )
        m.globalProps.timeunitname = '';
    end

% 2008 Apr 25  Put all morphogen names into upper case.
    minNumMorphogens = length( m.mgenIndexToName );
    for i=1:minNumMorphogens
        m.mgenIndexToName = upper( m.mgenIndexToName );
    end
    m.mgenNameToIndex = invertDictionary( m.mgenIndexToName );
    
    % 2007 Oct 24
    % Make sure the standard morphogens have the right names and are in the right order.
    % Earlier versions had polariser=2 and bendpolariser=5; these are now 3
    % and 6.
    if strcmp( m.mgenIndexToName{2}, 'POLARISER' )
        m.morphogens(:,[2 3 5 6]) = m.morphogens(:,[3 2 6 5]);
        m.morphogenclamp(:,[2 3 5 6]) = m.morphogenclamp(:,[3 2 6 5]);
        if isfield( m , 'mgen_absorption' )
            m.mgen_absorption(:,[2 3 5 6]) = m.mgen_absorption(:,[3 2 6 5]);
        end
        if isfield( m , 'mgen_dilution' )
            m.mgen_dilution([2 3 5 6]) = m.mgen_dilution([3 2 6 5]);
        end
        m.absKvector(:,[2 3 5 6]) = m.absKvector(:,[3 2 6 5]);
        x = m.mgenIndexToName{2};
        m.mgenIndexToName{2} = m.mgenIndexToName{3};
        m.mgenIndexToName{3} = x;
        x = m.mgenIndexToName{5};
        m.mgenIndexToName{5} = m.mgenIndexToName{6};
        m.mgenIndexToName{6} = x;
        m.mgenNameToIndex.ANISOTROPY = 2;
        m.mgenNameToIndex.POLARISER = 3;
        m.mgenNameToIndex.BENDANISOTROPY = 5;
        m.mgenNameToIndex.BENDPOLARISER = 6;
    end
    % 2008 Jun 06   Rename GPAR and GPERP to KPAR and KPERP.
    if strcmp( m.mgenIndexToName{1}, 'GPAR' )
        m.mgenIndexToName{1} = 'KPAR';
        m.mgenIndexToName{2} = 'KPERP';
        m.mgenNameToIndex.KPAR = 1;
        m.mgenNameToIndex.KPERP = 2;
        m.mgenNameToIndex = rmfield( m.mgenNameToIndex, {'GPAR', 'GPERP'} );
    end

   
% 2008 May 15
% Growth/Anisotropy mode is no longer supported.
    isGA = strcmp( m.mgenIndexToName{1}, 'GROWTH' );
    if isGA % isfield( m.globalProps, 'parperp' )
        m = setParPerpMode( m );
        m.globalProps = safermfield( m.globalProps, 'parperp' );
    end
    
% 2007 Jun 03
% Rename 'growth' to 'morphogens' and 'growthclamp' to 'morphogenclamp'.
    if isfield( m, 'growth' )
        m.morphogens = m.growth;
        m.morphogenclamp = m.growthclamp;
        m = safermfield( m, 'growth', 'growthclamp' );
    end
    
% 2007 Jul 6
    % Rename curl to bend.
    if isfield( m, 'gradpolcurl' )
        m.mgenIndexToName{gOLD_BEND_PAR} = 'BEND';
        m.mgenIndexToName{gOLD_BEND_PER} = 'BENDANISOTROPY';
        m.mgenIndexToName{gOLD_BEND_POL} = 'BENDPOLARISER';
        m.mgenNameToIndex = invertDictionary( m.mgenIndexToName );
    end

    % Eliminate bendpolariser.
    if strcmp( m.mgenIndexToName{gOLD_BEND_POL}, 'BENDPOLARISER' )
        m.mgenIndexToName{gOLD_BEND_POL} = 'NOTUSED';
        m.mgenNameToIndex.NOTUSED = gOLD_BEND_POL;
        m.mgenNameToIndex = rmfield( m.mgenNameToIndex, 'BENDPOLARISER' );
    end

% 2007 Nov 12
    % If morphogen gOLD_BEND_PAR is called "BEND", then change morphogens gOLD_BEND_PAR and
    % gOLD_BEND_PER to "BPAR" and "BPERP", and recompute their values.
    if strcmp( m.mgenIndexToName{gOLD_BEND_PAR}, 'BEND' ) || ...
            isfield( m.mgenNameToIndex, 'BEND' )
        fprintf( 1, 'Upgrademesh: bend\n' );
        m.mgenIndexToName{gOLD_BEND_PAR} = 'BPAR';
        m.mgenIndexToName{gOLD_BEND_PER} = 'BPERP';
        m.mgenNameToIndex.BPAR = gOLD_BEND_PAR;
        m.mgenNameToIndex.BPERP = gOLD_BEND_PER;
        PP = pp_from_ga( m.morphogens(:,[gOLD_BEND_PAR,gOLD_BEND_PER]) );
        m.morphogens(:,gOLD_BEND_PAR) = -PP(:,1);
        m.morphogens(:,gOLD_BEND_PER) = -PP(:,2);
        clear PP;
    end
    

% 2008 Feb 27
% Replace cellnormals by unitcellnormals
    if isfield( m, 'cellnormals' ) || (m.globalProps.currentArea==0)
        m = rmfield( m, 'cellnormals' );
        m = makeAreasAndNormals( m );
    end

    % Initialise any undefined fields of globalProps.
    if (~isfield( m.globalProps, 'initialArea' )) || (m.globalProps.initialArea==0)
        m.globalProps.initialArea = m.globalProps.currentArea;
    end
    if (~isfield( m.globalProps, 'previousArea' )) || (m.globalProps.previousArea==0)
        m.globalProps.previousArea = m.globalProps.currentArea;
    end
    if (~isfield( m.globalProps, 'bendunitlength' )) || (m.globalProps.bendunitlength==0)
        m.globalProps.bendunitlength = sqrt( m.globalProps.initialArea );
    end
    if isfield( m.globalProps, 'defaultThickness' )
        m.globalProps.thicknessRelative = m.globalProps.defaultThickness;
    end
    if isfield( m.globalProps, 'thickness' )
        m.globalProps.thicknessRelative = m.globalProps.thickness;
    end
    if m.globalProps.thicknessRelative==0
        m = oldSetInitialThickness( m );
    elseif (~isfield( m.globalProps, 'thicknessAbsolute' )) ...
           || (m.globalProps.thicknessAbsolute==0)
        m = oldSetThickness( m );
    else
        m = oldSetThicknessScale( m );
    end
    if isfield( m.globalProps, 'defaultThickness' )
        m.globalProps.thicknessRelative = m.globalProps.defaultThickness;
    end
    if ~isfield( m.globalProps, 'physicalThickness' )
        m.globalProps.physicalThickness = false;
    end

% 2008 Apr 7
    if ~isfield( m, 'mgen_dilution' )
        if isfield( m.globalProps, 'allowDilution' ) ...
                && m.globalProps.allowDilution
            m.mgen_dilution = true( 1, size(m.morphogens,1) );
        else
            m.mgen_dilution = false( 1, size(m.morphogens,1) );
        end
    end
    
    % 2008 Jan 11  Default model name is now 'untitled' instead of the empty string.
    if isempty( m.globalProps.modelname )
        m.globalProps.modelname = gGlobalProps.modelname;
    end
    
    % 2008 Feb 19  Add a new field to store the seams.
    if ~isfield( m, 'seams' )
        m.seams = false( size(m.edgeends,1), 1 );
    end

    % A newly loaded mesh should not be in the middle of making a movie.
    m.globalProps.mov = [];
    m.globalProps.framesize = [];

% 2007 Dec 10
    m = safermfield( m, 'fixedprismnodes' );
    
    if isfield( m.globalProps, 'fixedDFs' )
        dfsPerNode = 6;
        m.fixedDFmap = false( size(m.nodes,1)*dfsPerNode, 1 );
        m.fixedDFmap( m.globalProps.fixedDFs ) = true;
        m.fixedDFmap = reshape( m.fixedDFmap, dfsPerNode, [] )';
        m.globalProps = safermfield( m.globalProps, 'fixedDFs' );
    end

% 2008 Apr 16  Some old models somehow had a bad value for
% m.globalProps.displayedGrowth.
    m.globalProps.displayedGrowth = ...
        trimnumber( 1, m.globalProps.displayedGrowth, size(m.morphogens,2) );

    if ~isfield( m, 'morphogens' )
        m.morphogens = zeros( size(m.tricellvxs,1), minNumMorphogens );
    end
    m = safermfield( m, 'morphogenproduction', 'growthproduction' );
    if ~isfield( m, 'morphogenclamp' )
        m.morphogenclamp = zeros( size(m.tricellvxs,1), minNumMorphogens );
    end
% 2007 Sep 24
    if ~isfield( m, 'mgen_absorption' )
        m.mgen_absorption = zeros( 1, size( m.morphogens, 2 ) );
    end
    
% 2007 Apr 13
% Ensure that all required information for all the morphogens exists.
    numMorphogens = max( [ size(m.morphogens,2), ...
                           size(m.morphogenclamp,2), ...
                           size(m.absKvector,2), ...
                           length(m.mgenIndexToName) ] );
% 2007 Jun 1
    if ~isfield( m, 'mutantLevel' )
        m.mutantLevel = ones( 1, numMorphogens );
    else
        m.mutantLevel = procrustesWidth( m.mutantLevel, numMorphogens );
    end
% 2007 Nov 9
    if isfield( m, 'mutantEnabled' )
        m.mutantLevel( ~m.mutantEnabled ) = 1;
        m = rmfield( m, 'mutantEnabled' );
    end
% 2007 Sep 3
    if ~isfield( m, 'allMutantEnabled' )
        m.allMutantEnabled = true;
    end
    m.morphogens = procrustesWidth( m.morphogens, numMorphogens );
    m.morphogenclamp = procrustesWidth( m.morphogenclamp, numMorphogens );
    m.absKvector = procrustesWidth( m.absKvector, numMorphogens );
    m.mgen_absorption = procrustesWidth( m.mgen_absorption, numMorphogens );
    m.mgen_dilution = procrustesWidth( m.mgen_dilution, numMorphogens );
    
% 2008 May 14
% Insert all missing standard morphogens, renumbering
% all user-defined morphogens if necessary.
    if ~isfield( m, 'mgenIndexToName' )
        m.mgenIndexToName = OLD_PPMorphogenNames;
    end
    foo = min(length(m.mgenIndexToName),gOLD_NUMRESERVEDMGENS);
    firstUserMgen = foo+1;
    for i=1:foo
        s = m.mgenIndexToName{i};
        if ~strcmp(s, OLD_PPMorphogenNames{i})
            % User-defined morphogen found.
            firstUserMgen = i;
            break;
        end
    end
  % numMorphogens
  % firstUserMgen
  % gOLD_NUMRESERVEDMGENS
    if firstUserMgen <= gOLD_NUMRESERVEDMGENS
        fprintf( 1, 'Adding %d standard morphogens:\n', ...
            gOLD_NUMRESERVEDMGENS - firstUserMgen + 1 );
      % newmgenindexes = firstUserMgen:gOLD_NUMRESERVEDMGENS
      % OLD_PPMorphogenNames{firstUserMgen:gOLD_NUMRESERVEDMGENS}
        lastReserved = firstUserMgen - 1;
        numMissing = gOLD_NUMRESERVEDMGENS - lastReserved;
        newStuff = zeros( size(m.morphogens,1), numMissing );
        m.morphogens = [ m.morphogens(:,1:lastReserved), ...
                         newStuff, ...
                         m.morphogens(:,firstUserMgen:numMorphogens) ];
        m.morphogenclamp = [ m.morphogenclamp(:,1:lastReserved), ...
                         newStuff, ...
                         m.morphogenclamp(:,firstUserMgen:numMorphogens) ];
        m.absKvector = [ m.absKvector(:,1:lastReserved), ...
                         zeros( size(m.absKvector,1), numMissing ), ...
                         m.absKvector(:,firstUserMgen:numMorphogens) ];
        m.mgen_absorption = [ m.mgen_absorption(:,1:lastReserved), ...
                         zeros( size(m.mgen_absorption,1), numMissing ), ...
                         m.mgen_absorption(:,firstUserMgen:numMorphogens) ];
        m.mutantLevel = [ m.mutantLevel(:,1:lastReserved), ...
                         ones( size(m.mutantLevel,1), numMissing ), ...
                         m.mutantLevel(:,firstUserMgen:numMorphogens) ];
        m.mgen_dilution = [ m.mgen_dilution(:,1:lastReserved), ...
                         false( size(m.mgen_dilution,1), numMissing ), ...
                         m.mgen_dilution(:,firstUserMgen:numMorphogens) ];
        m.mgenIndexToName = { m.mgenIndexToName{1:lastReserved}, ...
                         OLD_PPMorphogenNames{firstUserMgen:gOLD_NUMRESERVEDMGENS}, ...
                         m.mgenIndexToName{firstUserMgen:end} };
    end
    m.mgenNameToIndex = invertDictionary( m.mgenIndexToName );
    
    for i = length(m.mgenIndexToName)+1 : numMorphogens
        mgenname = sprintf( 'MGEN_%d', i );
        m.mgenIndexToName{i} = mgenname;
        m.mgenNameToIndex.(mgenname) = i;
    end
    
    % 2008 Jun 12
    % strainretention replaced by gOLD_STRAINRET morphogen.
    if isfield( m.globalProps, 'straindecayrate' )
        if isfield( m.globalProps, 'retainstrain' ) ...
                && ~m.globalProps.retainstrain
            sd = 0;
        else
            sd = 10^(-m.globalProps.straindecayrate);
        end
        m.morphogens( :, gOLD_STRAINRET ) = sd;
        m.mgenIndexToName
    elseif isfield( m.globalProps, 'strainretention' )
        m.morphogens( :, gOLD_STRAINRET ) = m.globalProps.strainretention;
    end
    
% 2008 Feb 01
    if ~isfield( m, 'currentbendangle' )
        m = makebendangles( m );
        m.initialbendangle = m.currentbendangle;
    end

% 2006 Dec 04
% If the second layer exists, it needs cell area data calculated.
    if isfield( m, 'secondlayer' )
        numcells = length(m.secondlayer.cells);
        if ~isfield( m.secondlayer, 'colors' )
            m.secondlayer.colors = [ [0.1 1 0.1]; [1 0.1 0.1] ];
        end
        if ~isfield( m.secondlayer, 'colorvariation' )
            m.secondlayer.colorvariation = 0.1;
        end
        if ~isfield( m.secondlayer, 'cellarea' )
            m.secondlayer.cellarea = zeros(numcells,1);
            for ci=1:numcells
                m.secondlayer.cellarea(ci) = polyarea3( ...
                    m.secondlayer.cell3dcoords( m.secondlayer.cells(ci).vxs, : ) );
            end
        end
        if ~isfield( m.secondlayer, 'areamultiple' )
            m.secondlayer.areamultiple = ones(numcells,1);
        end
        if ~isfield( m.secondlayer, 'celltargetarea' )
            m.secondlayer.celltargetarea = m.secondlayer.cellarea;
        end
        if ~isfield( m.secondlayer, 'averagetargetarea' )
            m.secondlayer.averagetargetarea = ...
                sum(m.secondlayer.celltargetarea)/length(m.secondlayer.celltargetarea);
        end
        if ~isfield( m.secondlayer, 'generation' )
            m.secondlayer.generation = zeros( size(m.secondlayer.edges,1), 1 );
        end
        if ~isfield( m.secondlayer, 'cloneindex' )
            m.secondlayer.cloneindex = zeros( size(m.secondlayer.cells,1), 1 );
        end
        if ~isfield( m.secondlayer, 'colorparams' )
            m.secondlayer.colorparams = ...
                [ [ 1/3-0.01, 0.75, 0.45, 1/3+0.01, 0.8, 0.55 ]; ...
                  [ -0.01,    0.95, 0.95, 0.01,     1,   1 ] ];
        end
    end

% 2008 Jan 18
    if isfield( m, 'anisotropy' )
        m = rmfield( m, 'anisotropy' );
    end
    
% 2007 Apr 17
    if ~isfield( m, 'interactionMode' )
        m = clearInteractionMode( m );
    end
    
% 2007 May 22
    if ~isfield( m, 'effectiveGrowthTensor' )
        m.effectiveGrowthTensor = zeros( size(m.tricellvxs,1), 6 );
    else
        if size(m.effectiveGrowthTensor,2) ~= 6
            m.effectiveGrowthTensor = ...
                procrustesWidth( m.effectiveGrowthTensor, 6 );
        end
        if size(m.effectiveGrowthTensor,1) ~= size(m.tricellvxs,1)
% 2008 Apr 07
            m.effectiveGrowthTensor = ...
                procrustesHeight( m.effectiveGrowthTensor, size(m.tricellvxs,1) );
        end
    end
    
   
% 2007 Sep 06
    % Older meshes were constructed without regard to the ordering of the
    % vertexes of each cell.
    m = fixOrientations( m );
    
    if isfield( m, 'secondlayer' )
        % 2007 Jun 13
        if (size(m.secondlayer.colorparams,2) ~= 6)
            m.secondlayer.colorparams = ...
                [ [ 1/3-0.01 0.75 0.45 1/3+0.01 0.8 0.55 ]; ...
                  [ -0.01 0.95 0.95 0.01 1 1 ] ];
        end
    end
    
% 2007 Jun 27
    m = safermfield( m, 'effectiveMgen' );
    m.plotdefaults = safermfield( m.plotdefaults, ...
        'constantScale', 'axesRange' );
    if isfield( m.plotdefaults, 'emptyColor' )
        if ~isfield( m.plotdefaults, 'emptycolor' )
            m.plotdefaults.emptycolor = m.plotdefaults.emptyColor;
        end
        m.plotdefaults = rmfield( m.plotdefaults, 'emptyColor' );
    end
% 2008 Jan 18
    if isfield( m.plotdefaults, 'figure' )
        m.plotdefaults.hfigure = m.plotdefaults.figure;
        m.plotdefaults = rmfield( m.plotdefaults, 'figure' );
    end

% 2007 Nov 15
    if isfield( m.plotdefaults, 'frontcells' )
        if ~isfield( m.plotdefaults, 'asidecells' )
            m.plotdefaults.asidecells = m.plotdefaults.frontcells;
        end
        m.plotdefaults = rmfield( m.plotdefaults, 'frontcells' );
    end

% 2007 Jun 27
    m.plotdefaults = defaultFromStruct( m.plotdefaults, gDefaultPlotOptions );
% 2007 Oct 3
    m.plotdefaults.azimuth = normaliseAngle( m.plotdefaults.azimuth, -180 );
    
% 2007 Aug 6
    if ~isfield( m, 'displacements' )
        m.displacements = [];
    end
    if ~isfield( m, 'timeForIter' )
        m.timeForIter = 0;
    end
    if ~isfield( m, 'ticForIter' )
        m.ticForIter = 0;
    end
    if ~isfield( m, 'stop' )
        m.stop = 0;
    end
    
% 2007 Aug 8
    if ~isfield( m, 'userdata' )
        m.userdata = struct();
    end
    
% 2007 Aug 31
    if isfield( m.globalProps, 'tempdt' )
        m.globalProps.timestep = m.globalProps.tempdt;
        m.globalProps = rmfield( m.globalProps, 'tempdt' );
    end

% 2008 Jan 16
    if isfield( m.globalProps, 'initialtime' )
        m.globalProps.currenttime = ...
            m.globalProps.initialtime + ...
            m.globalProps.timestep * m.globalProps.currentIter;
        m.globalProps = rmfield( m.globalProps, 'initialtime' );
    end

% 2007 Dec 19
    if ~isfield( m, 'selection' )
        m.selection = emptyselection();
    else
        if isfield( m.selection, 'fem' )
            m.selection = m.selection.fem;
        end
        m.selection = safermfield( m.selection, 'c_click', 'e_click', 'v_click' );
    end

    % Verify the interaction function.
    m.globalProps.mgen_interaction = [];
    if ~isempty( m.globalProps.mgen_interactionName )
        ifname = makeIFname( m.globalProps.modelname );
        if ~strcmp( ifname, m.globalProps.mgen_interactionName );
            beep;
            fprintf( 1, 'WARNING: The loaded mesh includes an obsolete reference\n' );
            fprintf( 1, '    to a morphogen interaction function named "%s".\n', ...
                m.globalProps.mgen_interactionName );
            fprintf( 1, '    Use the "Edit" button on the Morphogens panel to install a new function,\n' );
            fprintf( 1, '    and then copy the contents of the old function to the new one.\n' );
            m.globalProps.mgen_interactionName = '';
        end
    end

% 2007 Mar 5
% Update interaction handle from interaction name.
    m.globalProps.addedToPath = false;
    m = resetInteractionHandle( m, 'Validating interaction function' );
    
% 2007 Jan 18
% Create the plothandles structure
    if ~isfield( m, 'plothandles' )
        m.plothandles = struct();
    elseif isfield( m.plothandles, 'figure' )
        m.plotdefaults.hfigure = m.plothandles.figure;
        m.plothandles = rmfield( m.plothandles, 'figure' );
    end

% 2008 Feb 25
% Create the node edge/cell lists.
    if (~isfield( m, 'nodecelledges' )) || (length(m.nodecelledges) ~= size(m.nodes,1))
        m = makeVertexConnections(m);
    elseif size(m.nodecelledges{1},1)==1
        for i=1:size(m.nodes,1)
            m.nodecelledges{i} = reshape( m.nodecelledges{i}, 2, [] );
        end
    end

% 2008 Mar 5
    if ~isfield( m, 'pictures' )
        m.pictures = [];
    end
    
% 2008 Apr 7
    if size(m.celldata,2) > 1
        fprintf( 1, 'upgrademesh: reshaping cell data.\n' );
        m.celldata = reshape( m.celldata, [], 1 );
    end
    
% 2008 Jul 14
% If the third layer is empty, delete it.
    if isfield( m, 'thirdlayer' ) && isempty( m.thirdlayer.region )
        m = rmfield( m, 'thirdlayer' );
    end

% Delete obsolete fields of globalProps.
    m.globalProps = safermfield( m.globalProps, ...
        'allowDilution', ...
        'threshold', ...
        'defaultThickness', ...
        'thickness', ...
        'damping', ...
        'numcells', ...
        'timescaling', ...
        'allowSplitFEM', ...
        'movieframe', ...
        'mgen_interactionPath', ...
        'loadfilepath', ...
        'loadfilename', ...
        'residStrain', ...
        'retainstrain', ...
        'strainretention', ...
        'straindecayrate', ...
        'maxcol', ...
        'mincol', ...
        'keepflatness' );

    if ~isfield( m, 'versioninfo' )
        m.versioninfo = newversioninfo( 0, 0, version );
    end
end

function m = setParPerpMode( m )
    OLD_PPMorphogenNames = upper( { ...
        'kpar', 'kperp', 'polariser', ...
        'bpar', 'bperp', 'NOTUSED', ...
        'arrest', 'strainret', 'thickness' } );
    global gOLD_K_PAR gOLD_K_PER gOLD_BEND_PAR gOLD_BEND_PER

    if isfield( m.mgenNameToIndex, 'GROWTH' );
        m.morphogens( :, [gOLD_K_PAR gOLD_K_PER] ) = ...
            pp_from_ga( m.morphogens( :, [gOLD_K_PAR gOLD_K_PER] ) );
        m.morphogenclamp( :, [gOLD_K_PAR gOLD_K_PER] ) = ...
            pp_from_ga( m.morphogenclamp( :, [gOLD_K_PAR gOLD_K_PER] ) );
        m.mgenNameToIndex.(OLD_PPMorphogenNames{gOLD_K_PAR}) = gOLD_K_PAR;
        m.mgenNameToIndex.(OLD_PPMorphogenNames{gOLD_K_PER}) = gOLD_K_PER;
        m.mgenNameToIndex = safermfield( m.mgenNameToIndex, ...
            'GROWTH', 'ANISOTROPY' );
        m.mgenIndexToName{gOLD_K_PAR} = OLD_PPMorphogenNames{gOLD_K_PAR};
        m.mgenIndexToName{gOLD_K_PER} = OLD_PPMorphogenNames{gOLD_K_PER};
    end
    
    if isfield( m.mgenNameToIndex, 'BENDANISOTROPY' );
        m.morphogens( :, [gOLD_BEND_PAR,gOLD_BEND_PER] ) = ...
            pp_from_ga( m.morphogens( :, [gOLD_BEND_PAR,gOLD_BEND_PER] ) );
        m.morphogenclamp( :, [gOLD_BEND_PAR,gOLD_BEND_PER] ) = ...
            pp_from_ga( m.morphogenclamp( :, [gOLD_BEND_PAR,gOLD_BEND_PER] ) );
        m.mgenNameToIndex.(OLD_PPMorphogenNames{gOLD_BEND_PAR}) = gOLD_BEND_PAR;
        m.mgenNameToIndex.(OLD_PPMorphogenNames{gOLD_BEND_PER}) = gOLD_BEND_PER;
        m.mgenNameToIndex = safermfield( m.mgenNameToIndex, ...
            'BEND', 'BENDANISOTROPY' );
        m.mgenIndexToName{gOLD_BEND_PAR} = OLD_PPMorphogenNames{gOLD_BEND_PAR};
        m.mgenIndexToName{gOLD_BEND_PER} = OLD_PPMorphogenNames{gOLD_BEND_PER};
    end
end

function m = oldSetThicknessScale( m )
    m.globalProps.thicknessAbsolute = measureThickness( m );
    m.globalProps.thicknessRelative = ...
        m.globalProps.thicknessAbsolute ...
        / m.globalProps.currentArea^(m.globalProps.thicknessArea/2);
end

function m = oldSetThickness( m )
    m.globalProps.thicknessAbsolute = ...
        m.globalProps.thicknessRelative * ...
            m.globalProps.currentArea^(m.globalProps.thicknessArea/2);
end

function m = oldSetInitialThickness( m )
  % m.globalProps.thicknessRelative = 0.5; % ...
      % m.globalProps.initialArea^((1 - m.globalProps.thicknessArea)/2) ...
      % / size(m.tricellvxs,2);
    m.globalProps.thicknessRelative = meshDiameter( m )/10;
    m = oldSetThickness( m );
end
