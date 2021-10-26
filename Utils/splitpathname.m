function [parentname,filename] = splitpathname( pathname )
%[parentname,filename] = splitpathname( pathname )
%   Split a path name into the parent and base parts.  Unlike fileparts(),
%   this does not split off the file extension, if any.  The file version,
%   which was returned as the fourth result of fileparts in versions of
%   Matlab prior to 2012, is ignored.
%
%   See also: fileparts.

    [parentname,filename,ext] = fileparts( pathname );
    filename = [filename,ext];
end
