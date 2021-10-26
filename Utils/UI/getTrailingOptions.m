function [s,otherargs] = getTrailingOptions( varargs, optionnames, ignorecase )
%[s,otherargs] = getTrailingOptions( varargs )
%   VARARGS is a cell array, typically that returned by varargin in a
%   function where you want to use this.
%
%   This function detects trailing pairs of arguments of the form
%   'optionname', optionvalue. It puts all of these into a struct and
%   returns the preceding members of varargs in otherargs.
%
%   If optionnames is supplied, then only option names that are members of
%   it will be recognised. If in addition ignorecase is supplied and is
%   true, then case will be ignored in comparing elements of varargs with
%   those of optionnames.
%
%   When case is to be ignored, the fields of s will be the cased versions
%   provided in optionnames.
%
%   If the same option name occurs multiple times, then only the earliest
%   in the list will be returned.
%
%   If a string to be used as an option is not a valid Matlab struct field
%   name, an error will be thrown.

    if nargin < 3
        ignorecase = false;
    end
    
    limited = nargin >= 2;
    if limited
        origoptionnames = optionnames;
        if ignorecase
            optionnames = upper(optionnames);
        end
    end
    
    nargs = length(varargs);
    s = struct();
    lastused = nargs+1;
    for i=(nargs-1):-2:1
        if ~ischar( varargs{i} )
            break;
        end
        if limited
            oname = varargs{i};
            if ignorecase
                oname = upper(oname);
            end
            found = false;
            for j=1:length(optionnames)
                if strcmp( oname, optionnames{j} )
                    s.(origoptionnames{j}) = varargs{i+1};
                    found = true;
                end
            end
            if ~found
                break;
            end
        else
            s.(varargs{i}) = varargs{i+1};
        end 
        lastused = lastused-2;
    end
    otherargs = varargs(1:(lastused-1));
end