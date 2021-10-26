function ok = saveStaticPart( m, filename )
%ok = saveStaticPart( m, filename )
%   Save the static part of m to the given file.
%
%   If m is the mesh of a project, filename can be omitted, and the static
%   part will be saved as the static file for the project.  Otherwise, the
%   given filename with '_static.mat' appended will be used.
%
%   If m.globalDynamicProps.staticreadonly is true, the static file is not
%   saved. This is used primarily for multiple concurrent runs of GFtbox on
%   the same project, where no files should be written except those
%   specific to each run, and common files must be left unaltered.

    ok = false;
    if isempty(m)
        return;
    end
    if m.globalDynamicProps.staticreadonly
        return;
    end
    if nargin < 2
        if isempty(m.globalProps.modelname)
            return;
        end
        filename = fullfile( getModelDir( m ), m.globalProps.modelname );
    end
    if isempty(filename)
        return;
    end
    ok = saveStaticPartToFile( m, filename );
end
