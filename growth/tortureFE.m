function m = tortureFE(f)
    resetGlobals();
    global CMDSTRUCT
    
    global outputDir;
    global framecount;
    global dofigures;
    
    whereami = mfilename('fullpath');
    growthDir = fileparts(whereami);
    toolboxDir = fileparts(growthDir);
    commandsDir = fullfile( growthDir, 'commands' );
    outputDir = fullfile( toolboxDir, 'NotForSVN', 'tortureresult' );
    allcmds = dir( fullfile(commandsDir,'*.m') );
    cmds = {allcmds.name};
    CMDSTRUCT = struct();
    for i=1:length(cmds)
        cmds{i} = regexprep( cmds{i}, '\.m$', '' );
        CMDSTRUCT.(cmds{i}) = false;
    end
    
    dofigures = 0;
    
    framecount = 0;
    
    if ~isempty(outputDir)
        [ok,msg] = mkdir( outputDir );
    end
    m = [];
    
    
%     m = testcmd( m, 'leaf_cylinder', 'xwidth', 2, 'ywidth', 2, 'height', 2, 'circumdivs', 8, 'heightdivs', 2 );
    m = leaf_block3D( [], 'size', [2 3 4], 'divisions', [2 3 4], 'type', 'H8' );
    m = show( m );
    
% These are not meaningful for volumetric FEs.
%     seamnodes = abs(m.nodes(:,1)) < 0.01;
%     m = testcmd( m, 'leaf_addseam', 'nodemap', seamnodes );
%     m = show( m );
%     m = testcmd( m, 'leaf_dissect' );
%     m = show( m );
%     m = testcmd( m, 'leaf_flatten', 'interactive', true );
%     m = show( m );
%     m = testcmd( m, 'leaf_explode', 0.5 );
%     m = show( m );

    

%     m = testcmd( [], 'leaf_cylinder', 'xwidth', 2, 'ywidth', 2, 'height', 2, 'circumdivs', 6, 'heightdivs', 2 );
    m = testcmd( m, 'leaf_addpicture', 'position', [700 800] );
    m = testcmd( m, 'leaf_enablelegend', false );
    if nargin >= 1
        m = testcmd( m, 'leaf_movie','filename',[f '.avi'], ...
            'fps', 5, ...
            'compression', 'Cinepak', ...
            'quality', 100, ...
            'keyframe', 5 );
    end
    
    m = show( m );
    mov = m.globalProps.mov;
    makemovie = movieInProgress(m);
%     m = testcmd( m, 'leaf_loadmodel', 'GPT_testradius_20131111', ...
%         '/Users/jrk/Documents/MATLAB/GFtboxProjects' );
%     m.secondlayer = fixBioOrientations( m.secondlayer );
%     m.globalProps.mov = mov;
%     m = show( m );

    m = testcmd( m, 'leaf_iterate', 3, 'plot', 1 );
    
%     m = testcmd( m, 'leaf_deletepatch', [1 2 3] );
%     m = show( m );
    
    m = testcmd( m, 'leaf_plotoptions', 'outputquantity', 'Strain' );
    m = show( m );

    m = testcmd( m, 'leaf_destrain' );
    m = show( m );
%     m = testcmd( m, 'leaf_flatstrain' );
%     m = show( m );

    m = testcmd( m, 'leaf_plotoptions', 'blank', true );
    m = show( m );
    stoptorture( m );    
    return;
    
    
    m = testcmd( [], 'leaf_lobes', 'radius', 2, 'rings', 2, 'height', 2, 'lobes', 4 );
    m = show( m );
    m = testcmd( m, 'leaf_bowlz', 'amount', 0.6 );
    m = leaf_mgen_radial( m, 'POLARISER', 1 );
    m = calcPolGrad( m );
    m = leaf_plotoptions( m, 'drawgradients', true, 'sidegrad', 'AB' );
    m = show( m );

    [m,elideEdgeOK] = elideEdge( m, 1 );
    elideEdgeOK
    m = show( m );
    
    m = testcmd( m, 'leaf_mgen_const', 'kapar', 2 );
    m = testcmd( m, 'leaf_plotoptions', 'drawedges', 2, 'drawseams', 2 );
    m = show( m );
    m = testcmd( m, 'leaf_onecell', 'xwidth', 4, 'ywidth', 3 );
    m = testcmd( m, 'leaf_plotoptions', 'drawedges', 2, 'drawseams', 2 );
    m = show( m );
    m = testcmd( m, 'leaf_snapdragon', 'petals', 5, 'radius', 3, 'rings', 3, 'height', 1 );
    m = testcmd( m, 'leaf_plotoptions', 'drawedges', 2, 'drawseams', 2 );
    m = show( m );
    m = testcmd( m, 'leaf_rectangle', ...
                    'xwidth', 2, 'ywidth', 2, 'xdivs', 8, 'ydivs', 8, 'base', 5 );
    m = testcmd( m, 'leaf_plotoptions', 'drawedges', 2, 'drawseams', 2 );
    m = show( m );
    m = testcmd( m, 'leaf_semicircle', 'xwidth', 2, 'ywidth', 2, 'rings', 4 );
    m = testcmd( m, 'leaf_plotoptions', 'drawedges', 2, 'drawseams', 2 );
    m = show( m );
    m = testcmd( m, 'leaf_subdivide', 'minabslength', 0 );  % Need more tests of the various options.
    m = show( m );
    m = testcmd( m, 'leaf_showaxes', false );
    m = show( m );
    m = testcmd( m, 'leaf_showaxes', true );
    m = show( m );
    
    m = testcmd( m, 'leaf_plotoptions', 'drawedges', 2, 'drawseams', 2 );
    m = show( m );
    m = testcmd( m, 'leaf_icosahedron', 'radius', 2 );
    m = testcmd( m, 'leaf_plotoptions', 'drawedges', 2, 'drawseams', 2 );
    m = show( m );
    m = testcmd( m, 'leaf_refineFEM', 'parameter', 1, 'mode', 'random' );
    m = show( m );
    m = testcmd( m, 'leaf_refineFEM', 'parameter', 1, 'mode', 'random' );
    m = show( m );
    m = testcmd( m, 'leaf_circle', 'xwidth', 2, 'ywidth', 2, 'rings', 4 );
    m = testcmd( m, 'leaf_plotoptions', 'drawedges', 2, 'drawseams', 2 );
    m = show( m );
    m = testcmd( m, 'leaf_alwaysflat', 1 );
    m = show( m );
    m = testcmd( m, 'leaf_bowlz', 'amount', 0.6 );
    m = show( m );
    m = testcmd( m, 'leaf_refineFEM', 'parameter', 0.5, 'mode', 'longest' );
    m = show( m );
    m = testcmd( m, 'leaf_fix_vertex', 'vertex', [1 2 3], 'dfs', 'xy' );
    m = show( m );
    m = testcmd( m, 'leaf_rotatexyz' );
    m = show( m );
    m = testcmd( m, 'leaf_rotatexyz' );
    m = show( m );
    m = testcmd( m, 'leaf_rotatexyz' );
    m = show( m );
    m = testcmd( m, 'leaf_saddlez', 'amount', 0.3, 'lobes', 3 );
    m = show( m );
    m = testcmd( m, 'leaf_setzeroz' );
    m = show( m );
    m = testcmd( m, 'leaf_perturbz', 0.3 );
    m = show( m );

    m = testcmd( m, 'leaf_add_mgen', 'testmgen' );
    m = show( m );
    m = testcmd( m, 'leaf_mgen_conductivity', 'testmgen', 0.5 );
    m = show( m );
    m = testcmd( m, 'leaf_mgen_const', 'testmgen', 2 );
    m = show( m );
    m = testcmd( m, 'leaf_mgen_edge', 'testmgen', 2 );
    m = show( m );
    m = testcmd( m, 'leaf_mgen_linear', 'testmgen', 2 );
    m = show( m );
    m = testcmd( m, 'leaf_mgen_radial', 'testmgen', 2 );
    m = show( m );
    m = testcmd( m, 'leaf_mgen_random', 'testmgen', 2 );
    m = show( m );
    m = testcmd( m, 'leaf_iterate', 3, 'plot', 1);
    m = show( m );
    m = testcmd( m, 'leaf_mgen_zero', 'testmgen' );
    m = show( m );
    m = testcmd( m, 'leaf_mgen_absorption', 'testmgen', 1 );
    m = testcmd( m, 'leaf_mgen_dilution', 'testmgen', true );
    m = testcmd( m, 'leaf_mgen_scale', 'testmgen', 2 );
    m = testcmd( m, 'leaf_rename_mgen', 'testmgen', 'testmgen2' );
    m = show( m );
    
    mgenNameToIndex = m.mgenNameToIndex
    
    
    
    m = testcmd( m, 'leaf_mgen_modulate', 'morphogen', 'testmgen2', ...
            'switch', 0.5', 'mutant', 0.4' );
    m = show( m, 'testmgen2' );
    m = testcmd( m, 'leaf_fix_mgen', 'testmgen2', 'vertex', [1 2 3], 'fix', 1 );
    m = show( m );
    m = testcmd( m, 'leaf_mgen_reset' );
    m = show( m );

    m = testcmd( m, 'leaf_delete_mgen', 'testmgen2' );
    m = show( m );

    m = testcmd( m, 'leaf_setbgcolor', [ 0.9, 0.8, 0.7 ] );
    m = show( m );

    m = testcmd( m, 'leaf_add_userdata', 'testuser', 'foo', 'testuser2', 'bar' );
    m_userdata_add = m.userdata
    m = show( m );
    m = testcmd( m, 'leaf_set_userdata', 'testuser', 'fob' );
    m_userdata_set = m.userdata
    m = show( m );
    m = testcmd( m, 'leaf_delete_userdata', 'testuser' );
    m = show( m );
    m = testcmd( m, 'leaf_delete_userdata', 'testuser2' );
    m = show( m );
    m = testcmd( m, 'leaf_delete_userdata', 'testuser3' );
    m = show( m );
    m_userdata_delete = m.userdata
    
    m = testcmd( m, 'leaf_deletepatch', [1 2 3] );
    m = show( m );
    m = testcmd( m, 'leaf_deletepatch', (1:size(m.tricellvxs)) <= 3 );
    m = show( m );
    m = testcmd( m, 'leaf_deletepatch', [1 2 3] );
    m = show( m );
    
    numstreamlines = 10;
    m.morphogens(:,6) = m.nodes(:,1).^2 + m.nodes(:,2);
    m = calcPolGrad( m );
    m = leaf_plotoptions( m, 'streamlinemiddotsize', 20, 'streamlineenddotsize', 30 );
    m = testcmd( m, 'leaf_createStreamlines', ...
        'startpos', [randn(numstreamlines,2),zeros(numstreamlines,1)], ...
        'length', rand(numstreamlines,1)*0.2 + 0.05, ...
        'downstream', rand(numstreamlines,1)>0.5 );
    m = show( m );
    m = testcmd( m, 'leaf_growStreamlines', ...
        'length', 0.1 );
    m = show( m );
    m = testcmd( m, 'leaf_growStreamlines', ...
        'length', 0.1 );
    m = show( m );
    m = testcmd( m, 'leaf_growStreamlines', ...
        'length', 0.1 );
    m = show( m );
    m = testcmd( m, 'leaf_deleteStreamlines' );
    m = show( m );
    
    m = testcmd( m, 'leaf_fliporientation' );
    m = show( m );
    
    
    m = testcmd( m, 'leaf_plotoptions', 'drawsecondlayer', 1 );
    
    
    
    
    m = testcmd( m, 'leaf_deletesecondlayer' );
    m = show( m );
    m = testcmd( m, 'leaf_makesecondlayer', 'mode', 'few', 'numcells', 10, 'absdiam', 0.1 );
    m = show( m );
    fprintf( 1, 'Showing second layer, mode ''few''.\n' );
    dopause();

    m = testcmd( m, 'leaf_deletesecondlayer' );
    m = show( m );
    m = testcmd( m, 'leaf_makesecondlayer', 'mode', 'universal', 'numcells', 60 );
    m = show( m );
    fprintf( 1, 'Showing second layer, mode ''universal''.\n' );
    dopause();
    m = testcmd( m, 'leaf_initiateICSpaces', 'number', 10, 'relsize', 0.2 );
    m = show( m );
    m = testcmd( m, 'leaf_growICSpaces', 'relsize', 0.2 );
    m = show( m );
    m = testcmd( m, 'leaf_growICSpaces', 'relsize', 0.2 );
    m = show( m );
    m = testcmd( m, 'leaf_growICSpaces', 'relsize', 0.2 );
    m = show( m );
    
    m = testcmd( m, 'leaf_deletesecondlayer' );
    m = show( m );
    m = testcmd( m, 'leaf_makesecondlayer', 'mode', 'grid', 'absdiam', 0.2 );
    m = show( m );
    fprintf( 1, 'Showing second layer, mode ''grid''.\n' );
    dopause();
    
    m = testcmd( m, 'leaf_deletesecondlayer' );
    m = show( m );
    m = testcmd( m, 'leaf_makesecondlayer', 'mode', 'each', 'numcells', 10, 'absdiam', 0.1 );
    m = show( m );
    fprintf( 1, 'Showing second layer, mode ''each''.\n' );
    dopause();
    
    stoptorture( m );
end

function dopause()
%     fprintf( 1, 'Hit any key to continue:\n' );
%     pause;
end

%{
71 of 123 commands were not tested:
    m = testcmd( m, 'leaf_addseam', XX );
    m = testcmd( m, 'leaf_addwaypoint', XX );
    m = testcmd( m, 'leaf_allowmutant', XX );
    m = testcmd( m, 'leaf_archive', XX );
    m = testcmd( m, 'leaf_attachpicture', XX );
    m = testcmd( m, 'leaf_clearwaypoints', XX );
    m = testcmd( m, 'leaf_colourA', XX );
    m = testcmd( m, 'leaf_computeGrowthFromDisplacements', XX );
    m = testcmd( m, 'leaf_createmesh', XX );
    m = testcmd( m, 'leaf_deletenodes', XX );
    m = testcmd( m, 'leaf_deletepatch_from_morphogen_level', XX );
    m = testcmd( m, 'leaf_deletestages', XX );
    m = testcmd( m, 'leaf_dointeraction', XX );
    m = testcmd( m, 'leaf_edit_interaction', XX );
    m = testcmd( m, 'leaf_enablemutations', XX );
    m = testcmd( m, 'leaf_flattenByElasticity', XX );
    m = testcmd( m, 'leaf_getplotoptions', XX );
    m = testcmd( m, 'leaf_getproperty', XX );
    m = testcmd( m, 'leaf_gyrate', XX );
    m = testcmd( m, 'leaf_light', XX );
    m = testcmd( m, 'leaf_load', XX );
    m = testcmd( m, 'leaf_loadgrowth', XX );
    m = testcmd( m, 'leaf_locate_vertex', XX );
    m = testcmd( m, 'leaf_lune', XX );
    m = testcmd( m, 'leaf_mgen_color', XX );
    m = testcmd( m, 'leaf_mgen_get_conductivity', XX );
    m = testcmd( m, 'leaf_mgen_plotpriority', XX );
    m = testcmd( m, 'leaf_mgeninterpolation', XX );
    m = testcmd( m, 'leaf_morphogen_midpoint', XX );
    m = testcmd( m, 'leaf_morphogen_pulse', XX );
    m = testcmd( m, 'leaf_morphogen_switch', XX );
    m = testcmd( m, 'leaf_movie', XX );
    m = testcmd( m, 'leaf_paintpatch', XX );
    m = testcmd( m, 'leaf_paintvertex', XX );
    m = testcmd( m, 'leaf_plot', XX );
    m = testcmd( m, 'leaf_plotview', XX );
    m = testcmd( m, 'leaf_profile_monitor', XX );
    m = testcmd( m, 'leaf_purgeproject', XX );
    m = testcmd( m, 'leaf_rasterize', XX );
    m = testcmd( m, 'leaf_recomputestages', XX );
    m = testcmd( m, 'leaf_record_mesh_frame', XX );
    m = testcmd( m, 'leaf_reload', XX );
    m = testcmd( m, 'leaf_requeststages', XX );
    m = testcmd( m, 'leaf_rescale', XX );
    m = testcmd( m, 'leaf_rewriteIF', XX );
    m = testcmd( m, 'leaf_rotate', XX );
    m = testcmd( m, 'leaf_saveas', XX );
    m = testcmd( m, 'leaf_savemodel', XX );
    m = testcmd( m, 'leaf_saverun', XX );
    m = testcmd( m, 'leaf_savestage', XX );
    m = testcmd( m, 'leaf_set_seams', XX );
    m = testcmd( m, 'leaf_setgrowthmode', XX );
    m = testcmd( m, 'leaf_setmutant', XX );
    m = testcmd( m, 'leaf_setproperty', XX );
    m = testcmd( m, 'leaf_setsecondlayerparams', XX );
    m = testcmd( m, 'leaf_setthickness', XX );
    m = testcmd( m, 'leaf_setthicknessparams', XX );
    m = testcmd( m, 'leaf_shockA', XX );
    m = testcmd( m, 'leaf_shockB', XX );
    m = testcmd( m, 'leaf_showaxes', XX );
    m = testcmd( m, 'leaf_snapshot', XX );
    m = testcmd( m, 'leaf_splitsecondlayer', XX );
    m = testcmd( m, 'leaf_splitting_factor', XX );
    m = testcmd( m, 'leaf_stereoparams', XX );
    m = testcmd( m, 'leaf_stitch_vertex', XX );
    m = testcmd( m, 'leaf_unshockA', XX );
    m = testcmd( m, 'leaf_vertex_follow_mgen', XX );
    m = testcmd( m, 'leaf_vertex_monitor', XX );
    m = testcmd( m, 'leaf_vertex_set_monitor', XX );
    m = testcmd( m, 'leaf_waypointmovie', XX );
%}

function m = testcmd( m, cmd, varargin )
    global CMDSTRUCT
    fprintf( 1, '%s\n', cmd );
    f = str2func(cmd);
    m = f( m, varargin{:} );
    CMDSTRUCT.(cmd) = true;
end

function m = show( m, mgen )
    global outputDir;
    global framecount;
    global dofigures;
    if nargin < 2
        mgen = 1;
    end
    m = leaf_plot(m, 'morphogen', mgen, ...
                     ... % 'hfigure', 1, ...
                     'azimuth', -45+framecount*2, ...
                     'elevation',33.75, ...
                     'drawedges', 2, ...
                     'drawlegend', false, ...
                     'autozoom', true, ...
                     'autocentre', true ...
                 );
    framecount = framecount+1;
    if dofigures
        m = leaf_saveas( m, sprintf( 'testfig%04d.fig', framecount ), outputDir, 'overwrite', 1 );
    end
    figure(ancestor(m.pictures(1),'figure'));
    drawnow;
    if ~isempty(m.globalProps.mov)
        m = recordframe( m );
    end
    show_ok = validmesh(m);
end

function stoptorture( m )
    m = leaf_movie( m, 0 );
    fprintf( 1, '\n\nTorture test ended.\n' );
    global CMDSTRUCT
    fn = fieldnames(CMDSTRUCT);
    totalcmds = length(fn);
    used = false(1,totalcmds);
    for i=1:totalcmds
        c = fn{i};
        used(i) = CMDSTRUCT.(c);
    end
    fn = sort( { fn{ ~used } } );
    if isempty(fn)
        fprintf( 1, 'All %d commands were tested.\n', totalcmds );
    else
        fprintf( 1, '%d of %d commands were not tested:\n', length(fn), totalcmds );
        for i=1:length(fn)
            c = fn{i};
            fprintf( 1, '    m = testcmd( m, ''%s'', XX );\n', c );
        end
    end
end
