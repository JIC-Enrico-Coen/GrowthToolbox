function [filename, pathname, filterindex] = uiputfileNoCD( directory, varargin )
%[filename, pathname, filterindex] = uiputfileNoCD( directory, varargin )
%   This is identical to the Matlab function uiputfile, except that it
%   takes an additional first argument, the directory in which uiputfile
%   should open its dialog.
%
%   The reason for the existence of this procedure is the conjunction of
%   these facts:
%   1. Matlab code should never change the current working directory.
%   2. uiputfile always opens in the current working directory.
%   3. When calling uiputfile, one usually wants to specify the directory.
%
%   This code minimises the interval during which the current working
%   directory is changed.
%
%   If the specified directory does not exist, then the results are all
%   returned a empty. Note thatwhen the user cancels the dialog, they are
%   all returned as zero. Thus these two reasons for not returning a file
%   can be distinguished.
%
%   See also: uiputfile.

    try
        olddir = cd( directory );
        [filename, pathname, filterindex] = uiputfile( varargin{:} );
        cd( olddir );
    catch
        filename = '';
        pathname = '';
        filterindex = '';
    end
end