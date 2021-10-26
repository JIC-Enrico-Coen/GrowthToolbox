function [m,ok] = leaf_savemodel( m, newmodelname, newprojectdir, varargin )
%[m,ok] = leaf_savemodel( m, modelname, projectdir, ... )
%   Save the model to its project folder.
%
%   NEWMODELNAME is the name of the model folder.  This must not be a full
%   path name, just the base name of the folder itself.  It will be looked
%   for in the folder NEWPROJECTDIR, if specified, otherwise in the parent
%   directory of m, if any, otherwise the current directory.
%
%   NEWMODELNAME and NEWPROJECTDIR must both be nonempty.
%
%   The model directory will be created if it does not exist.
%
%   If the model is being saved into its own model directory:
%       If it is in the initial state (i.e. no simulation steps have been
%       performed, and the initialisation function has not been called) then
%       it is saved into the file NEWMODELNAME.mat.
%       If it is in a later state, it will be saved to NEWMODELNAME_Snnnn.mat,
%       where nnnn is the current simulation time as a floating point
%       number with the decimal point replaced by a 'd'.
%
%   If the model is being saved into a new directory:
%       The current state will be saved as an initial state or a later
%       stage file as above.
%       If the current state is not the initial state, then the initial
%       state will be copied across.  Furthermore, the initial state of the
%       new project will be loaded.
%       The interaction function and notes file will be copied, if they
%       exist.  If the notes file exists, the new notes file will also be
%       opened in the editor.
%       Stage files, movies, snapshots, and runs are NOT copied across.
%
%   If for any reason the model cannot be saved, OK will be false.
%
%   Options:
%       strip:    If true, as many fields as possible of the mesh will be
%              deleted before saving.  They will be reconstructed as far as
%              possible when the mesh is loaded.  The only information that
%              is lost is the residual strains and effective growth tensor
%              from the last iteration.  The default is false.
%       static: If true, the static file of the project will
%               also be written.  If false, not.  The default is the value
%               of ~m.globalDynamicProps.staticreadonly.
%
%   Equivalent GUI operation: the "Save As..." button prompts for a
%   directory to save a new project to; the "Save" button saves the current
%   state to its own model directory.  The "strip" option can be toggled
%   with the "Misc/Strip Saved Meshes" menu command.
%
%   Topics: Project management.

    if isempty(m), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'strip', false, ...
            'static', ~m.globalDynamicProps.staticreadonly );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
            'strip', 'static' );
    if ~ok, return; end

    oldprojectdir = m.globalProps.projectdir;
    oldmodelname = m.globalProps.modelname;
%     oldmodeldir = fullfile( oldprojectdir, oldmodelname );
    
    if nargin < 2
        newmodelname = oldmodelname;
    end
    if nargin < 3
        newprojectdir = oldprojectdir;
    end
    
    ok = false;
    newmodeldir = fullfile( newprojectdir, newmodelname );

    saveasbase = m.globalProps.allowsave && (m.globalDynamicProps.currentIter==0);
    if ~saveasbase
        stagesuffix = makestagesuffixf( m.globalDynamicProps.currenttime );
        m.stagetimes = addStages( m.stagetimes, m.globalDynamicProps.currenttime );
    end
    % outsideProject = ~strcmpi( getModelDir( m ), newmodeldir );

    % J.A.B. stuff. Ignore.
    if isfield(m.globalProps,'RecordMeshes') ...
            && m.globalProps.RecordMeshes.flag ...
            && m.globalProps.RecordMeshes.saveframe
%         m.globalProps.RecordMeshes.saveframe=false;   
        % we are actually saving this copy as part of an iModel movie
        if ~exist('stagesuffix','var')
            stagesuffix = makestagesuffixf( m.globalDynamicProps.currenttime );
        end
        modelfilename = [ newmodelname, stagesuffix, '.mat' ];
        % ensure that there is a subdirectory in runs ready for these
        % frames
        if (~isempty(m.globalProps.mov)) && isfield( m.globalProps.mov, 'VideoName' )
            subdname=m.globalProps.mov.VideoName;
            newmodeldir=fullfile(newmodeldir,'runs',subdname);
            fprintf( 1, '%s:\n    m.globalProps.mov.VideoName %s\n    newmodeldir %s\n    ', mfilename(), m.globalProps.mov.VideoName, newmodeldir );
            [~,~,~] = mkdir(newmodeldir);
        end
    else
        if saveasbase
            modelfilename = [ newmodelname, '.mat' ];
        else
            modelfilename = [ newmodelname, stagesuffix, '.mat' ];
%             saved_laststagesuffix = m.globalDynamicProps.laststagesuffix;
            m.globalDynamicProps.laststagesuffix = stagesuffix;
        end
        if ~exist(newprojectdir,'dir')
            complain( '%s: Parent folder %s does not exist.  Model not saved.\n', ...
                mfilename(), newprojectdir );
            return;
        end
        if ~exist(newmodeldir,'dir')
            mkdir(newmodeldir);
        end

    end

    success = savemodelfile( m, fullfile( newmodeldir, modelfilename ), s.strip, s.static );
    


%     if ~(isfield(m.globalProps,'RecordMeshes') && m.globalProps.RecordMeshes.saveframe)
    if isfield(m.globalProps,'RecordMeshes') ...
            && m.globalProps.RecordMeshes.flag ...
            && m.globalProps.RecordMeshes.saveframe
        m.globalProps.RecordMeshes.saveframe=false;   
    else
        % Save a snapshot.
        if success && ~isempty( m.pictures )
            if saveasbase
                snapshotname = 'Initial.png';
            else
                snapshotname = [ 'Stage', stagesuffix, '.png' ];
            end
%             m = leaf_plot( m );
%             drawnow;
            m = leaf_snapshot( m, snapshotname, 'newfile', 0, 'hires', m.plotdefaults.hiresstages );
            if isinteractive(m)
                hh = guidata( m.pictures(1) );
                remakeStageMenu( hh, m.globalDynamicProps.laststagesuffix );
            end
        end
    end
end

