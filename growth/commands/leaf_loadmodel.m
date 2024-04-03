function [m,ok] = leaf_loadmodel( m, modelname, projectdir, varargin )
%[m,ok] = leaf_loadmodel( m, modelname, projectdir, ... )
%   Load a model.  If no model name is given or the model name is empty, a
%   dialog will be opened to choose one.  The model will be looked for in
%   projectdir, if given, otherwise the project directory of m, if any,
%   otherwise the current directory.  The argument m can be empty; in fact,
%   this will be the usual case.
%
%   If the model is successfully loaded, the new model is returned in M and
%   the (optional) return value OK is set to TRUE.  Otherwise M is left
%   unchanged and OK is set to FALSE.
%
%   Options:
%       rewrite:  Normally, when a model is loaded, its interaction
%                 function (if there is one) is read, parsed, and
%                 rewritten.  This is because it may have been created with
%                 an older version of GFtbox.  Specifying the rewrite
%                 option as false prevents this from being done.  This may
%                 be necessary when running several simulations
%                 concurrently on a parallel machine, all using the same
%                 project.  Note that when rewrite is true (the default),
%                 the interaction function will not actually be rewritten
%                 until the first time it is called, or any morphogen is
%                 added, deleted, or renamed, or the user requests a
%                 rewrite.
%       copyname, copydir:
%                 If either of these is given, a new copy of the project
%                 will be made and saved with the specified project name
%                 and parent folder.  The original project folder will be
%                 unmodified.  If one of these options is given, the other
%                 can be omitted or set to the empty string, in which
%                 case it defaults to the original project name or project
%                 folder respectively.  If the value of copyname is '?',
%                 then the user will be prompted to select or create a
%                 project folder.  In this case, copydir will be the folder
%                 at which the select-folder dialog starts.  If both
%                 options are empty, this is equivalent to omitting both of
%                 them (the default).  If copydir and copyname are the same
%                 as modelname and projectdir, a warning will be given, and
%                 the copy options ignored.
%       interactive:
%                 A boolean value.  If true, situations such as missing
%                 files will be reported by dialogs; if false, no dialogs
%                 will be presented.  In both cases a message will be
%                 written to the console.
%       soleaccess:
%                 A boolean value that specifies whether the caller of this
%                 procedure has sole access to the project from which this
%                 file is being loaded. If so,
%                 m.globalDynamicProps.staticreadonly will be turned off.
%                 If false, it will be turned on. If empty, it will be
%                 unaltered. The default is empty.
%
%   If for any reason the model cannot be loaded, a warning will be output,
%   the loaded model will be discarded, and m and ok returns as [] and
%   false.
%
%   Equivalent GUI operation: the "Load model..." button, or the items on
%   the Projects menu.  The items on the Motifs menu use copyname and
%   copydir to force the "motif" projects to be opened as copies in the
%   user's default project directory.
%
%   Examples:
%       m = leaf_loadmodel( [], 'flower7', 'C:\MyProjects\flowers', ...
%                           'copyname', 'flower8', ...
%                           'copydir', 'C:\MyProjects\flowers' );
%       This loads a model from the folder 'C:\MyProjects\flowers\flower7',
%       and saves it into a new project folder 'C:\MyProjects\flowers\flower8'.
%       Since the value of copydir is the same as the projectdir argument,
%       the copydir option could have been omitted.
%
%   Topics: Project management.

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'rewrite', true, 'copyname', [], 'copydir', [], ...
        'interactive', isinteractive( m ), 'soleaccess', [] );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'rewrite', 'copyname', 'copydir', 'interactive', 'soleaccess' );
    if ~ok, return; end

    s.interactive = s.interactive && ~oncluster();

    % Insert defaults for arguments.
    if nargin < 2
        modelname = '';
    end
    if nargin < 3
        projectdir = m.globalProps.projectdir; % Fails of m not given.
    end
    
    if isempty(modelname)
        if s.interactive
            fprintf( 1, '%s: uigetdir in %s.\n', mfilename(), projectdir );
            modeldir = uigetdir( projectdir, 'Select a model folder:' );
            if modeldir==0
                ok = false;
                return;
            end
            [projectdir,modelname] = dirparts( modeldir );
        else
            fprintf( 1, '%s: No model specified.\n', mfilename() );
            ok = false;
            return;
        end
    elseif isrootpath( modelname )
        modeldir = modelname;
        [projectdir,modelname] = dirparts( modeldir );
    else
        modeldir = fullfile( projectdir, modelname );
    end
    
    if ~exist( modeldir, 'dir' )
        if isempty( projectdir )
            projectdirmsg = '';
        else
            projectdirmsg = [ ' in ', projectdir ];
        end
        GFtboxAlert( s.interactive, '%s: Model %s%s does not exist.\n  No model loaded.', ...
            mfilename(), modelname, projectdirmsg );
        ok = false;
        return;
    end
    
    meshfilename = fullfile( modeldir, [ modelname, '.mat' ] );
    staticfilename = fullfile( modeldir, staticBaseName( modelname ) );
    m = loadmesh_anyfile( [], meshfilename, staticfilename, s.interactive );
    ok = ~isempty(m);
    if ok
        m.globalProps.projectdir = projectdir;
        m.globalProps.modelname = modelname;
        m.rewriteIFneeded = s.rewrite;
        needCopy = (~isempty(s.copyname)) || (~isempty(s.copydir));
        m = resetInteractionHandle( m, mfilename() );
        if needCopy
            if isempty(s.copyname)
                s.copyname = modelname;
            end
            if isempty(s.copydir)
                s.copydir = projectdir;
            end
            if strcmp( s.copyname, modelname ) && strcmp( s.copydir, projectdir )
                GFtboxAlert( s.interactive, '%s: copy options specify original project folder -- copy request ignored.\n', ...
                    mfilename() );
            else
                [m,ok] = leaf_copyproject( m, s.copyname, s.copydir );
                if ~ok
                    m = [];
                end
            end
        end
        if ~isempty(m)
            if ~isempty( s.soleaccess )
                switch s.soleaccess
                    case true
                        m.globalDynamicProps.staticreadonly = false;
                    case false
                        m.globalDynamicProps.staticreadonly = true;
                    otherwise
                        % Leave m.globalDynamicProps.staticreadonly unchanged.
                end
            end
            m = storeCodeRevInfo( m );
            for i=1:length(m.pictures)
                resetView( m.pictures(i) );
            end
        end
    end
end
