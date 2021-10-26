function [i,ok] = askForFloat( title, prompt, dflt, bounds )
%i = askForFloat( title, prompt, dflt, bounds )
%   Put up a modal dialog asking the user to enter a floating point number.
%   The dialog will have the specified title.
%   The PROMPT string will be displayed as static text above the text-entry box.
%   DFLT is the initial contents of the text-entry box.
%   The result will be [] if the user cancelled the dialog (by clicking the
%   "Cancel" button, clicking the close box, or hitting escape).
%   Otherwise, it will be the final contents of the text-entry box,
%   interpreted as a floating-point number.  If it is invalid, the dialog
%   will be re-opened.
%   BOUNDS is a pair of numbers, a lower and upper bound of acceptable
%   answers.  If omitted, it defaults to [-Inf Inf].

    if nargin < 1
        title = '';
    end
    if nargin < 2
        prompt = '';
    end
    haveDflt = (nargin >= 3) && ~isempty(dflt);
    if haveDflt
        i = dflt;
        dfltString = sprintf( '%g', dflt );
    else
        i = [];
        dfltString = '';
    end
    if nargin < 4
        bounds = [-Inf Inf];
    end
    prompt = [ prompt boundsInfo(bounds) ];
    ok = false;
    while true
%         s = askForStringDlg( 'title', title, 'prompt', prompt, 'initialvalue', dfltString );
        [s,ok] = askForString( title, prompt, dfltString );
        if isempty(s)
            return;
        end
        result = str2double( s );
        if isnan(result), continue; end
        if (result < bounds(1)) || (result > bounds(2))
            continue;
        end
        i = result;
        ok = true;
        return;
    end
end
