function notesname = makeNotesName( m )
%name = makeNotesName( modelname )
%   Make the name of the notes file for a model m.

    if isempty( m.globalProps.modelname ) || isempty( m.globalProps.projectdir )
        notesname = '';
    else
        modeldir = getModelDir( m );
        notesname = fullfile( modeldir, ...
                              [ m.globalProps.modelname, '-notes.txt' ] );
    end
end
