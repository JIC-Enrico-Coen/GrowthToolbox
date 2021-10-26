function [ni,delindexes,oldnew,newold] = deleteNamesFromIndex( ni, varargin )
%[ni,oldnew,newold] = deleteNamesFromIndex( ni, varargin )
%   Delete entries from a dictionary.  NI is a dictionary and the remaining
%   arguments are names to be deleted.
%
%   delindexes is the list of indexes that were deleted.

    if ~isempty(varargin)
        delindexes = name2Index( ni, varargin{:} );
        delindexes = delindexes(delindexes ~= 0);
        [ni,oldnew,newold] = deleteIndexesFromIndex( ni, delindexes );
    end
end
