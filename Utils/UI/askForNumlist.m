function [nums,ok] = askForNumlist( title )
%[nums,ok] = askForNumlist( title )
%   Put up a dialog that asks the user for a list of numbers.  TITLE is the
%   title of the dialog.
%
%   If the user types something syntactically invalid, the dialog will be
%   re-presented.  If the user cancels the dialog, OK will be false and
%   NUMS will be empty, otherwise OK will be true and NUMS will be the list
%   of numbers.
%
%   Matlab A:B and A:B:C syntax is supported: these will be expanded out to
%   the equivalent series of values.

    numsText = '';
    errText = '';
    nums = [];
    ok = false;
    while true
        x = numsDlg( 'title', title, 'numsText', numsText, 'errText', errText );
        if (~isstruct(x)) && (x==-1), return; end
        [nums,ok,errText] = parseNumList( x.numsText );
        if ok, break; end
        numsText = x.numsText;
    end
end
