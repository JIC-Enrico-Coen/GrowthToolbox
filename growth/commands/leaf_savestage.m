function [m,ok] = leaf_savestage( m, savedir )
%[m,ok] = leaf_savestage( m, savedir )
%
%   Save the current state of the mesh as a stage file.
%   By default it is saved to the project directory, but any other
%   directory can be specified. If DIR is a relative path name, it is
%   relative to the project directory.
%
%   Options: none.

    ok = false;

    if isempty(m), return; end
    if isempty( m.globalProps.modelname ) || isempty( m.globalProps.projectdir )
        complain( '%s: the mesh has not been saved as a project.  Stage not saved.', mfilename() );
        return;
    end
    
    projectsdir = m.globalProps.projectdir;
    modelname = m.globalProps.modelname;
    modeldir = fullfile( projectsdir, modelname );
    if (nargin < 2) || isempty(savedir)
        savedir = modeldir;
    elseif ~isFullPathname( savedir )
        savedir = fullfile( modeldir, savedir );
    end
    
    ok = savemodelfile( m, fullfile( savedir, modelname ), false, true );
    isInitial = m.globalDynamicProps.currentIter==0;
    if ~isInitial
        stagesuffix = makestagesuffixf( m.globalDynamicProps.currenttime );
        m.stagetimes = addStages( m.stagetimes, m.globalDynamicProps.currenttime );
        m.globalDynamicProps.laststagesuffix = stagesuffix;
    end
    
    % Save a snapshot.
    if ok && ~isempty( m.pictures )
        if isInitial
            snapshotname = 'Initial.png';
        else
            snapshotname = [ 'Stage', stagesuffix, '.png' ];
        end
%         m = leaf_plot( m );
%         drawnow;
        m = leaf_snapshot( m, snapshotname, 'newfile', 0, 'hires', m.plotdefaults.hiresstages );
        if isinteractive(m)
            hh = guidata( m.pictures(1) );
            remakeStageMenu( hh, m.globalDynamicProps.laststagesuffix );
        end
    end
end
