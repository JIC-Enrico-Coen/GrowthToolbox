function [fig,s] = modelessRSSSdialogFromFile( fn, initvals, userdata, initfun )
%[fig,s] = modelessRSSSdialogFromFile( fn, initvals, userdata, initfun )
%   Perform a modeless dialog.  The arguments are the same as those for
%   performRSSSdialogFromFile. The callback that handles user operations in
%   the dialog should be specified in the layout file FN.
%
%   FIG is a handle to the dialog window.
%
%   S (for debugging purposes) contains a struct describing the dialog
%   layout.
%
%   See also:
%       buildRSSSdialogFromFile, getRSSSFromFile, performRSSSdialogFromFile.

    if nargin < 2
        initvals = [];
    end
    if nargin < 3
        userdata = [];
    end
    if nargin < 4
        initfun = [];
    end
    fig = [];
    s = buildRSSSdialogFromFile( fn, false, initvals, userdata, initfun );
    if isempty(s)
        complain( 'Failed to build dialog from layout file %s.\n', fn );
        return;
    end
    fig = s.handle;
        
    set( fig, 'WindowStyle', 'normal' );

    if isfield( s.attribs, 'focus' )
      % fprintf( 1, 'Have s.attribs.focus = %s\n', s.attribs.focus );
        focus = s.attribs.focus;
        h = guidata( fig );
        if isfield( h, focus )
          % fprintf( 1, 'Setting focus to %s %f\n', focus, h.(focus) );
            uicontrol( h.(focus) );
        end
    end
end
