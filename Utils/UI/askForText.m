function [x,ok] = askForText( title, rubric, inittext, multiline )
%[x,ok] = askForText( title, rubric, inittext )
%   Present a modal dialog to request some text from the user.
%   TITLE will be used as the title of the figure and RUBRIC is a string
%   that will appear within the figure at the top.  INITTEXT is the text
%   that will initially be displayed in the edit box (default is empty),
%   and MULTILINE is true if the text can be multiple lines long, or false
%   (the default) if it must be a single line.
%
%   x will be returned as a one-dimensional character array containing
%   newline characters to separate the lines.  Trailing spaces before
%   newlines will have been removed.
%   OK will be true if the user clicked the OK button, false if the user
%   cancelled the dialog.  In the latter case X will be empty.

    if nargin < 3
        inittext = '';
    end
    if nargin < 4
        multiline = false;
    end
    if multiline
        lines = 4;
    else
        lines = 1;
    end
    initvals = struct( 'figure', title, 'rubric', rubric, 'init', inittext, 'multi', multiline, 'lines', lines );
    result = performRSSSdialogFromFile( 'askForText.txt', initvals, [], @setDefaultGUIColors ); % @(h)setGFtboxColourScheme( h, handles ) );
    ok = ~isempty(result);
    if ok
        x = result.text;
        if size(x,1) > 1
            x(:,end+1) = char(10);
            x = reshape( x', 1, [] );
            x = regexprep( x, ' +\n', '\n' );
        end
    else
        x = [];
    end
end
