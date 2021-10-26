function m = makeModelNamesConsistent( m, folder )
%m = makeModelNamesConsistent( m )
%   Update all of the following data so as to be consistent with the folder
%   name:
%       The internal model name, m.globalProps.modelname.
%       The internal projects directory name, m.globalProps.projectdir.
%       The name of the static file.
%       The name of the file containing the interaction function.
%       The name of the notes file.

    if isempty( folder ) || ~exist( folder, 'dir' )
        return;
    end
    if strcmp( m.globalProps.modelname, 'untitled' )
        m.globalProps.modelname = '';
    end
    oldmodelname = m.globalProps.modelname;
    oldprojectdir = m.globalProps.projectdir;
    [newprojectdir,newmodelname] = dirparts( folder );
    oldifname = m.globalProps.mgen_interactionName;
    newifname = makeIFname( newmodelname );
    if ~strcmp( oldmodelname, newmodelname )
        renameifneeded( oldmodelname, newmodelname, '_static.mat' );
        renameifneeded( oldmodelname, newmodelname, '-notes.txt' );
        renameifneeded( oldifname, newifname, '.m' );
    end
    m.globalProps.modelname = newmodelname;
    m.globalProps.projectdir = newprojectdir;

function renameifneeded( oldbasename, newbasename, suffix )
    if nargin >= 3
        oldbasename = [ oldbasename, suffix ];
        newbasename = [ newbasename, suffix ];
    end
    oldfullname = fullfile( newprojectdir, newmodelname, oldbasename );
    newfullname = fullfile( newprojectdir, newmodelname, newbasename );
    if exist( oldfullname, 'file' ) && ~exist( newfullname, 'file' )
        movefile( oldfullname, newfullname );
    end
end
end
