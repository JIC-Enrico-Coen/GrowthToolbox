function [f,exists,isdir] = newfilename( filename, alwaysSuffix, thisSuffix )
%[f,exists] = newfilename( filename, alwaysSuffix, thisSuffix )
%   Given a filename, find a filename similar to it for which a file does
%   not already exist, by inserting a 4-digit number before the extension,
%   starting from 0001 and counting upwards as far as necessary.
%   If alwaysSuffix is false (default is true) then if the given name does
%   not exist, that name will be used without a suffix.  Otherwise, a
%   suffix will always be used.
%
%   If thisSuffix is provided and nonempty, it must be a number. This
%   number will be used as the suffix, whether or not that file exists.
%
%   EXISTS specifies whether or not the resulting filename exists. This can
%   only be true if thisSuffix was specified and nonempty.  When it is
%   true, isdir specified whether the existing file is a directory.

    exists = false;
    isdir = false;

    if nargin < 3
        thisSuffix = [];
    end
    
    if (nargin < 2) || isempty(alwaysSuffix)
        alwaysSuffix = true;
    end
    if (~alwaysSuffix) && ~fileExists(filename) && isempty(thisSuffix)
        f = filename;
        return;
    end
    [path,name,ext] = fileparts( filename );
    
    % Find a numerical suffix.
    [a,~,~,~,e,~] = regexp( name, '-([0-9])+$|' );
    % If there is a suffix, a is the index of its first character, and
    % e{1}{1} is the suffix.  If there is no suffix, e is empty.
    startcount = 0;
    if ~isempty(e)
        % There is a numerical suffix.  Start counting from there, and
        % remove it from the filename.
        startcount = sscanf( e{1}{1}, '%d', 1 );
        name = name(1:(a-1));
    end
    
    if ~isempty(thisSuffix)
        tryname = sprintf( '%s-%04d%s', name, thisSuffix, ext );
        f = fullfile( path, tryname );
        [exists,isdir] = fileExists( f );
    else
        % Find the first suffix for which the file does not exist.
        haveext = ~isempty(ext);
        i = startcount+1;
        % It would be better to get a listing of all files that might
        % conflict with the given filename, and calculate a unique suffix
        % from that, instead of calling dir for every attempt.
        while true
            tryname = sprintf( '%s-%04d%s', name, i, ext );
%             fprintf( 1, 'newfilename: trying %s\n', tryname );
            f = fullfile( path, tryname );
            if haveext
                ok = ~fileExists( f );
            else
                ok = isempty( dir( [f '.*'] ) ) && isempty( dir( f ) );
            end
            if ok, return; end
            i = i+1;
        end
    end
end

