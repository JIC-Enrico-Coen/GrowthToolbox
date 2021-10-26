function [i,ok] = askForInt( title, prompt, dflt, bounds )
%i = askForInt( title, prompt, initval, bounds )
%   Put up a modal dialog asking the user to enter an integer.
%   The dialog will have the specified title.
%   The PROMPT string will be displayed as static text above the text-entry box.
%   INITVAL is the initial contents of the text-entry box.
%   BOUNDS is the minimum and maximum allowed value.  This defaults to
%   [-Inf,Inf], i.e. all values are allowed.  If supplied, both values must
%   be given.
%   The result will be [] if the user cancelled the dialog (by clicking the
%   "Cancel" button, clicking the close box, or hitting escape).
%   Otherwise, it will be the final contents of the text-entry box,
%   interpreted as an integer.  If it is invalid, the dialog will be re-opened.

    if nargin < 1
        title = '';
    end
    if nargin < 2
        prompt = '';
    end
    haveDflt = nargin >= 3;
    if haveDflt
        i = dflt;
        dfltString = sprintf( '%d', dflt );
    else
        i = [];
        dfltString = '';
    end
    ok = false;
    if nargin < 4
        bounds = [-Inf Inf];
    end
    prompt = [ prompt boundsInfo(bounds) ];
    while true
        [s,ok] = askForString( title, prompt, dfltString );
        if isempty(s)
            return;
        end
        result = str2double( s );
        if isnan(result), continue; end
        if (result < bounds(1)) || (result > bounds(2))
            continue;
        end
        if result == floor(result)
            i = result;
            ok = true;
            return;
        end
    end
end




