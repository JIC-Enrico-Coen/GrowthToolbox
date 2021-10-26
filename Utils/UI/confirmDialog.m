function ok = confirmDialog( format, varargin )
%ok = confirmDialog( format, varargin )
%   Put up a two-button dialog to ask the user to confirm some operation.
%   The text of the dialog will be the result of sprintf( format, varargin ).
%   The buttons will be labelled 'OK' abnd 'Cancel'.

    result = queryDialog( 2, 'Confirm', format, varargin );
    ok = result==1;
end
