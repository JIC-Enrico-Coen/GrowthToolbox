function result = queryDialog( numbuttons, title, format, varargin )
%result = queryDialog( numbuttons, title, format, varargin )
%   Show a modal dialog displaying the result of sprintf( format,
%   varargin{:} ).  The title of the dialog will be TITLE.
%   numbuttons must be 1, 2, or 3, and is the number of
%   buttons in the dialog.  Their labels will depend on the number of
%   buttons:
%   1 button: OK
%   2 buttons: OK, Cancel
%   3 buttons: Yes, No, Cancel.
%   Alternatively, the first argument can be a cell array of 1, 2, or 3
%   strings.  These strings will specify the labels of the buttons.
%   If title is empty, it will default to a string depending on the number
%   of buttons: 'Alert', 'Confirm', or 'Query' respectively.
%   The result is the index of the selected button.  Hitting return selects
%   the first button.  Hitting escape selects the last button (even if that
%   is the same as the first button).  Closing the dialog returns 0 (this
%   should be taken to be equivalent to selecting the last button).
%
%   The text of the dialog can have any length.  The dialog will
%   automatically be resized to fit.

    result = querydlg( 'buttons', numbuttons, ...
                       'title', title, ...
                       'querytext', sprintf( format, varargin{:} ) );
end
