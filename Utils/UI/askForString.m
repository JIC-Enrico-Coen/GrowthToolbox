function [s,ok] = askForString( title, prompt, initval )
%[s,ok] = askForString( title, prompt, initval )
%   Put up a modal dialog asking the user to enter a single line of text.
%   The dialog will have the specified title.
%   The PROMPT string will be displayed as static text above the text-entry
%   box.
%   INITVAL is the initial contents of the text-entry box.
%   The result S will be empty and OK will be false if the user cancelled
%   the dialog (by clicking the  "Cancel" button, clicking the close box,
%   or hitting escape). Otherwise, S will be the final contents of the
%   text-entry box and OK will be true.
%
%   All arguments are optional and default to the empty string.

    foreColor = [0.9 1 0.9];
    backColor = [0.4 0.8 0.4];

    if nargin < 3
        initval = '';
    end
    if nargin < 2
        prompt = '';
    end
    if nargin < 1
        title = '';
    end
    x = performRSSSdialogFromFile( 'askForText.txt', ...
            struct('title',title,'rubric',prompt,'init',initval,'multi',false), ...
            [], ...
            @(h)setGUIColors( h, backColor, foreColor ) );
    ok = ~isempty(x);
    if ok
        s = x.text;
    else
        s = '';
    end
    return;
    
    dlgResult = askForStringDlg( 'title', title, 'prompt', prompt, 'initialvalue', initval );
    if isempty(dlgResult) || ~isstruct(dlgResult)
        s = [];
    else
        s = dlgResult.editableText;
    end
end




