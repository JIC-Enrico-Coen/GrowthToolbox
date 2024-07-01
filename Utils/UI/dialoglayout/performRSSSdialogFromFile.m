function [result,s] = performRSSSdialogFromFile( fn, initvals, userdata, initfun )
%[result,s] = performRSSSdialogFromFile( fn, initvals, userdata, initfun )
%   Perform a modal dialog.  The layout of the dialog is specified in the
%   text file FN.  Initial values can be supplied by the struct INITVALS.
%   USERDATA will be stored (together with a struct defining the dialog
%   layout -- this is only for debugging purposes) in the 'Userdata' field
%   of the dialog window.  INITFUN is a function which will be called after
%   constructing the dialog but before making it visible, in order to make
%   any changes to it that cannot be done by setting initial values and
%   storing user data.  It receives the window handle as its only argument.
%
%   If the dialog needs a callback function to handle user actions that do
%   not close the dialog, this should be specified in the layout file FN.
%
%   All arguments except the first are optional.
%
%   RESULT will be empty if the user cancels.  Otherwise, it will be a
%   struct mapping the tags of all editable GUI elements to the
%   corresponding values.
%
%   S (for debugging purposes) contains a struct describing the dialog
%   layout.
%
%   See also:
%       buildRSSSdialogFromFile, getRSSSFromFile, modelessRSSSdialogFromFile

    if nargin < 2
        initvals = [];
    end
    if nargin < 3
        userdata = [];
    end
    if nargin < 4
        initfun = [];
    end
    result = [];
    s = buildRSSSdialogFromFile( fn, true, initvals, userdata, initfun );
    if isempty(s)
        complain( 'Failed to build dialog from layout file %s.\n', fn );
        return;
    end
    set( s.handle, 'WindowStyle', 'modal', 'Visible', 'on' );
    if isfield( s.attribs, 'focus' )
      % fprintf( 1, 'Have s.attribs.focus = %s\n', s.attribs.focus );
        focus = s.attribs.focus;
        h = guidata( s.handle );
        if isfield( h, focus )
          % fprintf( 1, 'Setting focus to %s %f\n', focus, h.(focus) );
            uicontrol( h.(focus) );
        end
    end
    
    uiwait(s.handle);
    
    if ishandle( s.handle )
        handles = guidata( s.handle );
        if isfield( handles, 'output' )
            result = handles.output;
        else
            % User cancelled the dialog.
            result = [];
        end
        delete( s.handle );
    else
        % User closed the dialog.
        result = [];
    end
    drawnow;
end
