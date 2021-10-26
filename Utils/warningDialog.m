function warningDialog( format, varargin )
%warningDialog( format, varargin )
%   Put up a one-button dialog to warn the user of something.  The text of
%   the dialog will be the result of sprintf( format, varargin ).

    queryDialog( 1, 'Warning', format, varargin );
end
