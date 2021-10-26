function [ok,isdir] = fileExists( filename, mustbedir )
%[ok,isdir] = fileExists( filename )
%[ok,isdir] = fileExists( filename, mustbedir )
%   Determine whether the named file or directory exists. FILENAME can be a
%   full or relative name. OK is true it is could be ascertained to exist
%   (i.e. not only does it exist, but all of the directories on the path to
%   it could be read). ISDIR is a boolean specifying whether it is a
%   directory.
%
%   If MUSTBEDIR is given, then if it is true, then OK is true if FILENAME
%   exists and is a directory. If it is false, OK is true if FILENAME
%   exists and is a file. If it is not given or is empty, OK is true in
%   both cases.
%
%   Matlab's exist(filename,'file') and exist(filename,'dir') do not work
%   as I would expect and need when the file is more than just a base name.
%   This procedure should operate correctly in all cases.

    try
        x = dir(filename);
        if isempty(x)
            % No such thing (or it might exist, but is in a directory that
            % you do not have access to).
            ok = false;
            isdir = false;
        elseif length(x) > 1
            % It exists, and must be a directory.
            ok = true;
            isdir = true;
        else
            % It exists, but it might be either a file or a directory with
            % just one entry. It is a file if and only if x.name is equal
            % to the base part of FILENAME. Note than in Unix-like systems,
            % every directory has at least two entries, '.' and '..', but I
            % don't want to depend on that.
            ok = true;
            [~,name,ext] = fileparts(filename);
            isdir = ~strcmp( [name,ext], x.name );
        end
    catch
        % I don't know if dir is capable of throwing an error, but we trap
        % this in case.
        ok = false;
        isdir = false;
    end
    
    if (nargin > 1) && ~isempty(mustbedir)
        ok = ok & (isdir==mustbedir);
    end
end
