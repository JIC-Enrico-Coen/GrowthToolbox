function [projectdir,relfilename] = findAncestorGFtboxProject( filepath )
%projectdir = findAncestorGFtboxProject( filepath )
%   Find an ancestor directory of the given path (which may be relative or
%   absolute) that is a GFtbox project. If the path is already a GFtbox
%   project directory, it is returned. If there is no such directory, the
%   result is the empty string.
%
%   The result is always an absolute file path.

    rootfilepath = makerootpath( filepath );
    currentpath = rootfilepath;
    if exist( currentpath, 'dir' )
        relfilename = '';
    else
        [currentpath,relfilename,relfileext] = fileparts( currentpath );
        relfilename = [relfilename,relfileext];
    end
    while true
        if isGFtboxProjectDir( currentpath )
            projectdir = currentpath;
            return;
        end
        [parent,name,~] = fileparts( currentpath );
        relfilename = fullfile( name, relfilename );
        if isempty(parent) || isempty(name)
            projectdir = '';
            relfilename = filepath;
            return;
        end
        currentpath = parent;
    end
end