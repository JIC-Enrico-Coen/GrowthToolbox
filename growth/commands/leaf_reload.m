function [m,ok] = leaf_reload( m, varargin )
%m = leaf_reload( m, stage, varargin )
%   Reload a leaf from the MAT, OBJ, or PTL file it was last loaded from,
%   discarding all changes made since then.  If there was no such previous
%   file, the mesh is left unchanged.
%
%   Arguments:
%       stage:  If 0 or more, the indicated stage of the mesh, provided
%               there is a saved state from that stage.  If 'reload', the
%               stage that the mesh was loaded from or was last saved to,
%               whichever is later.  If 'restart', the initial stage of the
%               mesh.  If the indicated stage does not exist a warning is
%               given and the mesh is left unchanged.  The default is
%               'reload'.
%
%   Options:
%       rewrite:  Normally, when a model is loaded, its interaction
%                 function (if there is one) is read, parsed, and
%                 rewritten.  This is because it may have been created with
%                 an older version of GFtbox.  Specifying the rewrite
%                 option as false prevents this from being done.  This may
%                 be necessary when running several simulations
%                 concurrently on a parallel machine, all using the same
%                 project.
%
%   Equivalent GUI operations:  The "Restart" button is equivalent to
%           m = leaf_reload( m, 'restart' );
%       The "Reload" button is equivalent to
%           m = leaf_reload( m, 'reload' );
%       or
%           m = leaf_reload( m );
%       The items on the "Stages" menu are equivalent to
%           m = leaf_reload( m, s );
%       for each valid s.  s should be passed as a string.  For example, if
%       the Stages menu has a menu item called 'Time 315.25', that stage
%       can be loaded with
%           m = leaf_reload( m, '315.25' );
%
%   Topics: Project management.

    ok = true;
    global gMISC_GLOBALS gFULLSTATICFIELDS
    if isempty(m), return; end
    [ok,stage,args] = getTypedArg( mfilename(), {'numeric','char'}, varargin, 'reload' );
    if ~ok
        return;
    end
    if isempty(stage)
        stage = 'restart';
    end
    [s,ok] = safemakestruct( mfilename(), args );
    if ~ok, return; end
    s = defaultfields( s, 'rewrite', true );
    ok = checkcommandargs( mfilename(), s, 'exact', 'rewrite' );
    if ~ok, return; end
    
    ok = true;
    stagesuffix = '';
    stagesuffixpattern = '';
    restarting = false;
    switch stage
        case 'restart'
            restarting = true;
        case 'reload'
            stagesuffix = m.globalDynamicProps.laststagesuffix;
        otherwise
            if isnumeric(stage)
                stagesuffixpattern = stageTimeToPattern( stage );
%             elseif any( stage=='d' )
%                 if regexp( stage, ['^', gMISC_GLOBALS.stageprefix] )
%                     stagesuffix = stage;
%                 else
%                     stagesuffix = [gMISC_GLOBALS.stageprefix, stage];
%                 end
            else
                stagesuffixpattern = stageStringToPattern( stage );
            end
    end
    
    projectdir = m.globalProps.projectdir;
    if isempty( projectdir )
        fprintf( 1, '%s: no project directory to load from.\n', mfilename() );
        ok = false;
        return;
    end
    modelname = m.globalProps.modelname;
    modelstaticname = staticBaseName( m );
    if isempty( modelname )
        fprintf( 1, '%s: no model to load.\n', mfilename() );
        ok = false;
        return;
    end
    modeldir = fullfile( projectdir, modelname );
    if isempty(stagesuffixpattern)
        if isempty(stagesuffix)
            loadfile = [ modelname, '.mat' ];
        else
            loadfile = [ modelname, stagesuffix, '.mat' ];
        end
    else
        loadfilepattern = fullfile( modeldir, [ modelname, gMISC_GLOBALS.stageprefix, '*.mat' ] );
        loadfiles = dir( loadfilepattern );
        loadfile = '';
        for i=1:length(loadfiles)
            [stagespec,ok1] = removeStringPrefix( loadfiles(i).name, [ modelname, gMISC_GLOBALS.stageprefix ] );
            if ~ok1, continue; end
            if ~isempty( regexp( stagespec, [ '^', stagesuffixpattern, '\.mat$' ], 'once' ) )
                loadfile = loadfiles(i).name;
                break;
            end
        end
    end
    if isempty( loadfile )
        ok = false;
        complain( '%s: Could not find model file %s.\n', mfilename(), loadfile );
        return;
    else
        loadfile = fullfile( modeldir, loadfile );
    end
    if false
        staticbasename = staticBaseName( modelname );
        staticfile = fullfile( modeldir, staticbasename );
        if ~exist( staticfile, 'file' )
            staticfile = '';
        end
    end
    staticpart = splitstruct( m, gFULLSTATICFIELDS );
    % [m,ok] = loadmesh_anyfile( m, loadfile, staticpart );
    [m,ok] = loadmesh_anyfile( m, loadfile, [], isinteractive(m) );
    % ok = ~isempty(m);
    if ~ok, m = []; end
    if ok
        m.globalProps.projectdir = projectdir;
        m.globalProps.modelname = modelname;
        m.globalDynamicProps.laststagesuffix = makestagesuffixf( m.globalDynamicProps.currenttime );
        if restarting
            m.globalDynamicProps.currentIter = 0;
            m.globalProps.IFsetsoptions = true;
        end
        m.rewriteIFneeded = s.rewrite;
        m = storeCodeRevInfo( m );

      % if s.rewrite
      %     [m,ok] = rewriteInteractionSkeleton( m, '', '', mfilename() );
      % else
            m = resetInteractionHandle( m, mfilename() );
      % end
    end
end
